import UIKit

extension UIImage {

    // MARK: - Properties

    static var camera: UIImage { symbol(named: "camera", scale: .large) }
    static var photo: UIImage { symbol(named: "photo", scale: .large) }
    static var leftArrow: UIImage { symbol(named: "arrow.left", scale: .large) }
    static var share: UIImage { symbol(named: "square.and.arrow.up", scale: .large) }

    // MARK: - Methods

    private static func symbol(
        named name: String,
        scale: UIImage.SymbolScale
    ) -> UIImage {
        return UIImage(
            systemName: name,
            withConfiguration: UIImage.SymbolConfiguration(
                scale: scale
            )
        ) ?? UIImage()
    }
}
