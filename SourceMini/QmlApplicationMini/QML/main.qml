import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import "./Main"

Item {
    id: root

    // 不动态创建会先显示一下默认的窗口
    // MainWindow {
    //     id: main_window
    //     visible: true
    // }

    WindowManager {
        id: window_manager
    }

    Component.onCompleted: {
        let main_window = window_manager.getMainWindow()
        main_window.show()
    }
}
