import UIKit

class RootView: UIView {
    
    // MARK: - Subviews
    
    lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Camera", for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.titleLabel?.font = Font.paragraph
        button.layer.cornerRadius = 16.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3
        button.backgroundColor = .black
        button.tintColor = .white;
        return button
    }()
    
    lazy var galleryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Gallery", for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.titleLabel?.font = Font.paragraph
        button.layer.cornerRadius = 16.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3
        button.backgroundColor = .black
        button.tintColor = .white
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.title
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.attributedText = NSAttributedString(
            string: "CartoonGan",
            attributes: [
                NSAttributedString.Key.strokeColor: UIColor.orange,
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.strokeWidth: 4,
                NSAttributedString.Key.font: Font.title
            ]
        )
        return label
    }()
    
    private lazy var buttonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.addSubview(cameraButton)
        view.addSubview(galleryButton)
        return view
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        addSubview(titleLabel)
        addSubview(buttonContainer)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32.0),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),

            buttonContainer.heightAnchor.constraint(equalToConstant: 132.0),
            buttonContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.0),
            buttonContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.0),
        ])
        
        NSLayoutConstraint.activate([
            galleryButton.heightAnchor.constraint(equalToConstant: 50.0),
            galleryButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            galleryButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
            galleryButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
            
            cameraButton.heightAnchor.constraint(equalToConstant: 50.0),
            cameraButton.topAnchor.constraint(equalTo: galleryButton.bottomAnchor, constant: 32.0),
            cameraButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
            cameraButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
        ])
    }
}
