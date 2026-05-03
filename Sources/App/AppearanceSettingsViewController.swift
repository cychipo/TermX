import AppKit

final class AppearanceSettingsViewController: NSViewController {
    private let store = SettingsStore.shared
    private let fontField = NSTextField(labelWithString: "")
    private let sizeLabel = NSTextField(labelWithString: "")
    private let sizeSlider = NSSlider(value: 13, minValue: 10, maxValue: 24, target: nil, action: nil)
    private let themeControl = NSSegmentedControl(labels: TerminalThemeMode.allCases.map(\.title), trackingMode: .selectOne, target: nil, action: nil)
    private let preview = NSTextField(labelWithString: "echo \"Hello from TermX\"\n$ ls -la")

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

        let fontButton = NSButton(title: "Select...", target: self, action: #selector(selectFont))
        let fontRow = row(label: "Font", controls: [fontField, fontButton])
        fontField.setContentHuggingPriority(.defaultLow, for: .horizontal)

        sizeSlider.target = self
        sizeSlider.action = #selector(fontSizeChanged)
        sizeSlider.numberOfTickMarks = 15
        sizeSlider.allowsTickMarkValuesOnly = false
        sizeSlider.widthAnchor.constraint(equalToConstant: 260).isActive = true
        let sizeRow = row(label: "Font Size", controls: [sizeSlider, sizeLabel])

        themeControl.target = self
        themeControl.action = #selector(themeChanged)
        themeControl.segmentStyle = .rounded
        let themeRow = row(label: "Theme", controls: [themeControl])

        preview.isEditable = false
        preview.isBordered = true
        preview.drawsBackground = true
        preview.lineBreakMode = .byClipping
        preview.usesSingleLineMode = false
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.heightAnchor.constraint(equalToConstant: 84).isActive = true
        preview.widthAnchor.constraint(equalToConstant: 420).isActive = true

        stack.addArrangedSubview(fontRow)
        stack.addArrangedSubview(sizeRow)
        stack.addArrangedSubview(themeRow)
        stack.addArrangedSubview(preview)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
    }

    private func row(label: String, controls: [NSView]) -> NSStackView {
        let title = NSTextField(labelWithString: label)
        title.font = .systemFont(ofSize: 13, weight: .semibold)
        title.widthAnchor.constraint(equalToConstant: 92).isActive = true

        let row = NSStackView(views: [title] + controls)
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 10
        row.widthAnchor.constraint(equalToConstant: 460).isActive = true
        return row
    }

    private func refresh() {
        fontField.stringValue = store.fontName
        sizeSlider.doubleValue = Double(store.fontSize)
        sizeLabel.stringValue = "\(Int(store.fontSize)) pt"
        themeControl.selectedSegment = TerminalThemeMode.allCases.firstIndex(of: store.theme) ?? 0
        preview.font = store.terminalFont
        preview.backgroundColor = TerminalTheme.terminalBackground
        preview.textColor = TerminalTheme.foreground
    }

    @objc private func selectFont() {
        NSFontManager.shared.target = self
        NSFontManager.shared.setSelectedFont(store.terminalFont, isMultiple: false)
        NSFontManager.shared.orderFrontFontPanel(self)
    }

    @objc func changeFont(_ sender: NSFontManager) {
        let converted = sender.convert(store.terminalFont)
        store.fontName = converted.fontName
        store.fontSize = converted.pointSize
        refresh()
    }

    @objc private func fontSizeChanged() {
        store.fontSize = CGFloat(sizeSlider.doubleValue.rounded())
        refresh()
    }

    @objc private func themeChanged() {
        let index = max(0, themeControl.selectedSegment)
        store.theme = TerminalThemeMode.allCases[index]
        refresh()
    }
}
