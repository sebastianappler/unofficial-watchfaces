﻿/*
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

    // Radian per degree used by all canvas arcs
    property real rad: .01745

    // Element sizes, positioning, linewidth and opacity
    property real switchSize: root.width * .1375
    property real boxSize: root.width * .35
    property real switchPosition: root.width * .26
    property real boxPosition: root.width * .25
    property real innerArcLineWidth: root.height * .008
    property real outerArcLineWidth: root.height * .016
    property real activeArcOpacity: !displayAmbient ? .7 : .4
    property real inactiveArcOpacity: !displayAmbient ? .5 : .3
    property real activeContentOpacity: !displayAmbient ? .95 : .6
    property real inactiveContentOpacity: !displayAmbient ? .5 : .3

    // Color definition
    property string customRed: "#DB5461" // Indian Red
    property string customBlue: "#1E96FC" // Dodger Blue
    property string customGreen: "#26C485" // Ocean Green
    property string customOrange: "#FFC600" // Mikado Yellow
    property string boxColor: "#E8DCB9" // Dutch White
    property string switchColor: "#A2D6F9" // Uranian Blue
    property string orangeColor: "#e5aa70"

    // HRM initialisation. Needs to be declared global since hrmBox and hrmSwitch both need it.
    property int hrmBpm: 0
    property bool hrmSensorActive: false
    property var hrmBpmTime: wallClock.time

    // Set day to use in the weatherBox to today.
    property int dayNb: 0

    function kelvinToTemperatureString(kelvin) {
        var celsius = (kelvin - 273);
        if(useFahrenheit.value)
            return Math.round(((celsius) * 9 / 5) + 32) + "°F";
        else
            return celsius + "°C";
    }

    // Prepare for feature where the secondary hardware button activates HRM mode.
    // Keycode 134 = Sawfish lower button.
    /*Keys.onPressed: {
        if (event.keyCode === 134) {
            hrmSensorActive = !hrmSensorActive
        }
    }*/

    // Request the heart rate related arcs to be repainted when hrm sensor is toggled.
    onHrmSensorActiveChanged: {
        hrmArc.requestPaint()
        hrmSwitchArc.requestPaint()
    }

//    MceBatteryState {
//        id: batteryChargeState
//    }

