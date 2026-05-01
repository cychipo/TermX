# TermX

TermX là terminal emulator native cho macOS, viết bằng Swift và AppKit. Mục tiêu của dự án là tạo terminal nhẹ, khởi động nhanh, render mượt và hòa hợp với trải nghiệm macOS.

## Mục tiêu

- Native macOS app, không phụ thuộc framework đa nền tảng.
- Khởi động nhanh, độ trễ input thấp.
- Hỗ trợ shell mặc định của người dùng như `zsh` hoặc `bash`.
- Hỗ trợ PTY, ANSI escape codes, scrollback và tab workflow.
- Tối ưu CPU, RAM và năng lượng.

## Tech Stack

| Thành phần | Công nghệ |
|-----------|-----------|
| Language | Swift 5.9+ |
| UI | AppKit |
| Terminal backend | `forkpty` qua C bridge |
| Build project | XcodeGen |
| Native C bridge | CMake / C |
| Target | macOS 13.0+ |

## Cấu trúc Dự án

```text
TermX/
├── Sources/
│   ├── App/        App lifecycle, window, tab
│   ├── Core/       PTY, shell session, terminal buffer
│   ├── Terminal/   Rendering, ANSI handling, input mapping
│   ├── UI/         AppKit wrappers
│   └── Utils/      Shared utilities
├── Resources/      Info.plist, entitlements, assets
├── libvtutil/      C bridge for PTY operations
├── docs/           Developer documentation
├── plans/          Implementation plans
├── project.yml     XcodeGen config
└── CMakeLists.txt  C bridge build config
```

## Yêu cầu

- macOS 13.0+
- Xcode 15+
- XcodeGen 2.40+

Cài XcodeGen nếu chưa có:

```bash
brew install xcodegen
```

## Lệnh Dev Nhanh

Generate Xcode project:

```bash
make generate
```

Build app:

```bash
make build
```

Build rồi mở app:

```bash
make dev
```

Build rồi chạy binary trực tiếp để xem log trong terminal:

```bash
make run
```

Mở app đã build sẵn, không build lại:

```bash
make open
```

Restart app đã build sẵn, không build lại:

```bash
make rerun
```

Dọn build output:

```bash
make clean
```

## Lệnh Thủ công

Nếu không muốn dùng `make`, có thể chạy trực tiếp:

```bash
xcodegen generate --spec project.yml
xcodebuild \
  -project TermX.xcodeproj \
  -scheme TermX \
  -configuration Debug \
  -derivedDataPath .derived-data \
  build
open .derived-data/Build/Products/Debug/TermX.app
```

## Tình trạng Hiện tại

Đã có foundation ban đầu:

- XcodeGen project config.
- AppKit app lifecycle.
- Main window và native tab controller.
- PTY bridge qua `forkpty`.
- Shell session đọc/ghi dữ liệu thật.
- NSTextView terminal view tối thiểu.
- Keyboard mapping cơ bản cho arrow keys, Home/End, Page Up/Down, F1-F4.

Giới hạn hiện tại:

- ANSI escape sequences hiện được strip để hiển thị text sạch, chưa preserve màu/style.
- Scrollback buffer hiện là implementation đơn giản, cần nâng cấp sang ring buffer đúng nghĩa.
- Chưa có test suite tự động.

## Roadmap Gần

1. Implement ANSI parser giữ style spans: color, bold, underline, true color.
2. Thay scrollback bằng circular/ring buffer O(1).
3. Dirty-region rendering để tránh redraw toàn màn hình.
4. Resize/reflow theo PTY size.
5. Preferences UI cho font size, theme và shell path.

## Tài liệu

- [Development Guide](docs/DEV.md)
- [User Stories](user_stories.md)
- [Implementation Plan](plans/260501-1024-setup-termx-codebase/plan.md)

## Nguyên tắc Phát triển

- Ưu tiên độ đúng của terminal core.
- Không block main thread bằng parsing hoặc I/O.
- Hot path phải tránh O(n²) và object allocation không cần thiết.
- Dùng `struct`/`enum` cho dữ liệu terminal khi có thể.
- Chỉ dùng `class` khi cần identity, lifecycle hoặc AppKit subclassing.
