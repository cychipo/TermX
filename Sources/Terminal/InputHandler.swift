import AppKit

struct InputHandler {
    static func sequence(for event: NSEvent) -> String? {
        if let special = specialSequence(for: event) {
            return special
        }
        return event.characters
    }

    private static func specialSequence(for event: NSEvent) -> String? {
        guard let scalar = event.charactersIgnoringModifiers?.unicodeScalars.first else { return nil }
        switch scalar.value {
        case UInt32(NSUpArrowFunctionKey):
            return "\u{001B}[A"
        case UInt32(NSDownArrowFunctionKey):
            return "\u{001B}[B"
        case UInt32(NSRightArrowFunctionKey):
            return "\u{001B}[C"
        case UInt32(NSLeftArrowFunctionKey):
            return "\u{001B}[D"
        case UInt32(NSDeleteFunctionKey):
            return "\u{001B}[3~"
        case UInt32(NSHomeFunctionKey):
            return "\u{001B}[H"
        case UInt32(NSEndFunctionKey):
            return "\u{001B}[F"
        case UInt32(NSPageUpFunctionKey):
            return "\u{001B}[5~"
        case UInt32(NSPageDownFunctionKey):
            return "\u{001B}[6~"
        case UInt32(NSF1FunctionKey):
            return "\u{001B}OP"
        case UInt32(NSF2FunctionKey):
            return "\u{001B}OQ"
        case UInt32(NSF3FunctionKey):
            return "\u{001B}OR"
        case UInt32(NSF4FunctionKey):
            return "\u{001B}OS"
        default:
            return nil
        }
    }
}