//    MceBatteryLevel {
//        id: batteryChargePercentage
//    }

    Item {
      id: batteryChargePercentage
      property var value: (featureSlider.value * 100).toFixed(0)
    }

    Item {
        id: dockMode

        readonly property bool active: nightstand
        property int batteryPercentChanged: batteryChargePercentage.percent

        anchors.fill: parent
        visible: dockMode.active
        layer {
            enabled: true
            samples: 4
            smooth: true
            textureSize: Qt.size(dockMode.width * 2, dockMode.height * 2)
        }

        Shape {
            id: chargeArc

            property real angle: batteryChargePercentage.percent * 360 / 100
            // radius of arc is scalefactor * height or width
            property real arcStrokeWidth: 0.016
            property real scalefactor: 0.39 - (arcStrokeWidth / 2)
            property var chargecolor: Math.floor(batteryChargePercentage.percent / 33.35)
            readonly property var colorArray: [ "red", "yellow", Qt.rgba(0.318, 1, 0.051, 0.9)]

            anchors.fill: parent

            ShapePath {
                fillColor: "transparent"
                strokeColor: chargeArc.colorArray[chargeArc.chargecolor]
                strokeWidth: parent.height * chargeArc.arcStrokeWidth
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.MiterJoin
                startX: width / 2
                startY: height * ( 0.5 - chargeArc.scalefactor)

                PathAngleArc {
                    centerX: parent.width / 2
                    centerY: parent.height / 2
                    radiusX: chargeArc.scalefactor * parent.width
                    radiusY: chargeArc.scalefactor * parent.height
                    startAngle: -90
                    sweepAngle: chargeArc.angle
                    moveToStart: false
                }
            }
        }

        Text {
            id: batteryDockPercent

            anchors {
                centerIn: parent
                verticalCenterOffset: parent.width * 0.22
            }
            font {
                pixelSize: parent.width * .15
                family: "Noto Sans"
                styleName: "Condensed Light"
            }
            visible: dockMode.active
            color: chargeArc.colorArray[chargeArc.chargecolor]
            style: Text.Outline; styleColor: "#80000000"
            text: batteryChargePercentage.percent
        }
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
                pixelSize: root.width * .08
                family: "Barlow"
                styleName: "Bold"
            }
            color: orangeColor
            //opacity: displayAmbient ? inactiveArcOpacity : activeContentOpacity
            text: wallClock.time.toLocaleString(Qt.locale(), "MMM").slice(0, 3).toUpperCase() +
                  " " +
                  wallClock.time.toLocaleString(Qt.locale(), "dd").slice(0, 2).toUpperCase()
        }

        Text {
            id: dayNumber

            anchors {
                top: monthName.bottom
                left: monthName.left
            }
            font {
                pixelSize: root.width * .07
                family: "Noto Sans"
                styleName: "Condensed"
            }
            color: "#ffffffff"
            opacity: activeContentOpacity
            text: wallClock.time.toLocaleString(Qt.locale(), "ddd").slice(0, 3).toUpperCase()
        }

    }

    Item {
        // Wrapper for digital time related objects. Hour, minute and AP following units setting.
        id: digitalBox

        anchors {
            centerIn: root
            horizontalCenterOffset: -root.width * .2
            verticalCenterOffset: -root.height * .08
        }
        width: root.height * 0.55
        height: width
        opacity: activeContentOpacity

        Text {
            id: digitalSeparator
            anchors {
                centerIn: parent
            }

            font {
                pixelSize: parent.width * .22
                family: "Noto Sans"
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
                pixelSize: parent.width * .22
                family: "Noto Sans"
                styleName: "Regular"
                //letterSpacing: -parent.width * .001
            }
            color: "#ccffffff"
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
                pixelSize: parent.width * .22
                family: "Noto Sans"
                styleName: "Light"
            }
            color: "#ddffffff"
            text: wallClock.time.toLocaleString(Qt.locale(), "mm")
        }


        Item {
            // Wrapper for date related objects, day name, day number and month short code.
            id: secondBox

            anchors {
                centerIn: parent
                //horizontalCenterOffset: -parent.width * .25
            }
            width: parent.width
            height: parent.height

            Canvas {
                z: 6
                id: secondStrokes
                property var second: 0
                anchors.fill: parent
                smooth: true
                renderStrategy: Canvas.Cooperative
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.lineWidth = parent.height/58
                    ctx.lineCap="round"
                    ctx.strokeStyle = "#8b8b8b"
                    ctx.translate(parent.width/2, parent.height/2)
                    ctx.rotate(Math.PI)
                    for (var i=0; i <= 60; i++) {
                        ctx.beginPath()
                        ctx.moveTo(0, height*0.367)
                        ctx.lineTo(0, height*0.395)
                        ctx.stroke()
                        ctx.rotate(Math.PI/30)
                    }
                }
            }

            Canvas {
                z: 6
                id: secondDisplay
                property var second: 0
                anchors.fill: parent
                smooth: true
                renderStrategy: Canvas.Cooperative
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.lineWidth = parent.height/58
                    ctx.lineCap="round"
                    ctx.strokeStyle = orangeColor
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


        //ConfigurationValue {
        Item {
            id: timestampDay0

            //key: "/org/asteroidos/weather/timestamp-day0"
            //defaultValue: 0
        }

        ConfigurationValue {
        //Item {
            id: useFahrenheit
            key: "/org/asteroidos/settings/use-fahrenheit"
            defaultValue: false
        }

        ConfigurationValue {
        //Item {
            id: owmId
            key: "/org/asteroidos/weather/day" + dayNb + "/id"
            defaultValue: 0
        }

        ConfigurationValue {
        //Item {
            id: maxTemp
            key: "/org/asteroidos/weather/day" + dayNb + "/max-temp"
            defaultValue: 0
        }


        ConfigurationValue {
        //Item {
            id: minTemp
            key: "/org/asteroidos/weather/day" + dayNb + "/min-temp"
            defaultValue: 0
        }


        // Work around for the beta release here. Currently catching for -273° string to display the no data message.
        // Plan is to use the commented check. But the result is always false like used now. Likely due to timestamp0 expecting a listview or delegate?
        property bool weatherSynced: kelvinToTemperatureString(maxTemp.value) !== "-273°" //availableDays(timestampDay0.value*1000) > 0

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
                ctx.fillStyle = Qt.rgba(0.278, 0.278, 0.278, 1)
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
            width: parent.width * .25
            height: width
            opacity: activeContentOpacity
            visible: weatherBox.weatherSynced
            name: WeatherIcons.getIconName(owmId.value)
        }

