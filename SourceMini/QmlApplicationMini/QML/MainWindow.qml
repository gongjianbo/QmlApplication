import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import Cute.Component 1.0

BasicWindow {
    id: control

    // Qt.Dialog 或者 Qt.Window
    windowType: Qt.Window
    modality: Qt.ApplicationModal
    width: 800
    height: 500
    visible: false
    title: qsTr("Qml Application Mini")

    property real ratio: windowTool.devicePixelRatio
    onRatioChanged: {
        console.log("ratio change", windowTool.devicePixelRatio)
    }
    onVisibleChanged: {
        console.log("visible", visible, windowTool.devicePixelRatio)
    }

    Rectangle {
        width: 100 * ratio
        height: 100
        color: "green"
        onWidthChanged: {
            console.log("width change", width)
        }
    }
}
