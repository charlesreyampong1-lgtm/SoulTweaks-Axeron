MODDIR="/sdcard/Android/data/frb.axeron.manager/files"
LOOP_FILE="$MODDIR/loop.sh"
LOG_FILE="$MODDIR/optimizer.log"

pkill -f "loop.sh" > /dev/null 2>&1
cmd battery reset > /dev/null 2>&1
echo "Automatic Optimizer Engine Started successfully in Background!"

cat << 'EOF' > "$LOOP_FILE"
#!/system/bin/sh
LAST_STATE=""
LAST_GAME=""
LOG_F="/sdcard/Android/data/frb.axeron.manager/files/optimizer.log"

while true; do
    if pgrep -f "com.mobile.legends" > /dev/null; then CURRENT_GAME="com.mobile.legends"
    elif pgrep -f "com.garena.game.codm" > /dev/null; then CURRENT_GAME="com.garena.game.codm"
    elif pgrep -f "com.roblox.client" > /dev/null; then CURRENT_GAME="com.roblox.client"
    elif pgrep -f "com.activision.callofduty.shooter" > /dev/null; then CURRENT_GAME="com.activision.callofduty.shooter"
    elif pgrep -f "com.tencent.ig" > /dev/null; then CURRENT_GAME="com.tencent.ig"
    elif pgrep -f "com.vng.pubgmobile" > /dev/null; then CURRENT_GAME="com.vng.pubgmobile"
    elif pgrep -f "com.dts.freefireth" > /dev/null; then CURRENT_GAME="com.dts.freefireth"
    elif pgrep -f "com.dts.freefiremax" > /dev/null; then CURRENT_GAME="com.dts.freefiremax"
    elif pgrep -f "com.miHoYo.GenshinImpact" > /dev/null; then CURRENT_GAME="com.miHoYo.GenshinImpact"
    elif pgrep -f "com.activision.callofduty.warzone" > /dev/null; then CURRENT_GAME="com.activision.callofduty.warzone"
    elif pgrep -f "com.HoYoverse.Nap" > /dev/null; then CURRENT_GAME="com.HoYoverse.Nap"
    elif pgrep -f "com.kurogame.wutheringwaves.global" > /dev/null; then CURRENT_GAME="com.kurogame.wutheringwaves.global"
    else
        CURRENT_GAME=""
    fi

    if [ -z "$CURRENT_GAME" ]; then
        cmd battery reset > /dev/null 2>&1
    fi

    if dumpsys battery | grep -qi "status: charging" || dumpsys battery | grep -E "AC powered:|USB powered:|Wireless powered:" | grep -q "true"; then
        CHARGING_STATUS=1
    else
        CHARGING_STATUS=0
    fi

    if [ ! -z "$CURRENT_GAME" ]; then
        if [ "$LAST_STATE" != "performance" ] || [ "$LAST_GAME" != "$CURRENT_GAME" ]; then
            cmd battery set wireless 0
            cmd battery set usb 0
            
            cmd power set-mode 0
            settings put global power_id 2
            settings put global peak_refresh_rate 90.0
            settings put global user_refresh_rate 90.0
            settings put system min_refresh_rate 90.0
            settings put global adaptive_battery_management_enabled 0

            if settings put global debug.hwui.renderer skiavk 2>/dev/null; then
                settings put global debug.renderengine.backend vulkan
            else
                settings delete global debug.hwui.renderer
                settings delete global debug.renderengine.backend
            fi
            
            if [ "$CHARGING_STATUS" -eq 1 ]; then
                echo "If charging while gaming go normal charging" > "$LOG_F"
            else
                echo "If not charging stays the same" > "$LOG_F"
            fi
            
            LAST_STATE="performance"
            LAST_GAME="$CURRENT_GAME"
        fi
    else
        if [ "$CHARGING_STATUS" -eq 1 ]; then
            if [ "$LAST_STATE" != "fast_charging" ]; then
                cmd power set-mode 2
                settings put global power_id 1
                
                settings put global peak_refresh_rate 90.0
                settings put global user_refresh_rate 90.0
                settings put system min_refresh_rate 90.0
                
                settings delete global debug.hwui.renderer
                settings delete global debug.renderengine.backend
                
                echo "If charging and idle go fast charging" > "$LOG_F"
                LAST_STATE="fast_charging"
                LAST_GAME=""
            fi
        else
            if [ "$LAST_STATE" != "balanced" ]; then
                cmd power set-mode 2
                settings put global power_id 1
                
                settings put global peak_refresh_rate 90.0
                settings put global user_refresh_rate 90.0
                settings put system min_refresh_rate 90.0
                
                settings delete global debug.hwui.renderer
                settings delete global debug.renderengine.backend
                
                echo "If not charging stays the same" > "$LOG_F"
                LAST_STATE="balanced"
                LAST_GAME=""
            fi
        fi
    fi
    sleep 5
done
EOF

chmod +x "$LOOP_FILE"
nohup sh "$LOOP_FILE" > /dev/null 2>&1 &