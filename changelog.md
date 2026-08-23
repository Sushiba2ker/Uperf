# Nhật ký thay đổi Uperf Sushiba

## [v1.1.0] - 2026-08-23

### 🔥 Nâng cấp bản vá PollingDelay Fast Thermal Response (Reddit mod)
- **Tích hợp bản vá `thermal_info_config.json` & `thermal_info_config_charge.json` chuẩn 100% trích xuất từ chính thiết bị Pixel 8 Pro:**
  - Giảm chu kỳ `PollingDelay` từ `300,000ms` (5 phút) và `60,000ms` (1 phút) xuống **`20,000ms` (20 giây)**.
  - Khắc phục triệt để lỗi sạc chậm (slow charging) và độ trễ nhận diện quá nhiệt của Thermal HAL trên Pixel 8 Pro.
  - Overlay mount trực tiếp qua KernelSU / Magisk (`system/vendor/etc`), đảm bảo 0% nguy cơ bootloop.

## [v1.0.0] - 2026-08-23

### 🚀 Tính năng & Tối ưu hóa mới
- **Hỗ trợ đầy đủ Google Tensor G3 (`zuma`):**
  - Khởi tạo file cấu hình chuẩn `gs301.json` khớp bảng tần số thực tế 3 cụm nhân từ ADB (4x Cortex-A510, 4x Cortex-A715, 1x Cortex-X3).
  - Tối ưu hóa bảng Energy Model và điểm ngọt tần số (**Sweet Frequency: 1.745GHz**) cho nhân Cortex-X3.
  - Mở rộng nhận diện thiết bị trong `libsysinfo.sh` cho toàn bộ dải thiết bị Tensor G3 (`husky`, `zuma`, `shiba`, `akita`).
- **Tích hợp KernelSU WebUI:**
  - Giao diện điều khiển 1 chạm hiện đại (Dark Glassmorphism).
  - Chuyển đổi tức thời 5 chế độ: `powersave`, `balance`, `auto`, `performance`, `fast`.
  - Giám sát xung nhịp thực tế 3 cụm CPU và nhiệt độ phần cứng theo thời gian thực.
  - Trình xem nhật ký vận hành trực tiếp (`uperf_log.txt`).
- **Nâng cấp trình cài đặt:**
  - Tối ưu `setup.sh` cài đặt tự động 100%.
