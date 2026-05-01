import Foundation

struct TerminalBuffer {
    private var storage: [String]
    private var startIndex = 0
    private(set) var count = 0
    private let maxLineCount: Int

    init(maxLineCount: Int = 10_000) {
        self.maxLineCount = max(1, maxLineCount)
        self.storage = Array(repeating: "", count: self.maxLineCount)
    }

    mutating func append(_ text: String) {
        guard !text.isEmpty else { return }
        let insertIndex = (startIndex + count) % maxLineCount
        storage[insertIndex] = text
        if count == maxLineCount {
            startIndex = (startIndex + 1) % maxLineCount
        } else {
            count += 1
        }
    }

    mutating func clear() {
        storage = Array(repeating: "", count: maxLineCount)
        startIndex = 0
        count = 0
    }

    var lines: [String] {
        guard count > 0 else { return [] }
        return (0..<count).map { storage[(startIndex + $0) % maxLineCount] }
    }

    var text: String {
        lines.joined()
    }
}
