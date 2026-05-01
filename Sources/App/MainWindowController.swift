import AppKit

final class MainWindowController: NSWindowController {
    private let tabController = MainTabViewController()

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1040, height: 680),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        self.init(window: window)
    }

    override init(window: NSWindow?) {
        super.init(window: window)
        configureWindow()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureWindow()
    }

    func openNewTab() {
        tabController.openNewTab()
    }

    func closeCurrentTab() {
        if tabController.tabViewItems.count <= 1 {
            close()
            return
        }
        tabController.closeCurrentTab()
    }

    private func configureWindow() {
        guard let window else { return }
        window.title = "TermX"
        window.center()
        window.tabbingMode = .preferred
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.backgroundColor = TerminalTheme.windowBackground
        window.isMovableByWindowBackground = true
        window.contentView = TerminalContainerView(tabController: tabController)
        tabController.openNewTab()
    }
}
