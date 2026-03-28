# Qt QML Smart Panel

A **Qt Quick (QML) host-side application** that mirrors the UI of the
[ESP32-S2-HMI-DevKit-1](https://docs.espressif.com/projects/esp-idf/en/latest/)
smart-panel example and can communicate with the board over a USB–serial
connection.

---

## Features

| Page | Description |
|------|-------------|
| **Dashboard** | Overview cards showing temperature, humidity, light and LED state |
| **Clock** | Analog + digital clock (local system time) |
| **Sensors** | Live gauge rings for temperature, humidity and ambient light, plus a temperature history sparkline |
| **LED Control** | WS2812 LED colour picker (presets + RGB sliders + brightness), sends `LED:r=,g=,b=` command to the board |
| **Settings** | Serial port selector, baud-rate picker, connect/disconnect, raw serial log |

When **no board is connected** the application shows **simulated** sensor
data so the UI can be developed and tested without hardware.

---

## Requirements

| Tool | Minimum version |
|------|----------------|
| Qt   | 5.15 **or** Qt 6.x |
| CMake | 3.16 |
| C++ compiler | C++17 |

Qt modules needed: `Qt::Core`, `Qt::Quick`, `Qt::SerialPort`

---

## Build

```bash
mkdir build && cd build
cmake .. -DCMAKE_PREFIX_PATH=/path/to/Qt/6.x.x/<platform>
cmake --build . --parallel
```

On Linux you may need:

```bash
sudo apt install qtbase5-dev qtdeclarative5-dev libqt5serialport5-dev
# or for Qt 6
sudo apt install qt6-base-dev qt6-declarative-dev qt6-serialport-dev
```

---

## Running

```bash
./qt_qml_smartpanel
```

The window is 480 × 800 px, matching the board's TFT-LCD panel.

---

## Connecting to the Board

1. Flash the `smart-panel` example onto the ESP32-S2-HMI-DevKit-1.
2. Connect the board via USB to the host PC.
3. Open the **Settings** page in this application.
4. Select the correct serial port (e.g. `/dev/ttyUSB0` or `COM3`) and baud
   rate (default **115200**).
5. Press **Connect**.

### Serial protocol

The application speaks a simple line-oriented protocol:

| Direction | Format | Example |
|-----------|--------|---------|
| Board → Host | `SENSOR:temp=<f>,humi=<f>,light=<f>` | `SENSOR:temp=25.3,humi=61.0,light=342` |
| Host → Board | `LED:r=<0-255>,g=<0-255>,b=<0-255>` | `LED:r=229,g=69,b=96` |

Add the following snippet to the ESP32 firmware to enable the host
application to read sensor data:

```c
// In your sensor task (runs every ~1 s)
float temp, humi, light;
hdc1080_get_temperature(&temp);
hdc1080_get_humidity(&humi);
bh1750_get_lux(&light);
printf("SENSOR:temp=%.1f,humi=%.1f,light=%.0f\n", temp, humi, light);
```

---

## Project structure

```
qt_qml_smartpanel/
├── CMakeLists.txt              Qt CMake project (Qt5/Qt6)
├── main.cpp                    Application entry point
├── serialhandler.h/.cpp        C++ serial-port backend exposed to QML
├── main.qml                    Root window, status bar, navigation bar
├── qml/
│   ├── Dashboard.qml           Overview page
│   ├── ClockPage.qml           Analog + digital clock
│   ├── SensorPage.qml          Sensor gauges and history
│   ├── LedPage.qml             LED colour control
│   └── SettingsPage.qml        Serial port settings and log
└── qt_qml_smartpanel.qrc       Qt resource file
```

---

## License

Copyright 2021 Espressif Systems (Shanghai) Co. Ltd.

Licensed under the Apache License, Version 2.0.  See the
[LICENSE](../../../../LICENSE) file in the repository root.
