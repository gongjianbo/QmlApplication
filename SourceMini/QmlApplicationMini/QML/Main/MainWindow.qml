import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import Cute.Component 1.0

import "../Component"

// 主窗口
BasicWindow {
    id: control

    windowType: Qt.Window
    modality: Qt.ApplicationModal
    initWidth: 800
    initHeight: 600
    minWidth: 400
    minHeight: 300
    autoSize: true
    visible: false
    title: String(qsTr("Qml Application Mini (%1%)")).arg((windowTool.devicePixelRatio * 100).toFixed(0))

    TabBar {
        id: tab_bar
        width: parent.width
        TabButton {
            text: qsTr("文本")
        }
        TabButton {
            text: qsTr("图片")
        }
        TabButton {
            text: qsTr("其他")
        }
    }
    StackLayout {
        id: stack_layout
        currentIndex: tab_bar.currentIndex
        anchors.fill: parent
        anchors.topMargin: tab_bar.height
        PageText {
            id: page_text
        }
        PageImage {
            id: page_image
        }
        PageOther {
            id: page_other
        }
    }
}
