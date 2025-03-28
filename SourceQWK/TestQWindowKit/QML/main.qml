import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GongJianBo 1.0
import "./Component"

BasicWindow {
    id: main_window
    initVisible: true
    initWidth: 700
    initHeight: 600
    title: "QWindowKit"
    color: "darkCyan"

    Column {
        anchors.centerIn: parent
        spacing: qDpi(10)

        Text {
            text: "GongJianBo"
            font.pixelSize: qDpi(14)
        }

        Button {
            text: "Fixed Small"
            onClicked: {
                main_window.minimumWidth = Qt.binding(()=>qDpi(500))
                main_window.width = Qt.binding(()=>qDpi(500))
                main_window.maximumWidth = Qt.binding(()=>qDpi(500))
            }
        }

        Button {
            text: "Fixed Big"
            onClicked: {
                main_window.maximumWidth = Qt.binding(()=>qDpi(700))
                main_window.width = Qt.binding(()=>qDpi(700))
                main_window.minimumWidth = Qt.binding(()=>qDpi(700))
            }
        }

        Button {
            text: "Pop Show"
            onClicked: {
                if (!winShow) {
                    winShow = comp_show.createObject(main_window)
                }
                winShow.show()
            }
        }

        Button {
            text: "Pop Max"
            onClicked: {
                if (!winMax) {
                    winMax = comp_max.createObject(main_window)
                }
                winMax.showMaximized()
            }
        }

    }

    property BasicWindow winShow: null
    Component {
        id: comp_show
        BasicWindow {
            id: win_show
            initVisible: false
            initWidth: 500
            initHeight: 400
            minimumWidth: qDpi(500)
            minimumHeight: qDpi(400)
            // maximumWidth: qDpi(500)
            // maximumHeight: qDpi(400)
            // modality: Qt.ApplicationModal
            Button {
                text: "Hide"
                onClicked: {
                    win_show.hide()
                }
            }
            onClosing: {
                winShow.destroy()
                winShow = null
            }
        }
    }

    property BasicWindow winMax: null
    Component {
        id: comp_max
        BasicWindow {
            id: win_max
            initVisible: false
            initWidth: 500
            initHeight: 400
            sizeAdaptive: true
            onClosing: {
                winMax.destroy()
                winMax = null
            }
        }
    }
}
