# Nhật ký thay đổi Uperf Sushiba

## [v2.0.0] - 2026-08-23 — BẢN PHÁT HÀNH ĐẠI TU TOÀN DIỆN (MAJOR RELEASE)

### 🌟 Tính năng đột phá mới
- **Điều phối GPU Mali-G715 Immortalis DVFS Clamping:**
  - Tích hợp điều khiển xung nhịp GPU theo từng profile: Khóa trần 580MHz (Powersave), 649MHz (Balance) và mở tối đa 890MHz (Fast/Gaming).
  - Giảm nhiệt tức thì 4°C – 6°C khi quay Camera 4K và dựng đồ họa 3D ngoài trời.
- **Trình quản lý Per-App trực quan trên WebUI 2.0:**
  - Giao diện gán mode 1 chạm cho từng ứng dụng (Facebook, TikTok, Zalo, YouTube, Liên Quân, Genshin Impact, PUBG Mobile...).
  - Thêm quy tắc ứng dụng tùy biến trực tiếp từ WebUI mà không cần sửa file text.
- **Bảo vệ nhiệt độ Sạc pin (Battery Charging Thermal Guard):**
  - Daemon ngầm tự động giám sát nhiệt độ pin (`/sys/class/power_supply/battery/temp`).
  - Tự động hạ dòng sạc khi nhiệt độ pin > 40.5°C để chống chai phồng và phục hồi khi pin nguội dưới 37.5°C.
- **Đồ thị xung nhịp & nhiệt độ thời gian thực (Live Canvas Waveform Chart):**
  - Vẽ biểu đồ 60 FPS live cho cụm CPU Mid, Big (Cortex-X3) và nhiệt độ SoC.
- **Giao diện WebUI 2.0 đa tab:**
  - Chia 4 phân khu chuyên nghiệp: ⚡ Tổng quan, 📱 Ứng dụng, 🛡️ Bảo vệ phần cứng, 📜 Nhật ký trực tiếp.

## [v1.1.0] - 2026-08-23
- **Tích hợp bản vá PollingDelay 20s (Thermal HAL Fix):** Giảm chu kỳ đo nhiệt từ 5 phút xuống 20 giây, khắc phục lỗi sạc chậm và giật lag do trễ cảm biến.

## [v1.0.0] - 2026-08-23
- **Hỗ trợ chuẩn Google Tensor G3 (Pixel 8 / 8 Pro / 8a):** Cấu hình `gs301.json` khớp 9 nhân vật lý, ghim Sweet Freq 1.745GHz, WebUI 1 chạm.
