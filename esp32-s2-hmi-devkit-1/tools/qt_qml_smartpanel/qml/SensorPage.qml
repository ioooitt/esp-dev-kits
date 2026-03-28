/**
 * SensorPage.qml – Temperature, humidity and ambient-light sensor display.
 *
 * Reads live (or simulated) data from serialHandler and presents it with
 * animated gauge rings and a history sparkline.
 */

import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    color: "#1a1a2e"
    property string pageSource: "qrc:/qml/SensorPage.qml"

    // Keep a short history (last 30 samples) for the sparkline
    property var tempHistory:  []
    property var humiHistory:  []
    property var lightHistory: []

    Connections {
        target: serialHandler
        function onSensorDataChanged() {
            // Append and trim to 30 points
            function push(arr, val) {
                var a = arr.slice()
                a.push(val)
                if (a.length > 30) a.shift()
                return a
            }
            root.tempHistory  = push(root.tempHistory,  serialHandler.temperature)
            root.humiHistory  = push(root.humiHistory,  serialHandler.humidity)
            root.lightHistory = push(root.lightHistory, serialHandler.light)
        }
    }

    // ------------------------------------------------------------------ //
    //  Gauge ring component
    // ------------------------------------------------------------------ //
    component GaugeCard: Rectangle {
        id: card
        property string label:   ""
        property string unit:    ""
        property real   value:   0
        property real   minVal:  0
        property real   maxVal:  100
        property color  arcColor: "#e94560"
        property string emoji:   ""

        width:  440
        height: 120
        radius: 14
        color:  "#16213e"

        Row {
            anchors { fill: parent; margins: 16 }
            spacing: 16

            // Circular arc gauge
            Item {
                width:  88
                height: 88
                anchors.verticalCenter: parent.verticalCenter

                // Background arc track
                Canvas {
                    id: bgArc
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.beginPath()
                        ctx.arc(width / 2, height / 2, 38,
                                -Math.PI * 0.75, Math.PI * 0.75, false)
                        ctx.strokeStyle = "#0f3460"
                        ctx.lineWidth   = 8
                        ctx.lineCap     = "round"
                        ctx.stroke()
                    }
                }

                // Value arc
                Canvas {
                    id: valueArc
                    anchors.fill: parent
                    property real fraction: Math.max(0,
                        Math.min(1, (card.value - card.minVal) / (card.maxVal - card.minVal)))

                    onFractionChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        var start = -Math.PI * 0.75
                        var end   = start + fraction * Math.PI * 1.5
                        if (fraction > 0) {
                            ctx.beginPath()
                            ctx.arc(width / 2, height / 2, 38, start, end, false)
                            ctx.strokeStyle = card.arcColor
                            ctx.lineWidth   = 8
                            ctx.lineCap     = "round"
                            ctx.stroke()
                        }
                    }

                    Behavior on fraction {
                        NumberAnimation { duration: 600; easing.type: Easing.InOutQuad }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: card.emoji
                    font.pixelSize: 26
                }
            }

            // Numeric readout and label
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    text: card.label
                    color: "#9e9e9e"
                    font.pixelSize: 13
                }

                Row {
                    spacing: 4
                    Text {
                        text: card.value.toFixed(1)
                        color: "#e0e0e0"
                        font.pixelSize: 32
                        font.bold: true
                    }
                    Text {
                        text: card.unit
                        color: "#9e9e9e"
                        font.pixelSize: 16
                        anchors.baseline: parent.children[0].baseline
                    }
                }
            }
        }
    }

    // ------------------------------------------------------------------ //
    //  Page content
    // ------------------------------------------------------------------ //
    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        clip: true

        Column {
            width: root.width
            spacing: 12
            topPadding: 20
            bottomPadding: 20

            Text {
                text: qsTr("Sensors")
                color: "#e0e0e0"
                font.pixelSize: 22
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: 20
            }

            Item { width: parent.width; height: 4 }

            GaugeCard {
                anchors.horizontalCenter: parent.horizontalCenter
                label:    qsTr("Temperature")
                unit:     "°C"
                value:    serialHandler.temperature
                minVal:   0
                maxVal:   50
                arcColor: "#e94560"
                emoji:    "🌡"
            }

            GaugeCard {
                anchors.horizontalCenter: parent.horizontalCenter
                label:    qsTr("Humidity")
                unit:     "%"
                value:    serialHandler.humidity
                minVal:   0
                maxVal:   100
                arcColor: "#2196f3"
                emoji:    "💧"
            }

            GaugeCard {
                anchors.horizontalCenter: parent.horizontalCenter
                label:    qsTr("Ambient Light")
                unit:     "lx"
                value:    serialHandler.light
                minVal:   0
                maxVal:   1000
                arcColor: "#ffc107"
                emoji:    "☀️"
            }

            // -------------------------------------------------------- //
            //  Mini sparklines (temperature)
            // -------------------------------------------------------- //
            Rectangle {
                width:  440
                height: 110
                radius: 14
                color:  "#16213e"
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: qsTr("Temperature history")
                    color: "#9e9e9e"
                    font.pixelSize: 12
                    anchors { top: parent.top; left: parent.left; margins: 12 }
                }

                Canvas {
                    id: sparkline
                    anchors {
                        fill: parent
                        topMargin: 30
                        leftMargin: 12
                        rightMargin: 12
                        bottomMargin: 12
                    }

                    property var history: root.tempHistory
                    onHistoryChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        var data = history
                        if (data.length < 2) return

                        var minV = 15, maxV = 40
                        ctx.beginPath()
                        for (var i = 0; i < data.length; i++) {
                            var x = (i / (data.length - 1)) * width
                            var y = height - ((data[i] - minV) / (maxV - minV)) * height
                            if (i === 0) ctx.moveTo(x, y)
                            else         ctx.lineTo(x, y)
                        }
                        ctx.strokeStyle = "#e94560"
                        ctx.lineWidth   = 2
                        ctx.stroke()
                    }
                }
            }

            Item { width: parent.width; height: 4 }

            // Refresh timestamp
            Text {
                text: qsTr("Last update: ") + Qt.formatTime(new Date(), "hh:mm:ss")
                color: "#9e9e9e"
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Timer {
                    interval: 1000
                    running:  true
                    repeat:   true
                    onTriggered: parent.text =
                        qsTr("Last update: ") + Qt.formatTime(new Date(), "hh:mm:ss")
                }
            }
        }
    }
}
