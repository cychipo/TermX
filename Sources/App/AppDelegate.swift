import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var windows: [MainWindowController] = []
    private var settingsWindowController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        SettingsStore.registerDefaults()
        setupMainMenu()
        openNewWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    @objc func openNewWindow(_ sender: Any?) {
        let controller = MainWindowController()
        controller.window?.delegate = self
        windows.append(controller)
        controller.showWindow(sender)
    }

    @objc func openNewTab(_ sender: Any?) {
        guard let controller = NSApp.keyWindow?.windowController as? MainWindowController else {
            openNewWindow(sender)
            return
        }
        controller.openNewTab()
    }

    @objc func closeCurrentTab(_ sender: Any?) {
        guard let controller = NSApp.keyWindow?.windowController as? MainWindowController else { return }
        controller.closeCurrentTab()
    }

    @objc func openPreferences(_ sender: Any?) {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }
        settingsWindowController?.showWindow(sender)
    }

    private func setupMainMenu() {
        let mainMenu = NSMenu()
        mainMenu.addItem(appMenuItem())
        mainMenu.addItem(fileMenuItem())
        mainMenu.addItem(editMenuItem())
        mainMenu.addItem(viewMenuItem())
        mainMenu.addItem(terminalMenuItem())
        NSApp.mainMenu = mainMenu
    }

    private func appMenuItem() -> NSMenuItem {
        let item = NSMenuItem()
        let menu = NSMenu(title: "TermX")
        menu.addItem(withTitle: "About TermX", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Preferences...", action: #selector(openPreferences(_:)), keyEquivalent: ",")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit TermX", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        item.submenu = menu
        return item
    }

    private func fileMenuItem() -> NSMenuItem {
        let item = NSMenuItem()
        let menu = NSMenu(title: "File")
        menu.addItem(withTitle: "New Window", action: #selector(openNewWindow(_:)), keyEquivalent: "n")
        menu.addItem(withTitle: "New Tab", action: #selector(openNewTab(_:)), keyEquivalent: "t")
        menu.addItem(withTitle: "Close Tab", action: #selector(closeCurrentTab(_:)), keyEquivalent: "w")
        item.submenu = menu
        return item
    }

    private func editMenuItem() -> NSMenuItem {
        let item = NSMenuItem()
        let menu = NSMenu(title: "Edit")
        menu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        menu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        menu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        item.submenu = menu
        return item
    }

    private func viewMenuItem() -> NSMenuItem {
        let item = NSMenuItem()
        let menu = NSMenu(title: "View")
        menu.addItem(withTitle: "Enter Full Screen", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f")
        item.submenu = menu
        return item
    }

    private func terminalMenuItem() -> NSMenuItem {
        let item = NSMenuItem()
        let menu = NSMenu(title: "Terminal")
        menu.addItem(withTitle: "Clear", action: #selector(TerminalView.clear(_:)), keyEquivalent: "k")
        item.submenu = menu
        return item
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard let controller = (notification.object as? NSWindow)?.windowController as? MainWindowController else { return }
        windows.removeAll { $0 === controller }
    }
}
