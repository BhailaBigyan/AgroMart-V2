import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

Item {
    id: root
    width: parent ? parent.width : 800
    height: parent ? parent.height : 600

    Rectangle {
        anchors.fill: parent
        color: "#F4F7FE"
        radius: 12

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Header Section
            RowLayout {
                Layout.fillWidth: true
                
                ColumnLayout {
                    spacing: 4
                    Text {
                        text: "Kalimati Live Prices"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#2B3674"
                    }
                    Text {
                        text: "Real-time vegetable market prices"
                        font.pixelSize: 14
                        color: "#A3AED0"
                    }
                }
                
                Item { Layout.fillWidth: true } // Spacer
                
                Button {
                    text: "↻ Fetch Latest Prices"
                    font.bold: true
                    font.pixelSize: 14
                    background: Rectangle {
                        color: parent.pressed ? "#3965FF" : "#4318FF"
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        inventoryManager.fetchMarketPrices()
                    }
                }

                Button {
                    text: "⟳ Sync to Inventory"
                    font.bold: true
                    font.pixelSize: 14
                    background: Rectangle {
                        color: parent.pressed ? "#04844B" : "#05CD99"
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        inventoryManager.syncInventoryPrices()
                    }
                }
            }

            // Data Table Header
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "#E9EDF7"
                radius: 8

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    spacing: 10

                    Text { text: "Product Name"; font.bold: true; color: "#2B3674"; Layout.preferredWidth: 200; Layout.fillWidth: true }
                    Text { text: "Unit"; font.bold: true; color: "#2B3674"; Layout.preferredWidth: 80 }
                    Text { text: "Min Price"; font.bold: true; color: "#2B3674"; Layout.preferredWidth: 100 }
                    Text { text: "Max Price"; font.bold: true; color: "#2B3674"; Layout.preferredWidth: 100 }
                    Text { text: "Avg Price"; font.bold: true; color: "#2B3674"; Layout.preferredWidth: 100 }
                }
            }

            // Data Table Body
            ListView {
                id: priceListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: inventoryManager.marketPrices
                spacing: 8
                
                delegate: Rectangle {
                    width: priceListView.width
                    height: 50
                    color: "white"
                    radius: 8
                    border.color: "#E2E8F0"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 10

                        Text { 
                            text: modelData.name 
                            font.bold: true
                            color: "#2B3674"
                            Layout.preferredWidth: 200
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        Text { 
                            text: modelData.unit 
                            color: "#A3AED0"
                            Layout.preferredWidth: 80 
                        }
                        Text { 
                            text: modelData.min_price 
                            color: "#E31A1A"
                            Layout.preferredWidth: 100 
                        }
                        Text { 
                            text: modelData.max_price 
                            color: "#05CD99"
                            Layout.preferredWidth: 100 
                        }
                        Text { 
                            text: modelData.avg_price 
                            font.bold: true
                            color: "#4318FF"
                            Layout.preferredWidth: 100 
                        }
                    }
                }
            }
        }
    }
}
