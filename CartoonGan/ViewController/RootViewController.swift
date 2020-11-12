import UIKit


class RootViewController: UIViewController {
    
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

    private lazy var rootView: RootView = RootView()
    private var cameraButton: UIButton { rootView.cameraButton }
    private var galleryButton: UIButton { rootView.galleryButton }
    
    // MARK: - View Lifecycle
    
    override func loadView() {
        self.view = rootView
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

}

// MARK: - ImagePickerControllerDelegate

extension RootViewController: ImagePickerControllerDelegate {
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
        // TODO!
    }
    
    func imagePicker(_ imagePicker: ImagePickerController, didCancel cancel: Bool) {
        if cancel { imagePickerController.dismiss() }
    }
}

// MARK: - CartoonGanModelDelegate

extension RootViewController: CartoonGanModelDelegate {
    func model(_ model: CartoonGanModel, didFinishProcessing image: UIImage) {

    }

    func model(_ model: CartoonGanModel, didFailedProcessing error: CartoonGanModelError) {
        
    }
}