//        Text {
//            id: weatherIcon

//            anchors {
//                centerIn: parent
//                horizontalCenterOffset: -parent.width * .27
//            }
//            font {
//                pixelSize: parent.width * .25
//                family: "Noto Sans"
//                styleName: "Regular"
//                letterSpacing: parent.width * .001
//            }
//            color: "#ccffffff"
//            text: "O"
//        }

        Text {
            id: weatherTemperature

            y: parent.height * .15
            x: parent.width * .40
            anchors {
               horizontalCenterOffset: width / 4
               verticalCenterOffset: -parent.height * .15
            }
            font {
                pixelSize: parent.width * 0.075
                family: "Noto Sans"
                styleName: "Regular"
                letterSpacing: parent.width * .001
            }
            color: "#ccffffff"
            text: kelvinToTemperatureString(minTemp.value) + " - " + kelvinToTemperatureString(maxTemp.value)
        }

        Text {
            id: weatherDescription
            y: parent.height * .50
            x: parent.width * .40
            anchors {
                horizontalCenterOffset: width / 2
                verticalCenterOffset: parent.height * .15

            }
            font {
                pixelSize: parent.width * 0.075
                family: "Noto Sans"
                styleName: "Regular"
                letterSpacing: parent.width * .001
            }
            color: "#ccffffff"
            text: WeatherIcons.getWeatherDesc(owmId.value)
        }

//        Label {
//            id: maxDisplay

//            anchors {
//                centerIn: parent
//                verticalCenterOffset: parent.height * (weatherBox.weatherSynced ? .155 : 0)
//                horizontalCenterOffset: parent.height * (weatherBox.weatherSynced ? .05 : 0)
//            }
//            width: parent.width
//            height: width
//            horizontalAlignment: Text.AlignHCenter
//            verticalAlignment: Text.AlignVCenter
//            opacity: activeContentOpacity
//            font {
//                family: "Barlow"
//                styleName: weatherBox.weatherSynced ? "Medium" : "Bold"
//                pixelSize: parent.width * (weatherBox.weatherSynced ? .30 : .14)
//            }
//            text: weatherBox.weatherSynced ? kelvinToTemperatureString(maxTemp.value) : "NO<br>WEATHER<br>DATA"
//        }

        // Preparation for a feature to open the weather app when the weatherBox is pressed.
        // Needs a delegate to hold the application names afaiu
        /*MouseArea {
            anchors.fill: weatherBox
            onClicked: {
               weather.launchApplication()
            }
        }*/
    }

    Connections {
        target: wallClock
        function onDisplayAmbientEntered() {
            hrmSensorActive = false
        }
        function onTimeChanged() {
            var second = wallClock.time.getSeconds()
            if(secondDisplay.second !== second) {
                secondDisplay.second = second
                secondDisplay.requestPaint()
            }
        }
    }
}
