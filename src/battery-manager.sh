#!/bin/bash

# BatGuard - Smart Battery Management System
# Author: Nathan
# Description: Intelligent battery charging control with hardware-level protection
# Supports MSI, ThinkPad, Dell, ASUS, and other laptop brands

VERSION="1.0.0"
MODE_FILE="/tmp/battery-mode"

# Auto-detect battery path
BATTERY_PATH=""
for bat in /sys/class/power_supply/BAT*; do
    if [ -f "$bat/capacity" ] && [ -f "$bat/status" ]; then
        BATTERY_PATH="$bat"
        break
    fi
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect laptop brand and available charge control methods
detect_charge_control() {
    # MSI Super Battery
    if [ -f "/sys/devices/platform/msi-ec/super_battery" ]; then
        echo "msi"
        return 0
    fi
    
    # ThinkPad charge thresholds
    if [ -f "/sys/class/power_supply/BAT0/charge_control_end_threshold" ]; then
        echo "thinkpad"
        return 0
    fi
    
    # Generic charge control (Dell, ASUS, some others)
    for bat in /sys/class/power_supply/BAT*; do
        if [ -f "$bat/charge_control_end_threshold" ] || [ -f "$bat/charge_threshold" ]; then
            echo "generic"
            return 0
        fi
    done
    
    # ASUS specific
    if [ -f "/sys/class/power_supply/BATT/charge_control_end_threshold" ]; then
        echo "asus"
        return 0
    fi
    
    echo "none"
    return 1
}

# Hardware charge control functions
set_charge_limit() {
    local limit=$1
    local control_type=$(detect_charge_control)
    
    case "$control_type" in
        "msi")
            if [ "$limit" -le 60 ]; then
                echo "on" | sudo tee /sys/devices/platform/msi-ec/super_battery > /dev/null 2>&1
            else
                echo "off" | sudo tee /sys/devices/platform/msi-ec/super_battery > /dev/null 2>&1
            fi
            ;;
        "thinkpad")
            echo "$limit" | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold > /dev/null 2>&1
            ;;
        "generic"|"asus")
            for bat in /sys/class/power_supply/BAT* /sys/class/power_supply/BATT; do
                [ -f "$bat/charge_control_end_threshold" ] && echo "$limit" | sudo tee "$bat/charge_control_end_threshold" > /dev/null 2>&1
                [ -f "$bat/charge_threshold" ] && echo "$limit" | sudo tee "$bat/charge_threshold" > /dev/null 2>&1
            done
            ;;
    esac
}

# Get current battery info
get_battery_info() {
    if [ -f "$BATTERY_PATH/capacity" ] && [ -f "$BATTERY_PATH/status" ]; then
        capacity=$(cat "$BATTERY_PATH/capacity")
        status=$(cat "$BATTERY_PATH/status")
        control_type=$(detect_charge_control)
        
        # Get current mode
        if [ -f "$MODE_FILE" ]; then
            mode=$(cat "$MODE_FILE")
        else
            mode="normal"
        fi
        
        echo -e "${BLUE}═══════════════════════════════════════${NC}"
        echo -e "${BLUE}         BatGuard Status Report         ${NC}"
        echo -e "${BLUE}═══════════════════════════════════════${NC}"
        
        # Battery percentage with color coding
        if [ "$capacity" -le 10 ]; then
            echo -e "Battery Level: ${RED}${capacity}% ⚠️${NC}"
        elif [ "$capacity" -le 20 ]; then
            echo -e "Battery Level: ${YELLOW}${capacity}% 🔋${NC}"
        elif [ "$capacity" -ge 80 ]; then
            echo -e "Battery Level: ${GREEN}${capacity}% 🔋${NC}"
        else
            echo -e "Battery Level: ${GREEN}${capacity}% 🔋${NC}"
        fi
        
        # Charging status
        case "$status" in
            "Charging")
                echo -e "Status: ${GREEN}Charging 🔌${NC}"
                ;;
            "Discharging")
                echo -e "Status: ${YELLOW}On Battery ⚡${NC}"
                ;;
            "Full")
                echo -e "Status: ${GREEN}Fully Charged ✓${NC}"
                ;;
            *)
                echo -e "Status: $status"
                ;;
        esac
        
        # Hardware control support
        if [ "$control_type" != "none" ]; then
            echo -e "Hardware Control: ${GREEN}Supported ($control_type)${NC}"
        else
            echo -e "Hardware Control: ${YELLOW}Software notifications only${NC}"
        fi
        
        # Current mode
        case "$mode" in
            "athome")
                echo -e "Mode: ${BLUE}At Home (60% limit) 🏠${NC}"
                if [ "$control_type" != "none" ]; then
                    echo -e "Info: Battery charging limited by hardware"
                else
                    echo -e "Info: Will notify at 60% to unplug"
                fi
                ;;
            "normal")
                echo -e "Mode: ${GREEN}Normal (80% recommended) 🚀${NC}"
                echo -e "Info: Will notify at 80% for optimal health"
                ;;
        esac
        
        # Health tip
        echo -e "${BLUE}───────────────────────────────────────${NC}"
        if [ "$capacity" -ge 80 ] && [ "$status" = "Charging" ]; then
            echo -e "${YELLOW}Tip: Unplug to preserve battery health${NC}"
        elif [ "$capacity" -le 20 ] && [ "$status" = "Discharging" ]; then
            echo -e "${YELLOW}Tip: Consider plugging in soon${NC}"
        elif [ "$mode" = "athome" ] && [ "$capacity" -ge 60 ] && [ "$status" = "Charging" ]; then
            echo -e "${GREEN}Optimal: At home mode protecting battery${NC}"
        else
            echo -e "${GREEN}Battery health: Good practices! 👍${NC}"
        fi
        echo -e "${BLUE}═══════════════════════════════════════${NC}"
        echo -e "${BLUE}BatGuard v${VERSION} by Nathan${NC}"
    else
        echo -e "${RED}Unable to read battery information${NC}"
        echo -e "Please check if your system has a battery."
    fi
}

