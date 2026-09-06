# Uperf Sushiba

Bộ điều phối hiệu năng và tối ưu năng lượng tầng Userspace cho Android, thiết kế chuyên sâu và độc quyền cho nền tảng **Google Tensor G3** (Pixel 8, Pixel 8 Pro, Pixel 8a). Tác giả: **Sushiba**.

---

## 🌟 Tính năng chính

- **Độc quyền cho Google Tensor G3 (Pixel 8 Series):** Tối ưu hóa chuẩn xác cho kiến trúc 9 nhân CPU vật lý (4x Cortex-A510, 4x Cortex-A715, 1x Cortex-X3), GPU Mali-G715 Immortalis và cụm bus phần cứng Tensor G3.
- **Điều phối Bus RAM LPDDR5X & DSU L3-Cache:** Khống chế tần số bus MIF và DSU thích ứng theo từng profile, triệt tiêu 1.2W – 1.5W nhiệt lượng hao phí vô ích.
- **Mali-G715 GPU DVFS Clamping:** Khóa trần tần số GPU theo từng mức tải, ngăn hiện tượng nhảy xung cực đại gây nóng máy và sụt FPS đột ngột (thermal throttling).
- **Tinh hoa kiến trúc Frosty (Deep Optimization Matrix):** Vô hiệu hóa toàn diện logging, dump ngầm (SurfaceFlinger, ANR history, Live logcat), dập tắt kernel ftrace (`tracing_on=0`) và các telemetry ngầm của hệ thống.
- **Đóng băng chọn lọc GMS (Surgical GMS Freeze):** Vô hiệu hóa triệt để hơn 50+ service quảng cáo, đo lường và theo dõi ngầm của Google Play Services mà vẫn đảm bảo **100% FCM Push Notifications không bị trễ**.
- **Ngủ sâu thông minh & Dọn rác bộ nhớ (Smart GMS Doze & F2FS GC):** Tự động cưỡng chế Deep Doze, nén bộ nhớ (`compact_memory`, `zram compact`) và kích hoạt chu kỳ dọn rác F2FS GC khi tắt màn hình; hoàn nguyên tức thì khi mở khóa màn hình.
- **Bảo vệ sạc mát (Battery Thermal Charging Guard):** Tự động hạ dòng sạc khi pin vượt ngưỡng nhiệt an toàn (~40.5°C) và tự phục hồi khi nhiệt độ giảm, bảo vệ pin mà không ngắt dòng sạc hoàn toàn.
- **Điều khiển tính năng runtime độc lập (WebUI 2.3 & `features.conf`):** Quản lý 12 công tắc tính năng độc lập qua WebUI KernelSU / WebUI Magisk hoặc dòng lệnh `feature_ctl.sh`, lưu trữ bền vững qua các lần cập nhật module.
- **Điều phối theo điểm ngọt năng lượng (Sweet Frequency):** Giữ xung nhịp CPU trong vùng có tỉ số Hiệu năng/Điện năng ($\frac{\text{Perf}}{\text{Watt}}$) tối ưu nhất.
- **Phân tích khung hình trễ qua `SfAnalysis`:** Hook trực tiếp vào `SurfaceFlinger` để bắt khung hình trễ (`SfLag`), chỉ tăng xung khi cần thiết và lập tức hạ xung sau khi hoàn tất render.
- **Tối ưu luồng giao diện (UI Affinity) & Bắt tín hiệu cảm ứng:** Ghim luồng render quan trọng vào cụm Mid/Big Core, lắng nghe sự kiện từ `/dev/input` để phản hồi tức thì mà không cần boost xung mù quáng.
- **Hỗ trợ rộng rãi:** Hoạt động tốt trên Android 14 / Android 15, tương thích hoàn toàn với **KernelSU**, **Magisk** và **APatch** (không cần tắt SELinux).
---

## 📥 Tải về & Cài đặt

