/**
 * LedPage.qml – WS2812 LED colour-picker and brightness control page.
 *
 * When connected to an ESP32-S2 HMI DevKit-1, pressing "Apply" sends the
 * command "LED:r=<R>,g=<G>,b=<B>" over the serial port.
 */

import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    color: "#1a1a2e"
    property string pageSource: "qrc:/qml/LedPage.qml"

    property int   ledR:  229
    property int   ledG:  69
    property int   ledB:  96
    property real  ledBrightness: 1.0

    // Computed colour at current brightness
    property color previewColor: Qt.rgba(
        ledR / 255 * ledBrightness,
        ledG / 255 * ledBrightness,
        ledB / 255 * ledBrightness,
        1)

    // ------------------------------------------------------------------ //
    //  Slider component
    // ------------------------------------------------------------------ //
    component ColorSlider: Column {
        property alias label: labelText.text
        property alias value: slider.value
        property alias sliderColor: track.color

        width: 400
        spacing: 4

        Row {
            width: parent.width
            Text { id: labelText; color: "#9e9e9e"; font.pixelSize: 13; width: 30 }
            Item { width: parent.width - 30 - 40; height: 1 }
            Text {
                text: Math.round(slider.value)
                color: "#e0e0e0"
                font.pixelSize: 13
                width: 40
                horizontalAlignment: Text.AlignRight
            }
        }

        Item {
            width:  parent.width
            height: 28

            // Track
            Rectangle {
                id: track
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 6
                radius: 3
                color: "#9e9e9e"
                opacity: 0.4
            }

            // Fill
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: slider.visualPosition * parent.width
                height: 6
                radius: 3
                color: track.color
            }

            Slider {
                id: slider
                anchors.fill: parent
                from: 0
                to:   255
                stepSize: 1
                background: Item {}   // custom track above

                handle: Rectangle {
                    x:      slider.visualPosition * (slider.width - width)
                    y:      (slider.height - height) / 2
                    width:  22
                    height: 22
                    radius: 11
                    color:  "#e0e0e0"
                    border { color: "#16213e"; width: 2 }
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
            spacing: 16
            topPadding: 20
            bottomPadding: 20

            Text {
                text: qsTr("LED Control")
                color: "#e0e0e0"
                font.pixelSize: 22
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: 20
            }

            // -------------------------------------------------------- //
            //  Colour preview
            // -------------------------------------------------------- //
            Rectangle {
                width: 160
                height: 160
                radius: 80
                color: root.previewColor
                anchors.horizontalCenter: parent.horizontalCenter

                // Glow effect
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 20
                    height: parent.height + 20
                    radius: (parent.width + 20) / 2
                    color: "transparent"
                    border {
                        color: Qt.rgba(
                            root.ledR / 255,
                            root.ledG / 255,
                            root.ledB / 255,
                            0.35)
                        width: 10
                    }
                    z: -1
                }
            }

            // -------------------------------------------------------- //
            //  Preset colours
            // -------------------------------------------------------- //
            Text {
                text: qsTr("Presets")
                color: "#9e9e9e"
                font.pixelSize: 13
                anchors.left: parent.left
                anchors.leftMargin: 20
            }

            Row {
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: [
                        { r: 229, g: 69,  b: 96,  label: "Red"    },
                        { r: 33,  g: 150, b: 243, label: "Blue"   },
                        { r: 76,  g: 175, b: 80,  label: "Green"  },
                        { r: 255, g: 193, b: 7,   label: "Yellow" },
                        { r: 255, g: 255, b: 255, label: "White"  }
                    ]

                    delegate: Column {
                        spacing: 4

                        Rectangle {
                            width:  44
                            height: 44
                            radius: 22
                            color:  Qt.rgba(modelData.r / 255,
                                            modelData.g / 255,
                                            modelData.b / 255, 1)
                            border {
                                color: (root.ledR === modelData.r
                                     && root.ledG === modelData.g
                                     && root.ledB === modelData.b)
                                       ? "#e0e0e0" : "transparent"
                                width: 2
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    root.ledR = modelData.r
                                    root.ledG = modelData.g
                                    root.ledB = modelData.b
                                }
                            }
                        }

                        Text {
                            text: modelData.label
                            color: "#9e9e9e"
                            font.pixelSize: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            // -------------------------------------------------------- //
            //  RGB sliders
            // -------------------------------------------------------- //
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                ColorSlider {
                    label: "R"
                    value: root.ledR
                    sliderColor: "#e94560"
                    onValueChanged: root.ledR = Math.round(value)
                }

                ColorSlider {
                    label: "G"
                    value: root.ledG
                    sliderColor: "#4caf50"
                    onValueChanged: root.ledG = Math.round(value)
                }

                ColorSlider {
                    label: "B"
                    value: root.ledB
                    sliderColor: "#2196f3"
                    onValueChanged: root.ledB = Math.round(value)
                }
            }

            // Brightness slider
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Text {
                    text: qsTr("Brightness: ") + Math.round(root.ledBrightness * 100) + "%"
                    color: "#9e9e9e"
                    font.pixelSize: 13
                }

                Slider {
                    id: brightnessSlider
                    width: 400
                    from: 0
                    to:   1.0
                    value: root.ledBrightness
                    onValueChanged: root.ledBrightness = value

                    background: Rectangle {
                        x: brightnessSlider.leftPadding
                        y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                        width:  brightnessSlider.availableWidth
                        height: 6
                        radius: 3
                        color: "#0f3460"

                        Rectangle {
                            width:  brightnessSlider.visualPosition * parent.width
                            height: parent.height
                            radius: 3
                            color: "#ffc107"
                        }
                    }

                    handle: Rectangle {
                        x: brightnessSlider.leftPadding
                           + brightnessSlider.visualPosition
                           * (brightnessSlider.availableWidth - width)
                        y: brightnessSlider.topPadding
                           + brightnessSlider.availableHeight / 2 - height / 2
                        width:  22
                        height: 22
                        radius: 11
                        color: "#e0e0e0"
                        border { color: "#16213e"; width: 2 }
                    }
                }
            }

            // -------------------------------------------------------- //
            //  Apply button
            // -------------------------------------------------------- //
            Rectangle {
                width:  200
                height: 48
                radius: 24
                color:  applyArea.pressed ? "#c73652" : "#e94560"
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    anchors.centerIn: parent
                    text: qsTr("Apply")
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                }

                MouseArea {
                    id: applyArea
                    anchors.fill: parent
                    onClicked: {
                        var r = Math.round(root.ledR * root.ledBrightness)
                        var g = Math.round(root.ledG * root.ledBrightness)
                        var b = Math.round(root.ledB * root.ledBrightness)
                        serialHandler.sendCommand(
                            "LED:r=" + r + ",g=" + g + ",b=" + b)
                    }
                }
            }
        }
    }
}
