
WARNING THIS IS A PROTOTYPE!
I TRIED IT ON MY LAPTOP AND IT DIDN'T WORK 

# 🔋 BatGuard

**Smart Battery Management for Linux Laptops**

BatGuard extends your laptop battery life through intelligent charging control and proactive notifications. It supports hardware-level charge limiting on compatible devices and provides smart software notifications on all Linux systems.

## ✨ Features

- 🏠 **At Home Mode** - Limits charging to 60% for maximum battery longevity
- 🚀 **Mobile Mode** - Full charge to 100% when you need maximum runtime
- ⚡ **Hardware Control** - Real charge limiting on MSI, ThinkPad, and other supported laptops
- 🎯 **Smart Notifications** - Context-aware alerts that appear center-screen
- 🔔 **Multi-Level Warnings** - 20%, 10%, and 5% battery alerts with increasing urgency
- 🎨 **Beautiful Interface** - Clean, colorful status reports and notifications
- 🔧 **Easy Setup** - One-command installation with automatic service management

## 🖥️ Supported Hardware

| Brand | Hardware Control | Method |
|-------|-----------------|--------|
| **MSI** | ✅ Full Support | Super Battery mode |
| **ThinkPad** | ✅ Full Support | Charge thresholds |
| **Dell** | ✅ Supported | Generic charge control |
| **ASUS** | ✅ Supported | Charge thresholds |
| **Other Laptops** | 📱 Software Only | Smart notifications |

*Don't see your brand? BatGuard still works with intelligent notifications!*

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
# Check battery status
battery

# Activate At Home mode (60% limit)
athome

# Switch to Mobile mode (100% charge)
gtg

# Full command interface
batguard status
batguard help
```

## 📖 Usage Guide

### At Home Mode
Perfect for when your laptop stays plugged in most of the day:
- **Hardware supported**: Stops charging at 60%
- **Software only**: Notifies you to unplug at 60%
- Warns at 50% if unplugged to maintain optimal range

### Mobile Mode  
For maximum runtime when traveling:
- Charges to 100% for longest battery life
- Warns at 80% that battery health would benefit from unplugging
- Standard 20%, 10%, 5% low battery warnings

### Status Display

```
═══════════════════════════════════════
         BatGuard Status Report         
═══════════════════════════════════════
Battery Level: 75% 🔋
Status: Charging 🔌
Hardware Control: Supported (msi)
Mode: At Home (60% limit) 🏠
Info: Battery charging limited by hardware
───────────────────────────────────────
Battery health: Good practices! 👍
═══════════════════════════════════════
```

*Extending laptop battery life, one charge cycle at a time* 🔋✨
