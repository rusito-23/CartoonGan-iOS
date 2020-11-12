import UIKit

class RootView: UIView {
    
    // MARK: - Subviews
    
    lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.camera(scale: .large), for: .normal)
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
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.photo(scale: .large), for: .normal)
        button.titleLabel?.font = Font.paragraph
        button.layer.cornerRadius = Constants.Button.cornerRadius
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = Constants.Button.borderWidth
        button.backgroundColor = .black
        button.tintColor = .white
        return button
    }()
    
    // MARK: - Constants
    
    private struct Constants {
        struct Button {
            static let size: CGFloat = 80
            static let cornerRadius: CGFloat = 40
            static let spacing: CGFloat = 32.0
            static let borderWidth: CGFloat = 3
        }
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        addSubview(cameraButton)
        addSubview(galleryButton)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
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
