import AppKit

final class TerminalScrollView: NSScrollView {
    init(terminalView: TerminalView) {
        super.init(frame: .zero)
        drawsBackground = true
        backgroundColor = ANSIStyleMapper.backgroundColor
        borderType = .noBorder
        hasVerticalScroller = true
        hasHorizontalScroller = false
        autohidesScrollers = true
        documentView = terminalView
        terminalView.frame = bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
