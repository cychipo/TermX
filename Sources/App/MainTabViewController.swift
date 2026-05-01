import AppKit

protocol MainTabViewControllerDelegate: AnyObject {
    func mainTabViewControllerDidChangeTabs(_ controller: MainTabViewController)
}

final class MainTabViewController: NSTabViewController {
    weak var tabDelegate: MainTabViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tabStyle = .unspecified
        transitionOptions = []
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
    }

    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)
        tabDelegate?.mainTabViewControllerDidChangeTabs(self)
        focusCurrentTerminal()
    }

    func openNewTab() {
        let tab = TerminalTab()
        let item = NSTabViewItem(viewController: tab)
        item.label = tab.tabTitle
        addTabViewItem(item)
        selectedTabViewItemIndex = tabViewItems.count - 1
        tabDelegate?.mainTabViewControllerDidChangeTabs(self)
        focusCurrentTerminal()
    }

    func closeCurrentTab() {
        closeTab(at: selectedTabViewItemIndex)
    }

    func closeTab(at index: Int) {
        guard tabViewItems.indices.contains(index), tabViewItems.count > 1 else { return }
        let item = tabViewItems[index]
        removeTabViewItem(item)
        selectedTabViewItemIndex = min(index, tabViewItems.count - 1)
        tabDelegate?.mainTabViewControllerDidChangeTabs(self)
        focusCurrentTerminal()
    }

    func selectTab(at index: Int) {
        guard tabViewItems.indices.contains(index) else { return }
        selectedTabViewItemIndex = index
        tabDelegate?.mainTabViewControllerDidChangeTabs(self)
        focusCurrentTerminal()
    }

    func focusCurrentTerminal() {
        guard tabViewItems.indices.contains(selectedTabViewItemIndex),
              let tab = tabViewItems[selectedTabViewItemIndex].viewController as? TerminalTab else { return }
        tab.focusTerminal()
    }

    func currentTabTitles() -> [String] {
        tabViewItems.map { $0.label }
    }
}
