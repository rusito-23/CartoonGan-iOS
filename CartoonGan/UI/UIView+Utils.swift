import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }
}

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            addArrangedSubview(view)
        }
    }
}
