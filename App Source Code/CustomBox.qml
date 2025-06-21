import QtQuick
import "Style"
Item {
    /*
    Rectangle {
        id: shadow
        width: box.width
        height: box.height
        radius: box.radius
        color: "black"
        opacity: 0.3
        anchors.top: box.top
        anchors.topMargin: 5
    }*/

    Rectangle {
        id: box
        width: parent.width - 8
        height: texto.contentHeight + 15
        radius: 2.5

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        border.color: Style.borderNormalColor
        color: Style.windowBackground

        Rectangle {
            id: circle
            height: parent.height-20
            width: height
            radius: 180
            color: Style.networkEnabled
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: height/2 + 0.5
        }

        Text {
            id: texto
            text: "Elemento " + index
            anchors.left: circle.left
            anchors.leftMargin: circle.width + 10
            anchors.verticalCenter: parent.verticalCenter
            //verticalAlignment: Text.AlignVCenter
        }
    }
}
