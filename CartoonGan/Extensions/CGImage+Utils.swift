import UIKit

extension CGImage {
    func resized(
        width: Int,
        height: Int,
        bitsPerComponent: Int = 8,
        bytesPerPixel: Int = 8 * 3
    ) -> CGImage? {
        guard
            let colorSpace = colorSpace,
            let context = CGContext(
                data: nil,
                width: width, height: height,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerPixel * width,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
            )
        else {
            log.debug("ERROR: Failed to get input context")
            return nil
        }

        context.interpolationQuality = .high
        context.draw(
            self,
            in: CGRect(
                x: 0,
                y: 0,
                width: width,
                height: height
            )
        )

        return context.makeImage()
    }
}
