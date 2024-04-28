import QtQuick 2.15

// 窗口动态创建
Item {
    id: control

    property MainWindow _mainWindow: null
    Component {
        id: main_component
        MainWindow {
            transientParent: null
            // @disable-check M16
            onClosing: {
                console.log("close", this)
                _mainWindow.destroy()
                _mainWindow = null
            }
            Component.onCompleted: {
                // console.log("new", this)
            }
            Component.onDestruction: {
                // console.log("delete", this)
            }
        }
    }
    function getMainWindow() {
        if (_mainWindow) {
            return _mainWindow
        }
        _mainWindow = main_component.createObject()
        return _mainWindow
    }
}
