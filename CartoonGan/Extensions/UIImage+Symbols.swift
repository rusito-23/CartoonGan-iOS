import UIKit

extension UIImage {
    static func camera(scale: UIImage.SymbolScale) -> UIImage {
        return UIImage(
            systemName: "camera",
            withConfiguration: UIImage.SymbolConfiguration(
                scale: scale
            )
        ) ?? UIImage()
    }

    static func photo(scale: UIImage.SymbolScale) -> UIImage {
        return UIImage(
            systemName: "photo",
            withConfiguration: UIImage.SymbolConfiguration(
                scale: scale
            )
        ) ?? UIImage()
    }
}
