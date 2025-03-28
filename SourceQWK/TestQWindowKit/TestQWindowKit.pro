QT += core
QT += gui
QT += quick
QT += widgets
QT += quicktemplates2
QT += quickcontrols2
QT += gui-private

CONFIG += c++17 utf8_source

DESTDIR = $$PWD/bin

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

HEADERS += \
    BasicWindowTool.h \

SOURCES += \
    BasicWindowTool.cpp \
    main.cpp

RESOURCES += $$PWD/QML/qml.qrc

INCLUDEPATH += $$PWD/qwindowkit/include
DEPENDPATH += $$PWD/qwindowkit/include
contains(QT_ARCH, x86_64){
    LIBS += -L$$PWD/qwindowkit/win64 -lQWKCore -lQWKQuick
}else{
    LIBS += -L$$PWD/qwindowkit/win32 -lQWKCore -lQWKQuick
}

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
