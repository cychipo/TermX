import Foundation

final class PTYManager {
    private(set) var masterFD: Int32 = -1
    private(set) var childPID: pid_t = -1

    deinit {
        close()
    }

    func start(shellPath: String, columns: Int, rows: Int) throws {
        var fd: Int32 = -1
        var pid: pid_t = -1
        let result = termx_open_pty(&fd, &pid, shellPath, "xterm-256color", Int32(columns), Int32(rows))
        guard result == 0 else {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
        masterFD = fd
        childPID = pid
    }

    func write(_ data: Data) throws {
        guard masterFD >= 0 else { return }
        try data.withUnsafeBytes { buffer in
            guard let baseAddress = buffer.baseAddress else { return }
            let written = Darwin.write(masterFD, baseAddress, buffer.count)
            if written < 0 {
                throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
            }
        }
    }

    func readAvailable(maxBytes: Int = 4096) -> Data? {
        guard masterFD >= 0 else { return nil }
        var buffer = [UInt8](repeating: 0, count: maxBytes)
        let count = Darwin.read(masterFD, &buffer, maxBytes)
        guard count > 0 else { return nil }
        return Data(buffer.prefix(count))
    }

    func resize(columns: Int, rows: Int) throws {
        guard masterFD >= 0 else { return }
        let result = termx_resize_pty(masterFD, Int32(columns), Int32(rows))
        guard result == 0 else {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
    }

    func close() {
        if masterFD >= 0 {
            Darwin.close(masterFD)
            masterFD = -1
        }
        if childPID > 0 {
            kill(childPID, SIGHUP)
            childPID = -1
        }
    }
}
