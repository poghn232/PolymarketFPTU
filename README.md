# FPT Market (Polymarket Sinh Viên FPT) 🍬🎓

Ứng dụng Mobile dự đoán (Prediction Market) phong cách Polymarket dành riêng cho sinh viên trường Đại học FPT. Dự án được phát triển phục vụ mục đích học tập môn học, hoàn toàn phi lợi nhuận và sử dụng đơn vị tiền tệ nội bộ là **Kẹo (🍬)**.

---

## 🌟 Tính Năng Nổi Bật

### 1. Cơ Chế Dự Đoán Kẹo (Polymarket Style)
- Sử dụng **Kẹo (🍬)** thay cho tiền thật.
- Mỗi sinh viên khi tạo tài khoản mới được tặng ngay **50 Kẹo** làm vốn ban đầu.
- Dự đoán hai cửa: **CÓ (YES)** hoặc **KHÔNG (NO)**.
- Tỉ lệ phần trăm chiến thắng và tỉ lệ trả thưởng được cập nhật theo thời gian thực (Real-time Odds & Payout) dựa trên tổng số kẹo sinh viên đặt vào các cửa.
- Nếu dự đoán đúng -> nhận kẹo thưởng theo tỉ lệ pool; nếu dự đoán sai -> mất số kẹo đã cược.
- Có tính năng điểm danh nhận thêm kẹo mỗi ngày (+20 🍬) để sinh viên thoải mái test không lo hết kẹo.

### 2. Giao Diện & Màu Sắc Chuẩn FPT
- Màu sắc chủ đạo:
  - **FPT Orange (`#F37021`)**: Màu cam đặc trưng của Tập đoàn FPT & ĐH FPT.
  - **FPT Blue (`#0054A6`)**: Màu xanh nhận diện thương hiệu FPT.
  - **Navy & Slate (`#0B192C`)**: Giao diện thẻ hiện đại, tinh gọn.
  - **Yes Green (`#10B981`) & No Red (`#EF4444`)**: Phong cách màu xác suất trực quan của Polymarket.
- Logo FPT thiết kế vector với 3 dải màu nghiêng biểu tượng (Cam, Xanh lá, Xanh dương).
- Các kèo dự đoán gắn liền với đời sống campus ĐH FPT: Kỳ thi PE/FE, Cóc Vàng, Canteen, KTX Hòa Lạc/Quận 9, CLB F-Code, võ Vovinam, v.v.

### 3. Phân Hệ Quản Trị (Admin Portal)
- Đăng nhập tài khoản **Admin gốc** tích hợp sẵn trực tiếp trong mã nguồn.
- **Tạo kèo dự đoán mới**: Admin nhập tiêu đề, danh mục, cơ sở campus, số kẹo bảo chứng và ngày kết thúc.
- **Cơ chế Kẹo Bảo Chứng (Admin Liquidity Backstop)**:
  - Nếu một kèo mà **không có ai chọn bên còn lại**, Admin sẽ đóng vai trò nhà cái/đối ứng bảo chứng quỹ kẹo để sinh viên thắng vẫn được nhận đủ kẹo thưởng.
  - Ngược lại, nếu sinh viên đều đoán sai cửa, toàn bộ số kẹo sẽ chuyển về kho quỹ của Admin.
- **Chốt kết quả kèo (Resolve Market)**: Admin công bố kết quả CÓ / KHÔNG, hệ thống tự động thanh toán và chuyển kẹo đến tài khoản của các sinh viên chiến thắng ngay lập tức.
- **Tặng kẹo / Khôi phục dữ liệu mẫu**: Admin có thể tặng thêm kẹo cho sinh viên hoặc reset lại dữ liệu mẫu bất cứ lúc nào phục vụ cho việc chấm bài của giảng viên.

---

## 🔑 Tài Khoản Test Sẵn Có (Quick Login)

Bạn có thể ấn nút đăng nhập nhanh trên giao diện hoặc sử dụng thông tin đăng nhập:

| Vai Trò | Email | Mật Khẩu | Số Kẹo Ban Đầu | Ghi Chú |
| :--- | :--- | :--- | :--- | :--- |
| **Admin Gốc** | `admin@fpt.edu.vn` | `admin123` | **10,000 🍬** | Có tab Admin quản trị, tạo và chốt kèo |
| **Sinh Viên Mẫu 1** | `student@fpt.edu.vn` | `student123` | **50 🍬** | Sinh viên SE180123 (Cóc Hòa Lạc) |
| **Sinh Viên Mẫu 2** | `linh.fpt@fe.edu.vn` | `123456` | **140 🍬** | Sinh viên IA170456 (TP.HCM) |
| **Đăng ký mới** | *(Bất kỳ)* | *(Bất kỳ)* | **50 🍬** | Tự động nhận ngay 50 kẹo |

---

## 🚀 Cách Chạy Ứng Dụng

1. **Cài đặt thư viện:**
   ```bash
   flutter pub get
   ```

2. **Chạy kiểm thử:**
   ```bash
   flutter test
   ```

3. **Khởi chạy ứng dụng:**
   ```bash
   flutter run
   ```
   *(Hỗ trợ Android Emulator, thiết bị thật, Chrome Web hoặc Windows desktop)*
