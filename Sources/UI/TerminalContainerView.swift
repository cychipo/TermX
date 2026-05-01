import AppKit

final class TerminalContainerView: NSView {
    private let visualEffectView = NSVisualEffectView()
    private let contentView = NSView()
    private let tabBarView = TerminalTabBarView()
    private let tabController: MainTabViewController

    init(tabController: MainTabViewController) {
        self.tabController = tabController
        super.init(frame: .zero)
        tabController.tabDelegate = self
        tabBarView.delegate = self
        wantsLayer = true
        layer?.backgroundColor = TerminalTheme.windowBackground.cgColor
        setupVisualEffect()
        setupContentView()
        updateTabs()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupVisualEffect() {
        visualEffectView.material = .hudWindow
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualEffectView)
        NSLayoutConstraint.activate([
            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupContentView() {
        contentView.wantsLayer = true
        contentView.layer?.cornerRadius = 18
        contentView.layer?.cornerCurve = .continuous
        contentView.layer?.borderWidth = 1
        contentView.layer?.borderColor = TerminalTheme.border.cgColor
        contentView.layer?.backgroundColor = TerminalTheme.terminalBackground.cgColor
        contentView.layer?.masksToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        let tabView = tabController.view
        tabView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tabBarView)
        contentView.addSubview(tabView)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
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
