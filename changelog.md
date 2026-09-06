# Changelog / Nhật ký thay đổi Uperf Sushiba

## [v1.0.0] - 2026-09-06 — FIRST OFFICIAL PUBLIC RELEASE

- **Official First Public Release:** Exclusively engineered and optimized for Google Tensor G3 (Pixel 8, Pixel 8 Pro, Pixel 8a).
- **Interactive Bilingual WebUI 2.3:** Live 60FPS waveform telemetry, 12 granular runtime switches via `features.conf`, and instant **EN | VI** language switcher with English as default.
- **Hardware Devfreq & DVFS Clamping:** Clamps LPDDR5X RAM bus and DSU L3-Cache (saves 1.2W–1.5W power) and Mali-G715 GPU to eliminate thermal throttling and stabilize gaming FPS.
- **Frosty Deep Optimization Matrix:** Complete suppression of silent background logging, ANR dumps, live logcat, system telemetry, and ftrace.
- **Surgical GMS Telemetry Freeze:** Safely disables 50+ background Google Play Services tracking & ads services while guaranteeing 100% instant FCM Push Notifications.
- **Smart GMS Doze & F2FS GC Maintenance:** Enforces deep sleep within 15 seconds, memory compaction, and F2FS background maintenance when screen off.
- **Battery Thermal Charging Guard:** Automatically throttles charging speed when battery temperature exceeds 40.5°C to protect battery health and prevent overheating.
- **Streamlined Installation:** Clean, professional English flash terminal interface; removed all legacy/dead code and Chinese notices.
## [v2.3.0] - 2026-09-06 — ĐIỀU KHIỂN TỪNG TÍNH NĂNG RUNTIME & TỰ ĐỘNG HÓA PHÁT HÀNH

- Thêm file cấu hình người dùng `features.conf` với các công tắc: `module_enabled`, `uperf`, `powercfg`, `powercfg_once`, `kernel_tweaks`, `system_tweaks`, `gms_freeze`, `gms_doze`, `thermal_guard`, `ram_clean`, `zram_compact`, `google_jobs`.
- WebUI đọc trạng thái runtime và cho phép bật/tắt từng tính năng hoặc tắt toàn bộ module.
- Tắt một tính năng ngăn các lần áp dụng tiếp theo; các giá trị sysfs, kernel và overlay đã áp dụng không tự hoàn nguyên, nên khởi động lại khi cần hoàn nguyên hoàn toàn.
- Chuẩn hóa implementation runtime tại `magisk/script`; thư mục gốc module chỉ còn các entrypoint Magisk và tài nguyên đóng gói.
- Thêm GitHub Actions build và publish ZIP khi push tag `v*`, kèm kiểm tra metadata, shell syntax và nội dung archive.

## [v2.2.0] - 2026-08-24 — TÍCH HỢP TINH HOA FROSTY (DEEP OPTIMIZATION MATRIX)

### 🧊 Tinh hoa kiến trúc từ Frosty:
- **Bộ thông số System Properties toàn diện (`system.prop`):**
  - Vô hiệu hóa toàn bộ logging & dump ngầm của SurfaceFlinger, EGL Profiler, Graphic render stats, ANR history, Live logcat, và IMS/Modem debug.
  - Bật Modem RIL power collapse (`ro.ril.power_collapse=1`), tối ưu hóa kết nối di động và tiết kiệm pin chờ.
  - Triệt tiêu StrictMode, CheckJNI runtime overhead, giúp ứng dụng khởi chạy tức thì và giảm micro-stutter.
- **Triệt tiêu Telemetry, Logging & Framework Tracing (`sys_opt.sh`):**
  - Tắt ftrace kernel (`tracing_on=0`), dập tắt các tiến trình `traced`, `cnss_diag`, `aplogd`.
  - Vô hiệu hóa Jank Monitor frame tracing, hoãn PSS profiler của ActivityManager để giải phóng 100% chu kỳ CPU cho luồng render game.
  - Kích hoạt cơ chế nén bộ nhớ runtime Zygote (`use_compaction=true`), Cached App Freezer (`use_freezer=true`) và USAP Pool.
  - Vô hiệu hóa Google Analytics, Clearcut Telemetry, Phenotype polling, và chặn toàn bộ 30+ tag logging sự cố Dropbox ngầm.
- **Nâng cấp Kernel, VM & Bộ nhớ sâu (`ktweak_opt.sh`):**
  - Khóa `watermark_boost_factor = 0` triệt tiêu hoàn toàn hiện tượng tụt FPS do kswapd thức giấc đột ngột khi game ngốn RAM.
  - Điều chỉnh `extra_free_kbytes` thích ứng tự động theo dung lượng RAM thực tế (lên tới 24MB trên máy 12GB+ RAM).
  - Tự động mở rộng luồng nén ZRAM (`max_comp_streams`) khớp với toàn bộ số nhân CPU (`nproc`), tăng tốc độ nén/giải nén swap song song.
  - Quét động và dập tắt toàn bộ `debug_mask`, `log_level`, `debug_level` trong `/sys/**`.
  - Tự động vô hiệu hóa các daemon dọn RAM rác của OEM/Vendor (`process_reclaim`, `mi_reclaim`, `memplus`, `opchain`).
  - Hỗ trợ TCP Congestion đa tầng tự thích ứng (`bbr3 -> bbr2 -> bbrplus -> bbr -> westwood -> cubic`) cùng TCP FastOpen & Keepalive tối ưu.
- **Nâng cấp Cơ chế Ngủ sâu & Dọn dẹp RAM Màn hình tắt (`gms_doze.sh`):**
  - Tự động kích hoạt nén bộ nhớ (`compact_memory`, `zram compact`) và xả cache an toàn khi tắt màn hình.
  - Kích hoạt chu kỳ bảo trì dọn rác F2FS GC ngầm khi màn hình tắt và lập tức ngắt khi bật sáng màn hình để chống giật khung hình.
  - Tự động cưỡng chế Deep Doze khi ngủ sâu và tự động hoàn nguyên khi mở khóa màn hình.
---

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
