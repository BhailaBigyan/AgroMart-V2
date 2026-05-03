import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    spacing: 0

    Rectangle {
        Layout.fillWidth: true; height: 70; color: "white"; border.color: "#E0E0E0"
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24
            Text { text: "👥 Staff & User Management"; font.pixelSize: 20; font.bold: true; color: "#1A3D16" }
            Item { Layout.fillWidth: true }
            Text { text: inventoryManager.userList.length + " registered users"; font.pixelSize: 12; color: "#888" }
        }
    }

    Rectangle {
        Layout.fillWidth: true; height: 64; color: "#F9FBF9"; border.color: "#E8F5E9"
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24; spacing: 10
            Text { text: "New User:"; font.pixelSize: 13; color: "#555"; font.bold: true }
            Rectangle {
                height: 40; width: 160; radius: 6; color: "white"; border.color: addUName.activeFocus ? "#4CAF50" : "#DDD"
                TextField { id: addUName; anchors.fill: parent; leftPadding: 12; placeholderText: "Full name"; background: null; font.pixelSize: 13 }
            }
            Rectangle {
                height: 40; width: 140; radius: 6; color: "white"; border.color: addUsername.activeFocus ? "#4CAF50" : "#DDD"
                TextField { id: addUsername; anchors.fill: parent; leftPadding: 12; placeholderText: "Username (login)"; background: null; font.pixelSize: 13 }
            }
            ComboBox {
                id: addRole
                Layout.preferredHeight: 40; Layout.preferredWidth: 100
                model: ["admin", "cashier"]
            }
            Rectangle {
                height: 40; width: 100; radius: 6
                color: createUserArea.containsMouse ? "#388E3C" : "#4CAF50"
                Behavior on color { ColorAnimation { duration: 120 } }
                Text { anchors.centerIn: parent; text: "＋ Create"; color: "white"; font.pixelSize: 13; font.bold: true }
                MouseArea {
                    id: createUserArea; anchors.fill: parent; hoverEnabled: true
                    onClicked: {
                        if (addUName.text !== "" && addUsername.text !== "") {
                            inventoryManager.addUser(addUName.text, addUsername.text, addRole.currentText)
                            addUName.text = ""; addUsername.text = ""
                        }
                    }
                }
            }
        }
    }

    ListView {
        Layout.fillWidth: true; Layout.fillHeight: true
        model: inventoryManager.userList
        clip: true
        spacing: 1

        delegate: Rectangle {
            width: ListView.view ? ListView.view.width : 300
            height: 68
            color: index % 2 === 0 ? "white" : "#FAFAFA"

            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24; spacing: 14

                // Avatar circle
                Rectangle {
                    width: 40; height: 40; radius: 20
                    color: ["#E8F5E9","#E3F2FD","#FFF3E0","#FCE4EC"][index % 4]
                    Text {
                        anchors.centerIn: parent
                        text: modelData.name.charAt(0).toUpperCase()
                        font.pixelSize: 18; font.bold: true
                        color: ["#2E7D32","#1565C0","#E65100","#880E4F"][index % 4]
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Text { text: modelData.name; font.bold: true; font.pixelSize: 14; color: "#1A3D16" }
                    Text { text: "👤 " + modelData.username + "  •  Role: " + modelData.role; font.pixelSize: 11; color: "#888" }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    height: 32; width: 110; radius: 6
                    color: resetPinArea.containsMouse ? "#FFF9C4" : "#FFFDE7"
                    border.color: "#F9A825"
                    Text { anchors.centerIn: parent; text: "🔑 Reset PIN"; font.pixelSize: 11; color: "#F57F17"; font.bold: true }
                    MouseArea { id: resetPinArea; anchors.fill: parent; hoverEnabled: true
                        onClicked: inventoryManager.resetUserPassword(index, "1234") }
                }

                Rectangle {
                    height: 32; width: 32; radius: 6
                    color: deleteUserArea.containsMouse ? "#FFCDD2" : "#FFF5F5"
                    border.color: "#EF9A9A"
                    Text { anchors.centerIn: parent; text: "🗑"; font.pixelSize: 14 }
                    MouseArea { id: deleteUserArea; anchors.fill: parent; hoverEnabled: true
                        onClicked: inventoryManager.removeUser(index) }
                }
            }

            Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#F0F0F0" }
        }

        Text {
            anchors.centerIn: parent
            visible: inventoryManager.userList.length === 0
            text: "No users registered yet.\nAdd your first user above."
            horizontalAlignment: Text.AlignHCenter
            color: "#999"; font.pixelSize: 14; lineHeight: 1.6
        }
    }
}
