import UIKit


class RootViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var rootView: RootView = RootView()
    private var cameraButton: UIButton { return rootView.cameraButton }
    private var galleryButton: UIButton { return rootView.galleryButton }
    
    // MARK: - View Lifecycle
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        
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
    
    // MARK: - IBActions
    
    @objc func cameraButtonTapped() {
        log.debug("Camera pressed!")
    }
    
    @objc func galleryButtonTapped() {
        log.debug("Camera pressed!")
    }
    
}
