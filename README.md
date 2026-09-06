[English](README.md) | [Tiếng Việt](README_VI.md)

# Uperf Sushiba | Pixel 8 (Tensor G3) Optimizer

An advanced userspace performance governor and deep hardware optimization suite exclusively engineered for **Google Tensor G3** devices (**Pixel 8, Pixel 8 Pro, and Pixel 8a**). Developed and maintained by **Sushiba**.

---

## 🌟 Key Features

- **Exclusive Google Tensor G3 Architecture Focus:** Precision-tuned for Tensor G3's 9 physical CPU cores (4x Cortex-A510, 4x Cortex-A715, 1x Cortex-X3), Mali-G715 Immortalis GPU, and hardware bus controllers (`zuma` / `husky` / `shiba` / `akita` / `gs301`).
- **LPDDR5X RAM & DSU L3-Cache Devfreq Clamping:** Dynamically clamps MIF and DSU bus frequencies based on active profiles, eliminating 1.2W – 1.5W of wasted interconnect power and thermal load.
- **Mali-G715 Immortalis GPU Clamping:** Clamps GPU peak frequencies to 580MHz / 649MHz under load, eliminating thermal throttling spikes and stabilizing FPS in demanding 3D gaming.
- **Frosty Deep Optimization Matrix:** Completely suppresses silent background logging, EGL profiler dumps, SurfaceFlinger tracing, and ftrace (`tracing_on=0`), freeing 100% CPU cycles for the foreground render thread.
- **Surgical GMS Telemetry Freeze:** Safely disables 50+ background tracking, analytics, and advertising services in Google Play Services while guaranteeing **100% instant FCM Push Notifications** for all messaging apps.
- **Smart GMS Doze & F2FS GC Maintenance:** Enforces deep sleep within 15 seconds of screen-off, triggers ZRAM compaction and pagecache cleanup, and runs F2FS garbage collection in the background without causing screen-on lag.
- **Battery Thermal Charging Guard:** Automatically throttles charging current when battery temperature exceeds 40.5°C to protect battery health and prevent overheating, restoring normal charging once cooled without severing power.
- **Bilingual WebUI 2.3 & Granular Runtime Controller:** Interactive WebUI with live 60FPS CPU/GPU/thermal waveform graph, 12 independent feature toggles (`features.conf` via `feature_ctl.sh`), Per-App profile manager, and instant **EN | VI** language switching.
- **Energy Model Sweet Frequency Tuning:** Locks CPU clock scaling to energy-optimal points ($\frac{\text{Perf}}{\text{Watt}}$ sweet spots) to prevent thermal degradation.
- **SurfaceFlinger Frame Lag Hook (`SfAnalysis`):** Hooks into `SurfaceFlinger` to detect rendering delays (`SfLag`), boosting frequencies only when a frame drop is imminent and immediately dropping clock speeds upon frame completion.
- **Broad Root Support:** Fully compatible with **KernelSU**, **KernelSU-Next**, **Magisk**, and **APatch** on Android 14 and Android 15 (SELinux Enforcing preserved).

---

## 📥 Download & Installation

