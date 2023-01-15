/*
 * Copyright (C) 2022 - Timo Könnecke <github.com/eLtMosen>
 *               2022 - Darrel Griët <dgriet@gmail.com>
 *               2022 - Ed Beroset <github.com/beroset>
 *               2016 - Sylvia van Os <iamsylvie@openmailbox.org>
 *               2015 - Florent Revest <revestflo@gmail.com>
 *               2012 - Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
 *                      Aleksey Mikhailichenko <a.v.mich@gmail.com>
 *                      Arto Jalkanen <ajalkane@gmail.com>
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 2.1 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtSensors 5.11
import QtGraphicalEffects 1.15

import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import Nemo.Configuration 1.0
import Nemo.Mce 1.0
import Connman 0.2
import 'weathericons.js' as WeatherIcons

Item {
    id: root

    anchors.fill: parent

    property string imgPath: "../watchfaces-img/digital-weather-focus-"

    // Element sizes, positioning, linewidth and opacity
    property real activeContentOpacity: !displayAmbient ? .95 : .6
    property real inactiveContentOpacity: !displayAmbient ? .5 : .3

    // Color definition
    property string colorOrange: "#e5aa70"
    property string colorLightGrey: "#8b8b8b"
    property string colorDarkGrey: "#424242"

    // Font
    property string fontColor: "#ccffffff"
    property string fontFamily: "Noto Sans"
    property string fontStyleName: "Regular"
    property int fontSizeBig: root.width * .22
    property int fontSizeMedium: root.width * .08
    property int fontSizeSmall: root.width * .07

    // Set day to use in the weatherBox to today.
    property int dayNb: 0

//    // Uncomment for qml-tester
//    property var useFahrenheit: { "value": false }
//    property var owmId: { "value": 310 }
//    property var minTemp: { "value": 300 }
//    property var maxTemp: { "value": 308 }

    function kelvinToTemperatureString(kelvin) {
        var celsius = (kelvin - 273);
        if(useFahrenheit.value)
            return Math.round(((celsius) * 9 / 5) + 32) + "°F";
        else
            return celsius + "°C";
    }

    Item {
        // Wrapper for date related objects, day name, day number and month short code.
        id: dayBox

        anchors {
            centerIn: root
            horizontalCenterOffset: -root.width * .29
            verticalCenterOffset: -root.height * .43
        }
        width: parent.width
        height: parent.height * 0.10

        Text {
            id: monthName

            anchors {
                centerIn: parent
            }
            font {
                pixelSize: fontSizeMedium
                family: fontFamily
                styleName: "Bold"
            }
            color: colorOrange
            text: wallClock.time.toLocaleString(Qt.locale(), "MMM").slice(0, 3).toUpperCase()
                  + " "
                  + wallClock.time.toLocaleString(Qt.locale(), "dd").slice(0, 2).toUpperCase()
        }

        Text {
            id: dayNumber

            anchors {
                top: monthName.bottom
                left: monthName.left
            }
            font {
                pixelSize: fontSizeSmall
                family: fontFamily
                styleName: "Condensed"
            }
            color: "#ffffffff"
            text: wallClock.time.toLocaleString(Qt.locale(), "ddd").slice(0, 3).toUpperCase()
        }
    }

    Item {
        // Wrapper for digital time related objects. Hour, minute and AP following units setting.
        id: digitalBox

        anchors {
            centerIn: root
            horizontalCenterOffset: -root.width * .20
            verticalCenterOffset: -root.height * .08
        }
        width: root.height * 0.50
        height: width
        opacity: activeContentOpacity

        Text {
            id: digitalSeparator
            anchors {
                centerIn: parent
            }

            font {
                pixelSize: parent.width * .25
                family: fontFamily
                styleName: "Regular"
                letterSpacing: -parent.width * .001
            }
            color: "#ccffffff"
            text: ":"
        }

        Text {
            id: digitalHour

            anchors {
                right: digitalSeparator.left
                bottom: digitalSeparator.bottom
                leftMargin: parent.width * .01
            }
            font {
                pixelSize: parent.width * .25
                family: fontFamily
                styleName: "Regular"
            }
            color: fontColor
            text: if (use12H.value) {
                      wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2)}
                  else
                      wallClock.time.toLocaleString(Qt.locale(), "HH")
        }

        Text {
            id: digitalMinutes

            anchors {
                left: digitalSeparator.right
                bottom: digitalSeparator.bottom
                leftMargin: parent.width * .01
            }
            font {
                pixelSize: parent.width * .25
                family: fontFamily
                styleName: "Light"
            }
            color: fontColor
            text: wallClock.time.toLocaleString(Qt.locale(), "mm")
        }


        Item {
            // Wrapper for date related objects, day name, day number and month short code.
            id: secondBox

            anchors {
                centerIn: parent
            }
            width: parent.width
            height: parent.height

            Canvas {
                z: 6
                id: secondStrokes
                property int second: 0
                anchors.fill: parent
                smooth: true
                renderStrategy: Canvas.Cooperative
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.lineWidth = parent.height/58
                    ctx.lineCap="round"
                    ctx.strokeStyle = colorLightGrey
                    ctx.translate(parent.width/2, parent.height/2)
                    ctx.rotate(Math.PI)
                    for (var i=0; i <= 60; i++) {
                        ctx.beginPath()
                        ctx.moveTo(0, height*0.367)
                        ctx.lineTo(0, height*0.387)
                        ctx.stroke()
                        ctx.rotate(Math.PI/30)
                    }
                }
            }

            Canvas {
                z: 6
                id: secondDisplay
                property int second: 0
                anchors.fill: parent
                smooth: true
                renderStrategy: Canvas.Cooperative
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.lineWidth = parent.height/58
                    ctx.lineCap="round"
                    ctx.strokeStyle = colorOrange
                    ctx.translate(parent.width/2, parent.height/2)
                    ctx.rotate(Math.PI)
                    for (var i=0; i <= wallClock.time.getSeconds(); i++) {
                        ctx.beginPath()
                        ctx.moveTo(0, height*0.367)
                        ctx.lineTo(0, height*0.387)
                        ctx.stroke()
                        ctx.rotate(Math.PI/30)
                    }
                }
            }
        }
    }

    Item {
        // Wrapper for weather related elements. Contains a weatherIcon and maxTemp display.
        // "No weather data" text is shown when no data is available.
        // ConfigurationValue depends on Nemo.Configuration 1.0
        id: weatherBox

        anchors {
            centerIn: root
            verticalCenterOffset: root.height * .32
        }
        width: parent.width
        height: parent.height * 0.3
        opacity: activeContentOpacity

        ConfigurationValue {
            id: useFahrenheit
            key: "/org/asteroidos/settings/use-fahrenheit"
            defaultValue: false
        }

        ConfigurationValue {
            id: owmId
            key: "/org/asteroidos/weather/day" + dayNb + "/id"
            defaultValue: 0
        }

        ConfigurationValue {
            id: minTemp
            key: "/org/asteroidos/weather/day" + dayNb + "/min-temp"
            defaultValue: 0
        }

        ConfigurationValue {
            id: maxTemp
            key: "/org/asteroidos/weather/day" + dayNb + "/max-temp"
            defaultValue: 0
        }


        // Work around for the beta release here. Currently catching for -273° string to display the no data message.
        // Plan is to use the commented check. But the result is always false like used now. Likely due to timestamp0 expecting a listview or delegate?
        property bool weatherSynced: kelvinToTemperatureString(maxTemp.value) !== "-273°C"

        Canvas {
            id: weatherRect

            anchors.fill: parent
            smooth: true
            visible: !dockMode.active
            renderStrategy : Canvas.Cooperative
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.beginPath()
                ctx.fillStyle = colorDarkGrey
                ctx.strokeStyle = ctx.fillStyle
                ctx.roundedRect(15, 0, width - 30, height, 27, 27)

                ctx.stroke()
                ctx.fill()
                ctx.closePath()
            }
        }

        Icon {
            // WeatherIcons depends on import 'weathericons.js' as WeatherIcons
            id: iconDisplay

            anchors {
                centerIn: parent
                horizontalCenterOffset: -parent.width * .27
            }
            width: parent.width * .22
            height: width
            visible: weatherBox.weatherSynced
            name: WeatherIcons.getIconName(owmId.value)
        }

//        // Uncomment for qml-tester
//        Text {
//            id: weatherIcon

//            anchors {
//                centerIn: parent
//                horizontalCenterOffset: -parent.width * .27
//            }
//            font {
//                pixelSize: fontSizeBig
//                family: fontFamily
//                styleName: "Regular"
//                letterSpacing: parent.width * .001
//            }
//            color: fontColor
//            text: "O"
//        }

        Text {
            id: weatherTemperature

            y: parent.height * .16
            x: parent.width * .4
            anchors {
               horizontalCenterOffset: width / 4
               verticalCenterOffset: -parent.height * .15
            }
            font {
                pixelSize: fontSizeSmall
                family: fontFamily
                styleName: "Regular"
                letterSpacing: parent.width * .001
            }
            color: fontColor
            text: kelvinToTemperatureString(minTemp.value) + " - " + kelvinToTemperatureString(maxTemp.value)
        }

        Text {
            id: weatherDescription
            y: parent.height * .45
            x: parent.width * .4
            width: parent.width * .59
            font {
                pixelSize: fontSizeSmall
                family: fontFamily
                styleName: "Regular"
                letterSpacing: parent.width * .001
            }
            color: fontColor
            text: WeatherIcons.getWeatherDesc(owmId.value)
            wrapMode: Text.WordWrap
            lineHeight: 0.75
        }
    }

    Connections {
        target: wallClock

        function onTimeChanged() {
            var second = wallClock.time.getSeconds()
            if(secondDisplay.second !== second) {
                secondDisplay.second = second
                secondDisplay.requestPaint()
            }
        }
    }
}
