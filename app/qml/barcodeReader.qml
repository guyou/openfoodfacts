import QtQuick 2.0
import Ubuntu.Components 1.1
import QtMultimedia 5.0
import Ubuntu.Content 0.1
/*
import QtQuick 2.4
import Ubuntu.Components 1.1
import QtMultimedia 5.4
import Ubuntu.Content 1.1
*/
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Popups 1.0
import CodeReader 1.0
import QtQuick.Window 2.0


    Page {
        id: grabCodePage
        title: i18n.tr("Scan QR code")

        QRCodeReader {
            id: qrCodeReader

            onValidChanged: {
                if (valid) {
                    /*var account = accounts.createAccount();
                    account.name = qrCodeReader.accountName;
                    account.type = qrCodeReader.type;
                    account.secret = qrCodeReader.secret;
                    account.counter = qrCodeReader.counter;
                    account.timeStep = qrCodeReader.timeStep;
                    account.pinLength = qrCodeReader.pinLength;*/
                    //pageStack.pop();
                }
            }
        }

        Camera {
            id: camera

            flash.mode: Camera.FlashTorch

            focus.focusMode: Camera.FocusContinuous
            focus.focusPointMode: Camera.FocusPointAuto

            Component.onCompleted: {
                captureTimer.start()
            }
        }

        Timer {
            id: captureTimer
            interval: 3000
            repeat: true
            onTriggered: {
                print("capturing");
                qrCodeReader.grab();
            }
        }

        VideoOutput {
            anchors {
                fill: parent
            }
            fillMode: Image.PreserveAspectCrop
            orientation: device.naturalOrientation === "portrait"  ? -90 : 0
            source: camera
            focus: visible

        }
        Label {
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
                margins: units.gu(1)
            }
            text: i18n.tr("Scan a QR Code containing account information")
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            fontSize: "large"
        }
        // We must use Item element because Screen component does not work with QtObject
        Item {
            id: device
            property string naturalOrientation: Screen.primaryOrientation == Qt.LandscapeOrientation ? "landscape" : "portrait"
            visible: false
        }

    }

