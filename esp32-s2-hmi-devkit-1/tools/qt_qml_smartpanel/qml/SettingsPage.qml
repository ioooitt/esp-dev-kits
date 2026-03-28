/**
 * SettingsPage.qml – Serial port connection settings.
 *
 * Lets the user pick a port / baud rate and connect to or disconnect from
 * an ESP32-S2 HMI DevKit-1 board.
 */

import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    color: "#1a1a2e"
    property string pageSource: "qrc:/qml/SettingsPage.qml"

    // ------------------------------------------------------------------ //
    //  Labelled field helper
    // ------------------------------------------------------------------ //
    component FieldLabel: Text {
        color: "#9e9e9e"
        font.pixelSize: 13
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
            spacing: 16
            topPadding: 24
            bottomPadding: 24

            Text {
                text: qsTr("Settings")
                color: "#e0e0e0"
                font.pixelSize: 22
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: 20
            }

            // -------------------------------------------------------- //
            //  Connection status banner
            // -------------------------------------------------------- //
            Rectangle {
                width: 440
                height: 56
                radius: 12
                color: serialHandler.connected ? "#1b5e20" : "#16213e"
                border { color: serialHandler.connected ? "#4caf50" : "#0f3460"; width: 1 }
                anchors.horizontalCenter: parent.horizontalCenter

                Row {
                    anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                    spacing: 10

                    Rectangle {
                        width: 10; height: 10; radius: 5
                        color: serialHandler.connected ? "#4caf50" : "#9e9e9e"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: serialHandler.connected
                              ? qsTr("Connected to board")
                              : qsTr("Not connected – showing simulated data")
                        color: "#e0e0e0"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // -------------------------------------------------------- //
            //  Port selector
            // -------------------------------------------------------- //
            Column {
                width: 440
                spacing: 6
                anchors.horizontalCenter: parent.horizontalCenter

                FieldLabel { text: qsTr("Serial port") }

                Rectangle {
                    width: parent.width
                    height: 44
                    radius: 10
                    color: "#16213e"
                    border { color: "#0f3460"; width: 1 }

                    Row {
                        anchors { fill: parent; leftMargin: 12; rightMargin: 8 }
                        spacing: 8

                        ComboBox {
                            id: portCombo
                            width: parent.width - refreshBtn.width - parent.spacing
                            height: parent.height
                            model: serialHandler.availablePorts
                            displayText: count > 0 ? currentText : qsTr("No ports found")

                            background: Rectangle { color: "transparent" }
                            contentItem: Text {
                                text: portCombo.displayText
                                color: "#e0e0e0"
                                font.pixelSize: 14
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 4
                            }

                            indicator: Text {
                                x: portCombo.width - width - 8
                                y: (portCombo.height - height) / 2
                                text: "▼"
                                color: "#9e9e9e"
                                font.pixelSize: 10
                            }

                            popup: Popup {
                                y: portCombo.height
                                width: portCombo.width
                                implicitHeight: contentItem.implicitHeight
                                padding: 1

                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: portCombo.delegateModel

                                    ScrollIndicator.vertical: ScrollIndicator { }
                                }

                                background: Rectangle {
                                    color: "#16213e"
                                    border { color: "#0f3460"; width: 1 }
                                    radius: 8
                                }
                            }
                        }

                        // Refresh button
                        Rectangle {
                            id: refreshBtn
                            width: 36
                            height: 36
                            radius: 18
                            color: refreshArea.pressed ? "#0f3460" : "transparent"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "↻"
                                color: "#9e9e9e"
                                font.pixelSize: 20
                            }

                            MouseArea {
                                id: refreshArea
                                anchors.fill: parent
                                onClicked: serialHandler.refreshPorts()
                            }
                        }
                    }
                }
            }

            // -------------------------------------------------------- //
            //  Baud rate selector
            // -------------------------------------------------------- //
            Column {
                width: 440
                spacing: 6
                anchors.horizontalCenter: parent.horizontalCenter

                FieldLabel { text: qsTr("Baud rate") }

                ComboBox {
                    id: baudCombo
                    width: parent.width
                    height: 44
                    model: ["115200", "921600", "460800", "230400", "57600", "9600"]
                    currentIndex: 0

                    background: Rectangle {
                        color: "#16213e"
                        radius: 10
                        border { color: "#0f3460"; width: 1 }
                    }

                    contentItem: Text {
                        text: baudCombo.currentText
                        color: "#e0e0e0"
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 12
                    }

                    indicator: Text {
                        x: baudCombo.width - width - 12
                        y: (baudCombo.height - height) / 2
                        text: "▼"
                        color: "#9e9e9e"
                        font.pixelSize: 10
                    }

                    popup: Popup {
                        y: baudCombo.height
                        width: baudCombo.width
                        padding: 1

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: baudCombo.delegateModel
                            ScrollIndicator.vertical: ScrollIndicator { }
                        }

                        background: Rectangle {
                            color: "#16213e"
                            border { color: "#0f3460"; width: 1 }
                            radius: 8
                        }
                    }
                }
            }

            // -------------------------------------------------------- //
            //  Connect / Disconnect buttons
            // -------------------------------------------------------- //
            Row {
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                // Connect
                Rectangle {
                    width:  200
                    height: 48
                    radius: 24
                    color:  serialHandler.connected
                            ? "#9e9e9e"
                            : (connectArea.pressed ? "#0a2a50" : "#0f3460")
                    opacity: serialHandler.connected ? 0.5 : 1.0

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Connect")
                        color: "#e0e0e0"
                        font.pixelSize: 15
                        font.bold: true
                    }

                    MouseArea {
                        id: connectArea
                        anchors.fill: parent
                        enabled: !serialHandler.connected && portCombo.count > 0
                        onClicked: {
                            var ok = serialHandler.connectToPort(
                                portCombo.currentText,
                                parseInt(baudCombo.currentText))
                            if (!ok) {
                                errorMsg.visible = true
                                errorTimer.restart()
                            }
                        }
                    }
                }

                // Disconnect
                Rectangle {
                    width:  200
                    height: 48
                    radius: 24
                    color:  !serialHandler.connected
                            ? "#9e9e9e"
                            : (disconnectArea.pressed ? "#c73652" : "#e94560")
                    opacity: serialHandler.connected ? 1.0 : 0.5

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Disconnect")
                        color: "#ffffff"
                        font.pixelSize: 15
                        font.bold: true
                    }

                    MouseArea {
                        id: disconnectArea
                        anchors.fill: parent
                        enabled: serialHandler.connected
                        onClicked: serialHandler.disconnectPort()
                    }
                }
            }

            // Error message
            Text {
                id: errorMsg
                visible: false
                text: qsTr("Failed to open port. Check permissions and cable.")
                color: "#e94560"
                font.pixelSize: 13
                anchors.horizontalCenter: parent.horizontalCenter

                Timer {
                    id: errorTimer
                    interval: 4000
                    onTriggered: errorMsg.visible = false
                }
            }

            // -------------------------------------------------------- //
            //  Serial log
            // -------------------------------------------------------- //
            Column {
                width: 440
                spacing: 6
                anchors.horizontalCenter: parent.horizontalCenter

                FieldLabel { text: qsTr("Serial log") }

                Rectangle {
                    width:  440
                    height: 160
                    radius: 10
                    color:  "#0d1117"
                    border { color: "#0f3460"; width: 1 }
                    clip: true

                    ListView {
                        id: logView
                        anchors { fill: parent; margins: 8 }
                        model: logModel
                        spacing: 2
                        clip: true

                        delegate: Text {
                            text: model.display
                            color: "#4caf50"
                            font.pixelSize: 11
                            font.family: "Courier New, monospace"
                            width: logView.width
                            wrapMode: Text.WrapAnywhere
                        }

                        onCountChanged: positionViewAtEnd()
                    }
                }
            }

            // -------------------------------------------------------- //
            //  About
            // -------------------------------------------------------- //
            Rectangle {
                width: 440
                height: 80
                radius: 12
                color: "#16213e"
                anchors.horizontalCenter: parent.horizontalCenter

                Column {
                    anchors { centerIn: parent }
                    spacing: 4

                    Text {
                        text: qsTr("ESP32-S2 HMI Smart Panel")
                        color: "#e0e0e0"
                        font.pixelSize: 14
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: qsTr("Qt QML Host Application v1.0")
                        color: "#9e9e9e"
                        font.pixelSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: qsTr("© Espressif Systems (Shanghai) Co. Ltd.")
                        color: "#9e9e9e"
                        font.pixelSize: 11
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }

    // ------------------------------------------------------------------ //
    //  Log model (ListModel backed by serial data)
    // ------------------------------------------------------------------ //
    ListModel { id: logModel }

    Connections {
        target: serialHandler
        function onDataReceived(line) {
            logModel.append({ "display": line })
            if (logModel.count > 200) {
                logModel.remove(0)
            }
        }
    }
}
