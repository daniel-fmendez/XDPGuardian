import QtQuick
import "../Style"
Item {
    id: root
    property string customText: "Elemento " + index
    property color circleColor: Style.networkDisabled
    property bool isSelected: false
    property bool isHovered: false
    property color hoverFillColor: Style.windowBackground
    property color hoverBorderColor: Style.borderNormalColor
    property color selectedFillColor: Style.windowBackground
    property color selectedBorderColor: Style.borderNormalColor

    signal leftClicked()
    signal rightClicked()
    Rectangle {
        id: box
        width: parent.width - 8
        height: textElement.contentHeight + 15
        radius: 2.5
        clip:true

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        //border.color: isSelected ? Style.netIfColor: Style.borderNormalColor
        //color: isSelected ? Style.netIfFill : Style.windowBackground
        border.color: isSelected ? selectedBorderColor: (isHovered ? hoverBorderColor : Style.borderNormalColor)
        color: isSelected ? selectedFillColor : (isHovered ? hoverFillColor : Style.windowBackground)

        Rectangle {
            id: circle
            height: parent.height-20
            width: height
            radius: 180
            color: circleColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: height/2 + 0.5 
        }

        Text {
            id: textElement
            text: customText
            anchors.left: circle.left
            anchors.leftMargin: circle.width + 10
            anchors.verticalCenter: parent.verticalCenter
            color: Style.textTitleColor
            //verticalAlignment: Text.AlignVCenter
        }

        MouseArea {
            anchors.fill: box
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton){
                    root.rightClicked()
                }
                if(mouse.button === Qt.LeftButton){
                    root.leftClicked()
                }
            }
            onEntered: {
                root.isHovered = true
            }

            onExited: {
                root.isHovered = false
            }
        }
    }
}
