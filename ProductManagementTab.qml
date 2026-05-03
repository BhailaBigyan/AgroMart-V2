import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ColumnLayout {
    spacing: 0
    property string searchQuery: ""
    property string selectedImagePath: ""
    
    signal viewProductProfile(string productName)

    // Header bar
    Rectangle {
        Layout.fillWidth: true
        height: 70
        color: "white"
        border.color: "#E0E0E0"; border.width: { bottom: 1 }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            spacing: 12

            ColumnLayout {
                spacing: 2
                Text { text: "📦 Product Management"; font.pixelSize: 20; font.bold: true; color: "#1A3D16" }
                Text { text: inventoryManager.vegetableList.length + " products in inventory"; font.pixelSize: 12; color: "#888" }
            }
            Item { Layout.fillWidth: true }

            // Search bar
            Rectangle {
                width: 200; height: 36
                radius: 18
                color: "#F5F5F5"
                border.color: searchField.activeFocus ? "#4CAF50" : "#DDD"
                Behavior on border.color { ColorAnimation { duration: 150 } }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 6
                    Text { text: "🔍"; font.pixelSize: 13; color: "#999" }
                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "Search products…"
                        background: null
                        font.pixelSize: 13
                        onTextChanged: searchQuery = text
                    }
                }
            }
        }
    }

    // Add product bar
    Rectangle {
        Layout.fillWidth: true
        height: 64
        color: "#F9FBF9"
        border.color: "#E8F5E9"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            spacing: 10

            Text { text: "Add New:"; font.pixelSize: 13; color: "#555"; font.bold: true }

            Rectangle {
                height: 40; width: 160
                radius: 6; color: "white"; border.color: newName.activeFocus ? "#4CAF50" : "#DDD"
                ComboBox {
                    id: newName
                    anchors.fill: parent
                    editable: true
                    model: inventoryManager.marketPrices
                    textRole: "name"
                    font.pixelSize: 13
                    background: null
                    onActivated: {
                        let item = inventoryManager.marketPrices[currentIndex]
                        if (item) {
                            newCost.text = item.min_price.toFixed(2)
                            newPrice.text = item.avg_price.toFixed(2)
                        }
                    }
                }
            }
            Rectangle {
                height: 40; width: 80
                radius: 6; color: "white"; border.color: newCost.activeFocus ? "#4CAF50" : "#DDD"
                TextField {
                    id: newCost; anchors.fill: parent; leftPadding: 12
                    placeholderText: "Cost"; background: null; font.pixelSize: 13
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                }
            }
            Rectangle {
                height: 40; width: 80
                radius: 6; color: "white"; border.color: newPrice.activeFocus ? "#4CAF50" : "#DDD"
                TextField {
                    id: newPrice; anchors.fill: parent; leftPadding: 12
                    placeholderText: "Price"; background: null; font.pixelSize: 13
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                }
            }
            Rectangle {
                height: 40; width: 60
                radius: 6; color: "white"; border.color: newStock.activeFocus ? "#4CAF50" : "#DDD"
                TextField {
                    id: newStock; anchors.fill: parent; leftPadding: 12
                    placeholderText: "Qty"; background: null; font.pixelSize: 13
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                }
            }

            ComboBox {
                id: unitSelector
                Layout.preferredHeight: 40; Layout.preferredWidth: 80
                model: ["kg", "bundle", "unit", "gm"]
                currentIndex: 0
            }

            Button {
                text: selectedImagePath === "" ? "📷 Pick Image" : "✅ Image Picked"
                Layout.preferredHeight: 40
                onClicked: imageDialog.open()
            }

            FileDialog {
                id: imageDialog
                title: "Please choose a product image"
                nameFilters: ["Image files (*.png *.jpg *.jpeg)"]
                onAccepted: { selectedImagePath = selectedFile.toString() }
            }

            Rectangle {
                height: 40; width: 100
                radius: 6
                color: addProductArea.containsMouse ? "#388E3C" : "#4CAF50"
                Behavior on color { ColorAnimation { duration: 120 } }
                Text {
                    anchors.centerIn: parent
                    text: "＋ Add Item"; color: "white"; font.pixelSize: 13; font.bold: true
                }
                MouseArea {
                    id: addProductArea; anchors.fill: parent; hoverEnabled: true
                    onClicked: {
                        if (newName.editText !== "") {
                            inventoryManager.addVegetable(
                                newName.editText,
                                unitSelector.currentText,
                                parseFloat(newCost.text || "0"),
                                parseFloat(newPrice.text || "0"),
                                parseFloat(newStock.text || "0"),
                                selectedImagePath
                            )
                            newName.editText = ""; newCost.text = ""; newPrice.text = ""; newStock.text = ""
                            selectedImagePath = ""
                        }
                    }
                }
            }
        }
    }

    // Product grid
    GridView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        leftMargin: 20; topMargin: 16; bottomMargin: 16
        model: inventoryManager.vegetableList
        cellWidth: 180; cellHeight: 220
        clip: true

        delegate: Rectangle {
            width: 166; height: 206
            color: "white"
            radius: 12
            border.color: modelData.stock === 0 ? "#FFCDD2" : "#E8F5E9"
            border.width: 1.5
            visible: searchQuery === "" || modelData.name.toLowerCase().indexOf(searchQuery.toLowerCase()) >= 0

            // Stock badge
            Rectangle {
                anchors.top: parent.top; anchors.right: parent.right
                anchors.topMargin: 10; anchors.rightMargin: 10
                width: 60; height: 20; radius: 10
                color: modelData.stock === 0 ? "#FFCDD2" : modelData.stock < 5 ? "#FFF9C4" : "#E8F5E9"
                Text {
                    anchors.centerIn: parent
                    text: modelData.stock === 0 ? "Out" : modelData.stock.toFixed(1) + " " + (modelData.unit || "kg")
                    font.pixelSize: 9; font.bold: true
                    color: modelData.stock === 0 ? "#C62828" : modelData.stock < 5 ? "#F57F17" : "#2E7D32"
                }
            }

            // Delete button
            Rectangle {
                anchors.top: parent.top; anchors.left: parent.left
                anchors.topMargin: 8; anchors.leftMargin: 8
                width: 24; height: 24; radius: 12
                color: deleteProductArea.containsMouse ? "#FFCDD2" : "transparent"
                Text { anchors.centerIn: parent; text: "🗑"; font.pixelSize: 12 }
                MouseArea { id: deleteProductArea; anchors.fill: parent; hoverEnabled: true
                    onClicked: inventoryManager.removeVegetable(index) }
            }

            ColumnLayout {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 0
                spacing: 4
                width: parent.width - 24

                // Product Image
                Image {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 60
                    source: modelData.image_path !== "" ? "file:///" + modelData.image_path : ""
                    fillMode: Image.PreserveAspectCrop
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "#F0F0F0"
                        z: -1
                        radius: 8
                        Text { anchors.centerIn: parent; text: "📦"; font.pixelSize: 24; visible: parent.parent.source == "" }
                    }
                }

                Text {
                    text: modelData.name
                    font.bold: true; font.pixelSize: 14; color: "#1A3D16"
                    Layout.alignment: Qt.AlignHCenter
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Rs. " + modelData.price.toFixed(2) + " / " + (modelData.unit || "kg")
                    color: "#2D6B26"; font.pixelSize: 11; font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: "Cost: " + (modelData.cost ? modelData.cost.toFixed(2) : "0.00")
                    color: "#888"; font.pixelSize: 9
                    Layout.alignment: Qt.AlignHCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Button {
                        text: "Profile"
                        Layout.preferredHeight: 24; Layout.fillWidth: true
                        font.pixelSize: 10
                        onClicked: viewProductProfile(modelData.name)
                    }
                    Button {
                        text: "Waste"
                        Layout.preferredHeight: 24; Layout.fillWidth: true
                        font.pixelSize: 10
                        onClicked: wastePopup.openPopup(modelData.name)
                    }
                }

                // Stock spinner
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 6
                    Rectangle {
                        width: 24; height: 24; radius: 12
                        color: stockDecreaseArea.containsMouse ? "#E8F5E9" : "#F5F5F5"
                        Text { anchors.centerIn: parent; text: "−"; font.pixelSize: 14; color: "#2D5A27" }
                        MouseArea { id: stockDecreaseArea; anchors.fill: parent; hoverEnabled: true
                            onClicked: if (modelData.stock > 0) inventoryManager.updateStock(index, modelData.stock - 0.5) }
                    }
                    Text {
                        text: modelData.stock.toFixed(1); font.pixelSize: 13; font.bold: true; color: "#333"
                        width: 40; horizontalAlignment: Text.AlignHCenter
                    }
                    Rectangle {
                        width: 24; height: 24; radius: 12
                        color: stockIncreaseArea.containsMouse ? "#E8F5E9" : "#F5F5F5"
                        Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 14; color: "#2D5A27" }
                        MouseArea { id: stockIncreaseArea; anchors.fill: parent; hoverEnabled: true
                            onClicked: inventoryManager.updateStock(index, modelData.stock + 0.5) }
                    }
                }
            }
        }
    Popup {
        id: wastePopup
        anchors.centerIn: parent
        width: 250; height: 280; modal: true; focus: true
        property string targetProduct: ""
        function openPopup(pname) { targetProduct = pname; open() }

        background: Rectangle { radius: 12; border.color: "#DDD" }
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 12
            Text { text: "Log Waste: " + wastePopup.targetProduct; font.bold: true }
            TextField { id: wasteQty; Layout.fillWidth: true; placeholderText: "Quantity (kg/unit)"; inputMethodHints: Qt.ImhFormattedNumbersOnly }
            ComboBox { id: wasteReason; Layout.fillWidth: true; model: ["Spoiled", "Damaged", "Missing", "Other"] }
            Button {
                text: "Confirm Log"
                Layout.fillWidth: true
                onClicked: {
                    inventoryManager.logWaste(wastePopup.targetProduct, parseFloat(wasteQty.text), wasteReason.currentText)
                    wasteQty.text = ""; wastePopup.close()
                }
            }
            Button { text: "Cancel"; Layout.fillWidth: true; onClicked: wastePopup.close() }
        }
    }
}
}