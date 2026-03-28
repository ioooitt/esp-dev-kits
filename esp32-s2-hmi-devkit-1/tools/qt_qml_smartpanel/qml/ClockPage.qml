/**
 * ClockPage.qml – Analog + digital clock page.
 *
 * Updates every second and displays the current local time.
 */

import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    color: "#1a1a2e"
    property string pageSource: "qrc:/qml/ClockPage.qml"

    // Current time, refreshed by timer
    property var   now:     new Date()
    property int   hours:   now.getHours()
    property int   minutes: now.getMinutes()
    property int   seconds: now.getSeconds()

    Timer {
        interval: 1000
        running:  true
        repeat:   true
        onTriggered: {
            root.now     = new Date()
            root.hours   = root.now.getHours()
            root.minutes = root.now.getMinutes()
            root.seconds = root.now.getSeconds()
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 32

        // ---------------------------------------------------------------- //
        //  Analog clock face
        // ---------------------------------------------------------------- //
        Item {
            id: clockFace
            width:  260
            height: 260
            anchors.horizontalCenter: parent.horizontalCenter

            // Outer ring
            Rectangle {
                anchors.centerIn: parent
                width:  parent.width
                height: parent.height
                radius: width / 2
                color:  "transparent"
                border { color: "#0f3460"; width: 4 }
            }

            // Hour tick marks
            Repeater {
                model: 12
                delegate: Rectangle {
                    width:  index % 3 === 0 ? 4 : 2
                    height: index % 3 === 0 ? 16 : 10
                    color:  index % 3 === 0 ? "#e0e0e0" : "#9e9e9e"
                    radius: 2
                    antialiasing: true
                    x: clockFace.width / 2 - width / 2
                    y: 8
                    transformOrigin: Item.Bottom
                    rotation: index * 30
                    transform: Rotation {
                        origin { x: width / 2; y: clockFace.height / 2 - 8 }
                        angle:  index * 30
                    }
                }
            }

            // Hour hand
            Rectangle {
                id: hourHand
                width:  5
                height: 80
                radius: 3
                color:  "#e0e0e0"
                antialiasing: true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                transformOrigin: Item.Bottom
                rotation: (root.hours % 12) * 30 + root.minutes * 0.5
            }

            // Minute hand
            Rectangle {
                id: minuteHand
                width:  3
                height: 105
                radius: 2
                color:  "#e94560"
                antialiasing: true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                transformOrigin: Item.Bottom
                rotation: root.minutes * 6 + root.seconds * 0.1
            }

            // Second hand
            Rectangle {
                id: secondHand
                width:  2
                height: 115
                radius: 1
                color:  "#ffc107"
                antialiasing: true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                transformOrigin: Item.Bottom
                rotation: root.seconds * 6
            }

            // Centre cap
            Rectangle {
                width:  14
                height: 14
                radius: 7
                color:  "#e94560"
                anchors.centerIn: parent
                z: 10
            }
        }

        // ---------------------------------------------------------------- //
        //  Digital readout
        // ---------------------------------------------------------------- //
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(root.now, "hh:mm:ss")
            color: "#e0e0e0"
            font.pixelSize: 42
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.now, "dddd, MMMM d yyyy")
            color: "#9e9e9e"
            font.pixelSize: 16
        }
    }
}