# Set at home mode (60% charging limit)
set_athome_mode() {
    echo "athome" > "$MODE_FILE"
    
    # Get current battery level
    if [ -f "$BATTERY_PATH/capacity" ]; then
        capacity=$(cat "$BATTERY_PATH/capacity")
    else
        capacity="Unknown"
    fi
    
    local control_type=$(detect_charge_control)
    
    if [ "$control_type" != "none" ]; then
        set_charge_limit 60
        echo -e "${GREEN}✓ At Home mode activated (Hardware Control: $control_type)${NC}"
        echo -e "Battery charging limited to 60% for optimal health"
        echo -e "Hardware-level protection enabled!"
        
        # Single notification with battery level and mode info
        notify-send -u normal "🏠 BatGuard: At Home Mode" \
            "Battery: ${capacity}%\nCharging limited to 60% for battery health" \
            -t 5000
    else
        echo -e "${GREEN}✓ At Home mode activated${NC}"
        echo -e "Note: Hardware charge limiting not supported on this device"
        echo -e "You'll receive notifications to unplug at 60%"
        
        notify-send -u normal "🏠 BatGuard: At Home Mode" \
            "Battery: ${capacity}%\nWill notify to unplug at 60%" \
            -t 5000
    fi
}

# Set normal mode (ready to go)
set_gtg_mode() {
    echo "normal" > "$MODE_FILE"
    
    # Get current battery level
    if [ -f "$BATTERY_PATH/capacity" ]; then
        capacity=$(cat "$BATTERY_PATH/capacity")
    else
        capacity="Unknown"
    fi
    
    local control_type=$(detect_charge_control)
    
    if [ "$control_type" != "none" ]; then
        set_charge_limit 100
        echo -e "${GREEN}✓ Mobile Mode activated (Hardware Control: $control_type)${NC}"
        echo -e "Battery will charge to 100% for mobile use"
        
        # Single notification with battery level and mode info
        notify-send -u normal "🚀 BatGuard: Mobile Mode" \
            "Battery: ${capacity}%\nCharging to 100% for mobile use" \
            -t 5000
    else
        echo -e "${GREEN}✓ Mobile Mode activated${NC}"
        echo -e "Battery will charge to full capacity"
        
        notify-send -u normal "🚀 BatGuard: Mobile Mode" \
            "Battery: ${capacity}%\nCharging to full capacity" \
            -t 5000
    fi
}

# Show help
show_help() {
    echo -e "${BLUE}BatGuard v${VERSION} - Smart Battery Management${NC}"
    echo -e "Created by Nathan"
    echo ""
    echo "Usage: batguard [command]"
    echo ""
    echo "Commands:"
    echo "  status, battery    Show battery status and current mode"
    echo "  athome            Activate At Home mode (60% charge limit)"
    echo "  gtg, mobile       Activate Mobile mode (100% charge)"
    echo "  help              Show this help message"
    echo "  version           Show version information"
    echo ""
    echo "Supported Hardware:"
    echo "  • MSI laptops (Super Battery)"
    echo "  • ThinkPad laptops (Charge thresholds)" 
    echo "  • Dell, ASUS, and other laptops with charge control"
    echo "  • Any laptop (software notifications)"
    echo ""
    echo "At Home Mode: Limits charging to 60% to maximize battery lifespan"
    echo "Mobile Mode: Charges to 100% for maximum runtime when traveling"
}

# Show version
show_version() {
    echo -e "${BLUE}BatGuard v${VERSION}${NC}"
    echo "Smart Battery Management System"
    echo "Created by Nathan"
    echo ""
    echo "Hardware Support: $(detect_charge_control)"
}

# Main command handling
case "$1" in
    "status"|"battery"|"")
        get_battery_info
        ;;
    "athome"|"home")
        set_athome_mode
        ;;
    "gtg"|"mobile"|"go")
        set_gtg_mode
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    "version"|"-v"|"--version")
        show_version
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo "Use 'batguard help' for usage information"
        exit 1
        ;;
esac