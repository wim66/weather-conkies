#!/bin/bash

# get_weather.sh
# by @wim66
# june 2 2024

# Determine the path to the script and its folders
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
WEATHER_DATA="$SCRIPT_DIR/weather_data"
CACHE_DIR="$SCRIPT_DIR/cache"
ICON_DIR="$SCRIPT_DIR/weather-icons/dark/SagiSan"
WEATHER_DATA="$SCRIPT_DIR/weather_data"

API_KEY="$OWM_API_KEY" # put your OpenWeatherMap api here https://openweathermap.org/
CITY_ID="2759794"      # find your city id in the url box https://openweathermap.org/city/2759794
UNITS="metric" # 'metric' for Celsius or 'imperial' for Fahrenheit
LANG="nl"
#URL="http://api.openweathermap.org/data/2.5/weather?id=${CITY_ID}&appid=${API_KEY}&units=metric"
WEATHER_RESPONSE=$(curl -s "http://api.openweathermap.org/data/2.5/weather?id=$CITY_ID&appid=$API_KEY&units=$UNITS&lang=$LANG")

# Create cache directory if it does not exist
mkdir -p $CACHE_DIR

# Parse JSON response
CITY=$(echo $WEATHER_RESPONSE | jq -r .name)
WEATHER_ICON=$(echo $WEATHER_RESPONSE | jq -r '.weather[0].icon')
WEATHER_DESC=$(echo $WEATHER_RESPONSE | jq -r '.weather[0].description')
TEMP=$(echo $WEATHER_RESPONSE | jq -r '.main.temp') 
HUMIDITY=$(echo $WEATHER_RESPONSE | jq -r '.main.humidity') 
WIND_SPEED=$(echo $WEATHER_RESPONSE | jq -r '.wind.speed')

TEMP=${TEMP%.*}
if [ "$UNITS" = "metric" ]; then
    TEMP="${TEMP}°C"
elif [ "$UNITS" = "imperial" ]; then
    TEMP="${TEMP}°F"
fi
# Copy the icon to the cache directory
cp ${ICON_DIR}/${WEATHER_ICON}.png ${CACHE_DIR}/weathericon.png

# Save the weather data
echo "CITY=${CITY}" > $WEATHER_DATA
echo "WEATHER_ICON=$WEATHER_ICON" >> $WEATHER_DATA
echo "WEATHER_DESC=$WEATHER_DESC" >> $WEATHER_DATA
echo "TEMP=$TEMP" >> $WEATHER_DATA
echo "HUMIDITY=$HUMIDITY" >> $WEATHER_DATA
echo "WIND_SPEED=$WIND_SPEED" >> $WEATHER_DATA

