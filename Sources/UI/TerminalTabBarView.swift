import AppKit

protocol TerminalTabBarViewDelegate: AnyObject {
    func terminalTabBarView(_ tabBar: TerminalTabBarView, didSelectTabAt index: Int)
    func terminalTabBarView(_ tabBar: TerminalTabBarView, didCloseTabAt index: Int)
    func terminalTabBarViewDidRequestNewTab(_ tabBar: TerminalTabBarView)
}

final class TerminalTabBarView: NSView {
    weak var delegate: TerminalTabBarViewDelegate?

    private let stackView = NSStackView()
    private let addButton = NSButton(title: "+", target: nil, action: nil)
    private var tabViews: [NSView] = []

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(titles: [String], selectedIndex: Int) {
        tabViews.forEach { $0.removeFromSuperview() }
        tabViews = titles.enumerated().map { index, title in
            makeTabView(title: title.isEmpty ? "Shell" : title, index: index, selected: index == selectedIndex)
        }

        for (offset, view) in tabViews.enumerated() {
            stackView.insertArrangedSubview(view, at: offset)
        }
    }

    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        translatesAutoresizingMaskIntoConstraints = false

        stackView.orientation = .horizontal
        stackView.alignment = .centerY
        stackView.spacing = 8
        stackView.edgeInsets = NSEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        addButton.target = self
        addButton.action = #selector(addTab)
        addButton.isBordered = false
        addButton.font = NSFont.systemFont(ofSize: 17, weight: .medium)
        addButton.contentTintColor = TerminalTheme.mutedForeground
        addButton.wantsLayer = true
        addButton.layer?.cornerRadius = 9
        addButton.layer?.cornerCurve = .continuous
        addButton.layer?.backgroundColor = NSColor(calibratedWhite: 1, alpha: 0.06).cgColor
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        stackView.addArrangedSubview(addButton)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 46)
        ])
    }

    private func makeTabView(title: String, index: Int, selected: Bool) -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.cornerRadius = 9
        container.layer?.cornerCurve = .continuous
        container.layer?.backgroundColor = selected ? NSColor(calibratedWhite: 1, alpha: 0.10).cgColor : NSColor.clear.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false

        let selectButton = NSButton(title: title, target: self, action: #selector(selectTab(_:)))
        selectButton.tag = index
        selectButton.isBordered = false
        selectButton.font = NSFont.systemFont(ofSize: 13, weight: selected ? .semibold : .medium)
        selectButton.contentTintColor = selected ? TerminalTheme.foreground : TerminalTheme.mutedForeground
        selectButton.translatesAutoresizingMaskIntoConstraints = false

        let closeButton = NSButton(title: "×", target: self, action: #selector(closeTab(_:)))
        closeButton.tag = index
        closeButton.isBordered = false
        closeButton.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        closeButton.contentTintColor = selected ? TerminalTheme.mutedForeground : NSColor(calibratedWhite: 1, alpha: 0.35)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(selectButton)
        container.addSubview(closeButton)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 30),
            container.widthAnchor.constraint(greaterThanOrEqualToConstant: 116),
            selectButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            selectButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            closeButton.leadingAnchor.constraint(equalTo: selectButton.trailingAnchor, constant: 6),
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            closeButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        return container
    }

    @objc private func selectTab(_ sender: NSButton) {
        delegate?.terminalTabBarView(self, didSelectTabAt: sender.tag)
    }

    @objc private func closeTab(_ sender: NSButton) {
        delegate?.terminalTabBarView(self, didCloseTabAt: sender.tag)
    }

    @objc private func addTab() {
        delegate?.terminalTabBarViewDidRequestNewTab(self)
    }
}
