import AppKit

final class TerminalView: NSTextView {
    private let session: ShellSession
    private var buffer: TerminalBuffer
    private var lastSize = (columns: 80, rows: 24)
    private var pendingOutput = ""
    private var screenRows: [[TerminalCell]] = []
    private var cursor = (row: 0, column: 0)
    private var savedCursor = (row: 0, column: 0)
    private var currentStyle = TerminalCell.empty

    init(session: ShellSession, scrollbackLines: Int = SettingsStore.shared.scrollbackLines) {
        self.session = session
        self.buffer = TerminalBuffer(maxLineCount: scrollbackLines)
        let storage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        let container = NSTextContainer(containerSize: NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        container.widthTracksTextView = true
        container.heightTracksTextView = false
        layoutManager.addTextContainer(container)
        storage.addLayoutManager(layoutManager)
        super.init(frame: .zero, textContainer: container)
        configure()
        resizeGrid(columns: lastSize.columns, rows: lastSize.rows)
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidChange), name: .termXSettingsDidChange, object: nil)
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

    override func scrollWheel(with event: NSEvent) {
        let sequence = event.scrollingDeltaY > 0 ? "\u{1B}[A" : "\u{1B}[B"
        let count = max(1, min(Int(abs(event.scrollingDeltaY) / 8), 6))
        for _ in 0..<count {
            session.send(sequence)
        }
    }

    @objc func clear(_ sender: Any?) {
        buffer.clear()
        pendingOutput.removeAll(keepingCapacity: true)
        cursor = (0, 0)
        savedCursor = cursor
        currentStyle = TerminalCell.empty
        resizeGrid(columns: lastSize.columns, rows: lastSize.rows)
        renderScreen()
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
        autoresizingMask = [.width]
        minSize = .zero
        maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        isVerticallyResizable = true
        isHorizontallyResizable = false
        textContainerInset = NSSize(width: 8, height: 6)
    }

    @objc private func settingsDidChange() {
        backgroundColor = ANSIStyleMapper.backgroundColor
        insertionPointColor = TerminalTheme.accent
        font = ANSIStyleMapper.baseFont
        textColor = ANSIStyleMapper.foregroundColor
        renderScreen()
        updateTerminalSizeIfNeeded()
    }

    private func append(_ text: String) {
        let input = pendingOutput + text
        pendingOutput.removeAll(keepingCapacity: true)
        let scalars = Array(input.unicodeScalars)
        var index = 0
        while index < scalars.count {
            let scalar = scalars[index]
            switch scalar.value {
            case 0x0D:
                cursor.column = 0
            case 0x0A:
                moveToNextLine()
            case 0x08:
                cursor.column = max(cursor.column - 1, 0)
            case 0x7F:
                eraseCellBeforeCursor()
            case 0x1B:
                let result = escapeSequence(in: scalars, from: index)
                if result.isIncomplete {
                    pendingOutput = String(String.UnicodeScalarView(scalars[index...]))
                    index = scalars.count
                    continue
                }
                handleEscapeResult(result)
                index = result.nextIndex
                continue
            case 0x07:
                handleBell()
            default:
                let character = Character(scalar)
                if shouldRender(character) {
                    write(character)
                }
            }
            index += 1
        }
        renderScreen()
        scrollToBottom()
    }

