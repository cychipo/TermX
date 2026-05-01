import AppKit

final class TerminalTab: NSViewController {
    private let session = ShellSession()
    private lazy var terminalView = TerminalView(session: session)
    private lazy var inputView = TerminalInputView(session: session)
    private var didStartSession = false

    var tabTitle: String {
        session.shellName
    }

    override func loadView() {
        view = TerminalScrollView(terminalView: terminalView, inputView: inputView)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        startIfNeeded()
        focusTerminal()
    }

    func focusTerminal() {
        guard isViewLoaded else { return }
        view.window?.makeFirstResponder(inputView)
    }

    func resizeTerminal(columns: Int, rows: Int) {
        session.resize(columns: columns, rows: rows)
    }

    private func startIfNeeded() {
        guard !didStartSession else { return }
        didStartSession = true
        session.start()
    }

    deinit {
        session.close()
    }
}
