#!/system/bin/sh
SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=false
LATESTARTSERVICE=false

ui_print() { echo "- $1"; }

ui_print "Injecting SoulTweaks..."

# Setup background directories and files
MODDIR="/sdcard/Android/data/frb.axeron.manager/files"
LOOP_FILE="$MODDIR/loop.sh"

# Clean up any existing background optimizer process
pkill -f "loop.sh" > /dev/null 2>&1
cmd battery reset > /dev/null 2>&1

# Module Information Display on Install
ui_print "========================================="
ui_print "   Smart charging"
ui_print "   Locks 90 fps"
ui_print "   vulkan rendering"
ui_print "   best for Mobile Legends, CODM, Roblox,"
ui_print "   PUBG, Free Fire, Genshin, Warzone,"
ui_print "   ZZZ, Wuthering Waves"
ui_print "========================================="

# Inject the background runtime loop
cat << 'EOF' > "$LOOP_FILE"
#!/system/bin/sh
LAST_STATE=""
LAST_GAME=""
LOG_F="/sdcard/Android/data/frb.axeron.manager/files/optimizer.log"

# Siguraduhing malinis ang battery status sa simula
cmd battery reset > /dev/null 2>&1

while true; do
    # Game list detection block
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

    # SAFE NON-ROOT SENSOR: Tinitignan kung may totoong kuryenteng pumapasok ayon sa Android OS
    if dumpsys battery | grep -E "AC powered:|USB powered:|Wireless powered:" | grep -q "true"; then
        REAL_PLUGGED=1
    else
        REAL_PLUGGED=0
    fi

    # CRITICAL BUGFIX: Kung tinanggal ang charger (REAL_PLUGGED=0), i-reset agad ang subsystem
    if [ "$REAL_PLUGGED" -eq 0 ]; then
        cmd battery reset > /dev/null 2>&1
        CHARGING_STATUS=0
    else
        if dumpsys battery | grep -qi "status: charging"; then
            CHARGING_STATUS=1
        else
            CHARGING_STATUS=0
        fi
    fi

    # SCENARIO 1: May nilalarong game sa listahan
    if [ ! -z "$CURRENT_GAME" ]; then
        if [ "$LAST_STATE" != "performance" ] || [ "$LAST_GAME" != "$CURRENT_GAME" ]; then
            
            # SAFE BYPASS: Imbis na i-lock ang USB port sa 0, ginagamit ang safe software unplug
            if [ "$REAL_PLUGGED" -eq 1 ]; then
                cmd battery unplug > /dev/null 2>&1
                echo "If charging while gaming go normal charging" > "$LOG_F"
            else
                cmd battery reset > /dev/null 2>&1
                echo "If not charging stays the same" > "$LOG_F"
            fi
            
            cmd power set-mode 0
            settings put global power_id 2
            settings put global adaptive_battery_management_enabled 0
            
            settings put global peak_refresh_rate 90.0
            settings put global user_refresh_rate 90.0
            settings put system min_refresh_rate 90.0

            if settings put global debug.hwui.renderer skiavk 2>/dev/null; then
                settings put global debug.renderengine.backend vulkan
            else
                settings delete global debug.hwui.renderer
                settings delete global debug.renderengine.backend
            fi
            
            LAST_STATE="performance"
            LAST_GAME="$CURRENT_GAME"
        fi
    else
        # SCENARIO 2: Walang laro at NAKASAKSAK ang charger (Idle Charging)
        if [ "$REAL_PLUGGED" -eq 1 ]; then
            if [ "$LAST_STATE" != "fast_charging" ]; then
                cmd battery reset > /dev/null 2>&1 # Binabawi ang pagkaka-unplug para mag-charge nang mabilis
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
        # SCENARIO 3: Walang laro at WALANG charger (Normal/Active Battery)
        else
            if [ "$LAST_STATE" != "balanced" ]; then
                cmd battery reset > /dev/null 2>&1 # Laging siguraduhing malinis kapag walang nakasaksak
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

if [ -d "$MODPATH" ]; then
    chown -R 0:0 "$MODPATH"
    chmod 755 "$MODPATH/action.sh"
    chmod 755 "$MODPATH/service.sh"
    chmod 755 "$MODPATH/uninstall.sh"
fi

ui_print "[✓] SoulTweaks successfully injected!"