import UIKit


class RootViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var rootView: RootView = RootView()
    
    // MARK: - View Lifecycle
    
    override func loadView() {
        self.view = rootView
    }
}
