# CLAUDE.md

Tệp này cung cấp hướng dẫn cho Claude Code (claude.ai/code) khi làm việc với mã nguồn trong dự án TermX.

## 1. Vai trò & Trách nhiệm

Claude Code chịu trách nhiệm:

- Phân tích yêu cầu của người dùng.
- Lập kế hoạch triển khai trước khi thay đổi mã nguồn.
- Phân công tác vụ cho sub-agents khi thật sự cần thiết.
- Đảm bảo tính năng được triển khai đồng bộ, đúng đặc tả kỹ thuật và tiêu chuẩn kiến trúc.
- Ưu tiên hiệu năng, độ ổn định và khả năng bảo trì của terminal emulator native macOS.

## 2. Quy trình Làm việc Bắt buộc

Luôn đọc và tuân thủ các workflow/rule sau:

- Quy trình chính: `./.claude/rules/primary-workflow.md`
- Quy tắc phát triển: `./.claude/rules/development-rules.md`
- Giao thức điều phối: `./.claude/rules/orchestration-protocol.md`
- Quản lý tài liệu: `./.claude/rules/documentation-management.md`
- Các quy trình khác: `./.claude/rules/*`

Quy tắc bắt buộc:

- Trước khi lập kế hoạch hoặc triển khai, luôn đọc `./README.md` để nắm ngữ cảnh dự án.
- Phân tích danh mục skills và kích hoạt skill phù hợp trong quá trình xử lý.
- Tuân thủ nghiêm ngặt `./.claude/rules/development-rules.md`.
- Không mô phỏng hoặc mock implementation để thay thế code thật.
- Sau khi tạo hoặc sửa code, phải chạy lệnh build/compile phù hợp để kiểm tra lỗi biên dịch.

## 3. Nguyên tắc Thiết kế & Triển khai

Áp dụng nhất quán:

- **YAGNI:** Không xây tính năng chưa cần.
- **KISS:** Giữ giải pháp đơn giản, rõ ràng.
- **DRY:** Tránh lặp logic khi việc tách dùng lại thật sự hợp lý.
- Ưu tiên code dễ đọc, dễ kiểm chứng, dễ bảo trì.
- Không thêm abstraction, fallback, compatibility shim nếu chưa có nhu cầu thực tế.
- Cập nhật file hiện có trực tiếp; không tạo file “enhanced/new version” song song.

## 4. Quy tắc Hiệu năng cho TermX

TermX là terminal emulator native macOS, nên mọi thay đổi liên quan đến terminal core, rendering, input hoặc buffer phải ưu tiên độ trễ thấp.

### 4.1. Độ phức tạp thuật toán

Terminal phải phản hồi gần như tức thì, kể cả khi xử lý lượng log rất lớn.

- **Mục tiêu bắt buộc:** Các thao tác tra cứu trạng thái grid, cấu hình, style, cursor nên hướng tới **O(1)** bằng Hash Map, Set hoặc truy cập index trực tiếp.
- **Hạn chế nghiêm ngặt:** Tránh **O(n)** trong luồng xử lý I/O liên tục hoặc vòng render thường xuyên.
- **Cấm tuyệt đối:** Không viết logic **O(n²)**, đặc biệt trong ANSI/VT parser, reflow text hoặc render grid.

### 4.2. Dữ liệu lớn & trạng thái

- Không tạo N+1 I/O hoặc N+1 fetch trong vòng lặp.
- Gom nhóm thao tác đọc/ghi khi có thể.
- Scrollback Buffer bắt buộc dùng cấu trúc dạng **Ring Buffer/Circular Buffer** để tránh dịch chuyển mảng lớn.
- Không copy toàn bộ buffer nếu chỉ cần cập nhật một vùng nhỏ.

### 4.3. Tối ưu riêng cho Swift

- Ưu tiên `struct` và `enum` thay vì `class` cho dữ liệu terminal cell, style, cursor state và parser state.
- Chỉ dùng `class` khi cần identity, reference semantics, lifecycle hoặc AppKit subclassing.
- Dùng `reserveCapacity(_:)` cho Array/Collection có kích thước dự đoán được.
- Tránh tạo object tạm thời trong hot path như parser, renderer, keyboard input loop.

### 4.4. Render giao diện

- Không block main thread bằng parsing, ANSI decoding hoặc grid layout calculation.
- Main thread chỉ dùng cho cập nhật UI/render cuối cùng.
- Dùng dirty regions/dirty rectangles để chỉ render vùng thay đổi.
- Không redraw toàn bộ màn hình khi chỉ cursor, một dòng hoặc một cell thay đổi.

## 5. Module hóa & Tổ chức File

- Nếu file code vượt quá 200 dòng, cân nhắc tách module.
- Kiểm tra module hiện có trước khi tạo module mới.
- Mỗi module nên có một trách nhiệm rõ ràng.
- Ưu tiên composition thay vì inheritance cho logic phức tạp.
- Không module hóa quá mức với Markdown, plain text, shell script hoặc config file.

