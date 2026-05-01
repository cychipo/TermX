import Foundation

protocol ShellSessionDelegate: AnyObject {
    func shellSession(_ session: ShellSession, didReceive text: String)
    func shellSession(_ session: ShellSession, didFail error: Error)
}

final class ShellSession {
    weak var delegate: ShellSessionDelegate?

    private let pty = PTYManager()
    private let ioQueue = DispatchQueue(label: "termx.shell.io", qos: .userInitiated)
    private var isRunning = false

    var shellName: String {
        URL(fileURLWithPath: shellPath).lastPathComponent
    }

    private var shellPath: String {
        let value = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        return FileManager.default.isExecutableFile(atPath: value) ? value : "/bin/zsh"
    }

    func start(columns: Int = 100, rows: Int = 30) {
        guard !isRunning else { return }
        isRunning = true

        ioQueue.async { [weak self] in
            guard let self else { return }
            do {
                try self.pty.start(shellPath: self.shellPath, columns: columns, rows: rows)
                self.readLoop()
            } catch {
                self.isRunning = false
                DispatchQueue.main.async { self.delegate?.shellSession(self, didFail: error) }
            }
        }
    }

    func send(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        send(data)
    }

    func send(_ data: Data) {
        ioQueue.async { [weak self] in
            guard let self else { return }
            do {
                try self.pty.write(data)
            } catch {
                DispatchQueue.main.async { self.delegate?.shellSession(self, didFail: error) }
            }
        }
    }

    func resize(columns: Int, rows: Int) {
        ioQueue.async { [weak self] in
            guard let self else { return }
            do {
                try self.pty.resize(columns: columns, rows: rows)
            } catch {
                DispatchQueue.main.async { self.delegate?.shellSession(self, didFail: error) }
            }
        }
    }

    func close() {
        isRunning = false
        ioQueue.async { [pty] in
            pty.close()
        }
    }

    private func readLoop() {
        while isRunning {
            guard let data = pty.readAvailable(), !data.isEmpty else {
                isRunning = false
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
