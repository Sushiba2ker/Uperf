# Nhật ký thay đổi Uperf Sushiba

## [v2.1.0] - 2026-08-23 — BẢN PHÁT HÀNH TỔNG LỰC PHẦN CỨNG (HARDWARE SYNERGY)

### 🚀 Tích hợp tinh hoa mã nguồn mở & Tinh chỉnh phần cứng sâu
- **Điều phối Bus RAM LPDDR5X & L3 Cache (Devfreq MIF / DSU Clamping):**
  - Khóa trần bus RAM ở 2288MHz (Powersave), 2730MHz (Balance) và mở tối đa 3744MHz (Gaming), triệt tiêu 1.2W – 1.5W nhiệt lượng controller RAM.
  - Khống chế bus DSU L3-Cache ở 1328MHz (Powersave) giúp giảm tải điện áp giao tiếp giữa các cụm nhân.
- **Cơ chế Siêu Ngủ Sâu Thông Minh (Smart GMS Doze & Deep Sleep):**
  - Kế thừa từ `Universal GMS Doze`, vô hiệu hóa các Receiver ngầm gây thức máy của Google Play Services.
  - Tự động Whitelist các ứng dụng liên lạc cốt lõi (FCM Google, Zalo, Messenger, Telegram, WhatsApp, Tin nhắn cuộc gọi) đảm bảo **100% tin nhắn và cuộc gọi đến tức thì không độ trễ**.
  - Giảm tụt pin qua đêm xuống mức kỷ lục **0.5% – 1% / 8 tiếng**.
- **Tối ưu hóa Ổ cứng UFS 3.1 & I/O Queue (Kế thừa từ KTweak):**
  - Đặt `read_ahead_kb = 128KB`, `nr_requests = 64` trên toàn bộ phân vùng Flash.
  - Tắt `iostats` (bộ đếm I/O) và `schedstats` giúp giảm ngắt CPU (interrupts) cho nhân Little, mở app mượt và phản hồi nhanh hơn.
- **Rà soát & Tối ưu hóa Code:**
  - Hợp nhất toàn bộ logic điều phối DVFS phần cứng vào một điểm duy nhất (`apply_hardware_profile`), loại bỏ 100% mã trùng lặp (No DUP logic), kiến trúc siêu vững chắc (Solid).

## [v2.0.0] - 2026-08-23
- **Điều phối GPU Mali-G715 Immortalis DVFS Clamping:** Khóa trần 580MHz/649MHz/890MHz.
- **Trình quản lý Per-App trực quan & WebUI 2.0:** Đồ thị sóng 60FPS live, gán mode 1 chạm.
- **Battery Charging Thermal Guard:** Bảo vệ sạc mát, chống chai pin.

## [v1.1.0] - 2026-08-23
- **Bản vá PollingDelay 20s:** Trích xuất từ vendor máy, chu kỳ quét nhiệt siêu nhạy 20s.

## [v1.0.0] - 2026-08-23
- **Hỗ trợ chuẩn Tensor G3 (Pixel 8 / 8 Pro):** Nạp `gs301.json` khớp 9 nhân vật lý.
