// https://openweathermap.org/weather-conditions
var iconNameByOwmCode = {
    '200': 'ios-thunderstorm',
    '201': 'ios-thunderstorm',
    '202': 'ios-thunderstorm',
    '210': 'ios-thunderstorm',
    '211': 'ios-thunderstorm',
    '212': 'ios-thunderstorm',
    '221': 'ios-thunderstorm',
    '230': 'ios-thunderstorm',
    '231': 'ios-thunderstorm',
    '232': 'ios-thunderstorm',
    
    '300': 'ios-rainy',
    '301': 'ios-rainy',
    '302': 'ios-rainy',
    '310': 'ios-rainy',
    '311': 'ios-rainy',
    '312': 'ios-rainy',
    '313': 'ios-rainy',
    '314': 'ios-rainy',
    '321': 'ios-rainy',
    
    '500': 'ios-rainy',
    '501': 'ios-rainy',
    '502': 'ios-rainy',
    '503': 'ios-rainy',
    '504': 'ios-rainy',
    '511': 'ios-snow',
    '520': 'ios-rainy',
    '521': 'ios-rainy',
    '522': 'ios-rainy',
    '531': 'ios-rainy',
    
    '600': 'ios-snow',
    '601': 'ios-snow',
    '602': 'ios-snow',
    '611': 'ios-snow',
    '612': 'ios-snow',
    '615': 'ios-snow',
    '616': 'ios-snow',
    '620': 'ios-snow',
    '621': 'ios-snow',
    '622': 'ios-snow',
    
    '701': 'ios-cloudy',
    '711': 'ios-cloudy',
    '721': 'ios-cloudy',
    '731': 'ios-cloudy',
    '741': 'ios-cloudy',
    '751': 'ios-cloudy',
    '761': 'ios-cloudy',
    
    '800': 'ios-sunny',
    '801': 'ios-partly-sunny',
    '802': 'ios-cloudy',
    '803': 'ios-cloudy',
    '804': 'ios-cloudy',
    
    '903': 'ios-snow',
    '904': 'ios-flame',
    '905': 'ios-sunny',
    '906': 'ios-snow',
    
    '950': 'ios-sunny',
    '951': 'ios-sunny',
    '952': 'ios-sunny',
    '953': 'ios-sunny',
    '954': 'ios-sunny',
    '955': 'ios-sunny',
    '956': 'ios-sunny',
};

var weatherDescByOwmCode = {
    '200': 'Thunderstorm with light rain',
    '201': 'Thunderstorm with rain',
    '202': 'Thunderstorm with heavy rain',
    '210': 'Light thunderstorm',
    '211': 'Thunderstorm',
    '212': 'Heavy thunderstorm',
    '221': 'Ragged thunderstorm',
    '230': 'Thunderstorm with light drizzle',
    '231': 'Thunderstorm with drizzle',
    '232': 'Thunderstorm with heavy drizzle',

    '300': 'Light intensity drizzle',
    '301': 'Drizzle',
    '302': 'Heavy intensity drizzle',
    '310': 'Light intensity drizzle rain',
    '311': 'Drizzle rain',
    '312': 'Heavy intensity drizzle rain',
    '313': 'Shower rain and drizzle ',
    '314': 'Heavy shower rain and drizzle ',
    '321': 'Shower drizzle ',

    '500': 'Light rain',
    '501': 'Moderate rain',
    '502': 'Heavy intensity rain',
    '503': 'Very heavy rain ',
    '504': 'Extreme rain',
    '511': 'Freezing rain',
    '520': 'Light intensity shower rain',
    '521': 'Shower rain',
    '522': 'Heavy intensity shower rain',
    '531': 'Ragged shower rain',

    '600': 'Light snow',
    '601': 'Snow',
    '602': 'Heavy snow',
    '611': 'Sleet',
    '612': 'Light shower sleet',
    '615': 'Light rain and snow',
    '616': 'Rain and snow',
    '620': 'Light shower snow',
    '621': 'Shower snow',
    '622': 'Heavy shower snow',

    '701': 'Mist',
    '711': 'Smoke',
    '721': 'Haze',
    '731': 'Sand/dust whirls',
    '741': 'Fog',
    '751': 'Sand',
    '761': 'Dust',

    '800': 'Clear sky',
    '801': 'Few clouds',
    '802': 'Scattered clouds',
    '803': 'Broken clouds',
    '804': 'Overcast clouds',

    '903': 'Warning cold!',
    '904': 'Warning hot!',
    '905': 'Warning windy!',
    '906': 'Warning hail!',

    '950': 'Setting',
    '951': 'Calm',
    '952': 'Breeze',
    '953': 'Gentle breeze',
    '954': 'Moderate breeze',
    '955': 'Fresh breeze',
    '956': 'Strong breeze',
};

function getIconName(owmCode) {
    var iconCodeParts = iconNameByOwmCode[owmCode]
    if (!iconCodeParts)
        return 'ios-alert';
    return iconCodeParts;
}

function getWeatherDesc(owmCode) {
    var weatherDesc = weatherDescByOwmCode[owmCode]
    if (!weatherDesc)
        return 'No description';
    return weatherDesc;
}
