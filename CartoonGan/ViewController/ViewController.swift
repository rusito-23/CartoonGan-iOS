import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties

    private lazy var cartoonGanModel: CartoonGanModel? = {
        let model = CartoonGanModel()
        model?.delegate = self
        return model
    }()
    
    private lazy var imagePickerController: ImagePickerController = {
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        return imagePicker
    }()
    
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

        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        galleryButton.addTarget(self, action: #selector(galleryButtonTapped), for: .touchUpInside)
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

    private func startLoading() {
        view.addSubview(spinner)
        spinner.startAnimating()
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func stopLoading() {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
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
            self.startLoading()
            guard let model = self.cartoonGanModel else {
                log.error("Failed to initialize model!")
                self.stopLoading()
                self.showErrorDialog(message: "We failed to initialize the model!")
                return
            }

            model.process(image)
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
        stopLoading()
        imageView.image = image
    }

    func model(_ model: CartoonGanModel, didFailedProcessing error: CartoonGanModelError) {
        stopLoading()
        showErrorDialog(message: error.localizedDescription)
    }
}
