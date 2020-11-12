import CoreImage
import Accelerate

extension CVPixelBuffer {
    
    // MARK: - Properties

    /// Extracts RGB (`UInt8`) data from RGBA `CVPixelBuffer`
    var pixelData: Data? {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(self, .readOnly) }
        
        guard let sourceData = CVPixelBufferGetBaseAddress(self) else {
            return nil
        }

        let destinationChannelCount = 3
        let destinationBytesPerRow = destinationChannelCount * width
        
        var sourceBuffer = vImage_Buffer(
            data: sourceData,
            height: vImagePixelCount(height),
            width: vImagePixelCount(width),
            rowBytes: sourceBytesPerRow
        )
        
        guard let destinationData = malloc(height * destinationBytesPerRow) else {
            print("Error: out of memory")
            return nil
        }
        
        defer { free(destinationData) }
        
        var destinationBuffer = vImage_Buffer(
            data: destinationData,
            height: vImagePixelCount(height),
            width: vImagePixelCount(width),
            rowBytes: destinationBytesPerRow
        )
        
        vImageConvert_ARGB8888toRGB888(
            &sourceBuffer,
            &destinationBuffer,
            UInt32(kvImageNoFlags)
        )
        
        return Data(
            bytes: destinationBuffer.data,
            count: destinationBuffer.rowBytes * height
        )
    }
    
    // MARK: - Private Properties
    
    private var height: Int {
        CVPixelBufferGetHeight(self)
    }
    
    private var width: Int {
        CVPixelBufferGetWidth(self)
    }
    
    private var sourceBytesPerRow: Int {
        CVPixelBufferGetBytesPerRow(self)
    }
    
}
