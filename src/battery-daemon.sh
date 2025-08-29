#!/bin/bash

# Lightweight battery daemon for critical alerts with mako
BATTERY_PATH="/sys/class/power_supply/BAT1"
MODE_FILE="/tmp/battery-mode"

# Thresholds
CRITICAL=10
VERY_LOW=5
LOW_WARNING=20
NORMAL_CHARGE_LIMIT=80
ATHOME_CHARGE_LIMIT=60

# Tracking
last_notified_discharge=100
last_notified_charge=0
last_status="Unknown"
last_mode="normal"

while true; do
    if [ -f "$BATTERY_PATH/capacity" ] && [ -f "$BATTERY_PATH/status" ]; then
        capacity=$(cat "$BATTERY_PATH/capacity")
        status=$(cat "$BATTERY_PATH/status")
        
        # Get current mode
        if [ -f "$MODE_FILE" ]; then
            mode=$(cat "$MODE_FILE")
        else
            mode="normal"
        fi
        
        # Check if mode changed
        if [ "$mode" != "$last_mode" ]; then
            last_notified_charge=0  # Reset charge notifications on mode change
            last_mode=$mode
        fi
        
        if [ "$status" = "Discharging" ]; then
            # Reset charge notification tracking
            last_notified_charge=0
            
            # Very low (5%) - Urgent repeating notification
            if [ "$capacity" -le "$VERY_LOW" ] && [ "$last_notified_discharge" -gt "$VERY_LOW" ]; then
                notify-send -u critical "🔴 BATTERY DYING!" \
                    "Only ${capacity}% left!\nSAVE YOUR WORK AND PLUG IN NOW!" \
                    -t 0
                # Play sound if available
                which paplay &>/dev/null && paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga &
                last_notified_discharge=$VERY_LOW
                
            # Critical (10%)
            elif [ "$capacity" -le "$CRITICAL" ] && [ "$last_notified_discharge" -gt "$CRITICAL" ]; then
                notify-send -u critical "⚠️ Battery Critical!" \
                    "${capacity}% remaining\nPlug in your charger immediately!" \
                    -t 0
                which paplay &>/dev/null && paplay /usr/share/sounds/freedesktop/stereo/dialog-warning.oga &
                last_notified_discharge=$CRITICAL
                
            # Low warning (20%) - but for At Home mode, warn at 50%
            elif [ "$mode" = "athome" ] && [ "$capacity" -le 50 ] && [ "$last_notified_discharge" -gt 50 ]; then
                notify-send -u normal -a "battery-daemon" "🏠 Plug In Charger" \
                    "Battery at ${capacity}%\nPlug in to maintain At Home mode (60% limit)" \
                    -t 10000
                last_notified_discharge=50
                
            elif [ "$capacity" -le "$LOW_WARNING" ] && [ "$last_notified_discharge" -gt "$LOW_WARNING" ]; then
                notify-send -u normal "🔋 Low Battery" \
                    "${capacity}% remaining\nConsider plugging in" \
                    -t 10000
                last_notified_discharge=$LOW_WARNING
            fi
            
        elif [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
            # Reset discharge notification tracking
            last_notified_discharge=100
            
            if [ "$mode" = "athome" ]; then
                # At home mode - notify at 60% to unplug
                if [ "$capacity" -ge "$ATHOME_CHARGE_LIMIT" ] && [ "$last_notified_charge" -lt "$ATHOME_CHARGE_LIMIT" ]; then
                    notify-send -u normal "🏠 Optimal Charge Reached" \
                        "Battery at ${capacity}%\nUnplug to maintain 60% (At Home mode)" \
                        -t 10000
                    last_notified_charge=$ATHOME_CHARGE_LIMIT
                fi
            else
                # Normal mode - notify at 80% as recommended
                if [ "$capacity" -ge "$NORMAL_CHARGE_LIMIT" ] && [ "$last_notified_charge" -lt "$NORMAL_CHARGE_LIMIT" ]; then
                    notify-send -u normal "🔋 Good Charge Level" \
                        "Battery at ${capacity}%\nConsider unplugging for battery health" \
                        -t 10000
                    last_notified_charge=$NORMAL_CHARGE_LIMIT
                fi
            fi
            
            # Notify when first plugged in
            if [ "$last_status" = "Discharging" ]; then
                if [ "$mode" = "athome" ]; then
                    notify-send -u low "🔌 Charging (At Home Mode)" \
                        "Will maintain around 60%" \
                        -t 3000
                else
                    notify-send -u low "🔌 Charger Connected" \
                        "Battery charging: ${capacity}%" \
                        -t 3000
                fi
            fi
        fi
        
        last_status=$status
    fi
    
    sleep 30  # Check every 30 seconds
done