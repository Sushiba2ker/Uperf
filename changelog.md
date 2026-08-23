# Nhật ký thay đổi Uperf Sushiba

## [v1.0.0] - 2026-08-23

### 🚀 Tính năng & Tối ưu hóa mới
- **Hỗ trợ đầy đủ Google Tensor G3 (`zuma`):**
  - Khởi tạo file cấu hình chuẩn `gs301.json` khớp bảng tần số thực tế 3 cụm nhân từ ADB (4x Cortex-A510, 4x Cortex-A715, 1x Cortex-X3).
  - Tối ưu hóa bảng Energy Model và điểm ngọt tần số (**Sweet Frequency: 1.745GHz**) cho nhân Cortex-X3 nhằm triệt tiêu nhiệt độ khi sử dụng 4G/5G và chơi game.
  - Mở rộng nhận diện thiết bị trong `libsysinfo.sh` cho toàn bộ dải thiết bị Tensor G3 (`husky`, `zuma`, `shiba`, `akita`).
- **Tích hợp KernelSU WebUI:**
  - Giao diện điều khiển 1 chạm hiện đại (Dark Glassmorphism).
  - Hỗ trợ chuyển đổi tức thời 5 chế độ hiệu năng: `powersave`, `balance`, `auto`, `performance`, `fast`.
  - Giám sát xung nhịp thực tế 3 cụm CPU và nhiệt độ SoC theo thời gian thực.
  - Tích hợp trình xem nhật ký vận hành trực tiếp (`uperf_log.txt`).
- **Nâng cấp trình cài đặt:**
  - Tối ưu `setup.sh` cài đặt tự động, không yêu cầu thao tác phím cứng.
  - Hỗ trợ đầy đủ KernelSU, KernelSU-Next, Magisk và APatch.
- **Tài liệu:** Toàn bộ `README.md` được biên soạn bằng tiếng Việt chuẩn kỹ thuật.
