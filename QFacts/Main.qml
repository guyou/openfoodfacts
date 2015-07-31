import QtQuick 2.0
import Ubuntu.Components 1.1
import QFacts 1.0
import QZXing 2.3
import QtMultimedia 5.4


/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "qfacts.nymeria"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(100)
    height: units.gu(75)

    Page {
        title: i18n.tr("QFacts")

        /*Camera {
            id: camera
            imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash
            exposure {
                exposureCompensation: -1.0
                exposureMode: Camera.ExposurePortrait
            }
            flash.mode: Camera.FlashRedEyeReduction
            imageCapture {
                onImageSaved : {
                    console.log("image saved");
                    imageToDecode.source= path
                    decoder.decodeImageQML(imageToDecode.source);
                }

                onImageCaptured: {
                    console.log("yii ah");
                    //imageToDecode.source = preview
                }
            }
        }
        VideoOutput {
            source: camera
            anchors.fill: parent
            focus : visible // to receive focus and capture key events when visible
            MouseArea {
                anchors.fill: parent;
                onClicked: camera.imageCapture.capture();
            }
        }*/

        Image{
            id:imageToDecode
            source: "bar-1.jpg"
            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    console.log(imageToDecode.source)
                    decoder.decodeImageFromFile(imageToDecode.source)
                 //decoder.decodeImageQML(imageToDecode)
                }
            }

        }

        QZXing{
            id: decoder
            enabledDecoders: QZXing.DecoderFormat_EAN_8 | QZXing.DecoderFormat_EAN_13

            onDecodingStarted: console.log("Decoding of image started...")

            onTagFound: console.log("Barcode data: " + tag)

            onDecodingFinished: console.log("Decoding finished " + (succeeded==true ? "successfully" :    "unsuccessfully") )
        }

        /*MyType {
            id: myType

            Component.onCompleted: {
                myType.helloWorld = i18n.tr("Hello world..")
            }
        }

        Column {
            spacing: units.gu(1)
            anchors {
                margins: units.gu(2)
                fill: parent
            }

            Label {
                id: label
                objectName: "label"

                text: myType.helloWorld
            }

            Button {
                objectName: "button"
                width: parent.width

                text: i18n.tr("Tap me!")

                onClicked: {
                    myType.helloWorld = i18n.tr("..from Cpp Backend")
                }
            }
        }*/
    }
}

