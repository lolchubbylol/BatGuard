# 🖥️ Supported Devices

BatGuard provides different levels of support depending on your laptop's hardware capabilities.

## ✅ Full Hardware Support

### MSI Laptops
- **Control Method**: Super Battery mode via `msi-ec` kernel module
- **Charge Limit**: ~60% when enabled
- **Models Tested**:
  - MSI Vector 16 HX AI A2XWIG ✅
  - MSI Gaming Series (Various models)
  - MSI Creator Series (Various models)

**Requirements**: `msi-ec-dkms-git` package from AUR

### ThinkPad Laptops  
- **Control Method**: Kernel charge thresholds
- **Charge Limit**: Configurable (BatGuard uses 60%)
- **Models**: Most modern ThinkPads with `/sys/class/power_supply/BAT*/charge_control_end_threshold`

### Dell Laptops
- **Control Method**: Generic kernel interfaces
- **Charge Limit**: Configurable via charge_control files
- **Models**: Many Dell laptops with BIOS charge control support

### ASUS Laptops
- **Control Method**: ASUS-specific charge thresholds
- **Charge Limit**: Configurable
- **Models**: Modern ASUS laptops with battery charge limiting

## 📱 Software Notification Support

All Linux laptops get intelligent notifications even without hardware control:
- Smart charge level recommendations (unplug at 80%)
- At Home mode reminders (unplug at 60%)
- Low battery warnings (20%, 10%, 5%)
- Contextual charging advice

## 🔍 Check Your Device Support

Run this command to see what's available on your system:

```bash
# Check for MSI support
ls /sys/devices/platform/msi-ec/ 2>/dev/null

# Check for ThinkPad support  
ls /sys/class/power_supply/BAT*/charge_control_end_threshold 2>/dev/null

# Check for generic support
find /sys/class/power_supply -name "*charge*" 2>/dev/null

# Auto-detect with BatGuard
batguard status
```

## 🚀 Adding Your Device

Don't see your laptop listed? You can help!

### Step 1: Investigation
```bash
# Look for any charge-related files
find /sys -name "*charge*" -o -name "*threshold*" 2>/dev/null

# Check power supply directory
ls -la /sys/class/power_supply/*/

# Check platform devices
ls /sys/devices/platform/ | grep -E "ec|battery|power"
```

### Step 2: Testing
If you find charge control files:
```bash
# Test writing to charge control (BACKUP YOUR DATA FIRST!)
echo 80 | sudo tee /path/to/charge/control/file

# Check if it worked
cat /path/to/charge/control/file
```

### Step 3: Contribute
1. Fork the BatGuard repository
2. Add detection logic for your device in `src/battery-manager.sh`
3. Test thoroughly on your hardware
4. Submit a pull request with details about your laptop model

## 🛡️ Safety Notes

- Always backup important data before testing hardware controls
- Some laptops may require BIOS settings changes
- Not all charge control files are safe to write to
- Test incrementally and monitor battery behavior

## 📝 Device Database

Help us build the device database by reporting your results:

```bash
# Get system info
sudo dmidecode -s system-manufacturer
sudo dmidecode -s system-product-name
uname -r  # Kernel version

# Check BatGuard detection
batguard status
```

Please report successful and unsuccessful attempts via GitHub issues!

---

*Last updated: January 2025*