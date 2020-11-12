import TensorFlowLite

// MARK: - CartoonGanModel Info

typealias ModelInfo = (name: String, ext: String)

enum CartoonGanModelInfo {
    static let `default` = (name: "cartoongan_int8", extension: "tflite")
}

// MARK: - CartoonGanModelDelegate

protocol CartoonGanModelDelegate: NSObject {
    func model(_ model: CartoonGanModel, didFinishProcessing image: UIImage)
    func model(_ model: CartoonGanModel, didFailedProcessing error: Error)
}

// MARK: - CartoonGanModel

class CartoonGanModel {
    
    // MARK: - Properties
    
    weak var delegate: CartoonGanModelDelegate?
    private var interpreter: Interpreter

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
    
    func process(with: UIImage) {
    }
    
}
