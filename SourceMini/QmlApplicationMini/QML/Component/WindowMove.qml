import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import Cute.Component 1.0

// 无边框移动
// 龚建波 2022-11-04
Item {
    id: control

    // 窗口工具类，Window内共享一个tool
    required property BasicWindowTool windowTool
    // 需绑定target，属性绑定外部window id会循环引用
    property Window target: Window.window
    // 拖到顶部放大
    property bool autoMax: true
    property bool onMove: false

    // 鼠标屏幕坐标
    property point tempGlobalPos
    // target.pos与global.pos差
    property point tempOffsetPos
    // 距离顶部px
    property int tempTopSpace

    // Rectangle{ anchors.fill: parent; color: "orange"; }
    MouseArea {
        z: -1
        anchors.fill: parent
        onPressed: {
            if (target.isMax && !autoMax || !windowTool)
                return;

            // mouse offset
            tempGlobalPos = windowTool.pos();
            tempOffsetPos = Qt.point(target.x - tempGlobalPos.x,
                                     target.y - tempGlobalPos.y);
            onMove = true;
        }
        onReleased: {
            if (onMove && autoMax) {
                // 拖到顶上最大化
                tempTopSpace = target.y - target.screen.virtualY + target.shadowWidth;
                // 给定一个区间，支持竖向多屏
                if (tempTopSpace <- 1 && tempTopSpace >- control.height) {
                    target.y = target.screen.virtualY;
                    windowTool.showMax();
                }
            }
            onMove = false;
        }
        onPositionChanged: {
            if (!onMove || !windowTool)
                return;

            if (target.isMax && autoMax) {
                // 最大化时拖动恢复为普通状态
                let max_wdith = target.width;
                windowTool.showNormal();
                let normal_width = target.width;
                // 放大缩小时mouse.x位置比例
                let normal_x = mouse.x / max_wdith * normal_width;
                // console.log(tempOffsetPos.x, tempGlobalPos.x, normal_x)
                // 默认作为标题栏，宽度同window宽度==来计算
                tempOffsetPos.x = -normal_x;
                tempOffsetPos.y -= target.shadowWidth;
            }
            tempGlobalPos = windowTool.pos();
            target.x = tempGlobalPos.x + tempOffsetPos.x;
            target.y = tempGlobalPos.y + tempOffsetPos.y;
        }
        onDoubleClicked: {
            // 避免触发移动
            onMove = false;
            if (!autoMax)
                return;

            // 双击放大缩小
            if (target.isMax) {
                windowTool.showNormal();
            } else {
                windowTool.showMax();
            }
        }
    }
}
