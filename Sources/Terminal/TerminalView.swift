import AppKit

final class TerminalView: NSTextView {
    private let session: ShellSession
    private var buffer = TerminalBuffer()

    init(session: ShellSession) {
        self.session = session
        let storage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        let container = NSTextContainer(containerSize: NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        container.widthTracksTextView = true
        container.heightTracksTextView = false
        layoutManager.addTextContainer(container)
        storage.addLayoutManager(layoutManager)
        super.init(frame: .zero, textContainer: container)
        configure()
        session.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        guard let sequence = InputHandler.sequence(for: event) else { return }
        session.send(sequence)
    }

    @objc func clear(_ sender: Any?) {
        buffer.clear()
        textStorage?.setAttributedString(NSAttributedString(string: "", attributes: ANSIStyleMapper.defaultAttributes))
    }

    private func configure() {
        isEditable = false
        isSelectable = true
        isRichText = false
        drawsBackground = true
        backgroundColor = ANSIStyleMapper.backgroundColor
        insertionPointColor = ANSIStyleMapper.foregroundColor
        font = ANSIStyleMapper.baseFont
        textColor = ANSIStyleMapper.foregroundColor
        autoresizingMask = [.width, .height]
        minSize = .zero
        maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textContainerInset = NSSize(width: 8, height: 8)
    }

    private func append(_ text: String) {
        buffer.append(text)
        textStorage?.append(ANSIStyleMapper.sanitizedAttributedString(from: text))
        scrollToEndOfDocument(nil)
    }
}

extension TerminalView: ShellSessionDelegate {
    func shellSession(_ session: ShellSession, didReceive text: String) {
        append(text)
    }

    func shellSession(_ session: ShellSession, didFail error: Error) {
        append("\r\nTermX error: \(error.localizedDescription)\r\n")
    }
}
