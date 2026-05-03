import AppKit

final class TerminalSettingsViewController: NSViewController {
    private let store = SettingsStore.shared
    private let scrollbackField = NSTextField(string: "")
    private let scrollbackStepper = NSStepper()
    private let soundSwitch = NSButton(checkboxWithTitle: "Audio bell", target: nil, action: nil)
    private let visualSwitch = NSButton(checkboxWithTitle: "Visual bell", target: nil, action: nil)

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

        let scrollbackTitle = sectionTitle("Scrollback")
        scrollbackField.widthAnchor.constraint(equalToConstant: 90).isActive = true
        scrollbackField.formatter = integerFormatter()
        scrollbackField.target = self
        scrollbackField.action = #selector(scrollbackChanged)

        scrollbackStepper.minValue = 1_000
        scrollbackStepper.maxValue = 100_000
        scrollbackStepper.increment = 1_000
        scrollbackStepper.target = self
        scrollbackStepper.action = #selector(stepperChanged)
        let scrollbackRow = NSStackView(views: [NSTextField(labelWithString: "Lines"), scrollbackField, scrollbackStepper])
        scrollbackRow.orientation = .horizontal
        scrollbackRow.alignment = .centerY
        scrollbackRow.spacing = 10

        let bellTitle = sectionTitle("Bell")
        soundSwitch.target = self
        soundSwitch.action = #selector(bellChanged)
        visualSwitch.target = self
        visualSwitch.action = #selector(bellChanged)

        stack.addArrangedSubview(scrollbackTitle)
        stack.addArrangedSubview(scrollbackRow)
        stack.addArrangedSubview(bellTitle)
        stack.addArrangedSubview(soundSwitch)
        stack.addArrangedSubview(visualSwitch)

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

    private func integerFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimum = 1_000
        formatter.maximum = 100_000
        formatter.allowsFloats = false
        return formatter
    }

    private func refresh() {
        scrollbackField.integerValue = store.scrollbackLines
        scrollbackStepper.integerValue = store.scrollbackLines
        soundSwitch.state = store.bellSound ? .on : .off
        visualSwitch.state = store.visualBell ? .on : .off
    }

    @objc private func scrollbackChanged() {
        store.scrollbackLines = scrollbackField.integerValue
        refresh()
    }

    @objc private func stepperChanged() {
        store.scrollbackLines = scrollbackStepper.integerValue
        refresh()
    }

    @objc private func bellChanged() {
        store.bellSound = soundSwitch.state == .on
        store.visualBell = visualSwitch.state == .on
    }
}
