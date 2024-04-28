QT += core
QT += gui
QT += widgets
QT += quick
QT += qml
QT += core-private
QT += gui-private
QT += quick-private

CONFIG += c++17
CONFIG += utf8_source
CONFIG += resources_big

DEFINES += QT_DEPRECATED_WARNINGS

TEMPLATE = app
TARGET = QmlApplicationMini
DESTDIR = $$PWD/bin

SOURCES += \
    main.cpp

RESOURCES += \
    $$PWD/QML/qml.qrc \
    $$PWD/Resource/res.qrc

INCLUDEPATH += $$PWD/Component
include($$PWD/Component/Component.pri)

win32 {
    # RC_FILE += $$PWD/QmlApplicationMini.rc

    VERSION = 1.2.3.00
    RC_ICONS = $$PWD/Resource/Image/icon.ico
    # RC_LANG = 0x0800
    # QMAKE_TARGET_COMPANY ="GongJianBo"
    # QMAKE_TARGET_DESCRIPTION = "Qml Application Template"
    # QMAKE_TARGET_COPYRIGHT = "Copyright(C) 2024 GongJianBo"
    # QMAKE_TARGET_PRODUCT = $${TARGET}
}

