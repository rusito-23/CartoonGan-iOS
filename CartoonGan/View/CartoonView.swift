import UIKit

final class CartoonView: UIView {

    // MARK: - Subviews

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(.share, for: .normal)
        button.imageView?.tintColor = .white
        return button
    }()

    lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(.leftArrow, for: .normal)
        button.imageView?.tintColor = .white
        return button
    }()

    // MARK: - Constants

    private struct Constants {
        struct Button {
            static let size: CGFloat = 60
            static let spacing: CGFloat = 8
        }
    }

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black

        addSubviews(
            imageView,
            backButton,
            shareButton
        )

        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),

            shareButton.heightAnchor.constraint(equalToConstant: Constants.Button.size),
            shareButton.widthAnchor.constraint(equalToConstant: Constants.Button.size),
            shareButton.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Button.spacing),
            shareButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Button.spacing),

            backButton.heightAnchor.constraint(equalToConstant: Constants.Button.size),
            backButton.widthAnchor.constraint(equalToConstant: Constants.Button.size),
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Button.spacing),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Button.spacing),
        ])
    }

}
