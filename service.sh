# 1. Performance Initialization
settings put global adaptive_battery_management_enabled 0

# 2. Force Peak Refresh Rate for the system
settings put global peak_refresh_rate 90.0
settings put global user_refresh_rate 90.0
settings put system min_refresh_rate 90.0

# 3. UI Optimization
settings put system animator_duration_scale 0.8
settings put system window_animation_scale 0.8
settings put system transition_animation_scale 0.8

echo "System initialized with Performance parameters"