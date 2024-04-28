import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Cute.Component 1.0

// 自定义窗口
// 龚建波 2024-01-02
Window {
    id: control

    visible: false
    flags: windowType | Qt.FramelessWindowHint |
           Qt.WindowMinMaxButtonsHint |
           Qt.WindowCloseButtonHint |
           Qt.WindowSystemMenuHint
    color: "transparent"

    // 可设置为 Window 或者 Dialog，不用每次都设置所有 flags 属性
    property int windowType: Qt.Window
    // Window 默认可拉伸，Dialog 默认不可以
    property bool resizable: (windowType === Qt.Window)
    // 阴影宽度
    property int shadowWidth: win_move.isMax ? 0 : 12
    // 自定义边框的圆角
    property int radius: 0 // win_move.isMax ? 0 : 8
    // 自定义边框相关接口
    property alias windowTool: win_tool
    // 标题栏
    property alias header: win_title
    // 标题栏按钮可见性
    property int headerFlags: (windowType === Qt.Window)
                              ? (Qt.WindowMinimizeButtonHint |
                                 Qt.WindowMaximizeButtonHint |
                                 Qt.WindowCloseButtonHint)
                              : Qt.WindowCloseButtonHint
    // 标题栏图标
    property alias icon: win_icon.source
    // 背景色
    property alias bgColor: win_content.color
    // 内容
    default property alias contentData: win_content.data
    // 点击关闭时回调函数
    property var doClose: function() {
        control.close()
    }

    BasicWindowTool {
        id: win_tool
        window: control
    }

    // 底部作阴影
    Rectangle {
        id: win_background
        anchors.fill: win_foreground
        // 阴影小1px，防止明显的黑边
        anchors.margins: 1
        radius: control.radius
        color: "black"
        layer.enabled: win_move.isMax ? false : true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 2
            verticalOffset: 2
            radius: 12
            samples: 16
            spread: 0
            color: "#88000000"
        }
    }

    Item {
        id: win_foreground
        anchors.fill: parent
        anchors.margins: control.shadowWidth

        // 内容区域
        Rectangle {
            id: win_content
            anchors.fill: parent
            anchors.topMargin: win_title.height
            color: "#F8F9F9"
        }

        // 标题栏
        Rectangle {
            id: win_title
            width: parent.width
            height: qDpi(36)
            radius: control.radius
            color: "darkCyan"

            // 标题栏拖动
            WindowMove {
                id: win_move
                anchors.fill: parent
                windowTool: win_tool
                autoMax: control.resizable
                shadowWidth: control.shadowWidth
            }

            // 左侧 icon + 标题
            Row {
                anchors{
                    left: parent.left
                    leftMargin: 10
                    verticalCenter: parent.verticalCenter
                }
                spacing: qDpi(8)
                Image {
                    id: win_icon
                    anchors.verticalCenter: parent.verticalCenter
                    width: qDpi(28)
                    height: qDpi(28)
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/Image/icon.png"
                    sourceSize: Qt.size(width, height)
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: control.title
                    color: "white"
                    font.pixelSize: qDpi(14)
                }
            }

            // 右侧窗口按钮
            Row {
                anchors{
                    right: parent.right
                    rightMargin: 16
                    verticalCenter: parent.verticalCenter
                }
                spacing: 4
                Button {
                    id: btn_min
                    visible: control.headerFlags & Qt.WindowMinimizeButtonHint
                    width: qDpi(60)
                    height: qDpi(26)
                    font.pixelSize: qDpi(12)
                    text: "Min"
                    onClicked: {
                        win_tool.showMin();
                    }
                }
                Button {
                    id: btn_max
                    visible: control.headerFlags & Qt.WindowMaximizeButtonHint
                    width: qDpi(60)
                    height: qDpi(26)
                    font.pixelSize: qDpi(12)
                    text: win_move.isMax ? "Normal" : "Max"
                    onClicked: {
                        if (win_move.isMax) {
                            win_tool.showNormal();
                        } else {
                            win_tool.showMax();
                        }
                    }
                }
                Button {
                    id: btn_close
                    visible: control.headerFlags & Qt.WindowCloseButtonHint
                    width: qDpi(60)
                    height: qDpi(26)
                    font.pixelSize: qDpi(12)
                    text: "Close"
                    onClicked: {
                        control.doClose()
                    }
                }
            }
        }

        // 无边框窗口拉伸，放到title之上
        WindowResize {
            id: win_resize
            anchors.fill: parent
            windowTool: win_tool
            visible: control.resizable
        }
    }

    // 重写show接口，去掉transientParent，让任务栏展示子窗口
    // 初始化 transientParent: null 可能会无效，所以改为重写show
    function show()
    {
        if (control.visible) {
            control.raise()
            control.requestActivate()
            // return
        }
        // if (control.transientParent) {
        //     control.transientParent = null
        // }
        //moveToCenter()
        win_tool.showNormal()
    }

    // 重写最大化最小化等接口
    function showMaximized()
    {
        win_tool.showMax()
    }
    function showMinimized()
    {
        win_tool.showMin()
    }
    function showNormal()
    {
        win_tool.showNormal()
    }

    // 恢复位置到父窗口所在屏幕中心
    function resetCenter()
    {
        control.show()
        //暂时不考虑任务栏的高度
        let w_screen = control.transientParent ? control.transientParent.screen : control.screen
        control.x = w_screen.virtualX + (w_screen.width - control.width) / 2
        control.y = w_screen.virtualY + (w_screen.height - control.height) / 2
    }

    // 移动到中心
    function moveToCenter(attachWin)
    {
        win_tool.moveToCenter(attachWin)
    }

    // 窗口全屏
    // qml的fullscreen有bug，改为将窗口设置为显示屏大小
    function showFullScreen()
    {
        if (Qt.platform.os !== "windows" && Qt.platform.os !== "winrt") {
            win_tool.showMax();
            return
        }
        control.show()
        let w_screen = control.transientParent ? control.transientParent.screen : control.screen
        control.x = w_screen.virtualX - 1 - shadowWidth
        control.y = w_screen.virtualY - 1 - shadowWidth
        control.width = w_screen.width + 2 + shadowWidth * 2
        control.height = w_screen.height + 2 + shadowWidth * 2
    }

    Component.onCompleted: {
        console.log("comp", width, height)
        control.width = qDpi(control.width)
        control.height = qDpi(control.height)
    }

    // 计算dpi缩放后的尺寸-整数
    function qDpi(val)
    {
        return Math.floor(win_tool.devicePixelRatio * val)
    }

    // 计算dpi缩放后的尺寸-浮点数
    function qDpiF(val)
    {
        return win_tool.devicePixelRatio * val
    }
}
