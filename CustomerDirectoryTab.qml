import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    spacing: 0

    Rectangle {
        Layout.fillWidth: true; height: 70; color: "white"; border.color: "#E0E0E0"
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24
            Text { text: "📇 Customer Directory"; font.pixelSize: 20; font.bold: true; color: "#1A3D16" }
            Item { Layout.fillWidth: true }
        }
    }

    ListView {
        Layout.fillWidth: true; Layout.fillHeight: true
        model: inventoryManager.customerList
        clip: true
        spacing: 1

        delegate: Rectangle {
            width: ListView.view ? ListView.view.width : 300
            height: 72
            color: "white"

            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24; spacing: 16

                Rectangle {
                    width: 44; height: 44; radius: 22
                    color: ["#E8F5E9","#E3F2FD","#FFF3E0","#FCE4EC"][index % 4]
                    Text {
                        anchors.centerIn: parent; text: modelData.name.charAt(0).toUpperCase()
                        font.pixelSize: 20; font.bold: true
                        color: ["#2E7D32","#1565C0","#E65100","#880E4F"][index % 4]
                    }
                }

                ColumnLayout {
                    spacing: 3
                    Text { text: modelData.name; font.bold: true; font.pixelSize: 15; color: "#1A3D16" }
                    Text { text: "📞 " + modelData.phone; color: "#666"; font.pixelSize: 12 }
                }

                Item { Layout.fillWidth: true }

            //     Rectangle {
            //         height: 34; width: 100; radius: 8
            //         color: viewProfileArea.containsMouse ? "#E3F2FD" : "white"
            //         border.color: "#90CAF9"
            //         Text { anchors.centerIn: parent; text: "👤 Profile"; font.pixelSize: 11; color: "#1976D2"; font.bold: true }
            //         MouseArea {
            //             id: viewProfileArea; anchors.fill: parent; hoverEnabled: true
            //             onClicked: customerProfilePopup.openProfile({
            //                 id: modelData.id,
            //                 name: modelData.name,
            //                 phone: modelData.phone,
            //                 loyalty_points: modelData.loyalty_points,
            //                 total_spent: modelData.total_spent
            //             })
            //         }
            //     }

            //     Rectangle {
            //         height: 34; width: 130; radius: 8
            //         color: resetPasswordArea.containsMouse ? "#EDE7F6" : "#F3E5F5"
            //         border.color: "#CE93D8"
            //         Text { anchors.centerIn: parent; text: "🔑 Reset Password"; font.pixelSize: 11; color: "#6A1B9A"; font.bold: true }
            //         MouseArea { id: resetPasswordArea; anchors.fill: parent; hoverEnabled: true
            //             onClicked: inventoryManager.resetCustomerPassword(index, "1234") }
            //     }
            // }
            }
            Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#F0F0F0" }
        }
    }

    Popup {
        id: customerProfilePopup
        anchors.centerIn: parent
        width: 350; height: 450
        modal: true; focus: true
        background: Rectangle { radius: 14; border.color: "#DDD" }

        property var currentCustomer: null
        property var historyList: []

        function openProfile(customer) {
            currentCustomer = customer;
            historyList = inventoryManager.getCustomerHistory(customer.id);
            open();
        }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 20; spacing: 16

            RowLayout {
                Layout.fillWidth: true; spacing: 12
                Rectangle {
                    width: 60; height: 60; radius: 30
                    color: "#E8F5E9"
                    Text { anchors.centerIn: parent; text: currentCustomer ? currentCustomer.name.charAt(0).toUpperCase() : ""; font.pixelSize: 24; font.bold: true; color: "#2E7D32" }
                }
                ColumnLayout {
                    spacing: 2
                    Text { text: currentCustomer ? currentCustomer.name : ""; font.bold: true; font.pixelSize: 18; color: "#1A3D16" }
                    Text { text: "📞 " + (currentCustomer ? currentCustomer.phone : ""); color: "#666"; font.pixelSize: 13 }
                }
            }

            Rectangle {
                Layout.fillWidth: true; height: 80; radius: 10; color: "#F5F5F5"
                RowLayout {
                    anchors.fill: parent; anchors.margins: 12; spacing: 20
                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Text { text: "Loyalty Points"; font.pixelSize: 11; color: "#888"; Layout.alignment: Qt.AlignHCenter }
                        Text { text: currentCustomer ? currentCustomer.loyalty_points : "0"; font.bold: true; font.pixelSize: 20; color: "#2E7D32"; Layout.alignment: Qt.AlignHCenter }
                    }
                    Rectangle { width: 1; height: 40; color: "#DDD" }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Text { text: "Total Spent"; font.pixelSize: 11; color: "#888"; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "Rs. " + (currentCustomer ? currentCustomer.total_spent.toFixed(2) : "0.00"); font.bold: true; font.pixelSize: 18; color: "#1565C0"; Layout.alignment: Qt.AlignHCenter }
                    }
                }
            }

            Text { text: "🕒 Last Purchases"; font.bold: true; font.pixelSize: 13; color: "#555" }

            ListView {
                Layout.fillWidth: true; Layout.fillHeight: true
                model: historyList; clip: true; spacing: 8
                delegate: Rectangle {
                    width: ListView.view.width; height: 50; radius: 8; color: "white"; border.color: "#EEE"
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 8
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 2
                            Text { text: modelData.date; font.pixelSize: 11; color: "#888" }
                            Text { text: modelData.items; font.pixelSize: 12; color: "#333"; elide: Text.ElideRight; Layout.maximumWidth: 200 }
                        }
                        Text { text: "Rs. " + modelData.total.toFixed(2); font.bold: true; font.pixelSize: 12; color: "#1A3D16" }
                    }
                }
            }

            Button {
                text: "Close Profile"
                Layout.fillWidth: true
                onClicked: customerProfilePopup.close()
            }
        }

    }
}
