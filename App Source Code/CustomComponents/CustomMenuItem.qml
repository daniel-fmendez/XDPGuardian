import QtQuick 2.15
import QtQuick.Controls
import "../Style"
MenuItem {
    id: customItem

    contentItem: Text {
        text: customItem.text
        color: Style.textTitleColor
        font.bold: false
        font.pixelSize: 14
        verticalAlignment: Text.AlignVCenter
    }
    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 30
        radius: 5
        color: customItem.highlighted ? Style.menuSelected : "transparent"
    }
}
