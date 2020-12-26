import AVFoundation
import Photos
import SwiftSpinner
import UIKit

// MARK: - ImagePickerControllerDelegate

protocol ImagePickerControllerDelegate: class {
    func imagePicker(_ imagePicker: ImagePickerController, canUseCamera allowed: Bool)
    func imagePicker(_ imagePicker: ImagePickerController, canUseGallery allowed: Bool)
    func imagePicker(_ imagePicker: ImagePickerController, didSelect image: UIImage)
    func imagePicker(_ imagePicker: ImagePickerController, didCancel cancel: Bool)
    func imagePicker(_ imagePicker: ImagePickerController, didFail failed: Bool)
}

// MARK: - ImagePickerController

final class ImagePickerController: NSObject {

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

    func dismiss(_ completion: (() -> ())? = nil) {
        controller.dismiss(animated: true, completion: completion)
    }

    // MARK: - Methods

    func cameraAccessRequest() {
        guard AVCaptureDevice.authorizationStatus(for: .video) != .authorized else {
            main { self.delegate?.imagePicker(self, canUseCamera: true) }
            return
        }

        SwiftSpinner.show("Checking camera access")
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            SwiftSpinner.hide()
            guard let self = self else { return }
            self.main { self.delegate?.imagePicker(self, canUseCamera: granted) }
        }
    }

    func photoGalleryAccessRequest() {
        SwiftSpinner.show("Checking gallery access")
        PHPhotoLibrary.requestAuthorization { [weak self] result in
            SwiftSpinner.hide()
            guard let self = self else { return }
            self.main { self.delegate?.imagePicker(self, canUseGallery: result == .authorized) }
        }
    }

    // MARK: - Private methods

    private func main(_ completion: @escaping(() -> ())) {
        DispatchQueue.main.async(execute: completion)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ImagePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let image = info[.originalImage] as? UIImage else {
            log.error("Failed to retrieve image")
            main { self.delegate?.imagePicker(self, didFail: true) }
            return
        }

        main { self.delegate?.imagePicker(self, didSelect: image) }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        main { self.delegate?.imagePicker(self, didCancel: true) }
    }
}
