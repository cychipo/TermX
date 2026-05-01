# 🚀 Dự Án: TermX - Native macOS Terminal

> A lightning-fast, lightweight, and truly native macOS terminal emulator written in Swift.

**TermX** là một trình giả lập terminal được thiết kế tinh gọn dành riêng cho macOS. Được xây dựng hoàn toàn bằng Swift và tận dụng tối đa các API gốc của Apple (AppKit/SwiftUI), TermX mang lại trải nghiệm gõ lệnh mượt mà, khởi động tức thì và sử dụng cực kỳ ít RAM cũng như năng lượng so với các terminal đa nền tảng. 

Mục tiêu của dự án là cung cấp một không gian làm việc ổn định, nhanh chóng và hòa hợp tuyệt đối với ngôn ngữ thiết kế của hệ điều hành.

## ✨ Tính năng nổi bật
*   🍏 **100% Native macOS:** Tối ưu hóa bộ nhớ, hỗ trợ Native Tabs và cực kỳ thân thiện với thời lượng pin (Battery-friendly).
*   ⚡ **Khởi động tức thì:** Không có độ trễ khi mở cửa sổ hoặc session mới.
*   🎨 **Giao diện hiện đại:** Hỗ trợ hiệu ứng làm mờ xuyên thấu (Vibrancy) nguyên bản của macOS.
*   🛠 **Tập trung cốt lõi:** Hỗ trợ đầy đủ ANSI escape codes, True Color và các thao tác I/O chuẩn xác.

---

## 🛠 Tech Stack
*   **Ngôn ngữ cốt lõi:** Swift.
*   **Giao diện (UI Framework):** AppKit (đảm bảo hiệu năng render text tối đa) và SwiftUI (cho các thành phần cài đặt, menu).
*   **Terminal Backend:** Sử dụng `Process` và `Pipe` của Swift Foundation để thiết lập giao tiếp PTY (Pseudoterminal).

---

## 📋 Danh sách User Stories

### Epic 1: Giao tiếp Terminal Cốt Lõi (Core I/O)
*Mục tiêu: Đảm bảo khả năng chạy shell và thực thi lệnh cơ bản với độ trễ bằng không.*

*   **Tính năng 1.1: Kết nối Shell macOS**
    *   **Là một** người dùng, **tôi muốn** TermX tự động khởi chạy shell mặc định của máy (ví dụ: `zsh` hoặc `bash`) khi mở, **để** tôi có thể bắt đầu làm việc ngay lập tức.
*   **Tính năng 1.2: Xử lý Luồng Dữ liệu (I/O)**
    *   **Là một** lập trình viên, **tôi muốn** các phím tôi gõ được gửi chính xác đến shell và kết quả trả về hiển thị ngay lập tức, **để** có trải nghiệm tương tác dòng lệnh mượt mà.
*   **Tính năng 1.3: Hỗ trợ ANSI Escape Codes & True Color**
    *   **Là một** người dùng, **tôi muốn** terminal đọc đúng các mã màu ANSI, **để** các text output (như log, git status) được tô màu chính xác và dễ đọc.

### Epic 2: Tương tác Màn hình (Screen & Keyboard)
*Mục tiêu: Cung cấp các thao tác chuẩn mực và quen thuộc của một công cụ nhập liệu.*

*   **Tính năng 2.1: Quản lý Con trỏ (Cursor Control)**
    *   **Là một** lập trình viên, **tôi muốn** dấu nháy (cursor) di chuyển chính xác khi tôi dùng phím mũi tên, xóa chữ, hoặc nhảy từ, **để** dễ dàng chỉnh sửa các đoạn script dài.
*   **Tính năng 2.2: Bộ đệm cuộn (Scrollback Buffer)**
    *   **Là một** người dùng, **tôi muốn** cuộn chuột lên để xem lại các dòng log cũ đã bị trôi khỏi màn hình, **để** không bỏ lỡ các thông tin quan trọng.
*   **Tính năng 2.3: Resize & Reflow**
    *   **Là một** người dùng, **tôi muốn** text tự động ngắt dòng và căn chỉnh lại khi tôi thay đổi kích thước cửa sổ ứng dụng, **để** giao diện không bao giờ bị vỡ.

### Epic 3: Trải nghiệm macOS (UI/UX)
*Mục tiêu: Đem lại cảm giác native, hòa hợp tuyệt đối với hệ sinh thái Apple.*

*   **Tính năng 3.1: Hỗ trợ Tab & Split gốc**
    *   **Là một** người dùng Mac, **tôi muốn** mở nhiều tab bằng phím tắt `Cmd + T` thông qua hệ thống quản lý tab gốc của macOS, **để** quản lý nhiều session một cách gọn gàng.
*   **Tính năng 3.2: Hiệu ứng Nền (Vibrancy)**
    *   **Là một** người yêu cái đẹp, **tôi muốn** cửa sổ TermX có hiệu ứng làm mờ xuyên thấu (Blur/Translucency) theo chuẩn giao diện macOS, **để** không gian làm việc trông hiện đại hơn.
*   **Tính năng 3.3: Tùy chỉnh Cơ bản (Settings)**
    *   **Là một** lập trình viên, **tôi muốn** có một giao diện cài đặt đơn giản để thay đổi font chữ, cỡ chữ và bảng màu (theme), **để** tùy biến theo sở thích cá nhân.