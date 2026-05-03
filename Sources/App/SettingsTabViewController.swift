import AppKit

final class SettingsTabViewController: NSTabViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabStyle = .toolbar
        addTab(title: "Appearance", controller: AppearanceSettingsViewController())
        addTab(title: "Terminal", controller: TerminalSettingsViewController())
        addTab(title: "Keyboard", controller: KeyboardSettingsViewController())
    }

    private func addTab(title: String, controller: NSViewController) {
        let item = NSTabViewItem(viewController: controller)
        item.label = title
        item.image = image(for: title)
        addTabViewItem(item)
    }

    private func image(for title: String) -> NSImage? {
        let name: NSImage.Name
        switch title {
        case "Appearance": name = NSImage.colorPanelName
        case "Terminal": name = NSImage.advancedName
        default: name = NSImage.preferencesGeneralName
        }
        return NSImage(named: name)
    }
}
