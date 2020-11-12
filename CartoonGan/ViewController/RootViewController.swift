import UIKit


class RootViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var imagePickerController: ImagePickerController = {
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        return imagePicker
    }()
    
    // MARK: - Views
    
    private lazy var rootView: RootView = RootView()
    private var cameraButton: UIButton { return rootView.cameraButton }
    private var galleryButton: UIButton { return rootView.galleryButton }
    
    // MARK: - View Lifecycle
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        galleryButton.addTarget(self, action: #selector(galleryButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Methods
    
    @objc func cameraButtonTapped() {
        imagePickerController.cameraAccessRequest()
    }
    
    @objc func galleryButtonTapped() {
        imagePickerController.photoGalleryAccessRequest()
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePickerController.present(parent: self, sourceType: sourceType)
    }

}

// MARK: - ImagePickerControllerDelegate

extension RootViewController: ImagePickerControllerDelegate {
    func imagePicker(_ imagePicker: ImagePickerController, canUseCamera accessIsAllowed: Bool) {
        if accessIsAllowed {
            presentImagePicker(sourceType: .camera)
        }
    }
    
    func imagePicker(_ imagePicker: ImagePickerController, canUseGallery accessIsAllowed: Bool) {
        if accessIsAllowed {
            presentImagePicker(sourceType: .photoLibrary)
        }
    }
    
    func imagePicker(_ imagePicker: ImagePickerController, didSelect image: UIImage) {
        
    }
    
    func imagePicker(_ imagePicker: ImagePickerController, didCancel cancel: Bool) {
        if cancel {
            imagePickerController.dismiss()
        }
    }
}
