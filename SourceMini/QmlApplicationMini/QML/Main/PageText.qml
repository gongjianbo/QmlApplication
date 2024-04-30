import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Cute.Component 1.0

// 文本缩放
Rectangle {
    id: control

    // 1.C++ 代码设置全局 NativeTextRendering（见 main 函数中设置）
    // QQuickWindow::setTextRenderType(QQuickWindow::NativeTextRendering);

    // 2.字体大小用 px，加 qDpi 函数计算对应缩放比的字体大小
    // qDpi 函数在 BasicWindow 中定义
    Column {
        anchors.centerIn: parent
        spacing: qDpi(6)
        Text {
            font.pixelSize: qDpi(16)
            font.family: "SimSun"
            text: String("14px(%1) 宋体").arg(font.pixelSize)
            ItemTag { index: 2; text: "qDpi 计算缩放" }
        }
        Text {
            font.pixelSize: qDpi(16)
            font.family: "Microsoft YaHei"
            text: String("14px(%1) 微软雅黑").arg(font.pixelSize)
        }
        Text {
            font.pixelSize: qDpi(16)
            font.family: "Microsoft YaHei UI"
            text: String("14px(%1) 微软雅黑UI").arg(font.pixelSize)
        }
    }
}