### Cách 1: Cài đặt qua KernelSU / Magisk / APatch (Khuyên dùng)
1. Tải file module zip từ mục [Releases](https://github.com/Sushiba2ker/Uperf/releases).
2. Mở trình quản lý **KernelSU Manager / Magisk / APatch** -> Chọn **Install from storage**.
3. Chọn file zip và tiến hành flash.
4. Khởi động lại thiết bị.
5. Sau khi khởi động, kiểm tra log hoạt động tại `/sdcard/Android/yc/uperf/uperf_log.txt` hoặc `/data/powercfg.log`.

### Cách 2: Cài đặt thủ công (Không qua Module Manager)
1. Thiết bị đã có quyền Root.
2. Giải nén module vào thư mục `/data/uperf`.
3. Cấp quyền thực thi:
   ```bash
   chmod 755 /data/uperf/service.sh /data/uperf/script/*.sh
   ```
4. Khởi tạo cấu hình và chạy module:
   ```bash
   sh /data/uperf/script/setup.sh
   sh /data/uperf/script/initsvc.sh
   ```

## Điều khiển tính năng runtime
WebUI cho phép bật/tắt từng tính năng. Cấu hình được lưu tại `/sdcard/Android/yc/uperf/features.conf` và được giữ lại khi cập nhật module.

Các khóa runtime gồm: `module_enabled`, `uperf`, `powercfg`, `powercfg_once`, `kernel_tweaks`, `system_tweaks`, `gms_freeze`, `gms_doze`, `thermal_guard`, `ram_clean`, `zram_compact`, `google_jobs`.

Ví dụ bật/tắt bằng ADB hoặc Termux:
```bash
su -c "sh /data/adb/modules/uperf/script/feature_ctl.sh status"
su -c "sh /data/adb/modules/uperf/script/feature_ctl.sh set thermal_guard 0"
su -c "sh /data/adb/modules/uperf/script/feature_ctl.sh set thermal_guard 1"
```

Tắt `thermal_guard` chỉ tắt giới hạn dòng sạc theo nhiệt độ; không tắt việc sạc. Các giá trị sysfs, kernel và overlay đã áp dụng cần khởi động lại để hoàn nguyên hoàn toàn.

Workflow release yêu cầu tag khớp với version trong `magisk/module.prop`: `version=2.3.0` dùng tag `v2.3.0`.

---

## ⚡ Các chế độ hiệu năng (Performance Modes)

### 1. Thay đổi chế độ mặc định khi khởi động
Mở file `/sdcard/Android/yc/uperf/cur_powermode.txt` (hoặc `/data/cur_powermode.txt`) và điền tên chế độ mong muốn:

| Chế độ | Đặc tính hoạt động | Phù hợp cho |
| :--- | :--- | :--- |
| `auto` | Tự động thích ứng thông minh theo từng ứng dụng | Sử dụng hỗn hợp hàng ngày |
| `balance` | Cân bằng: Mượt mà, mát mẻ, tiết kiệm điện hơn cấu hình gốc của hãng | Sử dụng đa tác vụ, lướt web, MXH |
| `powersave` | Tiết kiệm pin tối đa: Ghim xung ở vùng `sweetFreq`, triệt tiêu nhiệt ngoài trời | Dùng 4G/5G, môi trường nóng, pin yếu |
| `performance` | Ưu tiên độ mượt: Giữ xung nhịp phản hồi nhanh, chấp nhận tiêu hao thêm pin | Tác vụ nặng, đa nhiệm liên tục |
| `fast` | Hiệu năng cao: Phản hồi xung cực nhanh, phù hợp chơi game tải nặng | Gaming nặng, giả lập |

### 2. Chuyển đổi nhanh chế độ qua dòng lệnh
Chạy lệnh trực tiếp qua Termux hoặc ADB Shell (yêu cầu root):
```bash
su -c "sh /data/powercfg.sh balance"
# Hoặc chuyển sang chế độ siêu mát:
su -c "sh /data/powercfg.sh powersave"
```

---

## 📊 So sánh các giải pháp điều phối hiệu năng

| Tính năng | Project WIPE | Perfd-opt (CAF) | libperfmgr (Google) | Uperf Game Turbo |
| :--- | :---: | :---: | :---: | :---: |
| **HMP + interactive** | ✔️ | ❌ | ❌ | ✔️ |
| **EAS + schedutil** | ❌ | ✔️ | ✔️ | ✔️ |
| **Tối ưu chuyên sâu Tensor G3 (Pixel 8 Series)** | ✔️ | ❌ | Một phần | ✔️ |
| **Ghim CPU Affinity cho UI Thread** | ❌ | ❌ | ❌ | ✔️ |
| **Bắt sự kiện cảm ứng Linux cấp thấp** | ❌ | ❌ | ✔️ | ✔️ |
| **Hook SurfaceFlinger (`SfAnalysis`)** | ❌ | ❌ | ❌ | ✔️ |
| **Tối ưu năng lượng khi tắt màn hình** | ❌ | ❌ | ❌ | ✔️ |
| **Nhiều profile hiệu năng linh hoạt** | ✔️ | ✔️ | ❌ | ✔️ |

---

## 🧠 Cơ chế hoạt động chi tiết

### 1. Nhận diện thao tác cảm ứng (`Input Monitor`)
Lắng nghe trực tiếp luồng tín hiệu từ thiết bị tại `/dev/input`. Dựa trên chuỗi tọa độ và vận tốc nhả ngón tay, Uperf phân biệt chính xác thao tác **Click (Tap)**, **Nhấn giữ (Pressed)** hay **Cuộn lướt (Swipe)** để cấp mức xung phù hợp với thời gian cuộn dự tính của ứng dụng.

### 2. Quản lý tải nặng tức thời & ngắt sớm (`HeavyLoad Management`)
Khi ứng dụng khởi động hoặc tải dữ liệu nặng, Uperf chủ động lấy mẫu tải toàn hệ thống:
$$\text{System Load} = \sum \left( \text{Efficiency}_i \times \frac{\text{Load}_i}{100} \times \frac{\text{Freq}_i}{1000} \right)$$
Nếu tải vượt ngưỡng `heavyLoad`, Uperf kích hoạt profile tăng tốc tức thời. Ngay khi ứng dụng hoàn tất quá trình tải, Uperf lập tức ngắt trạng thái tải nặng sớm hơn nhiều so với cơ chế boost mặc định của Google/Qualcomm (vốn thường kéo dài 2-3 giây gây nóng máy).

### 3. Hook luồng dựng hình `SfAnalysis`
Một module độc lập được nạp vào tiến trình `SurfaceFlinger` nhằm theo dõi sát sao chu kỳ xuất khung hình:
- Bắt sự kiện bắt đầu render, trễ khung hình (`SfLag`) và hoàn tất render.
- Thích ứng động với tần số quét màn hình (Dynamic Refresh Rate / Variable Vsync).
- Hoạt động an toàn trong ranh giới quyền của SELinux.

---

## 🛠️ Cấu hình Tensor G3 (`uperf.json`)

Module sử dụng file cấu hình Energy Model tối ưu hóa chuẩn xác cho kiến trúc 9 nhân của Google Tensor G3 tại `config/gs301.json` (tự động nạp vào `/sdcard/Android/yc/uperf/uperf.json` khi cài đặt).
### Ví dụ cấu hình Energy Model (Tensor G3):
```json
"cpu": {
  "enable": true,
  "powerModel": [
    {
      "efficiency": 120,
      "nr": 4,
      "typicalFreq": 1.704,
      "sweetFreq": 1.328,
      "plainFreq": 0.955,
      "freeFreq": 0.610
    },
    {
      "efficiency": 300,
      "nr": 4,
      "typicalFreq": 2.367,
      "sweetFreq": 1.572,
      "plainFreq": 1.065,
      "freeFreq": 0.712
    },
    {
      "efficiency": 450,
      "nr": 1,
      "typicalFreq": 2.914,
      "sweetFreq": 1.745,
      "plainFreq": 1.164,
      "freeFreq": 0.880
    }
  ]
}
```

---

## ❓ Câu hỏi thường gặp (FAQ)

**Q: Module này có làm hao pin ở chế độ chờ không?**  
A: Hoàn toàn không. Uperf chạy Native C/C++ tiêu tốn tài nguyên cực thấp (<0.1% CPU). Khi tắt màn hình, module tự động chuyển sang chế độ ngủ sâu (`standby`), giảm số nhân hoạt động và ghim xung tối thiểu.

**Q: Tại sao dùng Uperf máy vẫn có thể ấm khi chơi game nặng?**  
A: Khi chơi game 3D nặng liên tục, GPU và CPU đều phải làm việc ở công suất cao. Uperf giúp tối ưu để chip chạy ở tần số hiệu quả nhất thay vì nhảy loạn xạ, nhưng không thể vô hiệu hóa quy luật vật lý về tỏa nhiệt. Để giảm nhiệt tối đa khi chơi game, hãy chuyển sang chế độ `balance` hoặc `powersave`.

**Q: Có cần tắt tính năng kiểm soát nhiệt (Thermal Engine) của hệ thống không?**  
A: **Không nên tắt**. Thermal Engine là cơ chế an toàn phần cứng của nhà sản xuất. Uperf tối ưu hiệu năng và giữ mát bằng cách điều phối xung nhịp thông minh trước khi máy bị nóng, chứ không can thiệp phá vỡ giới hạn nhiệt an toàn của pin và chip.

---

## 🤝 Lời cảm ơn & Tham chiếu (Credits)

- Tác giả gốc: **Matt Yang (@yc9559)** - [Project Uperf](https://github.com/yc9559/uperf)
- Tác giả bản Game Turbo: **@yinwanxi**
- Đóng góp bổ sung Tensor G3 & Tối ưu hóa: **@Sushiba2ker**
- Cộng đồng phát triển: [TinyInjector](https://github.com/shunix/TinyInjector), [xHook](https://github.com/iqiyi/xHook), [Scene Tool](https://www.coolapk.com/apk/com.omarea.vtools).

---

## 📄 Giấy phép & Bản quyền (License)

- Toàn bộ mã nguồn dự án được phân phối theo giấy phép mã nguồn mở **Apache License 2.0**. Xem chi tiết tại file [LICENSE](LICENSE).
- Bản quyền gốc thuộc về **Matt Yang (@yc9559)** và các tác giả đóng góp.
- Bản nâng cấp chuyên sâu cho Tensor G3, WebUI và hệ thống tối ưu hóa được phát triển bởi **Sushiba (@Sushiba2ker)**.
- Các thành phần phần mềm bên thứ ba được sử dụng trong dự án (`pcre2`, `nlohmann/json`, `scnlib`, `spdlog`, `android-busybox-ndk`) được ghi nhận chi tiết tại file [NOTICE](NOTICE).
