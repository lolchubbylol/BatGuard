# 🔋 BatGuard

**Smart Battery Management for Linux Laptops**

⚠️ **EXPERIMENTAL SOFTWARE** - Use at your own risk! While tested on MSI Vector 16 HX AI, hardware support varies by manufacturer. Always monitor your battery behavior when first using BatGuard.

✅ **CONFIRMED WORKING:** MSI Vector 16 HX AI with real hardware charge control!

BatGuard extends your laptop battery life through intelligent charging control and proactive notifications. It supports hardware-level charge limiting on compatible devices and provides smart software notifications on all Linux systems.

## ✨ Features

- 🏠 **At Home Mode** - Limits charging to 60% for maximum battery longevity  
- 🚀 **Mobile Mode** - Full charge to 100% when you need maximum runtime
- ⚡ **Hardware Control** - Real charge limiting using ACPI thresholds
- 🎯 **Smart Notifications** - Context-aware alerts that appear center-screen
- 🔔 **Multi-Level Warnings** - 50%, 20%, 10%, and 5% battery alerts with increasing urgency
- 🎨 **Beautiful Interface** - Clean, colorful status reports and notifications
- 🔧 **Easy Setup** - One-command installation with automatic service management

## 🖥️ Hardware Support Status

| Brand | Hardware Control | Method | Status |
|-------|-----------------|--------|--------|
| **MSI Vector 16 HX AI** | ✅ **CONFIRMED** | ACPI charge thresholds | Fully tested |
| **MSI (Other Models)** | 🔄 Likely Works | ACPI charge thresholds | Needs testing |
| **ThinkPad** | ✅ Expected | ACPI charge thresholds | Standard support |
| **Dell/ASUS/Others** | 🔄 Possible | ACPI charge thresholds | Check /sys/class/power_supply/BAT*/charge_control_* |
| **All Laptops** | ✅ **Always Works** | Smart notifications | Guaranteed |

*Don't see your laptop? BatGuard will still provide intelligent battery notifications!*

## 🚀 Quick Start

### Installation

```bash
git clone https://github.com/lolchubbylol/BatGuard.git
cd BatGuard
chmod +x install.sh
./install.sh
```

### Basic Usage

```bash
# Check battery status and hardware support
battery

# Activate At Home mode (40-60% range for longevity)
athome

# Switch to Mobile mode (5-100% for maximum runtime)
gtg
```

## 📖 Usage Guide

### At Home Mode 🏠
Perfect for when your laptop stays plugged in most of the day:
- **Hardware supported**: Battery charges between 40-60% automatically
- **Software fallback**: Notifies you to unplug at 60%  
- **Low battery alert**: Warns at 50% to plug back in
- **Battery lifespan**: Can extend battery life by 2-3x

### Mobile Mode 🚀
For maximum runtime when traveling:
- **Full capacity**: Charges from 5-100% for longest runtime
- **Health reminder**: Suggests unplugging at 80% when possible
- **Standard alerts**: 20%, 10%, 5% low battery warnings

### Status Display

```
═══════════════════════════════════════
         Battery Status Report          
═══════════════════════════════════════
Battery Level: 55% 🔋
Status: Charging 🔌
Mode: At Home (60% limit) 🏠
Info: Battery will stop charging at 60%
───────────────────────────────────────
Battery health: Good practices! 👍
═══════════════════════════════════════
```

## ⚙️ How It Works

### Hardware Control Detection
BatGuard automatically detects if your laptop supports ACPI charge thresholds:
```bash
# Checks for these files on your system:
/sys/class/power_supply/BAT*/charge_control_start_threshold
/sys/class/power_supply/BAT*/charge_control_end_threshold
```

### Battery Health Science
- **Lithium-ion degradation** happens fastest at 0% and 100% charge
- **Optimal range**: 40-60% can extend battery life by 200-300%
- **Heat reduction**: Lower charge levels generate less heat during use
- **Charge cycles**: Partial cycles (40-60%) cause less wear than full cycles

## 🔧 Advanced Configuration

### Check Hardware Support
```bash
# See if your laptop has charge control
ls /sys/class/power_supply/BAT*/charge_control_*

# Current thresholds (if supported)
cat /sys/class/power_supply/BAT*/charge_control_*_threshold
```

### Service Management
```bash
# Check service status
systemctl --user status battery-monitor

# View real-time logs
journalctl --user -u battery-monitor -f

# Restart service
systemctl --user restart battery-monitor
```

## 🛠️ Troubleshooting

### "Hardware charge limiting not available"
1. **Check detection**: `ls /sys/class/power_supply/BAT*/charge_control_*`
2. **Install drivers**: Some laptops need specific drivers (msi-ec, thinkpad_acpi, etc.)
3. **BIOS settings**: Enable "Battery Conservation" or similar in BIOS
4. **Permissions**: Ensure files are writable by your user

### Notifications Not Appearing
1. **Install notification daemon**: `yay -S mako` (Wayland) or `yay -S dunst` (X11)
2. **Test notifications**: `notify-send "Test" "BatGuard notification test"`
3. **Check daemon**: `pgrep mako` or `pgrep dunst`

### Service Issues
```bash
# Full troubleshooting sequence
systemctl --user daemon-reload
systemctl --user restart battery-monitor
journalctl --user -u battery-monitor --no-pager -l
```

## ⚠️ Important Notes

- **Experimental software**: Monitor your battery behavior when first installing
- **Hardware varies**: Not all laptops support charge limiting
- **BIOS interaction**: Some laptops need BIOS settings enabled
- **Safety first**: BatGuard won't override critical battery protections
- **Backup plan**: Always have a charger available when testing

## 🤝 Contributing

Found BatGuard working on your laptop? Please contribute!

1. **Report success**: Open an issue with your laptop model and "WORKING" status
2. **Add hardware support**: Submit PRs with new detection logic
3. **Share configs**: Help others with similar laptops

### Testing New Hardware
```bash
# Check for charge control support
find /sys -name "*charge*" 2>/dev/null | grep -E "threshold|control"

# Test manual control (safely!)
echo 80 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold
```

## 📞 Support

**Having issues?** Open a GitHub issue with:
- Laptop model and manufacturer
- Linux distribution and kernel version
- Output of `battery` command
- Any error messages from `journalctl --user -u battery-monitor`

## 📄 License

MIT License - Use, modify, and distribute freely.

---

**⚡ Extending laptop battery life, one charge cycle at a time** 🔋✨

*Made with ❤️ for the Linux community*