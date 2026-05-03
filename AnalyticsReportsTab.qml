import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    spacing: 0

    Rectangle {
        Layout.fillWidth: true; height: 70; color: "white"; border.color: "#E0E0E0"
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24
            Text { text: "📊 Business Analytics"; font.pixelSize: 20; font.bold: true; color: "#1A3D16" }
            Item { Layout.fillWidth: true }
            Text { text: Qt.formatDateTime(new Date(), "dd MMM yyyy"); font.pixelSize: 12; color: "#888" }
        }
    }

    ScrollView {
        Layout.fillWidth: true; Layout.fillHeight: true
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            anchors.leftMargin: 24; anchors.rightMargin: 24
            spacing: 24

            Item { height: 8 }

            // KPI Cards row
            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; spacing: 16

                Repeater {
                    model: [
                        { label: "Total Revenue", value: "Rs. " + inventoryManager.totalRevenue, icon: "💰", bg: "#1A3D16", accent: "#4CAF50" },
                        { label: "Top Product",   value: inventoryManager.getTopSellingProduct(), icon: "🏆", bg: "#1565C0", accent: "#42A5F5" },
                        { label: "Total Orders",  value: inventoryManager.salesHistory.length + "", icon: "🧾", bg: "#4E342E", accent: "#FF8A65" },
                        { label: "In Stock Items",value: inventoryManager.vegetableList.length + "", icon: "📦", bg: "#4A148C", accent: "#CE93D8" }
                    ]

                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 110; radius: 14
                        color: modelData.bg

                        Rectangle {
                            width: 48; height: 48; radius: 24
                            color: Qt.rgba(1,1,1,0.1)
                            anchors.right: parent.right; anchors.top: parent.top
                            anchors.rightMargin: 16; anchors.topMargin: 16
                            Text { anchors.centerIn: parent; text: modelData.icon; font.pixelSize: 22 }
                        }

                        ColumnLayout {
                            anchors.left: parent.left; anchors.bottom: parent.bottom
                            anchors.leftMargin: 18; anchors.bottomMargin: 16; spacing: 4
                            Text { text: modelData.label; color: Qt.rgba(1,1,1,0.7); font.pixelSize: 11; font.bold: true }
                            Text { text: modelData.value; color: "white"; font.pixelSize: 22; font.bold: true }
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                            height: 4; color: modelData.accent; radius: 14
                        }
                    }
                }
            }

            // Top products section
            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24
                height: 220; radius: 14; color: "white"; border.color: "#E0E0E0"

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 20; spacing: 12
                    Text { text: "📋 Inventory Overview"; font.pixelSize: 15; font.bold: true; color: "#1A3D16" }
                    ListView {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        model: inventoryManager.vegetableList
                        clip: true
                        delegate: RowLayout {
                            width: ListView.view ? ListView.view.width : 300
                            height: 36; spacing: 12
                            Text { text: modelData.name; font.pixelSize: 13; color: "#333"; Layout.fillWidth: true }
                            Text { text: "Rs. " + modelData.price; font.pixelSize: 13; color: "#2D6B26"; width: 80; horizontalAlignment: Text.AlignRight }
                            Rectangle {
                                width: 60; height: 20; radius: 10
                                color: modelData.stock === 0 ? "#FFCDD2" : modelData.stock < 5 ? "#FFF9C4" : "#E8F5E9"
                                Text {
                                    anchors.centerIn: parent; font.pixelSize: 10; font.bold: true
                                    text: modelData.stock + " units"
                                    color: modelData.stock === 0 ? "#C62828" : modelData.stock < 5 ? "#F57F17" : "#2E7D32"
                                }
                            }
                        }
                    }
                }
            }

            // Monthly Revenue section
            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24
                height: 250; radius: 14; color: "white"; border.color: "#E0E0E0"

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 20; spacing: 12
                    Text { text: "📅 Monthly Performance"; font.pixelSize: 15; font.bold: true; color: "#1A3D16" }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        Text { text: "Month"; font.pixelSize: 12; color: "#888"; Layout.fillWidth: true }
                        Text { text: "Revenue"; font.pixelSize: 12; color: "#888"; width: 100; horizontalAlignment: Text.AlignRight }
                        Text { text: "Profit"; font.pixelSize: 12; color: "#888"; width: 100; horizontalAlignment: Text.AlignRight }
                    }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#EEE" }

                    ListView {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        model: inventoryManager.getMonthlyRevenue()
                        clip: true
                        spacing: 8
                        delegate: RowLayout {
                            width: ListView.view ? ListView.view.width : 300
                            height: 24; spacing: 12
                            Text { text: modelData.month; font.pixelSize: 14; font.bold: true; color: "#333"; Layout.fillWidth: true }
                            Text { text: "Rs. " + modelData.revenue.toFixed(2); font.pixelSize: 13; color: "#1565C0"; width: 100; horizontalAlignment: Text.AlignRight; font.bold: true }
                            Text { text: "Rs. " + modelData.profit.toFixed(2); font.pixelSize: 13; color: "#2E7D32"; width: 100; horizontalAlignment: Text.AlignRight; font.bold: true }
                        }
                    }
                }
            }

            Item { height: 20 }
        }
    }
}
