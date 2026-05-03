import AppKit

final class MainWindowController: NSWindowController {
    private let tabController = MainTabViewController()

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1040, height: 680),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
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
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.backgroundColor = TerminalTheme.windowBackground
        window.isMovableByWindowBackground = false
        window.contentView = TerminalContainerView(tabController: tabController)
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidChange), name: .termXSettingsDidChange, object: nil)
        tabController.openNewTab()
    }

    @objc private func settingsDidChange() {
        window?.backgroundColor = TerminalTheme.windowBackground
    }
}
