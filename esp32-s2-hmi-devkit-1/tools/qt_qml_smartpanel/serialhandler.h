/**
 * @file serialhandler.h
 * @brief Serial port handler for ESP32-S2 HMI DevKit-1 communication
 * @version 1.0
 *
 * @copyright Copyright 2021 Espressif Systems (Shanghai) Co. Ltd.
 *
 *      Licensed under the Apache License, Version 2.0 (the "License");
 *      you may not use this file except in compliance with the License.
 *      You may obtain a copy of the License at
 *
 *               http://www.apache.org/licenses/LICENSE-2.0
 *
 *      Unless required by applicable law or agreed to in writing, software
 *      distributed under the License is distributed on an "AS IS" BASIS,
 *      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *      See the License for the specific language governing permissions and
 *      limitations under the License.
 */

#pragma once

#include <QObject>
#include <QSerialPort>
#include <QStringList>
#include <QTimer>

/**
 * @brief Manages the serial connection to an ESP32-S2 HMI DevKit-1 board.
 *
 * When not connected to real hardware the class simulates slowly changing
 * sensor readings so the QML UI can be developed and tested without a board.
 *
 * Expected serial protocol from the board (one message per line):
 *   SENSOR:temp=<f>,humi=<f>,light=<f>
 *   LED:r=<0-255>,g=<0-255>,b=<0-255>
 */
class SerialHandler : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool     connected   READ isConnected  NOTIFY connectedChanged)
    Q_PROPERTY(float    temperature READ temperature  NOTIFY sensorDataChanged)
    Q_PROPERTY(float    humidity    READ humidity     NOTIFY sensorDataChanged)
    Q_PROPERTY(float    light       READ light        NOTIFY sensorDataChanged)
    Q_PROPERTY(QStringList availablePorts READ availablePorts NOTIFY portsChanged)

public:
    explicit SerialHandler(QObject *parent = nullptr);
    ~SerialHandler() override;

    bool       isConnected()    const { return m_connected; }
    float      temperature()    const { return m_temperature; }
    float      humidity()       const { return m_humidity; }
    float      light()          const { return m_light; }
    QStringList availablePorts() const;

public slots:
    /** Connect to the given serial port at the specified baud rate. */
    bool connectToPort(const QString &portName, int baudRate = 115200);

    /** Disconnect from the current serial port. */
    void disconnectPort();

    /** Send a text command to the board (newline is appended automatically). */
    void sendCommand(const QString &command);

    /** Refresh the list of available serial ports. */
    void refreshPorts();

signals:
    void connectedChanged();
    void sensorDataChanged();
    void portsChanged();
    void dataReceived(const QString &line);

private slots:
    void onReadyRead();
    void onErrorOccurred(QSerialPort::SerialPortError error);
    void simulateSensorData();

private:
    void parseLine(const QString &line);

    QSerialPort *m_serial           = nullptr;
    QTimer      *m_simulationTimer  = nullptr;
    QString      m_readBuffer;

    bool  m_connected   = false;
    float m_temperature = 25.5f;
    float m_humidity    = 60.0f;
    float m_light       = 350.0f;
    float m_simPhase    = 0.0f;
};
