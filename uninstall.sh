#!/bin/bash

# BatGuard Uninstall Script
# Author: Nathan

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
echo -e "${BLUE}      BatGuard v${VERSION} Uninstaller      ${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"

echo -e "${YELLOW}Are you sure you want to uninstall BatGuard? (y/N)${NC}"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

# Stop and disable service
echo -e "${BLUE}Stopping BatGuard service...${NC}"
systemctl --user stop battery-monitor.service 2>/dev/null || true
systemctl --user disable battery-monitor.service 2>/dev/null || true

# Remove files
echo -e "${BLUE}Removing BatGuard files...${NC}"
rm -f "$INSTALL_DIR/batguard"
rm -f "$INSTALL_DIR/batguard-daemon"
rm -f "$CONFIG_DIR/systemd/user/battery-monitor.service"
rm -f "/tmp/battery-mode"

# Remove shell aliases
SHELL_CONFIG=""
if [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
fi

if [ -n "$SHELL_CONFIG" ]; then
    echo -e "${BLUE}Removing shell aliases...${NC}"
    sed -i '/# BatGuard aliases/,+3d' "$SHELL_CONFIG" 2>/dev/null || true
fi

# Clean up crontab entries (MSI)
if crontab -l 2>/dev/null | grep -q "msi-ec"; then
    echo -e "${BLUE}Removing MSI EC permissions from crontab...${NC}"
    crontab -l 2>/dev/null | grep -v "msi-ec" | crontab - || true
fi

# Reset MSI Super Battery if it was enabled
if [ -f "/sys/devices/platform/msi-ec/super_battery" ] && [ "$(cat /sys/devices/platform/msi-ec/super_battery)" = "on" ]; then
    echo -e "${BLUE}Resetting MSI Super Battery to normal mode...${NC}"
    echo "off" | sudo tee /sys/devices/platform/msi-ec/super_battery > /dev/null 2>&1 || true
fi

systemctl --user daemon-reload

echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}     BatGuard Uninstall Complete!       ${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "All BatGuard components have been removed."
echo -e ""
if [ -n "$SHELL_CONFIG" ]; then
    echo -e "${YELLOW}Please restart your terminal to remove shell aliases${NC}"
fi
echo -e ""
echo -e "Thank you for using BatGuard!"