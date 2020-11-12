import UIKit

extension UIImage {
    
    // MARK: - Properties

    private static let flags = CVPixelBufferLockFlags(rawValue: 0)
    private static let bitsPerComponent = 8
    private static let attributes = [
        kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
        kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue,
    ]
    
    // MARK: - Convenience
    
    /// Convert to `CVPixelBuffer`with RGBA format
    func asRGBABuffer(width: Int, height: Int) -> CVPixelBuffer? {
        return asBuffer(
            width: width,
            height: height,
            pixelFormatType: kCVPixelFormatType_32RGBA,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            alphaInfo: .noneSkipLast
        )
    }

    // MARK: - Conversion

    /// Convert to `CVPixelBuffer`
    private func asBuffer(
        width: Int,
        height: Int,
        pixelFormatType: OSType,
        colorSpace: CGColorSpace,
        alphaInfo: CGImageAlphaInfo
    ) -> CVPixelBuffer? {
        
        var maybePixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            pixelFormatType,
            Self.attributes as CFDictionary,
            &maybePixelBuffer
        )
        
        guard
            status == kCVReturnSuccess,
            let pixelBuffer = maybePixelBuffer,
            kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, Self.flags)
        else {
            return nil
        }
        
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, Self.flags) }
        
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer),
            width: width,
            height: height,
            bitsPerComponent: Self.bitsPerComponent,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: colorSpace,
            bitmapInfo: alphaInfo.rawValue
        ) else {
            return nil
        }

        UIGraphicsPushContext(context)
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        return pixelBuffer
    }
}
