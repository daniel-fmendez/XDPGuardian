import QtQuick
import "../Style"
Item {
    id: root
    property string textContent
    property color fillColor: Style.tableRowB

    signal removeClicked(string port)
    width: container.width
    height: container.height
    Rectangle {
        id: container
        radius: 180
        height: textElement.contentHeight + 10
        width: textElement.contentWidth + 55
        color: fillColor
        border.color: Style.borderNormalColor
        border.width:2

        Text {
            id: textElement
            text: root.textContent
            font.pixelSize: 16
            color: Style.textNormalColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
        }
        Rectangle {
            height: parent.height / 2 + parent.height/4
            width: height
            radius: height / 2
            color: Style.networkBlocked // Rojo menos intenso
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 5

            Canvas {
                id: closeX
                width: parent.width * 0.6  // Ajuste para que la X se vea mejor
                height: width
                anchors.centerIn: parent
                property color xColor: "white"
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    ctx.strokeStyle = xColor;
                    ctx.lineWidth = 2;

                    // Usar el centro como referencia y calcular desde ahí
                    var center = width / 2;
                    var offset = width * 0.35; // Distancia desde el centro a los extremos

                    ctx.beginPath();
                    ctx.moveTo(center - offset, center - offset);
                    ctx.lineTo(center + offset, center + offset);
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.moveTo(center + offset, center - offset);
                    ctx.lineTo(center - offset, center + offset);
                    ctx.stroke();
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    removeClicked(textContent)
                }

                onEntered: {
                    //closeX.xColor = Qt.darker(parent.color, 1.1)
                    parent.color = Qt.darker(parent.color, 1.1)
                }
                onExited: {
                    //closeX.xColor = Qt.lighter(parent.color, 1.1)
                    parent.color = Qt.lighter(parent.color, 1.1)
                }
            }
        }
    }
}
