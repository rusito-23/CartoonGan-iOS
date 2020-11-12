import UIKit

struct Font {
    
    // MARK: - Fonts
    
    static var title: UIFont { with(size: .extraLarge) }
    
    static var subtitle: UIFont { with(size: .medium) }
    
    static var paragraph: UIFont { with(size: .small) }

    static var small: UIFont { with(size: .extraSmall) }
        
    // MARK: - Size
    
    enum Size: CGFloat {
        case extraLarge = 80.0
        case large = 64.0
        case medium = 32.0
        case small = 23.0
        case extraSmall = 17.0
        case mini = 12.0
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let name = "AvenirNext-Heavy"
    }
    
    // MARK: - Methods
    
    static func with(size: Size) -> UIFont {
        return UIFont(
            name: Constants.name,
            size: size.rawValue
        ) ?? UIFont.systemFont(ofSize: size.rawValue)
    }
    
}
