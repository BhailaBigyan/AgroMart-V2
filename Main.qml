import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    width: 900
    height: 600
    visible: true
    title: qsTr("AgroMart Version 2.0")

    StackView {
        id: loader
        anchors.fill: parent
        initialItem: LoginScreen {
            onLoginSuccess: (role) => {
                loader.push("DashboardScreen.qml", { "userRole": role })
            }
        }
    }
}
