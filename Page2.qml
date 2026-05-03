import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Rectangle {
    id: posRoot
    color: "#F0F4F0"

    property string userRole: "salesman"
    property string activeTab: userRole === "salesman" ? "Products" : "Store"
    property double totalAmount: 0
    property string searchQuery: ""
    property string cartNote: ""

    // ── Helpers ──────────────────────────────────────────────────────────────

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

    function filteredModel() {
        // Filtering is done via a filtered proxy signal; handled in delegate visibility
    }

    ListModel { id: cartModel }

    // ── Root Layout ───────────────────────────────────────────────────────────

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ── SIDEBAR ───────────────────────────────────────────────────────────
        Rectangle {
            Layout.preferredWidth: 220
            Layout.fillHeight: true
            color: "#1A3D16"
            visible: userRole === "salesman"

            // Subtle pattern overlay
            Canvas {
                anchors.fill: parent
                opacity: 0.06
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.strokeStyle = "#FFFFFF"
                    ctx.lineWidth = 1
                    for (var y = 0; y < height; y += 30) {
                        ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke()
                    }
                    for (var x = 0; x < width; x += 30) {
                        ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, height); ctx.stroke()
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 6

                // Avatar + store name
                Item { Layout.preferredHeight: 12 }
                Rectangle {
                    width: 64; height: 64; radius: 32
                    color: "#2D6B26"
                    Layout.alignment: Qt.AlignHCenter
                    border.color: "#4CAF50"; border.width: 2
                    Text {
                        anchors.centerIn: parent
                        text: "🌿"; font.pixelSize: 28
                    }
                }
                Text {
                    text: "FreshMart POS"
                    color: "#FFFFFF"
                    font.pixelSize: 15
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: "Admin Dashboard"
                    color: "#81C784"
                    font.pixelSize: 11
                    Layout.alignment: Qt.AlignHCenter
                }
                Item { Layout.preferredHeight: 8 }

                // Nav section label
                Text { text: "NAVIGATION"; color: "#66BB6A"; font.pixelSize: 10; font.bold: true; leftPadding: 4 }

                Repeater {
                    model: [
                        { label: "Products",  icon: "📦" },
                        { label: "Users",     icon: "👥" },
                        { label: "Customers", icon: "📇" },
                        { label: "Reports",   icon: "📊" },
                        { label: "History",   icon: "🕒" }
                    ]
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 44
                        radius: 8
                        color: activeTab === modelData.label
                               ? "#4CAF50"
                               : mouseArea.containsMouse ? "#2A5224" : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 8
                            spacing: 10
                            Text { text: modelData.icon; font.pixelSize: 16 }
                            Text {
                                text: modelData.label
                                color: activeTab === modelData.label ? "white" : "#C8E6C9"
                                font.pixelSize: 13
                                font.bold: activeTab === modelData.label
                            }
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                width: 6; height: 6; radius: 3
                                color: "#81C784"
                                visible: activeTab === modelData.label
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: activeTab = modelData.label
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Divider
                Rectangle { Layout.fillWidth: true; height: 1; color: "#2D5A27"; opacity: 0.6 }
                Item { Layout.preferredHeight: 4 }

                // Logout
                Rectangle {
                    Layout.fillWidth: true
                    height: 42
                    radius: 8
                    color: logoutHover.containsMouse ? "#C62828" : "#B71C1C"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Text { text: "🚪"; font.pixelSize: 16 }
                        Text { text: "Logout"; color: "white"; font.pixelSize: 13; font.bold: true }
                    }
                    MouseArea {
                        id: logoutHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: loader.pop()
                    }
                }
                Item { Layout.preferredHeight: 6 }
            }
        }

        // ── CONTENT AREA ──────────────────────────────────────────────────────
        StackLayout {
            currentIndex: userRole === "customer"
                          ? 5
                          : ["Products", "Users", "Customers", "Reports", "History"].indexOf(activeTab)
            Layout.fillWidth: true
            Layout.fillHeight: true

            // ── Tab 0: Products ────────────────────────────────────────────────
            ColumnLayout {
                spacing: 0

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
                            height: 40; width: 200
                            radius: 6; color: "white"; border.color: newName.activeFocus ? "#4CAF50" : "#DDD"
                            TextField {
                                id: newName; anchors.fill: parent; leftPadding: 12
                                placeholderText: "Product name"; background: null; font.pixelSize: 13
                            }
                        }
                        Rectangle {
                            height: 40; width: 100
                            radius: 6; color: "white"; border.color: newPrice.activeFocus ? "#4CAF50" : "#DDD"
                            TextField {
                                id: newPrice; anchors.fill: parent; leftPadding: 12
                                placeholderText: "Price (Rs.)"; background: null; font.pixelSize: 13
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                            }
                        }
                        Rectangle {
                            height: 40; width: 90
                            radius: 6; color: "white"; border.color: newStock.activeFocus ? "#4CAF50" : "#DDD"
                            TextField {
                                id: newStock; anchors.fill: parent; leftPadding: 12
                                placeholderText: "Stock"; background: null; font.pixelSize: 13
                                inputMethodHints: Qt.ImhDigitsOnly
                            }
                        }

                        Rectangle {
                            height: 40; width: 100
                            radius: 6
                            color: addHover.containsMouse ? "#388E3C" : "#4CAF50"
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Text {
                                anchors.centerIn: parent
                                text: "＋ Add Item"; color: "white"; font.pixelSize: 13; font.bold: true
                            }
                            MouseArea {
                                id: addHover; anchors.fill: parent; hoverEnabled: true
                                onClicked: {
                                    if (newName.text !== "") {
                                        inventoryManager.addVegetable(newName.text,
                                            parseFloat(newPrice.text || "0"),
                                            parseInt(newStock.text || "0"))
                                        newName.text = ""; newPrice.text = ""; newStock.text = ""
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
                    cellWidth: 180; cellHeight: 200
                    clip: true

                    delegate: Rectangle {
                        width: 166; height: 186
                        color: "white"
                        radius: 12
                        border.color: modelData.stock === 0 ? "#FFCDD2" : "#E8F5E9"
                        border.width: 1.5
                        visible: searchQuery === "" || modelData.name.toLowerCase().indexOf(searchQuery.toLowerCase()) >= 0

                        // Stock badge
                        Rectangle {
                            anchors.top: parent.top; anchors.right: parent.right
                            anchors.topMargin: 10; anchors.rightMargin: 10
                            width: 50; height: 20; radius: 10
                            color: modelData.stock === 0 ? "#FFCDD2" : modelData.stock < 5 ? "#FFF9C4" : "#E8F5E9"
                            Text {
                                anchors.centerIn: parent
                                text: modelData.stock === 0 ? "Out" : modelData.stock + " left"
                                font.pixelSize: 9; font.bold: true
                                color: modelData.stock === 0 ? "#C62828" : modelData.stock < 5 ? "#F57F17" : "#2E7D32"
                            }
                        }

                        // Delete button
                        Rectangle {
                            anchors.top: parent.top; anchors.left: parent.left
                            anchors.topMargin: 8; anchors.leftMargin: 8
                            width: 24; height: 24; radius: 12
                            color: delHover.containsMouse ? "#FFCDD2" : "transparent"
                            Text { anchors.centerIn: parent; text: "🗑"; font.pixelSize: 12 }
                            MouseArea { id: delHover; anchors.fill: parent; hoverEnabled: true
                                onClicked: inventoryManager.removeVegetable(index) }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: 8
                            spacing: 6
                            width: parent.width - 24

                            Text {
                                text: modelData.name
                                font.bold: true; font.pixelSize: 14; color: "#1A3D16"
                                Layout.alignment: Qt.AlignHCenter
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Text {
                                text: "Rs. " + modelData.price.toFixed(2)
                                color: "#2D6B26"; font.pixelSize: 13
                                Layout.alignment: Qt.AlignHCenter
                            }

                            // Stock spinner
                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 6
                                Rectangle {
                                    width: 28; height: 28; radius: 14
                                    color: sHover.containsMouse ? "#E8F5E9" : "#F5F5F5"
                                    Text { anchors.centerIn: parent; text: "−"; font.pixelSize: 16; color: "#2D5A27" }
                                    MouseArea { id: sHover; anchors.fill: parent; hoverEnabled: true
                                        onClicked: if (modelData.stock > 0) inventoryManager.updateStock(index, modelData.stock - 1) }
                                }
                                Text {
                                    text: modelData.stock; font.pixelSize: 15; font.bold: true; color: "#333"
                                    width: 30; horizontalAlignment: Text.AlignHCenter
                                }
                                Rectangle {
                                    width: 28; height: 28; radius: 14
                                    color: aHover.containsMouse ? "#E8F5E9" : "#F5F5F5"
                                    Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 16; color: "#2D5A27" }
                                    MouseArea { id: aHover; anchors.fill: parent; hoverEnabled: true
                                        onClicked: inventoryManager.updateStock(index, modelData.stock + 1) }
                                }
                            }
                        }
                    }
                }
            }

            // ── Tab 1: Users ───────────────────────────────────────────────────
            ColumnLayout {
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true; height: 70; color: "white"; border.color: "#E0E0E0"
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24
                        Text { text: "👥 Staff & User Management"; font.pixelSize: 20; font.bold: true; color: "#1A3D16" }
                        Item { Layout.fillWidth: true }
                        Text { text: inventoryManager.customerList.length + " registered users"; font.pixelSize: 12; color: "#888" }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; height: 64; color: "#F9FBF9"; border.color: "#E8F5E9"
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24; spacing: 10
                        Text { text: "New User:"; font.pixelSize: 13; color: "#555"; font.bold: true }
                        Rectangle {
                            height: 40; width: 200; radius: 6; color: "white"; border.color: addCName.activeFocus ? "#4CAF50" : "#DDD"
                            TextField { id: addCName; anchors.fill: parent; leftPadding: 12; placeholderText: "Full name"; background: null; font.pixelSize: 13 }
                        }
                        Rectangle {
                            height: 40; width: 160; radius: 6; color: "white"; border.color: addCPhone.activeFocus ? "#4CAF50" : "#DDD"
                            TextField { id: addCPhone; anchors.fill: parent; leftPadding: 12; placeholderText: "Phone / ID"; background: null; font.pixelSize: 13 }
                        }
                        Rectangle {
                            height: 40; width: 120; radius: 6
                            color: createHover.containsMouse ? "#388E3C" : "#4CAF50"
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Text { anchors.centerIn: parent; text: "＋ Create"; color: "white"; font.pixelSize: 13; font.bold: true }
                            MouseArea {
                                id: createHover; anchors.fill: parent; hoverEnabled: true
                                onClicked: {
                                    if (addCName.text !== "") {
                                        inventoryManager.addCustomer(addCName.text, addCPhone.text)
                                        addCName.text = ""; addCPhone.text = ""
                                    }
                                }
                            }
                        }
                    }
                }

                ListView {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    model: inventoryManager.customerList
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
                                TextField {
                                    text: modelData.name; font.bold: true; font.pixelSize: 14
                                    background: null; color: "#1A3D16"
                                    onEditingFinished: inventoryManager.editCustomerName(index, text)
                                }
                                Text { text: "📞 " + modelData.phone + "  •  ID: " + (index + 1001); font.pixelSize: 11; color: "#888" }
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                height: 32; width: 110; radius: 6
                                color: rstHover.containsMouse ? "#FFF9C4" : "#FFFDE7"
                                border.color: "#F9A825"
                                Text { anchors.centerIn: parent; text: "🔑 Reset PIN"; font.pixelSize: 11; color: "#F57F17"; font.bold: true }
                                MouseArea { id: rstHover; anchors.fill: parent; hoverEnabled: true
                                    onClicked: inventoryManager.resetCustomerPassword(index, "1234") }
                            }

                            Rectangle {
                                height: 32; width: 32; radius: 6
                                color: userDelHover.containsMouse ? "#FFCDD2" : "#FFF5F5"
                                border.color: "#EF9A9A"
                                Text { anchors.centerIn: parent; text: "🗑"; font.pixelSize: 14 }
                                MouseArea { id: userDelHover; anchors.fill: parent; hoverEnabled: true
                                    onClicked: inventoryManager.removeCustomer(index) }
                            }
                        }

                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#F0F0F0" }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: inventoryManager.customerList.length === 0
                        text: "No users registered yet.\nAdd your first user above."
                        horizontalAlignment: Text.AlignHCenter
                        color: "#999"; font.pixelSize: 14; lineHeight: 1.6
                    }
                }
            }

            // ── Tab 2: Customers ───────────────────────────────────────────────
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

                            Rectangle {
                                height: 34; width: 130; radius: 8
                                color: prHover.containsMouse ? "#EDE7F6" : "#F3E5F5"
                                border.color: "#CE93D8"
                                Text { anchors.centerIn: parent; text: "🔑 Reset Password"; font.pixelSize: 11; color: "#6A1B9A"; font.bold: true }
                                MouseArea { id: prHover; anchors.fill: parent; hoverEnabled: true
                                    onClicked: inventoryManager.resetCustomerPassword(index, "1234") }
                            }
                        }
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#F0F0F0" }
                    }
                }
            }

            // ── Tab 3: Reports ─────────────────────────────────────────────────
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
                        Item { height: 20 }
                    }
                }
            }

            // ── Tab 4: History ─────────────────────────────────────────────────
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
                            color: clrHover.containsMouse ? "#FFCDD2" : "#FFF5F5"; border.color: "#EF9A9A"
                            Text { anchors.centerIn: parent; text: "🗑 Clear History"; font.pixelSize: 12; color: "#C62828"; font.bold: true }
                            MouseArea { id: clrHover; anchors.fill: parent; hoverEnabled: true; onClicked: inventoryManager.clearHistory() }
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

                            Rectangle {
                                height: 34; width: 100; radius: 8; color: "#E8F5E9"
                                Text { anchors.centerIn: parent; text: "Rs. " + modelData.total; font.bold: true; color: "#2E7D32"; font.pixelSize: 14 }
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

            // ── Tab 5: Customer Store ──────────────────────────────────────────
            RowLayout {
                spacing: 0

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
                                color: custLogHover.containsMouse ? "#C62828" : "#B71C1C"
                                Behavior on color { ColorAnimation { duration: 120 } }
                                Text { anchors.centerIn: parent; text: "Logout"; color: "white"; font.pixelSize: 13; font.bold: true }
                                MouseArea { id: custLogHover; anchors.fill: parent; hoverEnabled: true; onClicked: loader.pop() }
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

                                // Product emoji/icon placeholder
                                Rectangle {
                                    width: 56; height: 56; radius: 28
                                    color: modelData.stock === 0 ? "#F5F5F5" : "#E8F5E9"
                                    Layout.alignment: Qt.AlignHCenter
                                    Text { anchors.centerIn: parent; text: "🥦"; font.pixelSize: 28 }
                                }

                                Text { text: modelData.name; font.bold: true; font.pixelSize: 14; color: "#1A3D16"; Layout.alignment: Qt.AlignHCenter; elide: Text.ElideRight; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
                                Text { text: "Rs. " + modelData.price.toFixed(2); color: "#2D6B26"; font.pixelSize: 13; Layout.alignment: Qt.AlignHCenter }
                                Text { text: modelData.stock === 0 ? "Out of stock" : modelData.stock + " available"; font.pixelSize: 10; color: modelData.stock === 0 ? "#C62828" : "#999"; Layout.alignment: Qt.AlignHCenter }

                                Rectangle {
                                    Layout.fillWidth: true; height: 34; radius: 8
                                    color: modelData.stock === 0 ? "#F5F5F5" : (cartBtnHover.containsMouse ? "#388E3C" : "#4CAF50")
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                    Text { anchors.centerIn: parent; text: modelData.stock === 0 ? "Unavailable" : "+ Add to Cart"; color: modelData.stock === 0 ? "#AAA" : "white"; font.pixelSize: 12; font.bold: true }
                                    MouseArea { id: cartBtnHover; anchors.fill: parent; hoverEnabled: true; enabled: modelData.stock > 0; onClicked: addToCart(modelData.name, modelData.price) }
                                }
                            }
                        }
                    }
                }

                // Cart sidebar
                Rectangle {
                    Layout.preferredWidth: 300; Layout.fillHeight: true
                    color: "#FAFAFA"; border.color: "#E0E0E0"

                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 16; spacing: 12

                        // Cart header
                        RowLayout {
                            Text { text: "🧺 Basket"; font.bold: true; font.pixelSize: 18; color: "#1A3D16" }
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                id: cartFeedback
                                width: 28; height: 28; radius: 14; color: "#E8F5E9"
                                Text { anchors.centerIn: parent; text: cartModel.count; font.pixelSize: 13; font.bold: true; color: "#2E7D32" }
                                function flash() {
                                    flashAnim.start()
                                }
                                SequentialAnimation on scale {
                                    id: flashAnim; running: false
                                    NumberAnimation { to: 1.3; duration: 100 }
                                    NumberAnimation { to: 1.0; duration: 100 }
                                }
                            }
                        }

                        Rectangle { Layout.fillWidth: true; height: 1; color: "#E0E0E0" }

                        // Empty cart state
                        Item {
                            Layout.fillWidth: true; Layout.fillHeight: true; visible: cartModel.count === 0
                            ColumnLayout {
                                anchors.centerIn: parent; spacing: 8
                                Text { text: "🛒"; font.pixelSize: 40; Layout.alignment: Qt.AlignHCenter }
                                Text { text: "Your basket is empty"; color: "#999"; font.pixelSize: 13; Layout.alignment: Qt.AlignHCenter }
                                Text { text: "Add items from the store"; color: "#BBB"; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter }
                            }
                        }

                        // Cart items
                        ListView {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            model: cartModel; clip: true; spacing: 6
                            visible: cartModel.count > 0

                            delegate: Rectangle {
                                width: ListView.view ? ListView.view.width : 260
                                height: 64; radius: 10; color: "white"; border.color: "#EEEEEE"

                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; spacing: 8

                                    ColumnLayout {
                                        spacing: 2; Layout.fillWidth: true
                                        Text { text: model.name; font.bold: true; font.pixelSize: 13; color: "#1A3D16"; elide: Text.ElideRight; width: parent.width }
                                        Text { text: "Rs. " + (model.qty * model.price).toFixed(2); color: "#2D6B26"; font.pixelSize: 12 }
                                    }

                                    // Qty controls
                                    RowLayout {
                                        spacing: 4
                                        Rectangle {
                                            width: 24; height: 24; radius: 12; color: "#F5F5F5"
                                            Text { anchors.centerIn: parent; text: "−"; font.pixelSize: 16; color: "#333" }
                                            MouseArea { anchors.fill: parent; onClicked: decrementCart(index) }
                                        }
                                        Text { text: model.qty; font.pixelSize: 14; font.bold: true; color: "#333"; width: 20; horizontalAlignment: Text.AlignHCenter }
                                        Rectangle {
                                            width: 24; height: 24; radius: 12; color: "#E8F5E9"
                                            Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 16; color: "#2E7D32" }
                                            MouseArea { anchors.fill: parent; onClicked: incrementCart(index) }
                                        }
                                    }
                                }
                            }
                        }

                        // Note field
                        Rectangle {
                            Layout.fillWidth: true; height: 50; radius: 8; color: "white"; border.color: "#E0E0E0"
                            visible: cartModel.count > 0
                            TextField {
                                id: noteField; anchors.fill: parent; leftPadding: 12
                                placeholderText: "Add order note…"; background: null; font.pixelSize: 12
                                onTextChanged: cartNote = text
                            }
                        }

                        // Total
                        Rectangle {
                            Layout.fillWidth: true; height: 48; radius: 10; color: "#E8F5E9"
                            visible: cartModel.count > 0
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14
                                Text { text: "Total"; font.pixelSize: 14; color: "#555" }
                                Item { Layout.fillWidth: true }
                                Text { text: "Rs. " + totalAmount.toFixed(2); font.pixelSize: 18; font.bold: true; color: "#1A3D16" }
                            }
                        }

                        // Checkout button
                        Rectangle {
                            Layout.fillWidth: true; height: 46; radius: 10
                            color: cartModel.count > 0 ? (chkHover.containsMouse ? "#388E3C" : "#4CAF50") : "#BDBDBD"
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Text { anchors.centerIn: parent; text: cartModel.count > 0 ? "✔ Confirm Order" : "Add items to order"; color: "white"; font.pixelSize: 14; font.bold: true }
                            MouseArea {
                                id: chkHover; anchors.fill: parent; hoverEnabled: true
                                enabled: cartModel.count > 0
                                onClicked: {
                                    var historyString = ""
                                    for (var i = 0; i < cartModel.count; i++) {
                                        var item = cartModel.get(i)
                                        historyString += item.qty + "x " + item.name + " "
                                        inventoryManager.decrementStock(item.name, item.qty)
                                    }
                                    if (cartNote !== "") historyString += "[" + cartNote + "]"
                                    inventoryManager.processSale(historyString, totalAmount)
                                    cartModel.clear(); totalAmount = 0; cartNote = ""; noteField.text = ""
                                    statusPopup.open()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Success Popup ─────────────────────────────────────────────────────────
    Popup {
        id: statusPopup
        width: 300; height: 150
        anchors.centerIn: parent
        modal: true
        enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 } }
        exit:  Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150 } }

        background: Rectangle {
            radius: 16; color: "white"
            border.color: "#4CAF50"; border.width: 2
            layer.enabled: true
            layer.effect: null  // Replace with DropShadow if Qt Graphical Effects available
        }

        ColumnLayout {
            anchors.centerIn: parent; spacing: 10
            Text { text: "✅"; font.pixelSize: 36; Layout.alignment: Qt.AlignHCenter }
            Text { text: "Order Confirmed!"; font.bold: true; font.pixelSize: 17; color: "#1A3D16"; Layout.alignment: Qt.AlignHCenter }
            Text { text: "Thank you for your purchase"; font.pixelSize: 12; color: "#666"; Layout.alignment: Qt.AlignHCenter }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter; height: 36; width: 100; radius: 8
                color: doneHover.containsMouse ? "#388E3C" : "#4CAF50"
                Behavior on color { ColorAnimation { duration: 120 } }
                Text { anchors.centerIn: parent; text: "Done"; color: "white"; font.pixelSize: 13; font.bold: true }
                MouseArea { id: doneHover; anchors.fill: parent; hoverEnabled: true; onClicked: statusPopup.close() }
            }
        }

        Timer { interval: 3000; running: statusPopup.visible; onTriggered: statusPopup.close() }
    }
}
