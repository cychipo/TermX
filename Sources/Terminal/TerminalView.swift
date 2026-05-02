import AppKit

final class TerminalView: NSTextView {
    private let session: ShellSession
    private var buffer = TerminalBuffer()
    private var lastSize = (columns: 0, rows: 0)
    private var pendingOutput = ""
    private var cursorLocation = 0

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

    override var acceptsFirstResponder: Bool { false }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateTerminalSizeIfNeeded()
    }

    override func layout() {
        super.layout()
        updateTerminalSizeIfNeeded()
    }

    @objc func clear(_ sender: Any?) {
        buffer.clear()
        pendingOutput.removeAll(keepingCapacity: true)
        cursorLocation = 0
        textStorage?.setAttributedString(NSAttributedString(string: "", attributes: ANSIStyleMapper.defaultAttributes))
    }

    private func configure() {
        isEditable = false
        isSelectable = true
        isRichText = false
        drawsBackground = true
        backgroundColor = ANSIStyleMapper.backgroundColor
        insertionPointColor = TerminalTheme.accent
        font = ANSIStyleMapper.baseFont
        textColor = ANSIStyleMapper.foregroundColor
        allowsUndo = false
        usesFindBar = true
        autoresizingMask = [.width, .height]
        minSize = .zero
        maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textContainerInset = NSSize(width: 8, height: 6)
    }

    private func append(_ text: String) {
        var chunk = String.UnicodeScalarView()
        chunk.reserveCapacity(text.unicodeScalars.count)

        func flushChunk() {
            guard !chunk.isEmpty else { return }
            appendRenderable(String(chunk))
            chunk.removeAll(keepingCapacity: true)
        }

        let scalars = Array(text.unicodeScalars)
        var index = 0
        while index < scalars.count {
            let scalar = scalars[index]
            switch scalar.value {
            case 0x0D:
                flushChunk()
                if index + 1 < scalars.count, scalars[index + 1].value == 0x0A {
                    index += 1
                    appendRenderable("\n")
                } else {
                    moveCursorToCurrentLineStart()
                }
            case 0x0A:
                flushChunk()
                appendRenderable("\n")
            case 0x08:
                flushChunk()
                moveCursorBackwardInCurrentLine()
            case 0x7F:
                flushChunk()
                deletePreviousCharacterInCurrentLine()
            case 0x1B:
                flushChunk()
                index = handleEscapeSequence(in: scalars, from: index + 1)
                continue
            case 0x07:
                break
            default:
                chunk.append(scalar)
            }
            index += 1
        }
        flushChunk()
        scrollToEndOfDocument(nil)
    }

    private func appendRenderable(_ text: String) {
        let attributed = ANSIStyleMapper.sanitizedAttributedString(from: text)
        guard attributed.length > 0, let textStorage else { return }
        buffer.append(attributed.string)
        if cursorLocation >= textStorage.length {
            textStorage.append(attributed)
            cursorLocation = textStorage.length
            return
        }
        let replaceLength = min(attributed.length, textStorage.length - cursorLocation)
        textStorage.replaceCharacters(in: NSRange(location: cursorLocation, length: replaceLength), with: attributed)
        cursorLocation += attributed.length
    }

    private func handleEscapeSequence(in scalars: [UnicodeScalar], from start: Int) -> Int {
        guard start < scalars.count else { return start }
        let introducer = scalars[start]
        if introducer == "[" {
            var index = start + 1
            var sequence = ""
            while index < scalars.count {
                let value = scalars[index].value
                let character = Character(scalars[index])
                index += 1
                if value >= 0x40 && value <= 0x7E {
                    handleCSI(sequence, command: character)
                    return index
                }
                sequence.append(character)
            }
            return index
        }
        if introducer == "]" {
            var index = start + 1
            while index < scalars.count {
                let value = scalars[index].value
                if value == 0x07 {
                    return index + 1
                }
                if value == 0x1B, index + 1 < scalars.count, scalars[index + 1] == "\\" {
                    return index + 2
                }
                index += 1
            }
            return index
        }
        return start + 1
    }

    private func handleCSI(_ sequence: String, command: Character) {
        let parameters = csiParameters(sequence)
        switch command {
        case "C":
            moveCursorForwardInCurrentLine(parameters.first ?? 1)
        case "D":
            moveCursorBackwardInCurrentLine(parameters.first ?? 1)
        case "G":
            moveCursorToColumn(parameters.first ?? 1)
        case "J":
            if parameters.first ?? 0 == 0 {
                clearToEndOfDisplay()
            }
        case "K":
            clearCurrentLine()
        default:
            break
        }
    }

    private func csiParameters(_ sequence: String) -> [Int] {
        sequence
            .split(separator: ";", omittingEmptySubsequences: false)
            .map { Int($0.trimmingCharacters(in: CharacterSet(charactersIn: "?"))) ?? 0 }
    }

    private func moveCursorToCurrentLineStart() {
        guard let textStorage else { return }
        let current = textStorage.string as NSString
        let searchRange = NSRange(location: 0, length: min(cursorLocation, textStorage.length))
        let lineStart = current.range(of: "\n", options: .backwards, range: searchRange).location
        cursorLocation = lineStart == NSNotFound ? 0 : lineStart + 1
    }

    private func clearCurrentLine() {
        guard let textStorage else { return }
        let length = textStorage.length - cursorLocation
        guard length > 0 else { return }
        textStorage.deleteCharacters(in: NSRange(location: cursorLocation, length: length))
    }

    private func clearToEndOfDisplay() {
        guard let textStorage else { return }
        let length = textStorage.length - cursorLocation
        guard length > 0 else { return }
        textStorage.deleteCharacters(in: NSRange(location: cursorLocation, length: length))
    }

    private func moveCursorBackwardInCurrentLine(_ count: Int = 1) {
        guard count > 0 else { return }
        for _ in 0..<count {
            moveCursorBackwardOneCharacterInCurrentLine()
        }
    }

    private func moveCursorBackwardOneCharacterInCurrentLine() {
        guard let textStorage, cursorLocation > 0 else { return }
        let current = textStorage.string as NSString
        let searchRange = NSRange(location: 0, length: min(cursorLocation, textStorage.length))
        let lineStart = current.range(of: "\n", options: .backwards, range: searchRange).location
        let protectedStart = lineStart == NSNotFound ? 0 : lineStart + 1
        guard cursorLocation > protectedStart else { return }
        let range = current.rangeOfComposedCharacterSequence(at: cursorLocation - 1)
        cursorLocation = max(range.location, protectedStart)
    }

    private func moveCursorForwardInCurrentLine(_ count: Int) {
        guard let textStorage, count > 0 else { return }
        let current = textStorage.string as NSString
        let lineEndRange = current.range(of: "\n", range: NSRange(location: cursorLocation, length: textStorage.length - cursorLocation))
        let lineEnd = lineEndRange.location == NSNotFound ? textStorage.length : lineEndRange.location
        for _ in 0..<count where cursorLocation < lineEnd {
            cursorLocation = NSMaxRange(current.rangeOfComposedCharacterSequence(at: cursorLocation))
        }
    }

    private func moveCursorToColumn(_ oneBasedColumn: Int) {
        guard let textStorage else { return }
        moveCursorToCurrentLineStart()
        moveCursorForwardInCurrentLine(max(oneBasedColumn - 1, 0))
        cursorLocation = min(cursorLocation, textStorage.length)
    }

    private func deletePreviousCharacterInCurrentLine() {
        guard let textStorage, cursorLocation > 0 else { return }
        let current = textStorage.string as NSString
        let searchRange = NSRange(location: 0, length: min(cursorLocation, textStorage.length))
        let lineStart = current.range(of: "\n", options: .backwards, range: searchRange).location
        let protectedStart = lineStart == NSNotFound ? 0 : lineStart + 1
        guard cursorLocation > protectedStart else { return }
        let deletionRange = current.rangeOfComposedCharacterSequence(at: cursorLocation - 1)
        guard deletionRange.location >= protectedStart else { return }
        textStorage.deleteCharacters(in: deletionRange)
        cursorLocation = deletionRange.location
    }

    private func updateTerminalSizeIfNeeded() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        let font = ANSIStyleMapper.baseFont
        let cellWidth = max(font.maximumAdvancement.width, 1)
        let cellHeight = max(font.boundingRectForFont.height + 2, 1)
        let columns = max(Int((bounds.width - textContainerInset.width * 2) / cellWidth), 20)
        let rows = max(Int((bounds.height - textContainerInset.height * 2) / cellHeight), 5)
        guard columns != lastSize.columns || rows != lastSize.rows else { return }
        lastSize = (columns, rows)
        session.resize(columns: columns, rows: rows)
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
