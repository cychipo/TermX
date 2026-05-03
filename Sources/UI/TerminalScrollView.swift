import AppKit

final class TerminalScrollView: NSScrollView {
    private let inputView: TerminalInputView

    init(terminalView: TerminalView, inputView: TerminalInputView) {
        self.inputView = inputView
        super.init(frame: .zero)
        drawsBackground = true
        backgroundColor = ANSIStyleMapper.backgroundColor
        borderType = .noBorder
        hasVerticalScroller = true
        hasHorizontalScroller = false
        autohidesScrollers = true
        scrollerStyle = .overlay
        contentInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        documentView = terminalView
        terminalView.frame = bounds
        addSubview(inputView)
        inputView.frame = bounds
        inputView.autoresizingMask = [.width, .height]
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidChange), name: .termXSettingsDidChange, object: nil)
    }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(inputView)
    }

    @objc private func settingsDidChange() {
        backgroundColor = ANSIStyleMapper.backgroundColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
