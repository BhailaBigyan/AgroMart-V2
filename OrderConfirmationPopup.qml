import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: statusPopup
    property int currentSaleId: -1
    function openWithSale(saleId) {
        currentSaleId = saleId;
        open();
    }
    width: 300; height: 160
    anchors.centerIn: parent
    modal: true
    enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 } }
    exit:  Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150 } }

    background: Rectangle {
        radius: 16; color: "white"
        border.color: "#4CAF50"; border.width: 2
    }

    ColumnLayout {
        anchors.centerIn: parent; spacing: 10
        Text { text: "✅"; font.pixelSize: 36; Layout.alignment: Qt.AlignHCenter }
        Text { text: "Order Confirmed!"; font.bold: true; font.pixelSize: 17; color: "#1A3D16"; Layout.alignment: Qt.AlignHCenter }
        Text { text: "Thank you for your purchase"; font.pixelSize: 12; color: "#666"; Layout.alignment: Qt.AlignHCenter }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 15

            Rectangle {
                height: 36; width: 100; radius: 8
                color: printPopupArea.containsMouse ? "#1565C0" : "#1976D2"
                Behavior on color { ColorAnimation { duration: 120 } }
                Text { anchors.centerIn: parent; text: "🖨 Print Bill"; color: "white"; font.pixelSize: 13; font.bold: true }
                MouseArea { 
                    id: printPopupArea; anchors.fill: parent; hoverEnabled: true; 
                    onClicked: {
                        if (currentSaleId > 0) {
                            inventoryManager.generateBillPDF(currentSaleId)
                        }
                    } 
                }
            }

            Rectangle {
                height: 36; width: 100; radius: 8
                color: closePopupArea.containsMouse ? "#388E3C" : "#4CAF50"
                Behavior on color { ColorAnimation { duration: 120 } }
                Text { anchors.centerIn: parent; text: "Done"; color: "white"; font.pixelSize: 13; font.bold: true }
                MouseArea { id: closePopupArea; anchors.fill: parent; hoverEnabled: true; onClicked: statusPopup.close() }
            }
        }
    }
}
