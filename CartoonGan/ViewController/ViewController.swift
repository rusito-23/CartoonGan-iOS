import UIKit
import SwiftSpinner

class ViewController: UIViewController {
    
    // MARK: - Properties

    private lazy var cartoonGanModel: CartoonGanModel = {
        let model = CartoonGanModel()
        model.delegate = self
        return model
    }()
    
    private lazy var imagePickerController: ImagePickerController = {
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        return imagePicker
    }()

    private var enabled: Bool = false {
        didSet {
            galleryButton.isEnabled = enabled
            cameraButton.isEnabled = enabled
        }
    }
    
    // MARK: - Views

    private lazy var spinner = UIActivityIndicatorView(style: .large)
    private lazy var mainView = MainView()
    private var cameraButton: UIButton { mainView.cameraButton }
    private var galleryButton: UIButton { mainView.galleryButton }
    private var imageView: UIImageView { mainView.imageView }
    
    // MARK: - View Lifecycle
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpinner()

        cameraButton.addTarget(
            self,
            action: #selector(cameraButtonTapped),
            for: .touchUpInside
        )
        galleryButton.addTarget(
            self,
            action: #selector(galleryButtonTapped),
            for: .touchUpInside
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        SwiftSpinner.show("Initializing model...")
        cartoonGanModel.start()
        enabled = false
    }

    // MARK: - Private Methods

    @objc private func cameraButtonTapped() {
        imagePickerController.cameraAccessRequest()
    }
    
    @objc private func galleryButtonTapped() {
        imagePickerController.photoGalleryAccessRequest()
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePickerController.present(parent: self, sourceType: sourceType)
    }

    private func showErrorDialog(message: String) {
        let errorDialog = ErrorDialog(message: message)
        errorDialog.present(self)
    }

    private func setupSpinner() {
        SwiftSpinner.useContainerView(view)
        SwiftSpinner.showBlurBackground = false
        SwiftSpinner.setTitleFont(Font.paragraph)
    }
}

// MARK: - ImagePickerControllerDelegate

extension ViewController: ImagePickerControllerDelegate {
    func imagePicker(_ imagePicker: ImagePickerController, canUseCamera allowed: Bool) {
        guard allowed else {
            log.error("Camera access request failed!")
            showErrorDialog(message: "We don't have access to your camera")
            return
        }

        presentImagePicker(sourceType: .camera)
    }
    
    func imagePicker(_ imagePicker: ImagePickerController, canUseGallery allowed: Bool) {
        guard allowed else {
            log.error("Gallery access request failed!")
            showErrorDialog(message: "We don't have access to your gallery")
            return
        }

        presentImagePicker(sourceType: .photoLibrary)
    }
    
    func imagePicker(_ imagePicker: ImagePickerController, didSelect image: UIImage) {
        imagePicker.dismiss {
            SwiftSpinner.show("Processing your image...")
            self.cartoonGanModel.process(image)
        }
    }
    
    func imagePicker(_ imagePicker: ImagePickerController, didCancel cancel: Bool) {
        if cancel { imagePicker.dismiss() }
    }

    func imagePicker(_ imagePicker: ImagePickerController, didFail failed: Bool) {
        if failed {
            imagePicker.dismiss()
            showErrorDialog(message: "We're having some issues to load your image!")
        }
    }
}

// MARK: - CartoonGanModelDelegate

extension ViewController: CartoonGanModelDelegate {
    func model(_ model: CartoonGanModel, didFinishProcessing image: UIImage) {
        DispatchQueue.main.async {
            SwiftSpinner.hide()
            self.imageView.image = image
        }
    }

    func model(_ model: CartoonGanModel, didFailedProcessing error: CartoonGanModelError) {
        DispatchQueue.main.async {
            SwiftSpinner.hide()
            self.showErrorDialog(message: error.localizedDescription)
        }
    }

    func model(_ model: CartoonGanModel, didFinishAllocation error: CartoonGanModelError?) {
        DispatchQueue.main.async {
            SwiftSpinner.hide()
            guard let error = error else {
                self.enabled = true
                return
            }

            self.showErrorDialog(message: error.localizedDescription)
        }
    }
}