### Method 1: KernelSU / Magisk / APatch Manager (Recommended)
1. Download the flashable module ZIP from [Releases](https://github.com/Sushiba2ker/uperf-pixel-8/releases).
2. Open **KernelSU Manager**, **Magisk**, or **APatch** -> Navigate to **Modules** -> Select **Install from storage**.
3. Select the downloaded ZIP file and proceed with flashing.
4. Reboot your device.
5. After reboot, check operational logs at `/sdcard/Android/yc/uperf/uperf_log.txt` or through the WebUI.

### Method 2: Manual Installation (Root Terminal)
1. Ensure root permissions are granted.
2. Extract the module archive into `/data/uperf`.
3. Grant executable permissions:
   ```bash
   chmod 755 /data/uperf/service.sh /data/uperf/script/*.sh
   ```
4. Initialize configuration and run the module:
   ```bash
   sh /data/uperf/script/setup.sh
   sh /data/uperf/script/initsvc.sh
   ```

---

## ⚙️ Runtime Feature Controls

The module provides granular control over individual optimization subsystems. Your configuration is preserved across module upgrades in `/sdcard/Android/yc/uperf/features.conf`.

You can toggle individual features via the **WebUI** or through the CLI controller via Termux / ADB Shell:

| Feature Key | Default | Description |
| :--- | :---: | :--- |
| `module_enabled` | `1` | Master switch for all runtime scripts and daemons. |
| `uperf` | `1` | Core Uperf userspace scheduler and touch response engine. |
| `powercfg` | `1` | Hardware power profiles (GPU, LPDDR5X RAM, DSU bus clamping). |
| `powercfg_once` | `1` | Boot CPU safety script ensuring all 9 cores are online. |
| `kernel_tweaks` | `1` | Kernel, virtual memory (VM), and UFS 3.1 I/O queue optimizations. |
| `system_tweaks` | `1` | Framework tracing and background telemetry suppression. |
| `gms_freeze` | `1` | Surgical disablement of GMS analytics and ads services. |
| `gms_doze` | `1` | Smart Deep Doze, memory compaction, and F2FS GC on screen-off. |
| `thermal_guard` | `1` | Battery thermal charging current protection (~40.5°C). |
| `ram_clean` | `1` | Permission to execute manual RAM & PageCache cleanup. |
| `zram_compact` | `1` | Permission to trigger immediate ZRAM compression. |
| `google_jobs` | `1` | Permission to cancel pending Google background jobs. |

### CLI Usage Examples:
```bash
# Check current feature status
su -c "sh /data/adb/modules/uperf/script/feature_ctl.sh status"

# Disable Thermal Charging Guard
su -c "sh /data/adb/modules/uperf/script/feature_ctl.sh set thermal_guard 0"

# Re-enable Thermal Charging Guard
su -c "sh /data/adb/modules/uperf/script/feature_ctl.sh set thermal_guard 1"
```

*Note: Disabling `thermal_guard` stops thermal throttling of charging speed; it never stops charging. Applied sysfs, kernel, and overlay configurations require a device reboot to completely revert.*

---

## ⚡ Performance Modes

### 1. Change Default Boot Mode
Edit `/sdcard/Android/yc/uperf/cur_powermode.txt` (or `/data/cur_powermode.txt`) and set your desired mode:

| Mode | Operating Characteristics | Best For |
| :--- | :--- | :--- |
| `auto` | Dynamically adapts per application based on Per-App rules | Daily mixed usage |
| `balance` | Optimal $\frac{\text{Perf}}{\text{Watt}}$, smooth UI, lower temperatures than stock | Social media, browsing, multitasking |
| `powersave` | Clamps CPU to `sweetFreq`, GPU 580MHz, RAM 2288MHz | Outdoor use, 4G/5G, low battery |
| `performance` | Instantaneous touch response, unconstrained core scaling | Heavy productivity, intensive multitasking |
| `fast` | Maximum CPU clocks, GPU 890MHz, RAM 3744MHz | Competitive 3D gaming, emulators |

### 2. Quick Mode Switching via Terminal
Execute directly via Termux or ADB Shell (root required):
```bash
# Switch to Balance mode
su -c "sh /data/powercfg.sh balance"

# Switch to Powersave mode
su -c "sh /data/powercfg.sh powersave"

# Switch to Gaming Turbo mode
su -c "sh /data/powercfg.sh fast"
```

---

## 📊 Architecture Comparison

| Feature | Project WIPE | Perfd-opt (CAF) | libperfmgr (Google) | Uperf Sushiba |
| :--- | :---: | :---: | :---: | :---: |
| **HMP + interactive** | ✔️ | ❌ | ❌ | ✔️ |
| **EAS + schedutil** | ❌ | ✔️ | ✔️ | ✔️ |
| **Deep Tensor G3 Hardware Focus** | ❌ | ❌ | Partial | ✔️ |
| **GPU Mali-G715 Clamping** | ❌ | ❌ | ❌ | ✔️ |
| **LPDDR5X & DSU Devfreq Clamping** | ❌ | ❌ | ❌ | ✔️ |
| **SurfaceFlinger Frame Lag Hook (`SfAnalysis`)** | ❌ | ❌ | ❌ | ✔️ |
| **Surgical GMS Telemetry Freeze** | ❌ | ❌ | ❌ | ✔️ |
| **Screen-Off Deep Doze & F2FS GC** | ❌ | ❌ | ❌ | ✔️ |
| **Battery Thermal Charging Guard** | ❌ | ❌ | ❌ | ✔️ |
| **Interactive WebUI & Granular Toggles** | ❌ | ❌ | ❌ | ✔️ |

---

## 🧠 Deep Technical Architecture

### 1. Low-Level Touch Input Monitor (`Input Monitor`)
Listens directly to raw input event streams at `/dev/input`. Analyzing release coordinates and swipe velocity, Uperf accurately differentiates between **Tap**, **Hold (Pressed)**, and **Swipe (Fling)** gestures to allocate optimal clock frequencies matched precisely to the expected scroll duration.

### 2. HeavyLoad Predictive Governance
When an application launches or initiates heavy computation, Uperf continuously samples total system load:
$$\text{System Load} = \sum \left( \text{Efficiency}_i \times \frac{\text{Load}_i}{100} \times \frac{\text{Freq}_i}{1000} \right)$$
If system load surpasses the `heavyLoad` threshold, Uperf boosts frequencies instantly. Crucially, as soon as the load completes, Uperf terminates the boost immediately—unlike stock OEM governors which hold maximum clocks for 2–3 seconds and generate excess heat.

### 3. SurfaceFlinger Hook (`SfAnalysis`)
An independent instrumentation module hooks into `SurfaceFlinger` to monitor frame presentation pipelines:
- Intercepts frame draw dispatch, detect frame drop risks (`SfLag`), and confirms buffer submission.
- Dynamically adapts to Variable Refresh Rates (60Hz / 120Hz Vsync).
- Functions safely within standard SELinux enforcement boundaries.

---

## 🛠️ Tensor G3 Energy Model Configuration (`uperf.json`)

The module employs an Energy Model configuration specifically calibrated for Google Tensor G3's 9-core topology at `config/gs301.json` (deployed to `/sdcard/Android/yc/uperf/uperf.json` upon installation).

### Energy Model Snapshot (Tensor G3):
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

## ❓ Frequently Asked Questions (FAQ)

**Q: Does this module drain battery during standby?**  
A: No. Uperf executes compiled native C/C++ binaries consuming negligible CPU (<0.1%). When the display is turned off, the module immediately enters `standby`, drops CPU/GPU/RAM frequencies to absolute minimums, and triggers Smart Deep Doze.

**Q: Why does my device still warm up during heavy 3D gaming?**  
A: Modern 3D gaming fully taxes both CPU and GPU. Uperf ensures the hardware operates at optimal frequency-to-power curves rather than wildly throttling, but thermodynamics cannot be defied. For cooler temperatures while gaming, select `balance` or `powersave` mode.

**Q: Should I disable the system Thermal Engine?**  
A: **Do not disable Thermal Engine.** The system thermal engine protects your hardware and battery from physical damage. Uperf optimizes performance proactively so your device remains cooler before heating up, without compromising critical thermal safety limits.

---

## 🤝 Credits & Acknowledgements

- Original Author: **Matt Yang (@yc9559)** - [Project Uperf](https://github.com/yc9559/uperf) (Apache 2.0)
- Game Turbo Author: **@yinwanxi**
- Google Tensor G3 Pure Focus, WebUI 2.3, Release Automation & Systems Engineering: **@Sushiba2ker**
- Open Source Community: [TinyInjector](https://github.com/shunix/TinyInjector), [xHook](https://github.com/iqiyi/xHook), [Scene Tool](https://www.coolapk.com/apk/com.omarea.vtools).

---

## 📄 License & Copyright

- The source code is licensed under the **Apache License 2.0**. See the [LICENSE](LICENSE) file for complete terms.
- Original copyright belongs to **Matt Yang (@yc9559)** and project contributors.
- Google Tensor G3 optimizations, WebUI, and feature controller additions are developed and copyrighted by **Sushiba (@Sushiba2ker)**.
- Third-party components (`pcre2`, `nlohmann/json`, `scnlib`, `spdlog`, `android-busybox-ndk`) are acknowledged in the [NOTICE](NOTICE) file.
