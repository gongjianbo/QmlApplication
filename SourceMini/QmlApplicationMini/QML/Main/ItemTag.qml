import QtQuick 2.15

// 文本标记
// 用来标记 UI 中样式对应代码第几项
Rectangle {
    id: control

    property int index
    property alias text: tag_text.text

    anchors{
        right: parent.left
        bottom: parent.top
        margins: qDpi(6)
    }
    width: (tag_index.height > tag_index.width ? tag_index.height : tag_index.width) + qDpi(6)
    height: tag_index.height + qDpi(6)
    radius: height / 2
    color: "red"

    Text {
        id: tag_index
        anchors.centerIn: parent
        font.pixelSize: qDpi(16)
        font.bold: true
        color: "white"
        text: control.index.toString()
    }

    Text {
        id: tag_text
        anchors{
            left: parent.right
            leftMargin: qDpi(6)
            verticalCenter: parent.verticalCenter
        }
        font.pixelSize: qDpi(16)
        color: "red"
    }
}
