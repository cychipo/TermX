import AppKit

final class MainTabViewController: NSTabViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabStyle = .toolbar
        transitionOptions = []
    }

    func openNewTab() {
        let tab = TerminalTab()
        let item = NSTabViewItem(viewController: tab)
        item.label = tab.tabTitle
        addTabViewItem(item)
        selectedTabViewItemIndex = tabViewItems.count - 1
    }

    func closeCurrentTab() {
        guard tabViewItems.indices.contains(selectedTabViewItemIndex) else { return }
        let item = tabViewItems[selectedTabViewItemIndex]
        removeTabViewItem(item)
    }
}
