/**
 * Dashboard.qml – Overview page showing summary cards for all subsystems.
 *
 * Mirrors the main menu of the ESP32-S2 smart-panel example.
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#1a1a2e"

    // Exposed so the navigation bar can highlight the correct tab
    property string pageSource: "qrc:/qml/Dashboard.qml"

    // ------------------------------------------------------------------ //
    //  Shared card component
    // ------------------------------------------------------------------ //
    component SummaryCard: Rectangle {
        property string title:    ""
        property string value:    ""
        property string unit:     ""
        property string iconText: ""
        property color  iconColor: "#e94560"
        property string targetPage: ""

        width:  218
        height: 140
        radius: 12
        color:  "#16213e"

        Column {
            anchors {
                top:  parent.top
                topMargin: 16
                left: parent.left
                leftMargin: 16
            }
            spacing: 8

            Text {
                text:  parent.parent.iconText
                color: parent.parent.iconColor
                font.pixelSize: 28
            }

            Text {
                text:  parent.parent.title
                color: "#9e9e9e"
                font.pixelSize: 12
            }

            Row {
                spacing: 4
                Text {
                    id: cardValueText
                    text:  parent.parent.value
                    color: "#e0e0e0"
                    font.pixelSize: 28
                    font.bold: true
                }
                Text {
                    text:  parent.parent.unit
                    color: "#9e9e9e"
                    font.pixelSize: 14
                    anchors.baseline: cardValueText.baseline
                }
            }
        }

        // Tap-to-navigate
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (parent.targetPage !== "")
                    stack.replace(null, parent.targetPage)
            }
        }
    }

    // ------------------------------------------------------------------ //
    //  Content
    // ------------------------------------------------------------------ //
    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        clip: true

        Column {
            width: root.width
            spacing: 0

            // Header
            Item {
                width: parent.width
                height: 70

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20
                        verticalCenter: parent.verticalCenter
                    }
                    text: qsTr("Smart Panel")
                    color: "#e0e0e0"
                    font.pixelSize: 24
                    font.bold: true
                }

                Text {
                    anchors {
                        right: parent.right
                        rightMargin: 20
                        verticalCenter: parent.verticalCenter
                    }
                    text: Qt.formatDate(new Date(), "MMM d")
                    color: "#9e9e9e"
                    font.pixelSize: 14
                }
            }

            // Cards grid
            Grid {
                columns: 2
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter
                topPadding: 8
                bottomPadding: 16

                // Temperature card
                Rectangle {
                    width:  218
                    height: 140
                    radius: 12
                    color:  "#16213e"

                    Column {
                        anchors { top: parent.top; topMargin: 16; left: parent.left; leftMargin: 16 }
                        spacing: 8
                        Text { text: "🌡"; font.pixelSize: 28; color: "#e94560" }
                        Text { text: qsTr("Temperature"); color: "#9e9e9e"; font.pixelSize: 12 }
                        Row {
                            spacing: 4
                            Text {
                                text: serialHandler.temperature.toFixed(1)
                                color: "#e0e0e0"; font.pixelSize: 28; font.bold: true
                            }
                            Text { text: "°C"; color: "#9e9e9e"; font.pixelSize: 14 }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: stack.replace(null, "qrc:/qml/SensorPage.qml")
                    }
                }

                // Humidity card
                Rectangle {
                    width:  218
                    height: 140
                    radius: 12
                    color:  "#16213e"

                    Column {
                        anchors { top: parent.top; topMargin: 16; left: parent.left; leftMargin: 16 }
                        spacing: 8
                        Text { text: "💧"; font.pixelSize: 28; color: "#2196f3" }
                        Text { text: qsTr("Humidity"); color: "#9e9e9e"; font.pixelSize: 12 }
                        Row {
                            spacing: 4
                            Text {
                                text: serialHandler.humidity.toFixed(1)
                                color: "#e0e0e0"; font.pixelSize: 28; font.bold: true
                            }
                            Text { text: "%"; color: "#9e9e9e"; font.pixelSize: 14 }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: stack.replace(null, "qrc:/qml/SensorPage.qml")
                    }
                }

                // Light card
                Rectangle {
                    width:  218
                    height: 140
                    radius: 12
                    color:  "#16213e"

                    Column {
                        anchors { top: parent.top; topMargin: 16; left: parent.left; leftMargin: 16 }
                        spacing: 8
                        Text { text: "☀️"; font.pixelSize: 28; color: "#ffc107" }
                        Text { text: qsTr("Light"); color: "#9e9e9e"; font.pixelSize: 12 }
                        Row {
                            spacing: 4
                            Text {
                                text: Math.round(serialHandler.light)
                                color: "#e0e0e0"; font.pixelSize: 28; font.bold: true
                            }
                            Text { text: "lx"; color: "#9e9e9e"; font.pixelSize: 14 }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: stack.replace(null, "qrc:/qml/SensorPage.qml")
                    }
                }

                // LED card
                Rectangle {
                    width:  218
                    height: 140
                    radius: 12
                    color:  "#16213e"

                    Column {
                        anchors { top: parent.top; topMargin: 16; left: parent.left; leftMargin: 16 }
                        spacing: 8
                        Text { text: "💡"; font.pixelSize: 28; color: "#4caf50" }
                        Text { text: qsTr("LED Control"); color: "#9e9e9e"; font.pixelSize: 12 }
                        Text {
                            text: qsTr("Tap to control")
                            color: "#e0e0e0"; font.pixelSize: 16; font.bold: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: stack.replace(null, "qrc:/qml/LedPage.qml")
                    }
                }
            }

            // Quick-action row
            Item { width: parent.width; height: 8 }

            Text {
                text: qsTr("Quick Actions")
                color: "#9e9e9e"
                font.pixelSize: 13
                anchors.left: parent.left
                anchors.leftMargin: 20
            }

            Item { width: parent.width; height: 8 }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                Repeater {
                    model: [
                        { label: qsTr("Clock"),    page: "qrc:/qml/ClockPage.qml",    emoji: "🕐" },
                        { label: qsTr("Sensors"),  page: "qrc:/qml/SensorPage.qml",   emoji: "📡" },
                        { label: qsTr("Settings"), page: "qrc:/qml/SettingsPage.qml", emoji: "⚙️" }
                    ]

                    delegate: Rectangle {
                        width: 140
                        height: 60
                        radius: 10
                        color: "#0f3460"

                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            Text { text: modelData.emoji; font.pixelSize: 20 }
                            Text {
                                text: modelData.label
                                color: "#e0e0e0"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: stack.replace(null, modelData.page)
                        }
                    }
                }
            }

            Item { width: parent.width; height: 16 }
        }
    }

    // Resolve stack from the root window
    property var stack: {
        var p = parent
        while (p) {
            if (p.hasOwnProperty("stack")) return p.stack
            p = p.parent
        }
        return null
    }
}
