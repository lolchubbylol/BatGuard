#!/bin/bash

# Battery management system with different charging modes
MODE_FILE="/tmp/battery-mode"
BATTERY_PATH="/sys/class/power_supply/BAT1"
CHARGE_CONTROL_START_PATH="/sys/class/power_supply/BAT1/charge_control_start_threshold"
CHARGE_CONTROL_END_PATH="/sys/class/power_supply/BAT1/charge_control_end_threshold"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current battery info
get_battery_info() {
    if [ -f "$BATTERY_PATH/capacity" ] && [ -f "$BATTERY_PATH/status" ]; then
        capacity=$(cat "$BATTERY_PATH/capacity")
        status=$(cat "$BATTERY_PATH/status")
        
        # Get current mode
        if [ -f "$MODE_FILE" ]; then
            mode=$(cat "$MODE_FILE")
        else
            mode="normal"
        fi
        
        echo -e "${BLUE}═══════════════════════════════════════${NC}"
        echo -e "${BLUE}         Battery Status Report          ${NC}"
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
        
        # Current mode
        case "$mode" in
            "athome")
                echo -e "Mode: ${BLUE}At Home (60% limit) 🏠${NC}"
                echo -e "Info: Battery will stop charging at 60%"
                ;;
            "normal")
                echo -e "Mode: ${GREEN}Normal (80% recommended) 🚀${NC}"
                echo -e "Info: Will notify at 80% to unplug"
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
    else
        echo "Unable to read battery information"
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
    
    # Use proper ACPI charge thresholds to limit charging to 60%
    if [ -w "/sys/class/power_supply/BAT1/charge_control_end_threshold" ]; then
        echo 40 | sudo tee /sys/class/power_supply/BAT1/charge_control_start_threshold > /dev/null 2>&1
        echo 60 | sudo tee /sys/class/power_supply/BAT1/charge_control_end_threshold > /dev/null 2>&1
        echo -e "${GREEN}✓ At Home mode activated (Hardware charge limiting)${NC}"
        echo -e "Battery will charge between 40-60% to preserve health"
        echo -e "Real ACPI hardware-level protection enabled!"
        
        # Single notification with battery level and mode info
        notify-send -a "battery-daemon" -u normal "🏠 At Home Mode Activated" \
            "Battery: ${capacity}%\nHardware limited to 40-60% range" \
            -t 5000
    else
        echo -e "${GREEN}✓ At Home mode activated${NC}"
        echo -e "Note: Hardware charge limiting not available"
        echo -e "You'll get a notification to unplug at 60%"
        
        notify-send -a "battery-daemon" -u normal "🏠 At Home Mode" \
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
    
    # Reset charge thresholds for full charging
    if [ -w "/sys/class/power_supply/BAT1/charge_control_end_threshold" ]; then
        echo 5 | sudo tee /sys/class/power_supply/BAT1/charge_control_start_threshold > /dev/null 2>&1
        echo 100 | sudo tee /sys/class/power_supply/BAT1/charge_control_end_threshold > /dev/null 2>&1
        echo -e "${GREEN}✓ Ready to go! (Full charging enabled)${NC}"
        echo -e "Battery will charge to 100%"
        
        # Single notification with battery level and mode info
        notify-send -a "battery-daemon" -u normal "🚀 Mobile Mode Activated" \
            "Battery: ${capacity}%\nCharging to 100% for mobile use" \
            -t 5000
    else
        echo -e "${GREEN}✓ Mobile Mode activated${NC}"
        echo -e "Battery will charge to full capacity"
        
        notify-send -a "battery-daemon" -u normal "🚀 Mobile Mode" \
            "Battery: ${capacity}%\nCharging to full capacity" \
            -t 5000
    fi
}

# Main command handling
case "$1" in
    "status")
        get_battery_info
        ;;
    "athome")
        set_athome_mode
        ;;
    "gtg")
        set_gtg_mode
        ;;
    *)
        get_battery_info
        ;;
esac