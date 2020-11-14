import Accelerate
import TensorFlowLite

// MARK: - CartoonGanModel Errors

enum CartoonGanModelError: String, Error {
    case preprocess = "Failed to preprocess the image!"
    case process = "Failed to process the image!"
    case postprocess = "Failed to process the output!"

    var localizedDescription: String { rawValue }
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
    private var processing: Bool = false
    
    // MARK: - Constants
    
    private struct Constants {
        struct Parameters {
            static let height: Int = 512
            static let width: Int = 512
        }

        struct File {
            static let name = "cartoongan_int8"
            static let ext = "tflite"
        }

        struct ProcessUnits {
            static let mean: Float = 127.5
            static let std: Float = 127.5
        }
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
    
    convenience init?() {
        self.init(
            name: Constants.File.name,
            ext: Constants.File.ext
        )
    }

    // MARK: - Methods
    
    func process(_ image: UIImage) {
        guard !processing else {
            log.info("Already processing...")
            return
        }
        processing = true
        defer { processing = false }

        // 🛠 preprocess
        guard let data = preprocess(image) else {
            log.error("Preprocessing failed!")
            delegate?.model(self, didFailedProcessing: .preprocess)
            return
        }

        // 🚀 pass through the model
        do {
            try interpreter.copy(data, toInputAt: 0)
            try interpreter.invoke()
        } catch let error {
            log.error("Processing failed with error: \(error.localizedDescription)")
            delegate?.model(self, didFailedProcessing: .process)
            return
        }

        // 🍉 post process
        guard
            let outputTensor = try? interpreter.output(at: 0),
            let outputImage = postprocess(data: outputTensor.data)
        else {
            log.error("Could not retrieve image")
            delegate?.model(self, didFailedProcessing: .postprocess)
            return
        }

        log.info("Finished processing image!")
        delegate?.model(self, didFinishProcessing: outputImage)
    }

    private func preprocess(
        _ image: UIImage,
        width: Int = Constants.Parameters.width,
        height: Int = Constants.Parameters.height
    ) -> Data? {
        // resize and get image buffer
        guard
            let cgImage = image.cgImage?.resized(width: width, height: height),
            var buffer = try? vImage_Buffer(cgImage: cgImage)
        else {
            log.debug("ERROR: Failed to get input cgImage")
            return nil
        }

        // remove alpha channel
        vImageConvert_ARGB8888toRGB888(
            &buffer,
            &buffer,
            UInt32(kvImageNoFlags)
        )

        // parse image buffer data
        guard let bytes = Array<UInt8>(
            unsafeData: Data(
                bytes: buffer.data,
                count: buffer.rowBytes * height
            )
        ) else {
            log.debug("ERROR: Failed to create UInt8 Array")
            return nil
        }

        // normalize image pixels and convert to float data! wii! 🍻 🍺
        return Data(copyingBufferOf: bytes.map {
            (Float32($0) - Constants.ProcessUnits.mean) / Constants.ProcessUnits.std
        })
    }


    private func postprocess(
        data: Data,
        width: Int = Constants.Parameters.width,
        height: Int = Constants.Parameters.height
    ) -> UIImage? {
        let floats = data.toArray(type: Float32.self)

        let bufferCapacity = width * height * 4
        let unsafePointer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferCapacity)
        let unsafeBuffer = UnsafeMutableBufferPointer<UInt8>(start: unsafePointer, count: bufferCapacity)

        defer { unsafePointer.deallocate() }

        for x in 0 ..< width {
            for y in 0 ..< height {
                let floatIndex = (y * width + x) * 3
                let index = (y * width + x) * 4
                let red = UInt8(floats[floatIndex])
                let green = UInt8(floats[floatIndex + 1])
                let blue = UInt8(floats[floatIndex + 2])

                unsafeBuffer[index] = red
                unsafeBuffer[index + 1] = green
                unsafeBuffer[index + 2] = blue
                unsafeBuffer[index + 3] = 0
                log.debug("red: \(red) green: \(green) blue: \(blue)")
            }
        }

        let outData = Data(buffer: unsafeBuffer)

        // Construct image from output tensor data
        let alphaInfo = CGImageAlphaInfo.noneSkipLast
        let bitmapInfo = CGBitmapInfo(rawValue: alphaInfo.rawValue).union(.byteOrder32Big)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard
            let imageDataProvider = CGDataProvider(data: outData as CFData),
            let cgImage = CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: MemoryLayout<UInt8>.size * 4 * Int(width),
                space: colorSpace,
                bitmapInfo: bitmapInfo,
                provider: imageDataProvider,
                decode: nil,
                shouldInterpolate: false,
                intent: .defaultIntent
            )
        else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Data
extension Data {
  /// Convert a Data instance to Array representation.
  func toArray<T>(type: T.Type) -> [T] where T: AdditiveArithmetic {
    var array = [T](repeating: T.zero, count: self.count/MemoryLayout<T>.stride)
    _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
    return array
  }
}
