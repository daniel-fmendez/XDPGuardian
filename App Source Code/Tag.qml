import QtQuick
import "Style"

Item {
    property string textContent: ""
    property bool isOn: false
    property bool isInteractive
    property color borderColor
    property color fillColor
    width: textElement.implicitWidth + 20
    height: textElement.implicitHeight + 20
    signal tagStatusChanged()
    Rectangle {
        radius: 180
        height: textElement.contentHeight+10
        implicitWidth: textElement.implicitWidth + 20
        color: isOn ? fillColor : Style.tagOffFill
        border.color: isOn ? borderColor : Style.tagOffBorder
        border.width:2

        Text {
            id: textElement
            text: textContent
            font.pixelSize: 14
            color: isOn ? borderColor : Style.tagOffText
            anchors.verticalCenter: parent.verticalCenter
            anchors.centerIn: parent  // Centrar completamente el texto
        }

        MouseArea {
            anchors.fill: parent
            enabled: isInteractive
            onClicked: {
                isOn = !isOn
                parent.color = isOn ? fillColor : Style.tagOffFill
                parent.border.color = isOn ? borderColor : Style.tagOffBorder
                textElement.color = isOn ? borderColor : Style.tagOffText
                tagStatusChanged()
            }
            hoverEnabled: true
            onEntered: {
                parent.color = Qt.darker(parent.color,1.05)
                parent.border.color = Qt.darker(parent.border.color,1.25)
                textElement.color = Qt.darker(textElement.color)
            }
            onExited: {
                parent.color = isOn ? fillColor : Style.tagOffFill
                parent.border.color = isOn ? borderColor : Style.tagOffBorder
                textElement.color = isOn ? borderColor : Style.tagOffText
            }
        }
    }
}
