import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.impl 2.12
import QtQuick.Templates 2.12 as T

// 无标题栏弹框
// 龚建波 2024-05-09
T.Popup {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    margins: 1
    padding: 1

    background: Rectangle {
    }

    T.Overlay.modal: Item {
        // 模态阴影考虑无边框
        Rectangle {
            anchors.fill: parent
            anchors.margins: shadowWidth
            anchors.topMargin: headerHeight + shadowWidth
            color: Color.transparent(control.palette.shadow, 0.5)
        }
    }

    T.Overlay.modeless: Item {
        Rectangle {
            anchors.fill: parent
            anchors.margins: shadowWidth
            anchors.topMargin: headerHeight + shadowWidth
            color: Color.transparent(control.palette.shadow, 0.12)
        }
    }
}
