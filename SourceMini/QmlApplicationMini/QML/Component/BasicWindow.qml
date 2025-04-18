import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Cute.Component 1.0

// 自定义窗口
// 龚建波 2024-01-02
// NOTE 注意 BasicWindow 的 initWidth/Height 不要加 qDpi 后设置
// NOTE 最小宽高通过 minWidth/Height 而不是 minimumWidth/Height
// NOTE 根据内容适应宽高设置 initWidth/Height = 0，此时根据内容的第一个元素来计算宽高
// NOTE 因为是套了一层，设置背景色不能用 color，需要设置 bgColor
// NOTE 如果是自定义边框，Popup 或者 Dialog 的模态阴影需要加上 shadowWidth 和 headerHeight 的 margin
// TODO 触碰屏幕边框时的停靠效果需要调用 win32 接口，待完成
Window {
    id: control

    visible: false
    flags: (frameless
           ? (windowType | Qt.FramelessWindowHint |
              Qt.WindowMinMaxButtonsHint |
              Qt.WindowCloseButtonHint |
              Qt.WindowSystemMenuHint)
           : windowType)
    color: "transparent"
    transientParent: null

    // 窗口初始宽高单独设置，按未缩放大小设置（不用 qDpi）
    // 如果需要根据内容计算宽高则 initWidth/Height 设置为 0（不适用于 autoSize）
    required property int initWidth
    required property int initHeight
    // 窗口最小宽高，按未缩放大小设置（不用 qDpi）
    property int minWidth: 0
    property int minHeight: 0
    // 宽高是否自适应，如果 =true 则根据 initWidth/Height 与 1920/1080 的比例来自适应窗口大小
    property bool autoSize: false

    // 可设置为 Window 或者 Dialog，不用每次都设置所有 flags 属性
    property int windowType: Qt.Window
    // 无边框
    property bool frameless: true
    // Window 默认可拉伸，Dialog 默认不可以
    property bool resizable: (windowType === Qt.Window)
    // 当前是否最大化
    property bool isMax: (visibility === Window.Maximized || visibility === Window.FullScreen)
    // 阴影宽度
    property int shadowWidth: (!frameless || isMax) ? 0 : (win_tool.enableTransparent() ? 12 : 1)
    // 自定义边框的圆角
    property int radius: 0 // (!frameless || isMax) ? 0 : 8
    // 自定义边框相关接口
    property alias windowTool: win_tool
    // 标题栏
    property alias header: win_title
    // 标题栏高度
    property alias headerHeight: win_title.height
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
    // 内容区域
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
        visible: control.frameless
        anchors.fill: win_foreground
        // 阴影小 1px，防止明显的黑边
        anchors.margins: 1
        radius: control.radius
        color: "black"
        layer.enabled: control.isMax ? false : true
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
            anchors.topMargin: control.frameless ? win_title.height : 0
            color: "white"
        }

        // 标题栏
        Rectangle {
            id: win_title
            visible: control.frameless
            width: parent.width
            height: control.frameless ? qDpi(36) : 0
            radius: control.radius
            color: "darkCyan"

            // 标题栏拖动
            WindowMove {
                id: win_move
                anchors.fill: parent
                windowTool: win_tool
                autoMax: control.resizable
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
                    source: "qrc:/Image/Component/icon.svg"
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
                    rightMargin: qDpi(12)
                    verticalCenter: parent.verticalCenter
                }
                TitleButton {
                    id: btn_min
                    visible: control.headerFlags & Qt.WindowMinimizeButtonHint
                    // text: "Min"
                    source: "qrc:/Image/Component/min.svg"
                    onClicked: {
                        win_tool.showMin();
                    }
                }
                TitleButton {
                    id: btn_max
                    visible: control.headerFlags & Qt.WindowMaximizeButtonHint
                    // text: control.isMax ? "Normal" : "Max"
                    source: control.isMax
                            ? "qrc:/Image/Component/normal.svg"
                            : "qrc:/Image/Component/max.svg"
                    onClicked: {
                        if (control.isMax) {
                            win_tool.showNormal();
                        } else {
                            win_tool.showMax();
                        }
                    }
                }
                TitleButton {
                    id: btn_close
                    visible: control.headerFlags & Qt.WindowCloseButtonHint
                    // text: "Close"
                    source: "qrc:/Image/Component/close.svg"
                    onClicked: {
                        control.doClose()
                    }
                }
            }
        }

        // 无边框窗口拉伸，放到title之上
        WindowResize {
            id: win_resize
            visible: control.frameless && control.resizable
            anchors.fill: parent
            windowTool: win_tool
        }
    }

    // 定义标题栏按钮样式
    component TitleButton: AbstractButton {
        id: title_button

        property url source
        width: qDpi(34)
        height: qDpi(26)
        // 屏蔽空格触发点击
        Keys.onPressed: event.accepted = (event.key === Qt.Key_Space)
        Keys.onReleased: event.accepted = (event.key === Qt.Key_Space)
        hoverEnabled: true
        checkable: false
        padding: 0

        contentItem: Item {
            implicitWidth: img.width
            implicitHeight: img.height
            ColorImage {
                id: img
                anchors.centerIn: parent
                width: qDpi(16)
                height: qDpi(16)
                source: title_button.source
                sourceSize: Qt.size(width, height)
                color: "white"
            }
        }

        background: Rectangle {
            color: title_button.hovered ? "#55FFFFFF" : "transparent"
            radius: 4
        }
    }

    Component.onCompleted: {
        sizeAdaption()
    }

    // 窗口位置大小计算
    function sizeAdaption(targetWindow = null) {
        let w = control.width
        let h = control.height
        let s = targetWindow ? targetWindow.screen : control.screen
        if (autoSize) {
            // 更宽则按照高度适应，更高则按照宽度适应
            if (s.width / s.height > 1920 / 1080) {
                w = Math.floor(control.initWidth / 1080 * s.height) + control.shadowWidth * 2
                h = Math.floor(control.initHeight / 1080 * s.height) + control.shadowWidth * 2
            } else {
                w = Math.floor(control.initWidth / 1920 * s.width) + control.shadowWidth * 2
                h = Math.floor(control.initHeight / 1920 * s.width) + control.shadowWidth * 2
            }
        } else {
            // initWidth/Height = 0 则根据内容计算宽高
            if (control.initWidth > 0) {
                w = qDpi(control.initWidth) + control.shadowWidth * 2
            } else {
                w = win_content.children[0].width + control.shadowWidth * 2
            }
            if (control.initHeight > 0) {
                h = qDpi(control.initHeight) + control.shadowWidth * 2
            } else {
                h = control.headerHeight + win_content.children[0].height + control.shadowWidth * 2
            }
        }
        if (w < qDpi(control.minWidth)) {
            w = qDpi(control.minWidth)
        }
        if (h < qDpi(control.minHeight)) {
            h = qDpi(control.minHeight)
        }
        if (w > s.width - qDpi(40)) {
            w = s.width - qDpi(40)
        }
        if (h > s.height - qDpi(40)) {
            h = s.height - qDpi(40)
        }
        control.width = w
        control.height = h
        control.moveToCenter(targetWindow)
    }

    // 重写show接口，去掉transientParent，让任务栏展示子窗口
    // 初始化 transientParent: null 可能会无效，所以改为重写show
    function show()
    {
        // 已经可见就上浮
        if (control.visible) {
            control.raise()
            control.requestActivate()
            // win_tool.showNormal()
            // return
        }
        // 如果需要所有窗口在任务栏都是独立的，要去掉 transientParent
        if (control.transientParent) {
            control.transientParent = null
        }
        sizeAdaption()
        // moveToCenter()
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
