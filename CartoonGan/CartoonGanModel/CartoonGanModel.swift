import Accelerate
import TensorFlowLite

// MARK: - CartoonGanModel Errors

enum CartoonGanModelError: String, Error {
    case allocation = "Failed to initialize the interpreter!"
    case preprocess = "Failed to preprocess the image!"
    case process = "Failed to cartoonize the image!"
    case postprocess = "Failed to process the output!"

    var localizedDescription: String { rawValue }
}

// MARK: - CartoonGanModelDelegate

protocol CartoonGanModelDelegate: NSObject {
    func model(_ model: CartoonGanModel, didFinishProcessing image: UIImage)
    func model(_ model: CartoonGanModel, didFinishAllocation error: CartoonGanModelError?)
    func model(_ model: CartoonGanModel, didFailedProcessing error: CartoonGanModelError)
}

// MARK: - CartoonGanModel

class CartoonGanModel {
    
    // MARK: - Properties
    
    weak var delegate: CartoonGanModelDelegate?
    private var interpreter: Interpreter?
    private let queue = DispatchQueue(label: Constants.Queue.label)
    
    // MARK: - Constants
    
    private struct Constants {
        struct File {
            static let name = "cartoongan_int8"
            static let ext = "tflite"
        }

        struct Units {
            struct Common {
                static let height: Int = 512
                static let width: Int = 512
            }

            struct Input {
                static let mean: Float32 = 127.5
                static let std: Float32 = 127.5
            }

            struct Output {
                static let mean: Float32 = -1
                static let std: Float32 = 0.007843
            }
        }

        struct Queue {
            static let label = "com.rusito23.CartoonGan.serial"
        }
    }

    // MARK: - Methods

    func start(name: String, ext: String) {
        queue.async {
            guard let modelPath = Bundle.main.path(
                forResource: name,
                ofType: ext
            ) else {
                log.error("Could not find model file: \(name).\(ext)")
                self.delegate?.model(self, didFinishAllocation: .allocation)
                return
            }

            do {
                self.interpreter = try Interpreter(modelPath: modelPath)
                try self.interpreter?.allocateTensors()
            } catch let error {
                log.error("Interpreter initialization failed with error: \(error.localizedDescription)")
                self.delegate?.model(self, didFinishAllocation: .allocation)
                return
            }

            self.delegate?.model(self, didFinishAllocation: nil)
        }
    }

    func start() {
        start(
            name: Constants.File.name,
            ext: Constants.File.ext
        )
    }

    // TODO: handle things in queue
    func process(_ image: UIImage) {
        // check interpreter
        guard let interpreter = interpreter else {
            log.error("Interpreter not available")
            delegate?.model(self, didFailedProcessing: .allocation)
            return
        }

        // check input image
        guard let cgImage = image.cgImage else {
            log.error("Failed to retrieve cgImage")
            delegate?.model(self, didFailedProcessing: .preprocess)
            return
        }

        queue.async {
            // 🛠 preprocess
            log.debug("Start pre-processing 🛠")
            guard let data = self.preprocess(
                cgImage,
                orientation: image.imageOrientation
            ) else {
                log.error("Preprocessing failed!")
                self.delegate?.model(self, didFailedProcessing: .preprocess)
                return
            }

            // 🚀 pass through the model
//            log.debug("Invoke interpreter 🚀")
//            do {
//                try interpreter.copy(data, toInputAt: 0)
//                try interpreter.invoke()
//            } catch let error {
//                log.error("Processing failed with error: \(error.localizedDescription)")
//                self.delegate?.model(self, didFailedProcessing: .process)
//                return
//            }

            // 🍉 post process
            log.debug("Start post-processing 🚀")
            guard
                // let outputTensor = try? interpreter.output(at: 0),
                let output = self.postprocess(data: data)
            else {
                log.error("Could not retrieve output image")
                self.delegate?.model(self, didFailedProcessing: .postprocess)
                return
            }

            log.info("Finished processing image!")
            self.delegate?.model(self, didFinishProcessing: output)
        }
    }

    private func preprocess(
        _ image: CGImage,
        width: Int = Constants.Units.Common.width,
        height: Int = Constants.Units.Common.height,
        orientation: UIImage.Orientation
    ) -> Data? {
        // get some data
        let size = CGSize(width: width, height: height)

        // create brand new pixel buffer
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32ARGB,
            [
                kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
            ] as CFDictionary,
            &pixelBuffer
        )
        guard let buffer = pixelBuffer else { return nil }

        // lock buffer to write
        CVPixelBufferLockBaseAddress(buffer, .write)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .write) }

        // buffer information
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        let bytesCount = bytesPerRow * height
        guard let base = CVPixelBufferGetBaseAddress(buffer)
        else { return nil }

        // create proper context
        guard let context = CGContext(
            data: base,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else { return nil }

        // fix orientation (keep to .up)
        context.concatenate(
            createUpTransformation(
                orientation,
                size: size
            )
        )

        // and draw
        context.draw(
            image,
            in: CGRect(
                origin: .zero,
                size: size
            )
        )

        // parse byte data!
        guard let bytes = Array<UInt8>(unsafeData: Data(
            bytes: base,
            count: bytesCount
        )) else { return nil }

        // normalize, remove alpha and convert to float
        // in a single step!
        var normalized = [Float32]()
        for i in 1..<bytesCount {
            if i % 4 == 0 { continue } // ignore first alpha channel
            normalized.append(normalize(bytes[i]))
        }

        // 🍻 convert to data! 🍺
        return Data(copyingBufferOf: normalized)
    }

    private func postprocess(
        data: Data,
        width: Int = Constants.Units.Common.width,
        height: Int = Constants.Units.Common.height
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
                let red = denormalize(floats[floatIndex])
                let green = denormalize(floats[floatIndex + 1])
                let blue = denormalize(floats[floatIndex + 2])

                unsafeBuffer[index] = red
                unsafeBuffer[index + 1] = green
                unsafeBuffer[index + 2] = blue
                unsafeBuffer[index + 3] = 0
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

    private func denormalize(_ pixel: Float32) -> UInt8 {
        // UInt8(pixel) + Constants.ProcessUnits.mean / Constants.ProcessUnits.std
        // TODO: clip
        UInt8(pixel)
    }

    private func normalize(_ pixel: UInt8) -> Float32 {
        // (Float32($0) - Constants.ProcessUnits.mean) / Constants.ProcessUnits.std
        Float32(pixel)
    }

    private func createUpTransformation(
        _ orientation: UIImage.Orientation,
        size: CGSize
    ) -> CGAffineTransform {
        var transform = CGAffineTransform.identity

        switch orientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi * 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: .pi * -2)
        default: break
        }

        switch orientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        default: break
        }

        return transform
    }

}

// MARK: - CVPixelBufferLockFlags Utils

extension CVPixelBufferLockFlags {
    static var write: CVPixelBufferLockFlags {
        CVPixelBufferLockFlags(rawValue: 0)
    }
}
