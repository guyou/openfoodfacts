/*****************************************************************************
 * Copyright: 2013 Michael Zanetti <michael_zanetti@gmx.net>                 *
 *                                                                           *
 * This file is part of tagger                                               *
 *                                                                           *
 * This prject is free software: you can redistribute it and/or modify       *
 * it under the terms of the GNU General Public License as published by      *
 * the Free Software Foundation, either version 3 of the License, or         *
 * (at your option) any later version.                                       *
 *                                                                           *
 * This project is distributed in the hope that it will be useful,           *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 * GNU General Public License for more details.                              *
 *                                                                           *
 * You should have received a copy of the GNU General Public License         *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                           *
 ****************************************************************************/

import QtQuick 2.0
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Popups 1.0
import QtMultimedia 5.4
import QtQuick.Window 2.0
import Ubuntu.Content 0.1
import OpenFoodFacts 1.0

MainView {
    id: mainView

    applicationName: "com.ubuntu.developer.mzanetti.tagger"

    //automaticOrientation: true

    Component.onCompleted: i18n.domain = "tagger"

    backgroundColor: "#dddddd"

    width: units.gu(40)
    height: units.gu(68)

    PageStack {
        id: pageStack
        Component.onCompleted: {
            pageStack.push(dummyPage)
        }
    }
    Page {
        id: dummyPage
    }

    Timer {
        interval: 1
        running: true
        repeat: false
        onTriggered: {
            if (pageStack.currentPage == dummyPage) {
                pageStack.pop();
                pageStack.push(qrCodeReaderComponent)
            }
        }
    }

    Connections {
        target: qrCodeReader

        onScanningChanged: {
            if (!qrCodeReader.scanning) {
                mainView.decodingImage = false;
            }
        }

        onValidChanged: {
            if (qrCodeReader.valid) {
//                pageStack.pop();
                pageStack.push(resultsPageComponent, {type: qrCodeReader.type, text: qrCodeReader.text, imageSource: qrCodeReader.imageSource});
            }
        }
    }

    Connections {
        target: ContentHub
        onExportRequested: {
            // show content picker
            print("******* transfer requested!");
            pageStack.pop();
            pageStack.push(generateCodeComponent, {transfer: transfer})
        }
        onImportRequested: {
            print("**** import Requested")
            var filePath = String(transfer.items[0].url).replace('file://', '')
            qrCodeReader.processImage(filePath);
        }

        onShareRequested: {
            print("***** share requested", transfer)
            var filePath = String(transfer.items[0].url).replace('file://', '')
            qrCodeReader.processImage(filePath);
        }
    }

    property list<ContentItem> importItems
    property var activeTransfer: null
    property bool decodingImage: false
    ContentPeer {
        id: picSourceSingle
        contentType: ContentType.Pictures
        handler: ContentHandler.Source
        selectionType: ContentTransfer.Single
    }
    ContentTransferHint {
        id: importHint
        anchors.fill: parent
        activeTransfer: mainView.activeTransfer
        z: 100
    }
    Connections {
        target: mainView.activeTransfer
        onStateChanged: {
            switch (mainView.activeTransfer.state) {
            case ContentTransfer.Charged:
                print("should process", activeTransfer.items[0].url)
                mainView.decodingImage = true;
                qrCodeReader.processImage(activeTransfer.items[0].url);
                mainView.activeTransfer = null;
                break;
            case ContentTransfer.Aborted:
                mainView.activeTransfer = null;
                break;
            }
        }
    }

    onDecodingImageChanged: {
        if (!decodingImage && !qrCodeReader.valid) {
            pageStack.push(errorPageComponent)
        }
    }

    Component {
        id: errorPageComponent
        Page {
            title: i18n.tr("Error")
            Column {
                anchors {
                    left: parent.left;
                    right: parent.right;
                    verticalCenter: parent.verticalCenter
                }
                Label {
                    anchors { left: parent.left; right: parent.right }
                    horizontalAlignment: Text.AlignHCenter
                    // TRANSLATORS: Displayed after a picture has been scanned and no code was found in it
                    text: i18n.tr("No code found in image")
                }
            }
        }
    }

    Component {
        id: qrCodeReaderComponent

        PageWithBottomEdge {
            id: qrCodeReaderPage
            // TRANSLATORS: Title of the main page of the app, when the camera is active and scanning for codes
            title: i18n.tr("Scan code")
            signal codeParsed(string type, string text)

            property var aboutPopup: null

            Component.onCompleted: {
                qrCodeReader.scanRect = Qt.rect(mainView.mapFromItem(videoOutput, 0, 0).x, mainView.mapFromItem(videoOutput, 0, 0).y, videoOutput.width, videoOutput.height)
            }

            head {
                actions: [
                    Action {
                        text: i18n.tr("Generate code")
                        iconName: "compose"
                        onTriggered: pageStack.push(generateCodeComponent)
                    },
                    Action {
                        // TRANSLATORS: Name of an action in the toolbar to import pictures from other applications and scan them for codes
                        text: i18n.tr("Import image")
                        iconName: "insert-image"
                        onTriggered: {
                            mainView.activeTransfer = picSourceSingle.request()
                            print("transfer request", mainView.activeTransfer)
                        }
                    }
                ]
            }

            bottomEdgeTitle: i18n.tr("Previously scanned")

            bottomEdgePageComponent: Component {
                Page {
                    title: i18n.tr("Previously scanned")
                    ListView {
                        anchors.fill: parent
                        model: qrCodeReader.history
                        delegate: Subtitled {
                            text: model.text
                            subText: model.type + " - " + model.timestamp
                            iconSource: model.imageSource
                            onClicked: {
                                pageStack.push(resultsPageComponent, {type: model.type, text: model.text, imageSource: model.imageSource})
                            }
                            removable: true
                            onItemRemoved: {
                                qrCodeReader.history.remove(index)
                            }
                        }
                    }
                }
            }

            Camera {
                id: camera

                flash.mode: Camera.FlashTorch

                focus.focusMode: Camera.FocusContinuous
                focus.focusPointMode: Camera.FocusPointAuto

                /* Use only digital zoom for now as it's what phone cameras mostly use.
                       TODO: if optical zoom is available, maximumZoom should be the combined
                       range of optical and digital zoom and currentZoom should adjust the two
                       transparently based on the value. */
                property alias currentZoom: camera.digitalZoom
                property alias maximumZoom: camera.maximumDigitalZoom

                function startAndConfigure() {
                    start();
                    focus.focusMode = Camera.FocusContinuous
                    focus.focusPointMode = Camera.FocusPointAuto
                }
            }

            Connections {
                target: Qt.application
                onActiveChanged: Qt.application.active ? camera.startAndConfigure() : camera.stop()
            }

            Timer {
                id: captureTimer
                interval: 2000
                repeat: true
                running: pageStack.depth == 1
                         && qrCodeReaderPage.aboutPopup == null
                         && !mainView.decodingImage
                         && mainView.activeTransfer == null
                onTriggered: {
                    if (!qrCodeReader.scanning && qrCodeReaderPage.isCollapsed) {
                        print("capturing");
                        qrCodeReader.grab();
                    }
                }

                onRunningChanged: {
                    print("rimer running changed", running)
                    if (running) {
                        camera.startAndConfigure();
                    } else {
                        camera.stop();
                    }
                }
            }

            VideoOutput {
                id: videoOutput
                anchors {
                    fill: parent
                }
                fillMode: Image.PreserveAspectCrop
                orientation: device.naturalOrientation === "portrait"  ? -90 : 0
                source: camera
                focus: visible
                visible: pageStack.depth == 1 && !mainView.decodingImage

            }
            PinchArea {
                id: pinchy
                anchors.fill: parent

                property real initialZoom
                property real minimumScale: 0.3
                property real maximumScale: 3.0
                property bool active: false

                onPinchStarted: {
                    print("pinch started!")
                    active = true;
                    initialZoom = camera.currentZoom;
                }
                onPinchUpdated: {
                    print("pinch updated")
                    var scaleFactor = MathUtils.projectValue(pinch.scale, 1.0, maximumScale, 0.0, camera.maximumZoom);
                    camera.currentZoom = MathUtils.clamp(initialZoom + scaleFactor, 1, camera.maximumZoom);
                }
                onPinchFinished: {
                    active = false;
                }
            }

            ActivityIndicator {
                anchors.centerIn: parent
                running: mainView.decodingImage
            }
            Label {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: units.gu(5)
                text: i18n.tr("Decoding image")
                visible: mainView.decodingImage
            }
        }
    }

    Component {
        id: resultsPageComponent
        Page {
            id: resultsPage
            title: i18n.tr("Results")
            property string type
            property string text
            property string imageSource
            onTextChanged: console.log("text changed : "+resultsPage.text);


            property bool isUrl: (resultsPage.text.indexOf("http://") === 0 || resultsPage.text.indexOf("https://") === 0)
            property bool isPhoneNumber: resultsPage.text.indexOf("tel:") == 0

            Flickable {
                anchors.fill: parent
                contentHeight: resultsColumn.height + units.gu(4)
                interactive: contentHeight > height

                Column {
                    id: resultsColumn
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }
                    height: childrenRect.height

                    spacing: units.gu(1)
                    Row {
                        width: parent.width
                        spacing: units.gu(1)
                        Item {
                            id: imageItem
                            width: parent.width / 2
                            height: portrait ? width : imageShape.height
                            property bool portrait: resultsImage.height > resultsImage.width

                            UbuntuShape {
                                id: imageShape
                                anchors.centerIn: parent
                                // ssh : ssw = h : w
                                height: imageItem.portrait ? parent.height : resultsImage.height * width / resultsImage.width
                                width: imageItem.portrait ? resultsImage.width * height / resultsImage.height : parent.width
                                image: Image {
                                    id: resultsImage
                                    source: resultsPage.imageSource
                                }
                            }
                        }

                        Column {
                            width: (parent.width - parent.spacing) / 2
                            Label {
                                text: i18n.tr("Code type")
                                font.bold: true
                            }
                            Label {
                                text: resultsPage.type
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            }
                            Item {
                                width: parent.width
                                height: units.gu(1)
                            }

                            Label {
                                text: i18n.tr("Content length")
                                font.bold: true
                            }
                            Label {
                                text: resultsPage.text.length
                            }
                        }

                    }
                    Label {
                        width: parent.width
                        text: i18n.tr("Code content")
                        font.bold: true
                    }
                    UbuntuShape {
                        width: parent.width
                        height: resultsLabel.height + units.gu(2)
                        color: "white"


                        Label {
                            id: resultsLabel
                            text: resultsPage.text
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            width: parent.width - units.gu(2)
                            anchors.centerIn: parent
                            color: resultsPage.isUrl ? "blue" : "black"
                        }
                    }

                    Button {
                        width: parent.width
                        text: i18n.tr("Open URL")
                        visible: resultsPage.isUrl
                        onClicked: Qt.openUrlExternally(resultsPage.text)
                    }

                    Button {
                        width: parent.width
                        text: i18n.tr("Search online")
                        visible: !resultsPage.isUrl
                        onClicked: Qt.openUrlExternally("https://duckduckgo.com/?q=" + resultsPage.text)
                    }

                    Button {
                        width: parent.width
                        text: i18n.tr("Call number")
                        visible: resultsPage.isPhoneNumber
                        onClicked: {
                            Qt.openUrlExternally("tel:///" + resultsPage.text)
                        }
                    }

                    Button {
                        width: parent.width
                        text: i18n.tr("Copy to clipboard")
                        onClicked: Clipboard.push(resultsPage.text)
                    }

                    Button {
                        width: parent.width
                        text: i18n.tr("Generate QR code")
                        onClicked: {
                            pageStack.pop();
                            pageStack.push(generateCodeComponent, {textData: resultsPage.text})
                        }
                    }
                }
            }
        }
    }

    Component {
        id: aboutDialogComponent
        Dialog {
            id: aboutDialog
            title: "Tagger 0.5"
            text: "Michael Zanetti\nmichael_zanetti@gmx.net"

            signal closed()

            Item {
                width: parent.width
                height: units.gu(40)
                Column {
                    id: contentColumn
                    anchors.fill: parent
                    spacing: units.gu(1)

                    UbuntuShape {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: units.gu(6)
                        width: units.gu(6)
                        radius: "medium"
                        image: Image {
                            source: "images/tagger.svg"
                        }
                    }

                    Flickable {
                        width: parent.width
                        height: parent.height - y - (closeButton.height + parent.spacing) * 3
                        contentHeight: gplLabel.implicitHeight
                        clip: true
                        Label {
                            id: gplLabel
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: "This program is free software: you can redistribute it and/or modify " +
                                  "it under the terms of the GNU General Public License as published by " +
                                  "the Free Software Foundation, either version 3 of the License, or " +
                                  "(at your option) any later version.\n\n" +

                                  "This program is distributed in the hope that it will be useful, " +
                                  "but WITHOUT ANY WARRANTY; without even the implied warranty of " +
                                  "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the " +
                                  "GNU General Public License for more details.\n\n" +

                                  "You should have received a copy of the GNU General Public License " +
                                  "along with this program.  If not, see http://www.gnu.org/licenses/."
                        }
                    }
                    Button {
                        id: closeButton
                        width: parent.width
                        text: i18n.tr("Close")
                        onClicked: {
                            aboutDialog.closed()
                            PopupUtils.close(aboutDialog)
                        }
                    }
                }
            }
        }
    }

    // We must use Item element because Screen component does not work with QtObject
    Item {
        id: device
        property string naturalOrientation: Screen.primaryOrientation == Qt.LandscapeOrientation ? "landscape" : "portrait"
        visible: false
    }
}
