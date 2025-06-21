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

    property int maxHits: 0
    property int maxBytes: 0

    function getMaxHits() {
        var max = 0
        if (ruleHitsModel.rowCount() > 0) {
            max = ruleHitsModel.get(0).hits
        }
        maxHits = max
    }

    function getMaxBytes() {
        var max = 0
        if (ruleHitsModel.rowCount() > 0) {
            max = ruleHitsModel.get(0).bytes
        }
        maxBytes = max
    }

    function getTimeStamp(uptime){
        var time = parseInt(uptime)

        var bootTimeNs = Number(bootTime) * 1000000000;

        var timeStampNs = bootTimeNs + time
        const timestampMs = Number(timeStampNs / 1000000);

        var date = new Date(timestampMs);
        date.setHours(date.getHours()+gmtOffset)

        var isoString = date.toISOString().replace('Z', '').replace("T", " "); // Eliminar 'Z'
        return isoString
    }
    Connections {
        target: ruleHitsModel

        function onListChanged(){
            root.getMaxHits()
            root.getMaxBytes()
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
                text: "TOP RULEs"
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

        // Table Header
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            clip: true

            ColumnLayout{
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.topMargin: 2
                anchors.bottomMargin: 10
                spacing: 7.5

                Repeater {
                    model: ruleHitsModel
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        color: "transparent"
                        visible: index < 5

                        property variant ruleData: ruleHitsModel.get(index)

                        RowLayout {
                            id: textContainter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            spacing: 7.5

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                text: "Rule ID "+ruleData.id+", IP "+interfaceModel.getIpByRuleId(ruleData.id, SelectionManager.selectedInterface)+": "
                                font.pixelSize: 14
                                color: Style.textNormalColor
                            }
                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                id: flagValueText
                                text: ruleData && ruleData.hits !== undefined ? ruleData.hits : ""
                                font.pixelSize: 14
                                color: Style.textNormalColor
                            }

                            // Este item invisible consumirá el espacio restante
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


                            RowLayout {
                                anchors.fill: parent
                                anchors.centerIn: parent
                                spacing: 5

                                ProgressBar {
                                    id: progress
                                    height: 45
                                    Layout.fillWidth: true
                                    value: root.maxHits > 0 ? ruleData.hits/root.maxHits : 0
                                    padding: 2


                                    background: Rectangle {
                                        width: parent.width - 5
                                        height: 8
                                        color: Style.windowHeader
                                        radius: 3
                                    }

                                    contentItem: Item {
                                        width: parent.width - 5
                                        implicitHeight: 6

                                        // Progress indicator for determinate state.
                                        Rectangle {
                                            width: progress.visualPosition * parent.width
                                            height: parent.height
                                            radius: 2
                                            color: Style.ruleProgressBar
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
                                                        color: Style.ruleProgressBar
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
                                Text {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: ruleData && ruleData.lastSeen && !isNaN(Date.parse(ruleData.lastSeen))
                                            ? getTimeStamp(ruleData.lastSeen) : ""
                                    font.pixelSize: 14
                                    color: Style.textNormalColor
                                }
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
}