Quy tắc đặt tên:

- Swift: dùng chuẩn ngôn ngữ Swift, file/class/type dùng PascalCase khi phù hợp.
- JS/TS/Python/Shell: dùng kebab-case với tên mô tả rõ mục đích.
- Tên file phải đủ rõ để hiểu mục đích khi đọc qua danh sách file.

## 6. Kiểm thử & Chất lượng Code

- Sau khi triển khai, chạy build/compile phù hợp.
- Nếu có test suite, chạy test liên quan và sửa lỗi thật sự; không bỏ qua test fail.
- Không dùng fake data, mock, cheat hoặc workaround tạm chỉ để pass build/test.
- Ưu tiên chức năng đúng và code dễ hiểu hơn lint quá khắt khe.
- Đảm bảo không có lỗi cú pháp và code có thể biên dịch.
- Với thay đổi UI, nếu có thể, chạy app và kiểm tra luồng chính bằng giao diện thật.

## 7. Sub-agents & Điều phối

Chỉ dùng sub-agent khi task thật sự hưởng lợi từ nghiên cứu độc lập, review độc lập hoặc phạm vi rộng.

Khi dùng sub-agent, prompt phải có:

- Work context path.
- Reports path.
- Plans path.
- File cần đọc/sửa cụ thể.
- Acceptance criteria rõ ràng.

Không truyền toàn bộ lịch sử hội thoại cho sub-agent. Chỉ tóm tắt quyết định và ngữ cảnh cần thiết.

## 8. Git

- Không commit nếu người dùng chưa yêu cầu rõ ràng.
- Không commit/push thông tin bí mật như `.env`, API keys, credentials.
- Không dùng `chore` hoặc `docs` trong commit message cho thay đổi nằm trong `.claude`.
- Commit message nên sạch, chuyên nghiệp, theo conventional commit khi phù hợp.
- Không thêm tham chiếu AI trong commit message.

## 9. Tài liệu Dự án

Tài liệu kỹ thuật nằm trong `./docs`:

```text
./docs
├── INSTALL.md
├── DEV.md
├── GUIDE.md
├── GUIDE-VI.md
├── code-standards.md
└── system-architecture.md
```

Quy tắc:

- Khi thay đổi ảnh hưởng kiến trúc, cài đặt hoặc cách sử dụng, cập nhật tài liệu liên quan trong `./docs`.
- Markdown plan/report chỉ tạo trong `./plans` hoặc `./docs`, trừ khi người dùng yêu cầu rõ ràng vị trí khác.
- Không tạo tài liệu mới nếu cập nhật tài liệu hiện có là đủ.

## 10. Script Python trong Skills

Khi chạy script Python từ `.claude/skills/`, dùng Python trong virtual environment:

- macOS/Linux: `.claude/skills/.venv/bin/python3 scripts/xxx.py`
- Windows: `.claude\skills\.venv\Scripts\python.exe scripts\xxx.py`

Nếu script của skill lỗi:

- Không dừng ngay.
- Tự điều tra nguyên nhân.
- Sửa lỗi trực tiếp nếu nằm trong phạm vi an toàn.
- Chạy lại đến khi thành công hoặc báo blocker rõ ràng.

## 11. Giao thức Hook Quyền Riêng Tư

Khi tool call bị privacy-block hook chặn và output chứa marker `@@PRIVACY_PROMPT@@`, phải thực hiện đúng quy trình:

1. Phân tích JSON nằm giữa `@@PRIVACY_PROMPT_START@@` và `@@PRIVACY_PROMPT_END@@`.
2. Dùng `AskUserQuestion` với dữ liệu câu hỏi từ JSON.
3. Nếu người dùng chọn **"Yes, approve access"**, dùng `bash cat "filepath"` để đọc file.
4. Nếu người dùng chọn **"No, skip this file"**, tiếp tục mà không truy cập file đó.

## 12. Nguyên tắc Bảo mật

- Không ghi log hoặc commit secret/token/credential.
- Không thêm code có nguy cơ command injection, XSS, SQL injection hoặc các lỗi OWASP phổ biến.
- Với thao tác shell/process/PTY, luôn phân biệt rõ input người dùng, shell command và raw terminal bytes.
- Không chạy thao tác destructive hoặc ảnh hưởng shared state nếu chưa có xác nhận rõ ràng từ người dùng.

## 13. Ưu tiên của Dự án TermX

Khi có trade-off, ưu tiên theo thứ tự:

1. Đúng hành vi terminal core.
2. Độ trễ thấp và render mượt.
3. An toàn tài nguyên: CPU, RAM, energy.
4. Native macOS UX.
5. Code đơn giản, dễ bảo trì.
6. Tính năng mở rộng sau này.
