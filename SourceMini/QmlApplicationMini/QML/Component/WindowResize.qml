import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import Cute.Component 1.0

// 无边框缩放
// 龚建波 2022-11-04
Item {
    id: control

    // 窗口工具类，Window内共享一个tool
    required property BasicWindowTool windowTool
    // 需绑定target，属性绑定外部window id会循环引用
    property Window target: Window.window
    // 缩放拖动区域
    property int handleWidth: 5
    property int handleZ: 100
    property bool onResize: false

    // press时记录原geometry
    property rect tempRect
    // 鼠标屏幕坐标
    property point tempGlobalPos
    // mouse.pos与global.pos差
    property point tempOffsetPos
    // 计算得到的geometry
    property rect calcRect

    Item {
        z: handleZ
        anchors.fill: parent
        enabled: !target.isMax
        // 左上
        MouseArea {
            width: handleWidth * 2
            height: handleWidth * 2
            z: 1
            cursorShape: Qt.SizeFDiagCursor
            // Rectangle{ anchors.fill: parent; color: "blue" }
            onPressed: beginResize(mouse, cursorShape);
            onReleased: endResize();
            onPositionChanged: doResize(true, false, true, false, mouse);
        }
        // 右上
        MouseArea {
            anchors.right: parent.right
            width: handleWidth * 2
            height: handleWidth * 2
            z: 1
            cursorShape: Qt.SizeBDiagCursor
            // Rectangle{ anchors.fill: parent; color: "blue" }
            onPressed: beginResize(mouse, cursorShape);
            onReleased: endResize();
            onPositionChanged: doResize(true, false, false, true, mouse);
        }
        // 左下
        MouseArea {
            anchors.bottom: parent.bottom
            width: handleWidth * 2
            height: handleWidth * 2
            z: 1
            cursorShape: Qt.SizeBDiagCursor
            // Rectangle{ anchors.fill: parent; color: "blue" }
            onPressed: beginResize(mouse, cursorShape);
            onReleased: endResize();
            onPositionChanged: doResize(false, true, true, false, mouse);
        }
        // 右下
        MouseArea {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: handleWidth * 2
            height: handleWidth * 2
            z: 1
            cursorShape: Qt.SizeFDiagCursor
            // Rectangle{ anchors.fill: parent; color: "blue" }
            onPressed: beginResize(mouse, cursorShape);
            onReleased: endResize();
            onPositionChanged: doResize(false, true, false, true, mouse);
        }
        // 上
        MouseArea {
            width: target.width
            height: handleWidth
            cursorShape: Qt.SizeVerCursor
            // Rectangle{ anchors.fill: parent; color: "green" }
            onPressed: beginResize(mouse, cursorShape);
            onReleased: endResize();
            onPositionChanged: doResize(true, false, false, false, mouse);
        }
        // 下
        MouseArea {
            anchors.bottom: parent.bottom
            width: target.width
            height: handleWidth
            cursorShape: Qt.SizeVerCursor
            // Rectangle{ anchors.fill: parent; color: "green" }
            onPressed: beginResize(mouse, cursorShape);
            onReleased: endResize();
            onPositionChanged: doResize(false, true, false, false, mouse);
        }
        // 左
        MouseArea {
            width: handleWidth
            height: target.height
            cursorShape: Qt.SizeHorCursor
            // Rectangle{ anchors.fill: parent; color: "green" }
            onPressed: beginResize(mouse, cursorShape);
            onReleased: endResize();
            onPositionChanged: doResize(false, false, true, false, mouse);
        }
        // 右
        MouseArea {
            anchors.right: parent.right
            width: handleWidth
            height: target.height
            cursorShape: Qt.SizeHorCursor
            // Rectangle{ anchors.fill: parent; color: "green" }
            onPressed: beginResize(mouse, cursorShape);
            onReleased: endResize();
            onPositionChanged: doResize(false, false, false, true, mouse);
        }
    }

    function beginResize(mouse, shape) {
        if (!windowTool)
            return;
        // window rect
        tempRect = Qt.rect(target.x, target.y, target.width, target.height);
        calcRect = tempRect;
        // mouse offset
        tempGlobalPos = windowTool.pos();
        tempOffsetPos = Qt.point(mouse.x - tempGlobalPos.x,
                                 mouse.y - tempGlobalPos.y);
        onResize = true;
        // 设置鼠标形状，防止移动到item外部后变形
        windowTool.setOverrideCursor(shape);
    }

    function endResize(){
        if (!windowTool)
            return;
        onResize = false;
        windowTool.restoreOverrideCursor();
    }

    // m-上下左右为bool参数，表示在哪个边移动
    // mouse为MouseEvent
    function doResize(mtop, mbottom, mleft, mright, mouse){
        if (!onResize || !windowTool)
            return;

        tempGlobalPos = windowTool.pos();
        if (mtop) {
            calcRect.y = tempRect.y + tempGlobalPos.y + tempOffsetPos.y;
            if(calcRect.y > tempRect.y + tempRect.height - qDpi(target.refMinHeight))
                calcRect.y = tempRect.y + tempRect.height - qDpi(target.refMinHeight);
            calcRect.height = tempRect.y + tempRect.height - calcRect.y;
        } else if (mbottom) {
            calcRect.height = tempRect.height + tempGlobalPos.y + tempOffsetPos.y;
            if(calcRect.height < qDpi(target.refMinHeight))
                calcRect.height = qDpi(target.refMinHeight);
        }

        if (mleft) {
            calcRect.x = tempRect.x + tempGlobalPos.x + tempOffsetPos.x;
            if(calcRect.x > tempRect.x + tempRect.width - qDpi(target.refMinWidth))
                calcRect.x = tempRect.x + tempRect.width - qDpi(target.refMinWidth);
            calcRect.width = tempRect.x + tempRect.width - calcRect.x;
        } else if (mright) {
            calcRect.width = tempRect.width+tempGlobalPos.x + tempOffsetPos.x;
            if (calcRect.width < qDpi(target.refMinWidth))
                calcRect.width = qDpi(target.refMinWidth);
        }
        target.setGeometry(calcRect);
    }
}
