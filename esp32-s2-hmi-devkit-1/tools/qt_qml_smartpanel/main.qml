/**
 * main.qml – Root window for the ESP32-S2 HMI Smart Panel Qt QML application.
 *
 * The window is sized to 480 × 800 to match the board's TFT-LCD panel.
 * A persistent status bar sits at the top and a navigation bar at the bottom;
 * all pages are hosted inside a StackView between them.
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import "qml"

Window {
    id: root
    width: 480
    height: 800
    minimumWidth: 480
    minimumHeight: 800
    visible: true
    title: qsTr("ESP32-S2 HMI Smart Panel")
    color: "#1a1a2e"

    // ------------------------------------------------------------------ //
    //  Theme palette (mirrors the ESP32 smart-panel dark theme)
    // ------------------------------------------------------------------ //
    readonly property color clrBg:      "#1a1a2e"
    readonly property color clrSurface: "#16213e"
    readonly property color clrPrimary: "#0f3460"
    readonly property color clrAccent:  "#e94560"
    readonly property color clrText:    "#e0e0e0"
    readonly property color clrSubText: "#9e9e9e"

    // ------------------------------------------------------------------ //
    //  Status bar
    // ------------------------------------------------------------------ //
    Rectangle {
        id: statusBar
        width: parent.width
        height: 40
        color: clrSurface

        Row {
            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter: parent.verticalCenter
            }
            spacing: 6

            // Connection indicator
            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: serialHandler.connected ? "#4caf50" : "#9e9e9e"
                anchors.verticalCenter: parent.verticalCenter

                SequentialAnimation on opacity {
                    running: !serialHandler.connected
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 800 }
                    NumberAnimation { to: 1.0; duration: 800 }
                }
            }

            Text {
                text: serialHandler.connected
                      ? qsTr("Connected")
                      : qsTr("Simulated")
                color: clrSubText
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Text {
            anchors.centerIn: parent
            text: Qt.formatTime(new Date(), "hh:mm")
            color: clrText
            font.pixelSize: 14
            font.bold: true
        }

        Timer {
            interval: 10000
            running: true
            repeat: true
            onTriggered: statusBar.update()
        }

        function update() { }   // triggers binding re-evaluation via Timer
    }

    // ------------------------------------------------------------------ //
    //  Page stack
    // ------------------------------------------------------------------ //
    StackView {
        id: stack
        anchors {
            top:    statusBar.bottom
            bottom: navBar.top
            left:   parent.left
            right:  parent.right
        }
        initialItem: dashboardComponent

        pushEnter: Transition {
            PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 180 }
        }
        pushExit: Transition {
            PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 180 }
        }
        popEnter:  Transition {
            PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 180 }
        }
        popExit:   Transition {
            PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 180 }
        }
    }

    // ------------------------------------------------------------------ //
    //  Navigation bar
    // ------------------------------------------------------------------ //
    Rectangle {
        id: navBar
        width: parent.width
        height: 60
        color: clrSurface
        anchors.bottom: parent.bottom

        Row {
            anchors.centerIn: parent
            spacing: 0

            Repeater {
                model: [
                    { label: qsTr("Home"),     page: "qrc:/qml/Dashboard.qml"  },
                    { label: qsTr("Clock"),    page: "qrc:/qml/ClockPage.qml"  },
                    { label: qsTr("Sensors"),  page: "qrc:/qml/SensorPage.qml" },
                    { label: qsTr("LED"),      page: "qrc:/qml/LedPage.qml"    },
                    { label: qsTr("Settings"), page: "qrc:/qml/SettingsPage.qml" }
                ]

                delegate: Item {
                    width: 96
                    height: 60

                    Rectangle {
                        anchors.fill: parent
                        color: mouseArea.pressed
                               ? Qt.rgba(1, 1, 1, 0.08)
                               : "transparent"
                        radius: 4
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 3

                        Rectangle {
                            width: 6
                            height: 6
                            radius: 3
                            color: clrAccent
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: stack.currentItem
                                     && stack.currentItem.pageSource === modelData.page
                        }

                        Text {
                            text: modelData.label
                            color: (stack.currentItem
                                    && stack.currentItem.pageSource === modelData.page)
                                   ? clrAccent : clrSubText
                            font.pixelSize: 12
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: {
                            // Replace the whole stack so Back is not needed
                            stack.replace(null, modelData.page)
                        }
                    }
                }
            }
        }
    }

    // ------------------------------------------------------------------ //
    //  Page components
    // ------------------------------------------------------------------ //
    Component {
        id: dashboardComponent
        Dashboard { pageSource: "qrc:/qml/Dashboard.qml" }
    }
}
