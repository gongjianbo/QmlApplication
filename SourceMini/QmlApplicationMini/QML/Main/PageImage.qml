import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Cute.Component 1.0

// 图片缩放
Rectangle {
    id: control

    // 1.大部分图标用 Image 加载 svg
    // svg 加载有问题时可以选择两倍的 png
    // 如果 png 缩放后模糊也可以根据 dpi 加载对应倍数的 png

    // 2.图标大小加 qDpi 函数计算对应缩放比的大小
    // 需要将 Image sourceSize 也设置为 qDpi 计算后的大小
    Column {
        x: qDpi(50)
        y: qDpi(50)
        spacing: qDpi(6)
        Image {
            width: qDpi(64)
            height: qDpi(64)
            sourceSize: Qt.size(width, height)
            source: "qrc:/Image/Main/douyin.svg"
            ItemTag { index: 2; text: "qDpi 计算缩放" }
        }
        Image {
            width: qDpi(64)
            height: qDpi(64)
            sourceSize: Qt.size(width, height)
            source: "qrc:/Image/Main/douyin.png"
        }
        Image {
            width: qDpi(64)
            height: qDpi(64)
            sourceSize: Qt.size(width, height)
            source: "qrc:/Image/Main/douyin@2x.png"
        }
    }

    // 3.简单封装，在组件内部调用 qDpi
    component MyImage: Image {
        id: my_img

        // 传入未缩放时的尺寸进行计算参考值
        property int refWidth: 0
        property int refHeight: 0
        property alias refSource: img_tool.source

        width: refWidth > 0 ? qDpi(refWidth) : qDpi(img_tool.implicitWidth)
        height: refHeight > 0 ? qDpi(refHeight) : qDpi(img_tool.implicitHeight)
        source: img_tool.path
        sourceSize: Qt.size(img_tool.paintedWidth, img_tool.paintedHeight)

        BasicImageTool {
            id: img_tool
            // source: my_img.refSource
            // 浮点数
            devicePixelRatio: qDpiF(1)
        }
    }
    // 使用封装的 Image
    Column {
        x: qDpi(250)
        y: qDpi(50)
        spacing: qDpi(6)
        MyImage {
            refSource: "qrc:/Image/Main/douyin.svg"
            ItemTag { index: 3; text: "封装 Image" }
        }
        MyImage {
            refSource: "qrc:/Image/Main/douyin.png"
        }
        MyImage {
            refWidth: 64
            refHeight: 64
            refSource: "qrc:/Image/Main/douyin@2x.png"
        }
    }

    // 4.C++加载图片需要给宽高乘上缩放比
    Column {
        x: qDpi(450)
        y: qDpi(50)
        spacing: qDpi(6)
        CppImage {
            width: qDpi(64)
            height: qDpi(64)
            source: "qrc:/Image/Main/douyin.svg"
            devicePixelRatio: qDpiF(1)
            ItemTag { index: 4; text: "C++ 加载图片" }
        }
        CppImage {
            width: qDpi(64)
            height: qDpi(64)
            source: "qrc:/Image/Main/douyin@2x.png"
            devicePixelRatio: qDpiF(1)
        }
    }
}
