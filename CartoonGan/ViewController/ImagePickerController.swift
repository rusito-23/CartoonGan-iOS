import AVFoundation
import Photos
import UIKit

// MARK: - ImagePickerControllerDelegate

protocol ImagePickerControllerDelegate: class {
    func imagePicker(_ imagePicker: ImagePickerController, canUseCamera accessIsAllowed: Bool)
    func imagePicker(_ imagePicker: ImagePickerController, canUseGallery accessIsAllowed: Bool)
    func imagePicker(_ imagePicker: ImagePickerController, didSelect image: UIImage)
    func imagePicker(_ imagePicker: ImagePickerController, didCancel cancel: Bool)
}

// MARK: - ImagePickerController

class ImagePickerController: NSObject {

    // MARK: - Properties

    weak var delegate: ImagePickerControllerDelegate? = nil
    weak var parent: UIViewController?
    
    private lazy var controller: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        return controller
    }()

    // MARK: - UI Methods

    func present(parent viewController: UIViewController, sourceType: UIImagePickerController.SourceType) {
        DispatchQueue.main.async {
            self.controller.sourceType = sourceType
            self.parent = viewController
            viewController.present(self.controller, animated: true, completion: nil)
        }
    }

    func dismiss() { controller.dismiss(animated: true, completion: nil) }

    // MARK: - Methods
    
    private func presentError(targetName: String) {
        log.error("Access request failed for target: \(targetName)")
        // TODO: Manage error
    }

    func cameraAccessRequest() {
        guard AVCaptureDevice.authorizationStatus(for: .video) !=  .authorized else {
            delegate?.imagePicker(self, canUseCamera: true)
            return
        }
        
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self = self else { return }
            guard granted else {
                self.presentError(targetName: "camera")
                return
            }

            self.delegate?.imagePicker(self, canUseCamera: granted)
        }
    }

    func photoGalleryAccessRequest() {
        PHPhotoLibrary.requestAuthorization { [weak self] result in
            guard let self = self else { return }
            guard case .authorized = result else {
                self.presentError(targetName: "photo gallery")
                return
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.imagePicker(self, canUseGallery: true)
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
