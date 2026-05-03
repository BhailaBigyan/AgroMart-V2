import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    spacing: 0

    Rectangle {
        Layout.fillWidth: true; height: 70; color: "white"; border.color: "#E0E0E0"
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24
            Text { text: "🕒 Sales History"; font.pixelSize: 20; font.bold: true; color: "#1A3D16" }
            Item { Layout.fillWidth: true }
            Rectangle {
                height: 36; width: 130; radius: 8
                color: clearHistoryArea.containsMouse ? "#FFCDD2" : "#FFF5F5"; border.color: "#EF9A9A"
                Text { anchors.centerIn: parent; text: "🗑 Clear History"; font.pixelSize: 12; color: "#C62828"; font.bold: true }
                MouseArea { id: clearHistoryArea; anchors.fill: parent; hoverEnabled: true; onClicked: inventoryManager.clearHistory() }
            }
        }
    }

    ListView {
        Layout.fillWidth: true; Layout.fillHeight: true
        model: inventoryManager.salesHistory
        clip: true
        spacing: 1

        delegate: Rectangle {
            width: ListView.view ? ListView.view.width : 300
            height: 88
            color: "white"

            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24; spacing: 16

                Rectangle {
                    width: 44; height: 44; radius: 8
                    color: "#E8F5E9"
                    Text { anchors.centerIn: parent; text: "🧾"; font.pixelSize: 22 }
                }

                ColumnLayout {
                    spacing: 4
                    Text { text: modelData.date || "Unknown date"; font.bold: true; font.pixelSize: 14; color: "#1A3D16" }
                    Text { text: modelData.items || "No item details"; color: "#666"; font.pixelSize: 12; elide: Text.ElideRight; width: 300 }
                }

                Item { Layout.fillWidth: true }

                ColumnLayout {
                    spacing: 4
                    Rectangle {
                        height: 34; width: 100; radius: 8; color: "#E8F5E9"
                        Text { anchors.centerIn: parent; text: "Rs. " + modelData.total.toFixed(2); font.bold: true; color: "#2E7D32"; font.pixelSize: 14 }
                    }
                    Button {
                        text: "🖨 Print Bill"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24
                        font.pixelSize: 10
                        onClicked: {
                            var result = inventoryManager.generateBillPDF(modelData.id)
                            console.log(result)
                        }
                    }
                }
            }

            Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#F0F0F0" }
        }


        Text {
            anchors.centerIn: parent
            visible: inventoryManager.salesHistory.length === 0
            text: "No sales recorded yet.\nSales will appear here after checkout."
            horizontalAlignment: Text.AlignHCenter; color: "#999"; font.pixelSize: 14; lineHeight: 1.6
        }
    }
}
