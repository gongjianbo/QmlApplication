import QtQuick 2.15

// 文本标记
Rectangle {
    id: control

    property alias text: tag_text.text

    anchors{
        right: parent.left
        bottom: parent.top
        margins: qDpi(6)
    }
    width: (tag_text.height > tag_text.width ? tag_text.height : tag_text.width) + 4
    height: tag_text.height + 4
    radius: height / 2
    border.color: "red"

    Text {
        id: tag_text
        anchors.centerIn: parent
        font.pixelSize: 14
        color: "red"
    }
}
