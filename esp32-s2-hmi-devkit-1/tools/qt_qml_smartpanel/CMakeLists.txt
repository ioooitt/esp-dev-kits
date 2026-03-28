cmake_minimum_required(VERSION 3.16)
project(qt_qml_smartpanel VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Support both Qt5 (≥5.15) and Qt6
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick SerialPort)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Quick SerialPort)

set(PROJECT_SOURCES
    main.cpp
    serialhandler.h
    serialhandler.cpp
    qt_qml_smartpanel.qrc
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(qt_qml_smartpanel
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
    )
else()
    add_executable(qt_qml_smartpanel
        ${PROJECT_SOURCES}
    )
endif()

target_link_libraries(qt_qml_smartpanel PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::SerialPort
)

if(${QT_VERSION_MAJOR} EQUAL 6)
    qt_finalize_executable(qt_qml_smartpanel)
endif()
