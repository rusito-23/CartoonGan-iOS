import UIKit


class RootViewController: UIViewController {
    
    // MARK: - Properties

    private var cartoonGanModel: CartoonGanModel?
    
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
        initializeModel()
    }
    
    // MARK: - Methods

    private func initializeModel() {
        guard let model = CartoonGanModel(modelInfo: CartoonGanModelInfo.default) else {
            log.error("Failed to initialize the model!")
            // TODO: handle
            return
        }

        model.delegate = self
        self.cartoonGanModel = model
    }
    
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

// MARK: - CartoonGanModelDelegate

extension RootViewController: CartoonGanModelDelegate {
    func model(_ model: CartoonGanModel, didFinishProcessing image: UIImage) {

    }

    func model(_ model: CartoonGanModel, didFailedProcessing error: CartoonGanModelError) {
        
    }
}