    private func handleBell() {
        let store = SettingsStore.shared
        if store.bellSound {
            NSSound.beep()
        }
        if store.visualBell {
            window?.backgroundColor = TerminalTheme.accent.withAlphaComponent(0.18)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
                self?.window?.backgroundColor = TerminalTheme.windowBackground
            }
        }
    }

    private func shouldRender(_ character: Character) -> Bool {
        character != "%"
    }

    private func write(_ character: Character) {
        guard !screenRows.isEmpty else { return }
        if cursor.column >= lastSize.columns {
            moveToNextLine()
        }
        screenRows[cursor.row][cursor.column] = currentStyle.styled(character: character)
        cursor.column += 1
        if cursor.column >= lastSize.columns {
            moveToNextLine()
        }
    }

    private func moveToNextLine() {
        cursor.column = 0
        if cursor.row + 1 >= lastSize.rows {
            scrollGridUp()
        } else {
            cursor.row += 1
        }
    }

    private func scrollGridUp() {
        guard !screenRows.isEmpty else { return }
        buffer.append(String(screenRows.removeFirst().map(\.character)) + "\n")
        screenRows.append(emptyRow())
        cursor.row = max(lastSize.rows - 1, 0)
    }

    private func eraseCellBeforeCursor() {
        guard cursor.column > 0 else { return }
        cursor.column -= 1
        screenRows[cursor.row][cursor.column] = TerminalCell.empty
    }

    private func escapeSequence(in scalars: [UnicodeScalar], from start: Int) -> EscapeResult {
        guard start + 1 < scalars.count else { return EscapeResult(nextIndex: start, isIncomplete: true) }
        let introducer = scalars[start + 1]
        if introducer == "[" {
            var index = start + 2
            var sequence = ""
            while index < scalars.count {
                let value = scalars[index].value
                let character = Character(scalars[index])
                index += 1
                if value >= 0x40 && value <= 0x7E {
                    return EscapeResult(nextIndex: index, sequence: sequence, command: character)
                }
                sequence.append(character)
            }
            return EscapeResult(nextIndex: index, isIncomplete: true)
        }
        if introducer == "]" {
            var index = start + 2
            while index < scalars.count {
                let value = scalars[index].value
                if value == 0x07 {
                    return EscapeResult(nextIndex: index + 1)
                }
                if value == 0x1B, index + 1 < scalars.count, scalars[index + 1] == "\\" {
                    return EscapeResult(nextIndex: index + 2)
                }
                index += 1
            }
            return EscapeResult(nextIndex: index, isIncomplete: true)
        }
        switch introducer {
        case "c":
            return EscapeResult(nextIndex: start + 2, action: .reset)
        case "7":
            return EscapeResult(nextIndex: start + 2, action: .saveCursor)
        case "8":
            return EscapeResult(nextIndex: start + 2, action: .restoreCursor)
        default:
            return EscapeResult(nextIndex: start + 2)
        }
    }

    private func handleEscapeResult(_ result: EscapeResult) {
        if let action = result.action {
            handleEscapeAction(action)
        }
        guard let command = result.command else { return }
        if command == "m" {
            applySGR(result.sequence)
        } else {
            handleCSI(result.sequence, command: command)
        }
    }

    private enum EscapeAction {
        case reset
        case saveCursor
        case restoreCursor
    }

    private struct EscapeResult {
        let nextIndex: Int
        var sequence = ""
        var command: Character?
        var action: EscapeAction?
        var isIncomplete = false
    }

    private func handleEscapeAction(_ action: EscapeAction) {
        switch action {
        case .reset:
            clear(nil)
        case .saveCursor:
            savedCursor = cursor
        case .restoreCursor:
            cursor = clampedCursor(savedCursor)
        }
    }

    private func handleCSI(_ sequence: String, command: Character) {
        let parameters = csiParameters(sequence)
        switch command {
        case "A":
            cursor.row = max(cursor.row - countParameter(parameters), 0)
        case "B":
            cursor.row = min(cursor.row + countParameter(parameters), lastSize.rows - 1)
        case "C":
            cursor.column = min(cursor.column + countParameter(parameters), lastSize.columns - 1)
        case "D":
            cursor.column = max(cursor.column - countParameter(parameters), 0)
        case "G":
            cursor.column = min(max(countParameter(parameters) - 1, 0), lastSize.columns - 1)
        case "H", "f":
            let row = min(max(countParameter(parameters) - 1, 0), lastSize.rows - 1)
            let column = min(max(countParameter(Array(parameters.dropFirst())) - 1, 0), lastSize.columns - 1)
            cursor = (row, column)
        case "J":
            clearDisplay(mode: parameters.first ?? 0)
        case "K":
            clearCurrentLine(mode: parameters.first ?? 0)
        case "s":
            savedCursor = cursor
        case "u":
            cursor = clampedCursor(savedCursor)
        case "h":
            if sequence.contains("?1049") {
                clear(nil)
            }
        case "l":
            if sequence.contains("?1049") {
                clear(nil)
            }
        default:
            break
        }
    }

    private func csiParameters(_ sequence: String) -> [Int] {
        sequence
            .split(separator: ";", omittingEmptySubsequences: false)
            .map { Int($0.trimmingCharacters(in: CharacterSet(charactersIn: "?"))) ?? 0 }
    }

    private func countParameter(_ parameters: [Int]) -> Int {
        max(parameters.first ?? 1, 1)
    }

    private func applySGR(_ sequence: String) {
        let codes = sequence.replacingOccurrences(of: ":", with: ";")
            .split(separator: ";", omittingEmptySubsequences: false)
            .map { Int($0) ?? 0 }
        let normalizedCodes = codes.isEmpty ? [0] : codes
        var index = 0
        while index < normalizedCodes.count {
            let code = normalizedCodes[index]
            switch code {
            case 0:
                currentStyle = TerminalCell.empty
            case 1:
                currentStyle.isBold = true
                currentStyle.isDim = false
            case 2:
                currentStyle.isDim = true
            case 3:
                currentStyle.isItalic = true
            case 4:
                currentStyle.isUnderlined = true
            case 22:
                currentStyle.isBold = false
                currentStyle.isDim = false
            case 23:
                currentStyle.isItalic = false
            case 24:
                currentStyle.isUnderlined = false
            case 30...37:
                currentStyle.foregroundColor = terminalColor(index: code - 30, bright: false)
            case 38:
                if let color = extendedColor(codes: normalizedCodes, index: &index) {
                    currentStyle.foregroundColor = color
                }
            case 39:
                currentStyle.foregroundColor = TerminalTheme.foreground
            case 40...47:
                currentStyle.backgroundColor = terminalColor(index: code - 40, bright: false)
            case 48:
                if let color = extendedColor(codes: normalizedCodes, index: &index) {
                    currentStyle.backgroundColor = color
                }
            case 49:
                currentStyle.backgroundColor = TerminalTheme.terminalBackground
            case 90...97:
                currentStyle.foregroundColor = terminalColor(index: code - 90, bright: true)
            case 100...107:
                currentStyle.backgroundColor = terminalColor(index: code - 100, bright: true)
            default:
                break
            }
            index += 1
        }
    }

    private func clearDisplay(mode: Int) {
        switch mode {
        case 1:
            for row in 0...cursor.row {
                let endColumn = row == cursor.row ? cursor.column : lastSize.columns - 1
                clearRow(row, from: 0, through: endColumn)
            }
        case 2, 3:
            screenRows = Array(repeating: emptyRow(), count: lastSize.rows)
            cursor = (0, 0)
        default:
            for row in cursor.row..<lastSize.rows {
                let startColumn = row == cursor.row ? cursor.column : 0
                clearRow(row, from: startColumn, through: lastSize.columns - 1)
            }
        }
    }

    private func clearCurrentLine(mode: Int) {
        switch mode {
        case 1:
            clearRow(cursor.row, from: 0, through: cursor.column)
        case 2:
            clearRow(cursor.row, from: 0, through: lastSize.columns - 1)
        default:
            clearRow(cursor.row, from: cursor.column, through: lastSize.columns - 1)
        }
    }

    private func clearRow(_ row: Int, from startColumn: Int, through endColumn: Int) {
        guard row >= 0, row < screenRows.count else { return }
        let start = max(startColumn, 0)
        let end = min(endColumn, lastSize.columns - 1)
        guard start <= end else { return }
        for column in start...end {
            screenRows[row][column] = TerminalCell.empty
        }
    }

    private func renderScreen() {
        let output = NSMutableAttributedString()
        for rowIndex in screenRows.indices {
            appendAttributedRow(screenRows[rowIndex], to: output)
            if rowIndex < screenRows.count - 1 {
                output.append(NSAttributedString(string: "\n", attributes: TerminalCell.empty.attributes))
            }
        }
        textStorage?.setAttributedString(output)
        resizeDocumentToGrid()
    }

    private func appendAttributedRow(_ row: [TerminalCell], to output: NSMutableAttributedString) {
        var index = 0
        while index < row.count {
            let cell = row[index]
            var text = String(cell.character)
            var next = index + 1
            while next < row.count && sameStyle(row[next], cell) {
                text.append(row[next].character)
                next += 1
            }
            output.append(NSAttributedString(string: text, attributes: cell.attributes))
            index = next
        }
    }

    private func sameStyle(_ lhs: TerminalCell, _ rhs: TerminalCell) -> Bool {
        lhs.foregroundColor == rhs.foregroundColor &&
            lhs.backgroundColor == rhs.backgroundColor &&
            lhs.isBold == rhs.isBold &&
            lhs.isDim == rhs.isDim &&
            lhs.isItalic == rhs.isItalic &&
            lhs.isUnderlined == rhs.isUnderlined
    }

    private func scrollToBottom() {
        guard let clipView = enclosingScrollView?.contentView else {
            scrollToEndOfDocument(nil)
            return
        }
        let maxY = max(frame.height - clipView.bounds.height, 0)
        clipView.scroll(to: NSPoint(x: 0, y: maxY))
        enclosingScrollView?.reflectScrolledClipView(clipView)
    }

    private func resizeDocumentToGrid() {
        let font = ANSIStyleMapper.baseFont
        let cellWidth = max(font.maximumAdvancement.width, 1)
        let cellHeight = max(font.boundingRectForFont.height + 2, 1)
        let targetSize = NSSize(
            width: CGFloat(lastSize.columns) * cellWidth + textContainerInset.width * 2,
            height: CGFloat(lastSize.rows) * cellHeight + textContainerInset.height * 2
        )
        if abs(frame.width - targetSize.width) > 0.5 || abs(frame.height - targetSize.height) > 0.5 {
            setFrameSize(targetSize)
        }
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
        resizeGrid(columns: columns, rows: rows)
        renderScreen()
        session.resize(columns: columns, rows: rows)
    }

    private func resizeGrid(columns: Int, rows: Int) {
        let oldRows = screenRows
        screenRows = Array(repeating: emptyRow(columns: columns), count: rows)
        let copyRows = min(oldRows.count, rows)
        for row in 0..<copyRows {
            let copyColumns = min(oldRows[row].count, columns)
            for column in 0..<copyColumns {
                screenRows[row][column] = oldRows[row][column]
            }
        }
        cursor = clampedCursor(cursor)
        savedCursor = clampedCursor(savedCursor)
    }

    private func emptyRow(columns: Int? = nil) -> [TerminalCell] {
        Array(repeating: TerminalCell.empty, count: columns ?? lastSize.columns)
    }

    private func clampedCursor(_ value: (row: Int, column: Int)) -> (row: Int, column: Int) {
        (
            row: min(max(value.row, 0), max(lastSize.rows - 1, 0)),
            column: min(max(value.column, 0), max(lastSize.columns - 1, 0))
        )
    }

    private func terminalColor(index: Int, bright: Bool) -> NSColor {
        let normal: [NSColor] = [
            NSColor(calibratedRed: 0.00, green: 0.00, blue: 0.00, alpha: 1),
            NSColor(calibratedRed: 0.76, green: 0.15, blue: 0.13, alpha: 1),
            NSColor(calibratedRed: 0.12, green: 0.62, blue: 0.22, alpha: 1),
            NSColor(calibratedRed: 0.64, green: 0.51, blue: 0.18, alpha: 1),
            NSColor(calibratedRed: 0.22, green: 0.38, blue: 0.80, alpha: 1),
            NSColor(calibratedRed: 0.64, green: 0.23, blue: 0.68, alpha: 1),
            NSColor(calibratedRed: 0.12, green: 0.58, blue: 0.65, alpha: 1),
            TerminalTheme.foreground
        ]
        let brightColors: [NSColor] = [
            TerminalTheme.mutedForeground,
            NSColor(calibratedRed: 1.00, green: 0.33, blue: 0.29, alpha: 1),
            NSColor(calibratedRed: 0.32, green: 0.86, blue: 0.39, alpha: 1),
            NSColor(calibratedRed: 1.00, green: 0.82, blue: 0.35, alpha: 1),
            NSColor(calibratedRed: 0.39, green: 0.58, blue: 1.00, alpha: 1),
            NSColor(calibratedRed: 0.82, green: 0.46, blue: 1.00, alpha: 1),
            NSColor(calibratedRed: 0.36, green: 0.90, blue: 0.94, alpha: 1),
            NSColor(calibratedWhite: 1.00, alpha: 1)
        ]
        return (bright ? brightColors : normal)[max(0, min(index, 7))]
    }

    private func extendedColor(codes: [Int], index: inout Int) -> NSColor? {
        guard index + 1 < codes.count else { return nil }
        switch codes[index + 1] {
        case 5:
            guard index + 2 < codes.count else { return nil }
            index += 2
            return xtermColor(codes[index])
        case 2:
            guard index + 4 < codes.count else { return nil }
            let red = CGFloat(max(0, min(codes[index + 2], 255))) / 255
            let green = CGFloat(max(0, min(codes[index + 3], 255))) / 255
            let blue = CGFloat(max(0, min(codes[index + 4], 255))) / 255
            index += 4
            return NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1)
        default:
            return nil
        }
    }

    private func xtermColor(_ value: Int) -> NSColor {
        let index = max(0, min(value, 255))
        if index < 16 {
            return terminalColor(index: index % 8, bright: index >= 8)
        }
        if index < 232 {
            let color = index - 16
            return NSColor(
                calibratedRed: cubeComponent(color / 36),
                green: cubeComponent((color / 6) % 6),
                blue: cubeComponent(color % 6),
                alpha: 1
            )
        }
        return NSColor(calibratedWhite: CGFloat(8 + (index - 232) * 10) / 255, alpha: 1)
    }

    private func cubeComponent(_ value: Int) -> CGFloat {
        value == 0 ? 0 : CGFloat(55 + value * 40) / 255
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
