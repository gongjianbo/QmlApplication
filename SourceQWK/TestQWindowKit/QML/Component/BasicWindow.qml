import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QWindowKit 1.0
import GongJianBo 1.0

// 自定义窗口-基于QWindowKit无边框库
// 龚建波 2025-03-28
// QWindowKit问题：
// 属性绑定visible:true，win10会有一圈白色
// 修改Window flags显示异常
// 调用close关闭后再show显示异常
Window {
    id: control

    visible: false
    color: "white"
    transientParent: null
    title: "QWindowKit"

    // 窗口初始宽高单独设置，按未缩放大小设置（不用 qDpi）
    // TODO 如果需要根据内容计算宽高则 initWidth/Height 设置为 0（不适用于 sizeAdaptive）
    required property int initWidth
    required property int initHeight
    // 初始化完成后的显示逻辑-Window.Hidden即visible=false，否则visible=true
    property int initVisibility: initVisible ? Window.Windowed : Window.Hidden
    // 初始化后立即显示
    property bool initVisible: false
    // 宽高是否自适应，如果 =true 则根据 initWidth/Height 与 1920/1080 的比例来自适应窗口大小
    property bool sizeAdaptive: false

    // 窗口可拖动尺寸
    property bool _resizable: (control.minimumWidth < 1 || control.minimumWidth !== control.maximumWidth)
    // 当前是否最大化
    property bool _isMax: (visibility === Window.Maximized || visibility === Window.FullScreen)
    // 标题栏
    property alias header: win_title
    // 标题栏图标
    property alias icon: win_icon.source
    // 内容
    default property alias contentData: win_content.data

    // 初始化时回调函数
    property var doInit: function() {
        switch (initVisibility)
        {
        case Window.Windowed: control.show(); break;
        case Window.Minimized: control.showMinimized(); break;
        case Window.Maximized: control.showMaximized(); break;
        case Window.FullScreen: control.showFullScreen(); break;
        case Window.Hidden: break;
        }
    }
    // 点击关闭时回调函数
    property var doClose: function() {
        control.close()
    }

    Component.onCompleted: {
        window_agent.setup(control)
        // window_agent.setWindowAttribute("dark-mode", true)
        win_tool.initWindow(initWidth, initHeight, sizeAdaptive)
        control.transientParent = null
        doInit()
    }

    BasicWindowTool {
        id: win_tool
        window: control
    }

    // QWindowKit无边框库
    WindowAgent {
        id: window_agent
    }

    Item {
        id: win_foreground
        anchors.fill: parent

        // 内容区域
        Rectangle {
            id: win_content
            anchors.fill: parent
            anchors.topMargin: win_title.height
            color: control.color
        }
        // 标题栏
        Rectangle {
            id: win_title
            width: control.width
            height: qDpi(30)
            color: "red"
            Component.onCompleted: window_agent.setTitleBar(win_title)

            // 标题栏背景
            // Image {
            //     id: win_bg
            //     anchors.fill: parent
            //     source: "qrc:/"
            // }
            // 左侧 icon + 标题
            Row {
                anchors{
                    left: parent.left
                    leftMargin: qDpi(10)
                    verticalCenter: parent.verticalCenter
                }
                spacing: qDpi(8)
                Image {
                    id: win_icon
                    visible: source != ""
                    anchors.verticalCenter: parent.verticalCenter
                    width: qDpi(20)
                    height: qDpi(20)
                    fillMode: Image.PreserveAspectFit
                    // source: xxxStyle.appIcon()
                    sourceSize: Qt.size(width, height)
                    Component.onCompleted: window_agent.setSystemButton(WindowAgent.WindowIcon, win_icon)
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
                    rightMargin: qDpi(10)
                    verticalCenter: parent.verticalCenter
                }
                spacing: 0

                BasicWindowButton {
                    id: btn_min
                    visible: control._resizable
                    width: qDpi(30)
                    height: qDpi(24)
                    // text: "Minimize"
                    source: "qrc:/Component/min.svg"
                    sourceSize: Qt.size(qDpi(16), qDpi(16))
                    bgColor: hovered ? "#55FFFFFF" : "transparent"
                    onClicked: {
                        control.showMinimized()
                    }
                    Component.onCompleted: window_agent.setSystemButton(WindowAgent.Minimize, btn_min)
                }
                BasicWindowButton {
                    id: btn_max
                    visible: control._resizable
                    width: qDpi(30)
                    height: qDpi(24)
                    // text: control._isMax ? "Restore" : "Maximize"
                    source: control._isMax
                            ? "qrc:/Component/normal.svg"
                            : "qrc:/Component/max.svg"
                    sourceSize: Qt.size(qDpi(16), qDpi(16))
                    bgColor: hovered ? "#55FFFFFF" : "transparent"
                    onClicked: {
                        if (control._isMax) {
                            control.showNormal()
                        } else {
                            control.showMaximized()
                        }
                    }
                    Component.onCompleted: window_agent.setSystemButton(WindowAgent.Maximize, btn_max)
                }
                BasicWindowButton {
                    id: btn_close
                    width: qDpi(30)
                    height: qDpi(24)
                    // text: "Close"
                    source: "qrc:/Component/close.svg"
                    sourceSize: Qt.size(qDpi(16), qDpi(16))
                    bgColor: hovered ? "#55FFFFFF" : "transparent"
                    onClicked: {
                        control.doClose()
                    }
                    Component.onCompleted: window_agent.setSystemButton(WindowAgent.Close, btn_close)
                }
            }
        }
    }

    component BasicWindowButton: T.AbstractButton {
        id: btn_comp

        // 图标url
        property alias source: btn_comp.icon.source
        property color sourceColor: btn_comp.icon.color
        property size sourceSize: Qt.size(0, 0)
        property color bgColor: "transparent"
        property int radius: 0

        implicitWidth: implicitContentWidth + leftPadding + rightPadding
        implicitHeight: implicitContentHeight + topPadding + bottomPadding
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
                width: btn_comp.sourceSize.width > 0 ? implicitWidth : qDpi(implicitWidth)
                height: btn_comp.sourceSize.height > 0 ? implicitHeight : qDpi(implicitHeight)
                // fillMode: Image.PreserveAspectFit
                source: btn_comp.source
                sourceSize: btn_comp.sourceSize
                color: btn_comp.sourceColor
            }
        }

        background: Rectangle {
            color: btn_comp.bgColor
            radius: btn_comp.radius
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
        }
        control.showNormal()
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
