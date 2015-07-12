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
import Ubuntu.Components 0.1

Item {
    id: root
    width: (parent.width - parent.spacing) / 2
    height: width

    property string text

    signal clicked()

    ShaderEffectSource {
        id: source
        width: 1
        height: 1
        hideSource: true

        sourceItem: Image {
            source: "image://qrcode/" + root.text
            height: root.height
            width: root.width

            Rectangle {
                id: textBackground
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: units.gu(8)
                opacity: 0.7
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#00000000" }
                    GradientStop { position: 0.33; color: "#ff000000" }
                    GradientStop { position: 1.0; color: "#ff000000" }
                }
            }
            Label {
                id: textLabel
                anchors.centerIn: textBackground
                anchors.verticalCenterOffset: units.gu(1)
                text: root.text
                fontSize: "large"
            }
        }
    }

    Shape {
        id: shape
        image: source

        anchors.fill: parent
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.clicked();
        }
    }
}

