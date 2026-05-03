import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: sidebarRoot
    Layout.preferredWidth: 220
    Layout.fillHeight: true
    color: "#1A3D16"

    property string activeTab: "Products"
    signal tabChanged(string tabName)
    signal logoutRequested()

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
                { label: "Products",    icon: "📦" },
                { label: "Live Prices", icon: "🌐" },
                { label: "Users",       icon: "👥" },
                { label: "Customers",   icon: "📇" },
                { label: "Reports",     icon: "📊" },
                { label: "History",     icon: "🕒" }
            ]
            delegate: Rectangle {
                Layout.fillWidth: true
                height: 44
                radius: 8
                color: activeTab === modelData.label
                       ? "#4CAF50"
                       : navItemArea.containsMouse ? "#2A5224" : "transparent"
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
                    id: navItemArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: tabChanged(modelData.label)
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
            color: logoutArea.containsMouse ? "#C62828" : "#B71C1C"
            Behavior on color { ColorAnimation { duration: 150 } }
            RowLayout {
                anchors.centerIn: parent
                spacing: 8
                Text { text: "🚪"; font.pixelSize: 16 }
                Text { text: "Logout"; color: "white"; font.pixelSize: 13; font.bold: true }
            }
            MouseArea {
                id: logoutArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: logoutRequested()
            }
        }
        Item { Layout.preferredHeight: 6 }
    }
}
