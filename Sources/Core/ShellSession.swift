import Foundation

protocol ShellSessionDelegate: AnyObject {
    func shellSession(_ session: ShellSession, didReceive text: String)
    func shellSession(_ session: ShellSession, didFail error: Error)
}

final class ShellSession {
    weak var delegate: ShellSessionDelegate?

    private let pty = PTYManager()
    private let readQueue = DispatchQueue(label: "termx.shell.read", qos: .userInitiated)
    private let writeQueue = DispatchQueue(label: "termx.shell.write", qos: .userInteractive)
    private let stateLock = NSLock()
    private var running = false

    var shellName: String {
        URL(fileURLWithPath: shellPath).lastPathComponent
    }

    private var shellPath: String {
        let value = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        return FileManager.default.isExecutableFile(atPath: value) ? value : "/bin/zsh"
    }

    func start(columns: Int = 100, rows: Int = 30) {
        stateLock.lock()
        guard !running else {
            stateLock.unlock()
            return
        }
        running = true
        stateLock.unlock()

        do {
            try pty.start(shellPath: shellPath, columns: columns, rows: rows)
            readQueue.async { [weak self] in
                self?.readLoop()
            }
        } catch {
            setRunning(false)
            DispatchQueue.main.async { self.delegate?.shellSession(self, didFail: error) }
        }
    }

    func send(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        send(data)
    }

    func send(_ data: Data) {
        writeQueue.async { [weak self] in
            guard let self, self.isRunning else { return }
            do {
                try self.pty.write(data)
            } catch {
                DispatchQueue.main.async { self.delegate?.shellSession(self, didFail: error) }
            }
        }
    }

    func resize(columns: Int, rows: Int) {
        writeQueue.async { [weak self] in
            guard let self, self.isRunning else { return }
            do {
                try self.pty.resize(columns: columns, rows: rows)
            } catch {
                DispatchQueue.main.async { self.delegate?.shellSession(self, didFail: error) }
            }
        }
    }

    func close() {
        setRunning(false)
        writeQueue.async { [pty] in
            pty.close()
        }
    }

    private var isRunning: Bool {
        stateLock.lock()
        defer { stateLock.unlock() }
        return running
    }

    private func setRunning(_ value: Bool) {
        stateLock.lock()
        running = value
        stateLock.unlock()
    }

    private func readLoop() {
        while isRunning {
            guard let data = pty.readAvailable(), !data.isEmpty else {
                setRunning(false)
                break
            }
            let text = String(decoding: data, as: UTF8.self)
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.shellSession(self, didReceive: text)
            }
        }
    }
}
