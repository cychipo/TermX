import AppKit

struct InputHandler {
    static func sequence(for command: Selector) -> String? {
        switch command {
        case #selector(NSResponder.insertNewline(_:)),
             #selector(NSResponder.insertLineBreak(_:)),
             #selector(NSResponder.insertParagraphSeparator(_:)):
            return "\r"
        case #selector(NSResponder.insertTab(_:)),
             #selector(NSResponder.insertBacktab(_:)):
            return "\t"
        case #selector(NSResponder.deleteBackward(_:)),
             #selector(NSResponder.deleteWordBackward(_:)),
             #selector(NSResponder.deleteToBeginningOfLine(_:)):
            return "\u{7F}"
        case #selector(NSResponder.deleteForward(_:)),
             #selector(NSResponder.deleteWordForward(_:)),
             #selector(NSResponder.deleteToEndOfLine(_:)):
            return "\u{001B}[3~"
        case #selector(NSResponder.moveUp(_:)),
             #selector(NSResponder.moveBackwardAndModifySelection(_:)):
            return "\u{001B}[A"
        case #selector(NSResponder.moveDown(_:)),
             #selector(NSResponder.moveForwardAndModifySelection(_:)):
            return "\u{001B}[B"
        case #selector(NSResponder.moveRight(_:)),
             #selector(NSResponder.moveWordRight(_:)),
             #selector(NSResponder.moveForward(_:)):
            return "\u{001B}[C"
        case #selector(NSResponder.moveLeft(_:)),
             #selector(NSResponder.moveWordLeft(_:)),
             #selector(NSResponder.moveBackward(_:)):
            return "\u{001B}[D"
        case #selector(NSResponder.moveToBeginningOfLine(_:)),
             #selector(NSResponder.moveToLeftEndOfLine(_:)):
            return "\u{001B}[H"
        case #selector(NSResponder.moveToEndOfLine(_:)),
             #selector(NSResponder.moveToRightEndOfLine(_:)):
            return "\u{001B}[F"
        case #selector(NSResponder.scrollPageUp(_:)):
            return "\u{001B}[5~"
        case #selector(NSResponder.scrollPageDown(_:)):
            return "\u{001B}[6~"
        case #selector(NSResponder.cancelOperation(_:)):
            return "\u{3}"
        default:
            return nil
        }
    }
}
