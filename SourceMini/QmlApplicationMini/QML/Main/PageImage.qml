import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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
            ItemTag { text: "2" }
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
        id: my_image

        // 传入未缩放时的尺寸进行计算参考值
        property int refWidth: 0
        property int refHeight: 0

        width: refWidth > 0 ? qDpi(refWidth) : implicitWidth
        height: refHeight > 0 ? qDpi(refHeight) : implicitHeight
        sourceSize: Qt.size(width, height)
    }
    // 使用封装的 Image
    Column {
        anchors.centerIn: parent
        spacing: qDpi(6)
        Row {
            spacing: qDpi(6)
            MyImage {
                source: "qrc:/Image/Main/douyin.svg"
            }
            MyImage {
                source: "qrc:/Image/Main/kuaishou.svg"
            }
            MyImage {
                source: "qrc:/Image/Main/wangyiyun.svg"
            }
            MyImage {
                source: "qrc:/Image/Main/wangluo.svg"
            }
        }
    }
}
