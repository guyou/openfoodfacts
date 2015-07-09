import QtQuick 2.0
import Ubuntu.Components 1.1
import OpenFoodFacts 1.0

/*!
    \brief MainView with Tabs element.
           First Tab has a single Label and
           second Tab has a single ToolbarAction.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "openfoodfacts.ubuntouch"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(40)
    height: units.gu(68)

   PageStack {
        id: pageStack
        Component.onCompleted: push(pageMain)
        height: parent.height

        Page {
            title: i18n.tr("OpenFoodFacts")
            id:pageMain

          Column {
                spacing: units.gu(2)
                anchors {
                     margins: units.gu(2)
                        right: parent.right
                        left: parent.left

                 }
            Button {
                objectName: "button"
                anchors.horizontalCenter: parent.horizontalCenter
                width: units.gu(30)

                text: i18n.tr("Take a picture")

                onClicked: {
                    var barcodeValue = "3103220022696";
                    console.log("picture tooken with barcode = " + barcodeValue);
                    pageStack.push(Qt.resolvedUrl("tagger.qml"));
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: units.gu(1)



                    TextField {
                        id: barcodeinput
                        height: units.gu(4)
                        placeholderText: "Enter your barcode"
                        text : "3029330003533"
                        inputMethodHints : Qt.ImhDigitsOnly
                    }



                    Button {
                      objectName: "envoyer"
                      width: units.gu(4)
                      height: units.gu(4)
                      iconName: "search"

                      onClicked: {
                          var barcodeValue = barcodeinput.text;
                          pageStack.push(Qt.resolvedUrl("qml/ProductView.qml"), {"barcode": barcodeValue});
                      }
                    }

            }
          }

        }
    }
}

