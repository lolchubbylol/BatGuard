#!/bin/bash

# BatGuard Installation Script
# Author: Nathan

set -e

VERSION="1.0.0"
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}       BatGuard v${VERSION} Installer       ${NC}"
echo -e "${BLUE}       Created by Nathan                  ${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo -e "${RED}Error: BatGuard is designed for Linux systems only${NC}"
    exit 1
fi

# Check for notification daemon
if ! command -v notify-send &> /dev/null; then
    echo -e "${YELLOW}Warning: notify-send not found. Installing libnotify...${NC}"
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm libnotify
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y libnotify-bin
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y libnotify
    else
        echo -e "${RED}Could not install libnotify. Please install it manually.${NC}"
        exit 1
    fi
fi

# Check for notification daemon (mako, dunst, etc.)
if ! pgrep -x "mako\|dunst\|notification-daemon" > /dev/null; then
    echo -e "${YELLOW}Warning: No notification daemon detected.${NC}"
    echo -e "Please install one: mako (Wayland) or dunst (X11/Wayland)"
    echo -e "Continue anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create directories
echo -e "${BLUE}Creating directories...${NC}"
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR/systemd/user"

# Install binaries
echo -e "${BLUE}Installing BatGuard...${NC}"
cp src/battery-manager.sh "$INSTALL_DIR/batguard"
cp src/battery-daemon.sh "$INSTALL_DIR/batguard-daemon"
chmod +x "$INSTALL_DIR/batguard" "$INSTALL_DIR/batguard-daemon"

# Install systemd service
cp config/systemd/battery-monitor.service "$CONFIG_DIR/systemd/user/"

# Create aliases in shell config
SHELL_CONFIG=""
if [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
fi

if [ -n "$SHELL_CONFIG" ]; then
    echo -e "${BLUE}Adding shell aliases...${NC}"
    
    # Remove existing BatGuard aliases
    sed -i '/# BatGuard aliases/,+3d' "$SHELL_CONFIG" 2>/dev/null || true
    
    # Add new aliases
    echo "" >> "$SHELL_CONFIG"
    echo "# BatGuard aliases" >> "$SHELL_CONFIG"
    echo "alias battery='batguard'" >> "$SHELL_CONFIG"
    echo "alias athome='batguard athome'" >> "$SHELL_CONFIG"
    echo "alias gtg='batguard gtg'" >> "$SHELL_CONFIG"
fi

# Detect hardware support
echo -e "${BLUE}Detecting hardware support...${NC}"
HARDWARE_TYPE="none"

if [ -f "/sys/devices/platform/msi-ec/super_battery" ]; then
    HARDWARE_TYPE="MSI Super Battery"
    echo -e "${GREEN}✓ MSI laptop detected - Hardware charge control available${NC}"
    
    # Set up permissions for MSI
    echo "Setting up MSI permissions..."
    sudo chmod 666 /sys/devices/platform/msi-ec/super_battery 2>/dev/null || true
    
    # Add to crontab for persistent permissions
    if ! crontab -l 2>/dev/null | grep -q "msi-ec"; then
        (crontab -l 2>/dev/null; echo "@reboot chmod 666 /sys/devices/platform/msi-ec/super_battery") | crontab -
    fi
    
elif [ -f "/sys/class/power_supply/BAT0/charge_control_end_threshold" ]; then
    HARDWARE_TYPE="ThinkPad charge control"
    echo -e "${GREEN}✓ ThinkPad laptop detected - Hardware charge control available${NC}"
    
elif [ -f "/sys/class/power_supply/BAT0/charge_threshold" ]; then
    HARDWARE_TYPE="Generic charge control"
    echo -e "${GREEN}✓ Generic charge control detected${NC}"
    
else
    echo -e "${YELLOW}ⓘ Software notifications only (no hardware charge control)${NC}"
fi

# Enable and start systemd service
echo -e "${BLUE}Setting up background service...${NC}"
systemctl --user daemon-reload
systemctl --user enable battery-monitor.service
systemctl --user start battery-monitor.service

echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}     BatGuard Installation Complete!    ${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "Hardware Support: ${HARDWARE_TYPE}"
echo -e ""
echo -e "Usage:"
echo -e "  ${YELLOW}battery${NC}  - Check battery status"
echo -e "  ${YELLOW}athome${NC}   - At Home mode (60% limit)"
echo -e "  ${YELLOW}gtg${NC}      - Mobile mode (100% charge)"
echo -e ""
echo -e "The background service is now running and will start automatically on boot."
echo -e ""
if [ -n "$SHELL_CONFIG" ]; then
    echo -e "${YELLOW}Please restart your terminal or run: source $SHELL_CONFIG${NC}"
fi
echo -e ""
echo -e "Test with: ${YELLOW}batguard status${NC}"
echo -e ""
echo -e "Created by Nathan - Enjoy extended battery life! 🔋"