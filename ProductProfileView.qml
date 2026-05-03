import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: profileRoot
    color: "#F0F4F0"

    property string productName: ""
    property var productData: ({})

    signal backRequested()

    onProductNameChanged: {
        if (productName !== "") {
            productData = inventoryManager.getProductPerformance(productName)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        // Header
        RowLayout {
            Layout.fillWidth: true
            Button {
                text: "← Back to Products"
                onClicked: backRequested()
                background: Rectangle { color: "transparent" }
                contentItem: Text { text: parent.text; color: "#2D5A27"; font.pixelSize: 16; font.bold: true }
            }
            Item { Layout.fillWidth: true }
        }

        // Profile Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 250
            color: "white"
            radius: 12
            border.color: "#E0E0E0"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 30

                // Image
                Image {
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 200
                    source: productData.imagePath ? "file:///" + productData.imagePath : ""
                    fillMode: Image.PreserveAspectCrop
                    Rectangle {
                        anchors.fill: parent; color: "#F5F5F5"; z: -1; radius: 10
                        Text { anchors.centerIn: parent; text: "📦"; font.pixelSize: 64; visible: parent.parent.source == "" }
                    }
                }

                // Details
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    Text { text: productData.name || "Unknown Product"; font.pixelSize: 32; font.bold: true; color: "#1A3D16" }
                    
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#EEE" }

                    RowLayout {
                        spacing: 40
                        ColumnLayout {
                            Text { text: "Price"; color: "#888"; font.pixelSize: 14 }
                            Text { text: "Rs. " + (productData.price ? productData.price.toFixed(2) : "0.00"); font.pixelSize: 20; font.bold: true; color: "#2D5A27" }
                        }
                        ColumnLayout {
                            Text { text: "Cost"; color: "#888"; font.pixelSize: 14 }
                            Text { text: "Rs. " + (productData.cost ? productData.cost.toFixed(2) : "0.00"); font.pixelSize: 20; font.bold: true; color: "#D32F2F" }
                        }
                        ColumnLayout {
                            Text { text: "Margin"; color: "#888"; font.pixelSize: 14 }
                            Text { 
                                text: "Rs. " + (productData.price && productData.cost ? (productData.price - productData.cost).toFixed(2) : "0.00")
                                font.pixelSize: 20; font.bold: true; color: "#1976D2" 
                            }
                        }
                        ColumnLayout {
                            Text { text: "Current Stock"; color: "#888"; font.pixelSize: 14 }
                            Text { text: productData.stock || "0"; font.pixelSize: 20; font.bold: true }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }

        // Performance Stats
        Text { text: "Sales Performance"; font.pixelSize: 20; font.bold: true; color: "#333"; Layout.topMargin: 20 }

        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            // Units Sold Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: "white"
                radius: 12
                border.color: "#E0E0E0"
                ColumnLayout {
                    anchors.centerIn: parent
                    Text { text: "Total Units Sold"; color: "#666"; font.pixelSize: 14; Layout.alignment: Qt.AlignHCenter }
                    Text { text: productData.unitsSold || "0"; font.pixelSize: 36; font.bold: true; color: "#1A3D16"; Layout.alignment: Qt.AlignHCenter }
                }
            }

            // Total Profit Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: "white"
                radius: 12
                border.color: "#E0E0E0"
                ColumnLayout {
                    anchors.centerIn: parent
                    Text { text: "Total Profit Generated"; color: "#666"; font.pixelSize: 14; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "Rs. " + (productData.totalProfit ? productData.totalProfit.toFixed(2) : "0.00"); font.pixelSize: 36; font.bold: true; color: "#2D5A27"; Layout.alignment: Qt.AlignHCenter }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
