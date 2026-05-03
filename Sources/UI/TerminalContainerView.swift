import AppKit

final class TerminalContainerView: NSView {
    private let contentView = NSView()
    private let tabBarView = TerminalTabBarView()
    private let tabController: MainTabViewController

    init(tabController: MainTabViewController) {
        self.tabController = tabController
        super.init(frame: .zero)
        tabController.tabDelegate = self
        tabBarView.delegate = self
        wantsLayer = true
        applyTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidChange), name: .termXSettingsDidChange, object: nil)
        setupContentView()
        updateTabs()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func setupContentView() {
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = TerminalTheme.terminalBackground.cgColor
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        let tabView = tabController.view
        tabView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tabBarView)
        contentView.addSubview(tabView)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tabBarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tabBarView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tabView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tabView.topAnchor.constraint(equalTo: tabBarView.bottomAnchor),
            tabView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func updateTabs() {
        tabBarView.update(titles: tabController.currentTabTitles(), selectedIndex: tabController.selectedTabViewItemIndex)
    }

    private func applyTheme() {
        layer?.backgroundColor = TerminalTheme.windowBackground.cgColor
        contentView.layer?.backgroundColor = TerminalTheme.terminalBackground.cgColor
    }

    @objc private func settingsDidChange() {
        applyTheme()
    }
}

extension TerminalContainerView: MainTabViewControllerDelegate {
    func mainTabViewControllerDidChangeTabs(_ controller: MainTabViewController) {
        updateTabs()
    }
}

extension TerminalContainerView: TerminalTabBarViewDelegate {
    func terminalTabBarView(_ tabBar: TerminalTabBarView, didSelectTabAt index: Int) {
        tabController.selectTab(at: index)
    }

    func terminalTabBarView(_ tabBar: TerminalTabBarView, didCloseTabAt index: Int) {
        tabController.closeTab(at: index)
    }

    func terminalTabBarViewDidRequestNewTab(_ tabBar: TerminalTabBarView) {
        tabController.openNewTab()
    }
}
