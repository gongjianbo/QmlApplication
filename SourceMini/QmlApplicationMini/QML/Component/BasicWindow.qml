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
// NOTE 因为是套了一层，设置背景色不能用 color，需要设置 bgColor
// TODO 触碰屏幕边框时的停靠效果需要调用 win32 接口，待完成
Window {
    id: control

    visible: false
    flags: framless
           ? (windowType | Qt.FramelessWindowHint |
              Qt.WindowMinMaxButtonsHint |
              Qt.WindowCloseButtonHint |
              Qt.WindowSystemMenuHint)
           : windowType
    color: win_tool.enableTransparent() ? "transparent" : "black"

    // 宽高单独设置，按未缩放大小设置，因为切换缩放比
    required property int initWidth
    required property int initHeight
    // 最小宽高，按未缩放大小设置
    property int minWidth: 0
    property int minHeight: 0
    // 宽高是否自适应，如果 =true 则根据 initWidth/Height 与 1920/1080 的比例来自适应窗口大小
    property bool autoSize: false

    // 可设置为 Window 或者 Dialog，不用每次都设置所有 flags 属性
    property int windowType: Qt.Window
    // 无边框
    property bool framless: true
    // Window 默认可拉伸，Dialog 默认不可以
    property bool resizable: (windowType === Qt.Window)
    // 阴影宽度
    property int shadowWidth: (!framless || win_move.isMax) ? 0 : (win_tool.enableTransparent() ? 12 : 1)
    // 自定义边框的圆角
    property int radius: 0 // (!framless || win_move.isMax) ? 0 : 8
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
        visible: control.framless && win_tool.enableTransparent()
        anchors.fill: win_foreground
        // 阴影小 1px，防止明显的黑边
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
            anchors.topMargin: control.framless ? win_title.height : 0
            color: "white"
        }

        // 标题栏
        Rectangle {
            id: win_title
            visible: control.framless
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
                    // text: win_move.isMax ? "Normal" : "Max"
                    source: win_move.isMax
                            ? "qrc:/Image/Component/normal.svg"
                            : "qrc:/Image/Component/max.svg"
                    onClicked: {
                        if (win_move.isMax) {
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
            visible: control.framless && control.resizable
            anchors.fill: parent
            windowTool: win_tool
            minWidth: qDpi(control.minWidth)
            minHeight: qDpi(control.minHeight)
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
        // 初始化时根据 dpi 重置宽高，阴影额外加宽高
        if (autoSize) {
            control.width = Math.floor(control.initWidth / 1920 * screen.width) + control.shadowWidth * 2
            control.height = Math.floor(control.initHeight / 1080 * screen.height) + control.shadowWidth * 2
        } else {
            control.width = qDpi(control.initWidth) + control.shadowWidth * 2
            control.height = qDpi(control.initHeight) + control.shadowWidth * 2
        }
    }

    // 重写show接口，去掉transientParent，让任务栏展示子窗口
    // 初始化 transientParent: null 可能会无效，所以改为重写show
    function show()
    {
        // 已经可见就上浮
        if (control.visible) {
            control.raise()
            control.requestActivate()
            win_tool.showNormal()
            return
        }
        // 如果需要所有窗口在任务栏都是独立的，要去掉 transientParent
        if (control.transientParent) {
            control.transientParent = null
        }
        moveToCenter()
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
