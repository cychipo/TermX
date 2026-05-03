import AppKit

final class KeyboardSettingsViewController: NSViewController {
    private let store = SettingsStore.shared
    private let optionPopup = NSPopUpButton()

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 520, height: 360))
        setupUI()
        refresh()
    }

    private func setupUI() {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 18
        stack.edgeInsets = NSEdgeInsets(top: 24, left: 28, bottom: 24, right: 28)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let optionTitle = sectionTitle("Option Key (⌥)")
        optionPopup.addItems(withTitles: TerminalOptionKeyBehavior.allCases.map(\.title))
        optionPopup.target = self
        optionPopup.action = #selector(optionBehaviorChanged)
        optionPopup.widthAnchor.constraint(equalToConstant: 240).isActive = true

        let shortcutsTitle = sectionTitle("Shortcuts")
        let shortcuts = NSTextField(labelWithString: "Copy\t⌘C\nPaste\t⌘V\nSelect All\t⌘A\nClear\t⌘K\nNew Tab\t⌘T")
        shortcuts.font = .monospacedSystemFont(ofSize: 13, weight: .regular)

        stack.addArrangedSubview(optionTitle)
        stack.addArrangedSubview(optionPopup)
        stack.addArrangedSubview(shortcutsTitle)
        stack.addArrangedSubview(shortcuts)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
    }

    private func sectionTitle(_ text: String) -> NSTextField {
        let field = NSTextField(labelWithString: text)
        field.font = .systemFont(ofSize: 13, weight: .semibold)
        return field
    }

    private func refresh() {
        optionPopup.selectItem(at: TerminalOptionKeyBehavior.allCases.firstIndex(of: store.optionKeyBehavior) ?? 0)
    }

    @objc private func optionBehaviorChanged() {
        store.optionKeyBehavior = TerminalOptionKeyBehavior.allCases[optionPopup.indexOfSelectedItem]
    }
}
