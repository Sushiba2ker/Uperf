# Uperf Game Turbo

Bộ điều phối hiệu năng và tối ưu năng lượng tầng Userspace cho Android, hỗ trợ toàn diện các nền tảng SoC hiện đại (bao gồm **Google Tensor G1 / G2 / G3**, Snapdragon, MediaTek Dimensity, Exynos và Kirin).

---

## 🌟 Tính năng chính

- **Điều phối hiệu năng động theo ngữ cảnh:** Tự động điều chỉnh các node `sysfs` (tần số CPU/GPU, bus DDR, cgroups) dựa trên hành vi thực tế của người dùng.
- **Tối ưu luồng giao diện (UI Affinity):** Tự động ghim các luồng render/UI quan trọng của ứng dụng đang thao tác vào cụm nhân tối ưu (Mid/Big Cores) và đẩy tác vụ nền về Little Cores.
- **Bắt tín hiệu cảm ứng cấp thấp:** Đọc trực tiếp sự kiện từ `/dev/input` (chạm, nhấn giữ, vuốt, tốc độ lướt) để dự đoán nhu cầu tài nguyên ngay lập tức.
- **Phân tích khung hình trễ qua `SfAnalysis`:** Hook trực tiếp vào `SurfaceFlinger` để phát hiện trễ khung hình (`SfLag`), chỉ nâng xung khi thực sự có nguy cơ rớt FPS và lập tức hạ xung khi hoàn thành khung hình.
- **Triệt tiêu Input Boost mù quáng:** Khóa hoàn toàn các cơ chế boost xung đỉnh vô tội vạ của kernel/OEM (`cpu_boost`, `input_booster`, `libperfmgr`), triệt tiêu nguồn nhiệt sinh ra khi thao tác vuốt lướt nhẹ.
- **Điều phối theo điểm ngọt năng lượng (Sweet Frequency):** Giữ xung nhịp CPU trong vùng có tỉ số Hiệu năng/Điện năng ($\frac{\text{Perf}}{\text{Watt}}$) tối ưu nhất, ngăn chặn hiện tượng quá nhiệt và sụt xung (thermal throttling).
- **Hỗ trợ rộng rãi:** Hoạt động tốt trên Android 6.0+ đến Android 15, tương thích hoàn toàn với **KernelSU**, **Magisk** và **APatch** (không cần tắt SELinux).

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
   chmod 755 /data/uperf/setup_uperf.sh /data/uperf/run_uperf.sh /data/uperf/initsvc_uperf.sh
   ```
4. Thực thi cài đặt và khởi chạy:
   ```bash
   sh /data/uperf/setup_uperf.sh
   sh /data/uperf/run_uperf.sh
   ```

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
| **Hỗ trợ Tensor / Exynos / MTK** | ✔️ | ❌ | Một phần | ✔️ |
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

## 🛠️ Tùy biến cấu hình (`uperf.json`)

Mỗi nền tảng SoC sử dụng một file cấu hình định dạng JSON tại `config/<tên_soc>.json`:
- Google Tensor G3 (Pixel 8 / 8 Pro / 8a): `gs301.json`
- Google Tensor G2 (Pixel 7 / 7 Pro / 7a): `gs201.json`
- Google Tensor G1 (Pixel 6 / 6 Pro / 6a): `gs101.json`
- Snapdragon 8 Gen 2 / 8 Gen 3: `sdm8g2.json` / `sdm8g3.json`
- MediaTek Dimensity 9000 / 9200: `mtd9000.json` / `mtd9200.json`

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
