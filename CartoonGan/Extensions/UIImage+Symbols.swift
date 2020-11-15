import UIKit

extension UIImage {

    // MARK: - Properties

    static var camera: UIImage {
        symbol(named: "camera", scale: .large)
    }

    static var photo: UIImage {
        symbol(named: "photo", scale: .large)
    }

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
