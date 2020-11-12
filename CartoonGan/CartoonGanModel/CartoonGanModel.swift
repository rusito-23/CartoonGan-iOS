import TensorFlowLite

// MARK: - CartoonGanModel Errors

enum CartoonGanModelError: Error {
    case preprocess
    case process
    case postprocess
}

// MARK: - CartoonGanModel Info

typealias ModelInfo = (name: String, ext: String)

enum CartoonGanModelInfo {
    static let `default`: ModelInfo = (name: "cartoongan_int8", ext: "tflite")
}

// MARK: - CartoonGanModelDelegate

protocol CartoonGanModelDelegate: NSObject {
    func model(_ model: CartoonGanModel, didFinishProcessing image: UIImage)
    func model(_ model: CartoonGanModel, didFailedProcessing error: CartoonGanModelError)
}

// MARK: - CartoonGanModel

class CartoonGanModel {
    
    // MARK: - Properties
    
    weak var delegate: CartoonGanModelDelegate?
    private var interpreter: Interpreter
    
    // MARK: - Constants
    
    private struct Constants {
        static let height: Int = 512
        static let width: Int = 512
    }

    // MARK: - Initializers

    init?(name: String, ext: String) {
        guard let modelPath = Bundle.main.path(forResource: name, ofType: ext) else {
            log.error("Could not find model file: \(name).\(ext)")
            return nil
        }
        
        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter.allocateTensors()
        } catch let error {
            log.error("Interpreter initialization failed with error: \(error.localizedDescription)")
            return nil
        }
    }
    
    convenience init?(modelInfo: ModelInfo) {
        self.init(name: modelInfo.name, ext: modelInfo.ext)
    }

    // MARK: - Methods
    
    func process(with image: UIImage) {
        guard let data = preprocess(image) else {
            delegate?.model(self, didFailedProcessing: .preprocess)
            return
        }

        do {
            try interpreter.copy(data, toInputAt: 0)
            try interpreter.invoke()
        } catch let error {
            log.error("Processing failed with error: \(error.localizedDescription)")
            delegate?.model(self, didFailedProcessing: .process)
            return
        }

        do {
            let outputTensor = try interpreter.output(at: 0)
            log.debug("outputTensor dataType: \(outputTensor.dataType)")

        } catch let error {
            log.error("Output failed with error: \(error.localizedDescription)")
            delegate?.model(self, didFailedProcessing: .postprocess)
        }
    }

    // MARK: - Private Methods

    private func preprocess(_ image: UIImage) -> Data? {
        image.asRGBABuffer(
            width: Constants.width,
            height: Constants.height
        )?.pixelData
    }

}
