import AppKit

final class TerminalInputView: NSView, NSTextInputClient {
    private let session: ShellSession
    private lazy var textInputContext = NSTextInputContext(client: self)
    private var markedText = ""

    init(session: ShellSession) {
        self.session = session
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var acceptsFirstResponder: Bool { true }

    override var inputContext: NSTextInputContext? {
        textInputContext
    }

    override func keyDown(with event: NSEvent) {
        if inputContext?.handleEvent(event) != true {
            interpretKeyEvents([event])
        }
    }

    override func scrollWheel(with event: NSEvent) {
        superview?.scrollWheel(with: event)
    }

    override func doCommand(by selector: Selector) {
        guard let sequence = InputHandler.sequence(for: selector) else { return }
        session.send(sequence)
    }

    override func insertText(_ insertString: Any) {
        sendCommittedText(insertString)
    }

    func insertText(_ string: Any, replacementRange: NSRange) {
        sendCommittedText(string)
    }

    private func sendCommittedText(_ value: Any) {
        markedText.removeAll(keepingCapacity: true)
        guard let text = plainText(from: value), !text.isEmpty else { return }
        session.send(text)
    }

    func setMarkedText(_ string: Any, selectedRange: NSRange, replacementRange: NSRange) {
        markedText = plainText(from: string) ?? ""
    }

    func unmarkText() {
        markedText.removeAll(keepingCapacity: true)
    }

    func selectedRange() -> NSRange {
        NSRange(location: markedText.utf16.count, length: 0)
    }

    func markedRange() -> NSRange {
        markedText.isEmpty ? NSRange(location: NSNotFound, length: 0) : NSRange(location: 0, length: markedText.utf16.count)
    }

    func hasMarkedText() -> Bool {
        !markedText.isEmpty
    }

    func validAttributesForMarkedText() -> [NSAttributedString.Key] {
        []
    }

    func attributedSubstring(forProposedRange range: NSRange, actualRange: NSRangePointer?) -> NSAttributedString? {
        nil
    }

    func characterIndex(for point: NSPoint) -> Int {
        markedText.utf16.count
    }

    func firstRect(forCharacterRange range: NSRange, actualRange: NSRangePointer?) -> NSRect {
        guard let window else { return .zero }
        let rect = convert(bounds, to: nil)
        return window.convertToScreen(rect)
    }

    private func plainText(from value: Any) -> String? {
        if let text = value as? String {
            return text
        }
        if let text = value as? NSAttributedString {
            return text.string
        }
        return nil
    }
}
