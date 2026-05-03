import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: storeRoot
    spacing: 0

    property string searchQuery: ""
    property double totalAmount: 0
    property string cartNote: ""

    signal logoutRequested()
    signal checkoutSuccess(int saleId)

    ListModel { id: cartModel }

    function addToCart(itemName, price) {
        for (var i = 0; i < cartModel.count; i++) {
            if (cartModel.get(i).name === itemName) {
                cartModel.setProperty(i, "qty", cartModel.get(i).qty + 1)
                calculateTotal()
                cartFeedback.flash()
                return
            }
        }
        cartModel.append({ "name": itemName, "price": price, "qty": 1 })
        calculateTotal()
        cartFeedback.flash()
    }

    function removeFromCart(index) {
        cartModel.remove(index)
        calculateTotal()
    }

    function incrementCart(index) {
        cartModel.setProperty(index, "qty", cartModel.get(index).qty + 1)
        calculateTotal()
    }

    function decrementCart(index) {
        var current = cartModel.get(index).qty
        if (current <= 1) {
            removeFromCart(index)
        } else {
            cartModel.setProperty(index, "qty", current - 1)
            calculateTotal()
        }
    }

    function calculateTotal() {
        var sum = 0
        for (var j = 0; j < cartModel.count; j++) {
            sum += cartModel.get(j).price * cartModel.get(j).qty
        }
        totalAmount = sum
    }

    // Product grid
    ColumnLayout {
        Layout.fillWidth: true; Layout.fillHeight: true; spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true; height: 70; color: "white"; border.color: "#E0E0E0"
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24
                Text { text: "🛒 Shop"; font.pixelSize: 20; font.bold: true; color: "#1A3D16" }
                Item { Layout.fillWidth: true }

                // Search
                Rectangle {
                    width: 200; height: 36; radius: 18; color: "#F5F5F5"; border.color: custSearch.activeFocus ? "#4CAF50" : "#DDD"
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 6
                        Text { text: "🔍"; font.pixelSize: 13; color: "#999" }
                        TextField { id: custSearch; Layout.fillWidth: true; placeholderText: "Search…"; background: null; font.pixelSize: 13; onTextChanged: searchQuery = text }
                    }
                }

                Rectangle {
                    height: 36; width: 90; radius: 8
                    color: customerLogoutArea.containsMouse ? "#C62828" : "#B71C1C"
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Text { anchors.centerIn: parent; text: "Logout"; color: "white"; font.pixelSize: 13; font.bold: true }
                    MouseArea { id: customerLogoutArea; anchors.fill: parent; hoverEnabled: true; onClicked: logoutRequested() }
                }
            }
        }

        GridView {
            Layout.fillWidth: true; Layout.fillHeight: true
            leftMargin: 20; topMargin: 16
            model: inventoryManager.vegetableList
            cellWidth: 170; cellHeight: 200; clip: true

            delegate: Rectangle {
                width: 154; height: 184; color: "white"; radius: 12
                border.color: modelData.stock === 0 ? "#FFCDD2" : "#E8F5E9"; border.width: 1.5
                visible: searchQuery === "" || modelData.name.toLowerCase().indexOf(searchQuery.toLowerCase()) >= 0
                opacity: modelData.stock === 0 ? 0.6 : 1.0

                ColumnLayout {
                    anchors.centerIn: parent; spacing: 8; width: parent.width - 24

                    Image {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 80
                        source: modelData.image_path !== "" ? "file:///" + modelData.image_path : ""
                        fillMode: Image.PreserveAspectCrop
                        
                        Rectangle {
                            anchors.fill: parent
                            color: "#F0F0F0"
                            z: -1
                            radius: 8
                            Text { anchors.centerIn: parent; text: "🥦"; font.pixelSize: 32; visible: parent.parent.source == "" }
                        }
                    }

                    Text { text: modelData.name; font.bold: true; font.pixelSize: 14; color: "#1A3D16"; Layout.alignment: Qt.AlignHCenter; elide: Text.ElideRight; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
                    Text { text: "Rs. " + modelData.price.toFixed(2); color: "#2D6B26"; font.pixelSize: 13; Layout.alignment: Qt.AlignHCenter }
                    Text { text: modelData.stock === 0 ? "Out of stock" : modelData.stock + " available"; font.pixelSize: 10; color: modelData.stock === 0 ? "#C62828" : "#999"; Layout.alignment: Qt.AlignHCenter }

                    Rectangle {
                        Layout.fillWidth: true; height: 34; radius: 8
                        color: modelData.stock === 0 ? "#F5F5F5" : (addToCartArea.containsMouse ? "#388E3C" : "#4CAF50")
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text { anchors.centerIn: parent; text: modelData.stock === 0 ? "Unavailable" : "+ Add to Cart"; color: modelData.stock === 0 ? "#AAA" : "white"; font.pixelSize: 12; font.bold: true }
                        MouseArea { id: addToCartArea; anchors.fill: parent; hoverEnabled: true; enabled: modelData.stock > 0; onClicked: addToCart(modelData.name, modelData.price) }
                    }
                }
            }
        }
    }

    property var selectedCustomer: null
    property var lastPurchases: []

    // Cart sidebar
    Rectangle {
        Layout.preferredWidth: 320; Layout.fillHeight: true
        color: "#FAFAFA"; border.color: "#E0E0E0"

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 12

            // Customer Selector
            Rectangle {
                Layout.fillWidth: true; height: 100; radius: 10; color: "white"; border.color: "#EEE"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 12; spacing: 8
                    RowLayout {
                        Text { text: "👤 Customer"; font.bold: true; font.pixelSize: 13; color: "#555" }
                        Item { Layout.fillWidth: true }
                        Text { 
                            text: selectedCustomer ? "Change" : "Select"
                            font.pixelSize: 11; color: "#1976D2"; font.underline: true
                            MouseArea { anchors.fill: parent; onClicked: customerPopup.open() }
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: selectedCustomer !== null
                        spacing: 2
                        Text { text: selectedCustomer ? selectedCustomer.name : ""; font.bold: true; font.pixelSize: 15; color: "#1A3D16" }
                        RowLayout {
                            Text { text: "Points: " + (selectedCustomer ? selectedCustomer.loyalty_points : 0); font.pixelSize: 12; color: "#2E7D32"; font.bold: true }
                            Text { text: "•"; color: "#CCC" }
                            Text { text: selectedCustomer ? selectedCustomer.phone : ""; font.pixelSize: 12; color: "#888" }
                        }
                    }
                    Text { 
                        text: "Guest Checkout"; font.italic: true; color: "#AAA"; font.pixelSize: 13
                        visible: selectedCustomer === null
                    }

                }
            }

            // History Recall (Conditional)
            Rectangle {
                Layout.fillWidth: true; height: 120; radius: 10; color: "#FFF9C4"; border.color: "#FBC02D"
                visible: selectedCustomer !== null && lastPurchases.length > 0
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 10; spacing: 4
                    Text { text: "🕒 Last 5 Purchases"; font.bold: true; font.pixelSize: 11; color: "#F57F17" }
                    ListView {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        model: lastPurchases
                        delegate: Text { 
                            text: modelData.date + ": " + modelData.items
                            font.pixelSize: 10; color: "#555"; elide: Text.ElideRight; width: parent.width 
                        }
                    }
                }
            }


            // Cart header
            RowLayout {
                Text { text: "🧺 Basket"; font.bold: true; font.pixelSize: 16; color: "#1A3D16" }
                Item { Layout.fillWidth: true }
                Rectangle {
                    id: cartFeedback
                    width: 24; height: 24; radius: 12; color: "#E8F5E9"
                    Text { anchors.centerIn: parent; text: cartModel.count; font.pixelSize: 11; font.bold: true; color: "#2E7D32" }
                    function flash() { flashAnim.start() }
                    SequentialAnimation on scale {
                        id: flashAnim; running: false
                        NumberAnimation { to: 1.3; duration: 100 }
                        NumberAnimation { to: 1.0; duration: 100 }
                    }
                }
            }

            // Cart items
            ListView {
                Layout.fillWidth: true; Layout.fillHeight: true
                model: cartModel; clip: true; spacing: 6
                visible: cartModel.count > 0
                delegate: Rectangle {
                    width: ListView.view ? ListView.view.width : 280
                    height: 54; radius: 8; color: "white"; border.color: "#EEEEEE"
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; spacing: 8
                        ColumnLayout {
                            spacing: 1; Layout.fillWidth: true
                            Text { text: model.name; font.bold: true; font.pixelSize: 12; color: "#1A3D16"; elide: Text.ElideRight; width: parent.width }
                            Text { text: "Rs. " + (model.qty * model.price).toFixed(2); color: "#2D6B26"; font.pixelSize: 11 }
                        }
                        RowLayout {
                            spacing: 4
                            Rectangle {
                                width: 20; height: 20; radius: 10; color: "#F5F5F5"
                                Text { anchors.centerIn: parent; text: "−"; font.pixelSize: 14 }
                                MouseArea { anchors.fill: parent; onClicked: decrementCart(index) }
                            }
                            Text { text: model.qty; font.pixelSize: 12; font.bold: true; width: 16; horizontalAlignment: Text.AlignHCenter }
                            Rectangle {
                                width: 20; height: 20; radius: 10; color: "#E8F5E9"
                                Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 14; color: "#2E7D32" }
                                MouseArea { anchors.fill: parent; onClicked: incrementCart(index) }
                            }
                        }
                    }
                }
            }

            // Total & Checkout
            ColumnLayout {
                Layout.fillWidth: true; spacing: 8
                visible: cartModel.count > 0

                Rectangle {
                    Layout.fillWidth: true; height: 44; radius: 8; color: "#E8F5E9"
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 12
                        Text { text: "Total"; font.pixelSize: 13; color: "#555" }
                        Item { Layout.fillWidth: true }
                        Text { text: "Rs. " + totalAmount.toFixed(2); font.pixelSize: 16; font.bold: true; color: "#1A3D16" }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; height: 46; radius: 8
                    color: checkoutArea.containsMouse ? "#388E3C" : "#4CAF50"
                    Text { anchors.centerIn: parent; text: "✔ Confirm Order"; color: "white"; font.pixelSize: 14; font.bold: true }
                    MouseArea {
                        id: checkoutArea; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            var cartArray = []
                            for (var i = 0; i < cartModel.count; i++) {
                                var item = cartModel.get(i)
                                cartArray.push({ "name": item.name, "qty": item.qty, "price": item.price })
                                inventoryManager.decrementStock(item.name, item.qty)
                            }
                            var saleId = inventoryManager.processSale(cartArray, totalAmount, selectedCustomer ? selectedCustomer.id : 0)
                            cartModel.clear(); totalAmount = 0; selectedCustomer = null; lastPurchases = []
                            checkoutSuccess(saleId)
                        }
                    }
                }
            }
        }
    }

    // Customer Selection Popup
    Popup {
        id: customerPopup
        anchors.centerIn: parent
        width: 300; height: 400
        modal: true; focus: true
        background: Rectangle { radius: 12; border.color: "#DDD" }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 16
            Text { text: "Select Customer"; font.bold: true; font.pixelSize: 16 }
            TextField {
                id: custSearchInput; Layout.fillWidth: true; placeholderText: "Search name/phone..."
            }
            ListView {
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                model: inventoryManager.customerList
                spacing: 4
                delegate: Rectangle {
                    width: parent.width; height: 44; radius: 6; color: "#F9F9F9"
                    visible: custSearchInput.text === "" || modelData.name.toLowerCase().includes(custSearchInput.text.toLowerCase()) || modelData.phone.includes(custSearchInput.text)
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 8
                        ColumnLayout {
                            spacing: 0
                            Text { text: modelData.name; font.bold: true; font.pixelSize: 13 }
                            Text { text: modelData.phone; font.pixelSize: 11; color: "#888" }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selectedCustomer = modelData
                            lastPurchases = inventoryManager.getCustomerHistory(modelData.id)
                            customerPopup.close()
                        }
                    }
                }
            }
            Button {
                text: "+ Add New Customer"
                Layout.fillWidth: true
                onClicked: addCustDialog.open()
            }
        }
    }

    Dialog {
        id: addCustDialog
        anchors.centerIn: parent
        width: 250; height: 280
        title: "Quick Add Customer"
        modal: true; focus: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: {
            if (newNameInput.text && newPhoneInput.text) {
                inventoryManager.addCustomer(newNameInput.text, newPhoneInput.text)
                newNameInput.text = ""; newPhoneInput.text = ""
            }
        }
        ColumnLayout {
            anchors.fill: parent; spacing: 10
            TextField { id: newNameInput; Layout.fillWidth: true; placeholderText: "Full Name" }
            TextField { id: newPhoneInput; Layout.fillWidth: true; placeholderText: "Phone Number"; inputMethodHints: Qt.ImhDigitsOnly }
        }
    }
}
