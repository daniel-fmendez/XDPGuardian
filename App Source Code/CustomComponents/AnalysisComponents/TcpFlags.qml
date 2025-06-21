import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15
import "../../Style"

Rectangle {
    id: root
    anchors.fill: parent
    radius: 7.5
    color: Style.windowBackground


    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: header

            Layout.fillWidth: true
            Layout.minimumHeight: 45
            Layout.preferredHeight: 45

            color: Style.windowHeader
            height: 45
            radius: 7.5

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 16

                text: "TCP FLAGS"
                font.pixelSize: 14
                font.bold: true
                color: Style.textTitleColor
            }

            // Separator line
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.radius
                color: Style.windowHeader
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            clip: true

            ColumnLayout{
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.topMargin: 4
                anchors.bottomMargin: 4
                spacing: 5

                // Usar Repeater para generar todos los elementos de flag
                Repeater {
                    model: flagModel
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        //property string flagId: model.flagId

                        RowLayout {
                            anchors.fill: parent
                            spacing: 7.5

                            Rectangle {
                                Layout.preferredWidth: 25
                                Layout.preferredHeight: 15
                                Layout.alignment: Qt.AlignVCenter
                                color: Style.flagsColors[model.flagName]
                            }
                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                text: model.flagName+":"
                                font.pixelSize: 16
                                color: Style.textNormalColor
                            }
                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                text: model.value
                                font.pixelSize: 16
                                color: Style.textNormalColor

                            }

                            // Este item invisible consumirá el espacio restante
                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }
}
