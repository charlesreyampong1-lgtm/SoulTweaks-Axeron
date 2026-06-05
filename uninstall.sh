# Reset Display to stock
settings put global peak_refresh_rate 60.0
settings put global user_refresh_rate 60.0

# Reset Battery Management to stock
settings put global adaptive_battery_management_enabled 1

# Reset UI Animation Scales to stock
settings put system animator_duration_scale 1.0
settings put system window_animation_scale 1.0
settings put system transition_animation_scale 1.0

# Clear Process Priority
am set-process-foreground $PACKAGE false

echo "GeminiTweaks: Reverted to stock successfully."