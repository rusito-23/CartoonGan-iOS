import PopupDialog

class ErrorDialog {

    // MARK: - Properties

    private var dialog: PopupDialog

    private lazy var defaultButton = DefaultButton(
        title: "Oh... OK",
        dismissOnTap: true,
        action: nil
    )

    // MARK: - Initializers

    init(message: String) {
        dialog = PopupDialog(
            title: "☹️",
            message: message,
            buttonAlignment: .horizontal,
            transitionStyle: .bounceDown
        )

        dialog.addButton(defaultButton)
    }

    // MARK: - Methods

    func present(
        _ parent: UIViewController,
        completion: (() -> Void)? = nil
    ) {
        parent.present(
            dialog,
            animated: true,
            completion: completion
        )
    }
}
