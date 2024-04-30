import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T
import QtQuick.Layouts 1.15
import Cute.Component 1.0

// 其他缩放
Rectangle {
    id: top

    // 1.Rectangle geometry 非整数时开抗锯齿模糊
    Rectangle {
        x: 100.3
        y: 100.4
        width: 100.5
        height: 30.5
        border.color: "#00A7AE"
        // 开启 antialiasing 后， geometry 有非整数会出现模糊
        antialiasing: true
        // 有圆角时，antialiasing 默认开启
        // radius: 4
        // 设置 layer 后模糊消失
        // layer.enabled: true
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("rect", parent.x, parent.y, parent.width, parent.height)
            }
        }
    }

    Rectangle {
        x: 100.3
        y: 200.4
        width: 100.5
        height: 30.5
        border.color: "#00A7AE"
        antialiasing: true
        layer.enabled: true
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("rect", parent.x, parent.y, parent.width, parent.height)
            }
        }
    }
}
