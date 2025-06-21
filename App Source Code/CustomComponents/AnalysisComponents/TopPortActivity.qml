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

    property int maxValue: 0

    function getMaxHits() {
        var max = 0
        if (portHitsModel.rowCount() > 0) {
            max = portHitsModel.get(0).hits
        }
        maxValue = max
    }
    Connections {
        target: portHitsModel

        function onListChanged(){
            root.getMaxHits()
        }
    }

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

                text: "TOP PORT ACTIVITY"
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
            Layout.bottomMargin: 5
            color: "transparent"
            clip: true

            ColumnLayout{
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.topMargin: 4
                anchors.bottomMargin: 10

                Repeater {
                    model:  portHitsModel
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        color: "transparent"
                        visible: index < 5
                        property variant portData: portHitsModel.get(index)

                        RowLayout {
                            id: textContainter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            spacing: 7.5

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                text: portData.port+":"
                                font.pixelSize: 14
                                color: Style.textNormalColor
                            }
                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                id: flagValueText
                                text: typeof portData.hits !== "undefined" ? portData.hits : ""

                                font.pixelSize: 14
                                color: Style.textNormalColor
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }
                        // ProgressBar
                        Rectangle {
                            anchors.top: textContainter.bottom
                            anchors.topMargin: 1
                            anchors.bottomMargin: 4
                            width: parent.width - 10
                            height: 12.5
                            color: "transparent"

                            ProgressBar {
                                id: progress
                                value: root.maxValue > 0 ? portData.hits / root.maxValue : 0
                                padding: 2
                                anchors.fill: parent
                                anchors.centerIn: parent

                                background: Rectangle {
                                    width: parent.width - 5
                                    height: 6
                                    color: Style.windowHeader
                                    radius: 3
                                }

                                contentItem: Item {
                                    width: parent.width - 5
                                    height: 4

                                    // Progress indicator for determinate state.
                                    Rectangle {
                                        width: progress.visualPosition * parent.width
                                        height: parent.height
                                        radius: 2
                                        color: Style.portProgressBar
                                        visible: !progress.indeterminate
                                    }

                                    // Scrolling animation for indeterminate state.
                                    Item {
                                        anchors.fill: parent
                                        visible: progress.indeterminate
                                        clip: true

                                        Row {
                                            spacing: 20

                                            Repeater {
                                                model: progress.width / 40 + 1

                                                Rectangle {
                                                    color: Style.portProgressBar
                                                    width: 20
                                                    height: progress.height
                                                }
                                            }
                                            XAnimator on x {
                                                from: 0
                                                to: -40
                                                loops: Animation.Infinite
                                                running: progress.indeterminate
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
