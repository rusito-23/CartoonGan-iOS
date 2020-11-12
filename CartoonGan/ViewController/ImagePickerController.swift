import AVFoundation
import Photos
import UIKit

// MARK: - ImagePickerControllerDelegate

protocol ImagePickerControllerDelegate: class {
    func imagePicker(_ imagePicker: ImagePickerController, canUseCamera allowed: Bool)
    func imagePicker(_ imagePicker: ImagePickerController, canUseGallery allowed: Bool)
    func imagePicker(_ imagePicker: ImagePickerController, didSelect image: UIImage)
    func imagePicker(_ imagePicker: ImagePickerController, didCancel cancel: Bool)
}

// MARK: - ImagePickerController

class ImagePickerController: NSObject {

    // MARK: - Properties

    weak var delegate: ImagePickerControllerDelegate? = nil
    
    private lazy var controller: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        return controller
    }()

    // MARK: - UI Methods

    func present(parent viewController: UIViewController, sourceType: UIImagePickerController.SourceType) {
        self.controller.sourceType = sourceType
        viewController.present(self.controller, animated: true, completion: nil)
    }

    func dismiss() { controller.dismiss(animated: true, completion: nil) }

    // MARK: - Methods

    func cameraAccessRequest() {
        guard AVCaptureDevice.authorizationStatus(for: .video) !=  .authorized else {
            DispatchQueue.main.async {
                self.delegate?.imagePicker(self, canUseCamera: true)
            }
            return
        }
        
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.delegate?.imagePicker(self, canUseCamera: granted)
            }
        }
    }

    func photoGalleryAccessRequest() {
        PHPhotoLibrary.requestAuthorization { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.delegate?.imagePicker(self, canUseGallery: result == .authorized)
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ImagePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let image = info[.editedImage] as? UIImage else {
            log.warning("Failed to retrieve image")
            return
        }

        DispatchQueue.main.async {
            self.delegate?.imagePicker(self, didSelect: image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        DispatchQueue.main.async {
            self.delegate?.imagePicker(self, didCancel: true)
        }
    }
}
