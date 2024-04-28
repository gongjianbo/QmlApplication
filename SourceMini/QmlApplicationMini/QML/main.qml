import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Item {
    id: root

    Component.onCompleted: {
        let main_window = window_manager.getMainWindow()
        main_window.show()
    }

    WindowManager {
        id: window_manager
    }
}
