import UIKit

class MainView: UIView {
    
    // MARK: - Subviews
    
    lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(.camera, for: .normal)
        button.titleLabel?.font = Font.paragraph
        button.layer.cornerRadius = Constants.Button.cornerRadius
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = Constants.Button.borderWidth
        button.backgroundColor = .black
        button.tintColor = .white;
        return button
    }()
    
    lazy var galleryButton: UIButton = {
        let button = UIButton()
        button.setImage(.photo, for: .normal)
        button.titleLabel?.font = Font.paragraph
        button.layer.cornerRadius = Constants.Button.cornerRadius
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = Constants.Button.borderWidth
        button.backgroundColor = .black
        button.tintColor = .white
        return button
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "CartoonGan"
        label.font = Font.title
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Please select an option below"
        label.font = Font.subtitle
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    // MARK: - Constants
    
    private struct Constants {
        struct Button {
            static let size: CGFloat = 80
            static let cornerRadius: CGFloat = 40
            static let spacing: CGFloat = 32
            static let borderWidth: CGFloat = 3
        }
        struct Title {
            static let topSpacing: CGFloat = 32
            static let sideSpacing: CGFloat = 16
        }
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black

        addSubviews(
            titleLabel,
            subtitleLabel,
            galleryButton,
            cameraButton
        )

        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Title.topSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Title.sideSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Title.sideSpacing),

            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Title.sideSpacing),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Title.sideSpacing),

            galleryButton.heightAnchor.constraint(equalToConstant: Constants.Button.size),
            galleryButton.widthAnchor.constraint(equalToConstant: Constants.Button.size),
            galleryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Button.spacing),
            galleryButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.Button.spacing),
            
            cameraButton.heightAnchor.constraint(equalToConstant: Constants.Button.size),
            cameraButton.widthAnchor.constraint(equalToConstant: Constants.Button.size),
            cameraButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Button.spacing),
            cameraButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.Button.spacing),
        ])
    }
}
