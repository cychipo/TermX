import AppKit

final class TerminalTab: NSViewController {
    private let session = ShellSession()
    private lazy var terminalView = TerminalView(session: session)

    var tabTitle: String {
        session.shellName
    }

    override func loadView() {
        view = TerminalScrollView(terminalView: terminalView)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(terminalView)
        session.start()
    }

    deinit {
        session.close()
    }
}
