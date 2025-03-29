#!/bin/bash

# get_weather.sh v1.2
# by @wim66
# June 12 2024

# Determine the path to the script and its folders
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
WEATHER_DATA="$SCRIPT_DIR/weather_data"
CACHE_DIR="$SCRIPT_DIR/cache"
ICON_DIR="$SCRIPT_DIR/weather-icons/dark/SagiSan"

# Load variables from settings.lua
API_KEY=$(lua -e 'require("settings"); conky_vars(); print(API_KEY)')
CITY_ID=$(lua -e 'require("settings"); conky_vars(); print(CITY_ID)')
UNITS=$(lua -e 'require("settings"); conky_vars(); print(UNITS)')
LANG=$(lua -e 'require("settings"); conky_vars(); print(LANG)')
WEATHER_RESPONSE=$(curl -s "http://api.openweathermap.org/data/2.5/weather?id=$CITY_ID&appid=$API_KEY&units=$UNITS&lang=$LANG")

# Create cache directory if it does not exist
mkdir -p "$CACHE_DIR"

# Parse JSON response
CITY=$(echo "$WEATHER_RESPONSE" | jq -r .name)
WEATHER_ICON=$(echo "$WEATHER_RESPONSE" | jq -r '.weather[0].icon')
WEATHER_DESC=$(echo "$WEATHER_RESPONSE" | jq -r '.weather[0].description')
TEMP=$(echo "$WEATHER_RESPONSE" | jq -r '.main.temp')
TEMP_MIN=$(echo "$WEATHER_RESPONSE" | jq -r '.main.temp_min')
TEMP_MAX=$(echo "$WEATHER_RESPONSE" | jq -r '.main.temp_max')   
HUMIDITY=$(echo "$WEATHER_RESPONSE" | jq -r '.main.humidity') 
WIND_SPEED=$(echo "$WEATHER_RESPONSE" | jq -r '.wind.speed')

# Translation function for weather descriptions (optional, not currently used)
translate_weather() {
    local desc="$1"
    case "$desc" in
        "zeer lichte bewolking")
            echo "lichte bewolking"  # Translate "very light clouds" to "light clouds"
            ;;
        # Add more translations here if needed, for example:
        # "heavy rain")
        #     echo "severe rain"  # Translate "heavy rain" to "severe rain"
        #     ;;
        *)
            echo "$desc"  # Default: return the original description unchanged
            ;;
    esac
}

# Remove decimal places from temperatures
TEMP=${TEMP%.*}
TEMP_MIN=${TEMP_MIN%.*}
TEMP_MAX=${TEMP_MAX%.*}

# Append temperature units based on UNITS setting
if [ "$UNITS" = "metric" ]; then
    TEMP="${TEMP}°C"
    TEMP_MIN="${TEMP_MIN}°C"
    TEMP_MAX="${TEMP_MAX}°C"
elif [ "$UNITS" = "imperial" ]; then
    TEMP="${TEMP}°F"
    TEMP_MIN="${TEMP_MIN}°F"
    TEMP_MAX="${TEMP_MAX}°F"
fi

# Copy the weather icon to the cache directory
cp "${ICON_DIR}/${WEATHER_ICON}.png" "${CACHE_DIR}/weathericon.png"

# Save the weather data to file
echo "CITY=${CITY}" > "$WEATHER_DATA"
echo "LANG=${LANG}" >> "$WEATHER_DATA"
echo "WEATHER_DESC=${WEATHER_DESC}" >> "$WEATHER_DATA"
echo "TEMP=${TEMP}" >> "$WEATHER_DATA"
echo "TEMP_MIN=${TEMP_MIN}" >> "$WEATHER_DATA"
echo "TEMP_MAX=${TEMP_MAX}" >> "$WEATHER_DATA"
echo "HUMIDITY=${HUMIDITY}" >> "$WEATHER_DATA"
echo "WIND_SPEED=${WIND_SPEED}" >> "$WEATHER_DATA"
echo "$WEATHER_RESPONSE" >> "$WEATHER_DATA"