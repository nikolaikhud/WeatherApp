### WeatherApp: Weather Information for Different US Cities and Towns

The app uses data from the [OpenWeather API](https://openweathermap.org/).
To test the app, you need to [create an acoount](https://home.openweathermap.org/users/sign_up) and obtain your own API key. The service provides free API keys.

Once you have your API key, add it to **WeatherApp/Supporting Files/Secrets.plist** as a string, replacing **your_api_key_here**:
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>API_KEY</key>
	<string>your_api_key_here</string>
</dict>
</plist>
```
