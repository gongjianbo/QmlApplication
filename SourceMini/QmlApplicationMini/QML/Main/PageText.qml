import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// 文本缩放
Rectangle {
    id: control

    // 1.C++ 代码设置全局 NativeTextRendering（见 main 函数中设置）
    // QQuickWindow::setTextRenderType(QQuickWindow::NativeTextRendering);

    // 2.字体大小用 px，加 qDpi 函数计算对应缩放比的字体大小
    // qDpi 函数在 BasicWindow 中定义
    Column {
        x: qDpi(50)
        y: qDpi(50)
        spacing: qDpi(6)
        Text {
            font.pixelSize: qDpi(14)
            font.family: "SimSun"
            text: String("14px(%1) 宋体").arg(font.pixelSize)
            ItemTag { text: "2" }
        }
        Text {
            font.pixelSize: qDpi(14)
            font.family: "Microsoft YaHei"
            text: String("14px(%1) 微软雅黑").arg(font.pixelSize)
        }
        Text {
            font.pixelSize: qDpi(14)
            font.family: "Microsoft YaHei UI"
            text: String("14px(%1) 微软雅黑UI").arg(font.pixelSize)
        }
    }

    // 3.简单封装，在组件内部调用 qDpi
    component MyText: Text {
        id: my_text

        // 传入未缩放时的尺寸进行计算参考值
        property int refWidth: 0
        property int refHeight: 0
        property int refPixelSize: 14

        width: refWidth > 0 ? qDpi(refWidth) : implicitWidth
        height: refHeight > 0 ? qDpi(refHeight) : implicitHeight
        font.pixelSize: qDpi(my_text.refPixelSize)
        font.family: "Microsoft YaHei"

        // 测试用，加个边框
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            color: "transparent"
            border.color: "black"
        }
    }
    // 使用封装的 Text
    Column {
        anchors.centerIn: parent
        spacing: qDpi(6)
        // 单行
        MyText {
            refPixelSize: 16
            text: String("MyText %1px %2").arg(refPixelSize).arg(font.family)
            ItemTag { text: "3" }
        }
        // 换行
        MyText {
            refWidth: 60
            refPixelSize: 16
            wrapMode: Text.WordWrap
            text: String("MyText %1px %2").arg(refPixelSize).arg(font.family)
        }
        // 省略号
        MyText {
            refWidth: 60
            refPixelSize: 16
            elide: Text.ElideRight
            text: String("MyText %1px %2").arg(refPixelSize).arg(font.family)
        }
    }
}
