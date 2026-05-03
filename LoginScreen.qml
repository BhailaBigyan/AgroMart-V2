import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: loginPageRoot
    color: "#f0f4f0"

    signal loginSuccess(string role)

    // ── Login Card ────────────────────────────────────────────────────
    Rectangle {
        id: loginCard
        width: 400
        height: 520
        anchors.centerIn: parent
        radius: 20
        color: "white"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 12

            // ── 1. Branding ───────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                Layout.alignment: Qt.AlignLeft

                Image {
                    id: brandLogo
                    source: "logo.png"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 50
                    fillMode: Image.PreserveAspectFit
                }

                ColumnLayout {
                    spacing: -2
                    Text {
                        text: "AgroMart"
                        font.pixelSize: 28
                        font.bold: true
                        color: "#2D5A27"
                        Layout.alignment: Qt.AlignLeft
                    }
                    Text {
                        text: "GROW YOUR BUSINESS"
                        font.pixelSize: 10
                        font.letterSpacing: 1.5
                        color: "#2D5A27"
                        Layout.alignment: Qt.AlignLeft
                    }
                }
            }

            // ── 2. Welcome Message ────────────────────────────────────
            Text {
                text: "Hello! Welcome back"
                font.pixelSize: 14
                color: "#666"
                lineHeight: 1.2
                Layout.alignment: Qt.AlignLeft
                Layout.topMargin: 5
                Layout.bottomMargin: 10
            }

            // ── 3. Input Fields ───────────────────────────────────────
            TextField {
                id: emailField
                placeholderText: "Email / Phone"
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                topPadding: 10
                leftPadding: 20
                background: Rectangle {
                    radius: 8
                    border.color: emailField.activeFocus ? "#2D5A27" : "#ccc"
                    border.width: emailField.activeFocus ? 2 : 1
                }
            }

            TextField {
                id: passwordField
                placeholderText: "Password"
                echoMode: TextInput.Password
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                topPadding: 10
                leftPadding: 20
                background: Rectangle {
                    radius: 8
                    border.color: passwordField.activeFocus ? "#2D5A27" : "#ccc"
                    border.width: passwordField.activeFocus ? 2 : 1
                }
            }

            // ── 4. Error Message ──────────────────────────────────────
            Text {
                id: loginErrorMessage
                text: "⚠ Incorrect Email or Password. Please try again."
                color: "#d9534f"
                font.pixelSize: 12
                visible: false
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            // ── 5. Sign In Button ────────────────
            Button {
                id: signInButton
                text: "Sign In to Dashboard"
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                Layout.topMargin: 10

                onClicked: {
                    var role = inventoryManager.authenticate(emailField.text, passwordField.text)
                    if (role !== "") {
                        loginErrorMessage.visible = false
                        loginSuccess(role)
                    } else {
                        loginErrorMessage.visible = true
                    }
                }

                contentItem: Text {
                    text: signInButton.text
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: signInButton.pressed ? "#d4843f" : "#F2994A"
                    radius: 8
                }
            }
        }
    }
}
