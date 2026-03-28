/**
 * @file serialhandler.cpp
 * @brief Serial port handler implementation
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

#include "serialhandler.h"

#include <QSerialPortInfo>
#include <QtMath>

SerialHandler::SerialHandler(QObject *parent)
    : QObject(parent)
    , m_serial(new QSerialPort(this))
    , m_simulationTimer(new QTimer(this))
{
    connect(m_serial, &QSerialPort::readyRead,
            this, &SerialHandler::onReadyRead);
    connect(m_serial, &QSerialPort::errorOccurred,
            this, &SerialHandler::onErrorOccurred);

    // Provide simulated data when not connected to real hardware
    connect(m_simulationTimer, &QTimer::timeout,
            this, &SerialHandler::simulateSensorData);
    m_simulationTimer->start(1500);
}

SerialHandler::~SerialHandler()
{
    if (m_serial->isOpen()) {
        m_serial->close();
    }
}

QStringList SerialHandler::availablePorts() const
{
    QStringList ports;
    for (const QSerialPortInfo &info : QSerialPortInfo::availablePorts()) {
        ports << info.portName();
    }
    return ports;
}

bool SerialHandler::connectToPort(const QString &portName, int baudRate)
{
    if (m_serial->isOpen()) {
        m_serial->close();
    }

    m_serial->setPortName(portName);
    m_serial->setBaudRate(baudRate);
    m_serial->setDataBits(QSerialPort::Data8);
    m_serial->setParity(QSerialPort::NoParity);
    m_serial->setStopBits(QSerialPort::OneStop);
    m_serial->setFlowControl(QSerialPort::NoFlowControl);

    if (m_serial->open(QIODevice::ReadWrite)) {
        m_connected = true;
        m_simulationTimer->stop();
        emit connectedChanged();
        return true;
    }
    return false;
}

void SerialHandler::disconnectPort()
{
    if (m_serial->isOpen()) {
        m_serial->close();
    }
    m_connected = false;
    m_simulationTimer->start(1500);
    emit connectedChanged();
}

void SerialHandler::sendCommand(const QString &command)
{
    if (m_serial->isOpen()) {
        m_serial->write((command + "\r\n").toUtf8());
    }
}

void SerialHandler::refreshPorts()
{
    emit portsChanged();
}

void SerialHandler::onReadyRead()
{
    m_readBuffer += QString::fromUtf8(m_serial->readAll());
    while (m_readBuffer.contains('\n')) {
        int idx = m_readBuffer.indexOf('\n');
        QString line = m_readBuffer.left(idx).trimmed();
        m_readBuffer = m_readBuffer.mid(idx + 1);
        if (!line.isEmpty()) {
            parseLine(line);
            emit dataReceived(line);
        }
    }
}

void SerialHandler::parseLine(const QString &line)
{
    // Expected format: "SENSOR:temp=25.5,humi=60.0,light=350"
    if (line.startsWith("SENSOR:")) {
        bool changed = false;
        for (const QString &part : line.mid(7).split(',')) {
            const QStringList kv = part.split('=');
            if (kv.size() == 2) {
                bool ok = false;
                float val = kv[1].trimmed().toFloat(&ok);
                if (ok) {
                    const QString key = kv[0].trimmed();
                    if (key == "temp")  { m_temperature = val; changed = true; }
                    else if (key == "humi")  { m_humidity    = val; changed = true; }
                    else if (key == "light") { m_light       = val; changed = true; }
                }
            }
        }
        if (changed) {
            emit sensorDataChanged();
        }
    }
}

void SerialHandler::onErrorOccurred(QSerialPort::SerialPortError error)
{
    if (error != QSerialPort::NoError && m_connected) {
        m_connected = false;
        m_simulationTimer->start(1500);
        emit connectedChanged();
    }
}

void SerialHandler::simulateSensorData()
{
    m_simPhase += 0.12f;
    m_temperature = 24.5f + 2.0f  * qSin(static_cast<double>(m_simPhase * 0.30f));
    m_humidity    = 58.0f + 8.0f  * qCos(static_cast<double>(m_simPhase * 0.20f));
    m_light       = 300.0f + 100.0f * qSin(static_cast<double>(m_simPhase * 0.15f));
    emit sensorDataChanged();
}
