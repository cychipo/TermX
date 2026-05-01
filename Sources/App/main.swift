import AppKit

setenv("LANG", "en_US.UTF-8", 1)
setenv("LC_CTYPE", "UTF-8", 1)
unsetenv("LC_ALL")

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
