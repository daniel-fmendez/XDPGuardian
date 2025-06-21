import QtQuick 2.15
import QtCharts 2.9
import QtQuick.Controls
import QtQuick.Layouts
import "../Style"
import "../CustomComponents/AnalysisComponents"

Page {
    visible: true
    header: Rectangle {
        height: 45
        color: Style.netIfFill
        RowLayout {
            anchors.fill: parent
            spacing: 5

            Rectangle {
                Layout.fillWidth: true
                Layout.minimumWidth: 350
                Layout.preferredWidth: 400
                Layout.maximumWidth: 600
                Layout.minimumHeight: parent.height
                color:"transparent"

                Label {
                    text: "Traffic Analysis"
                    font.pixelSize: 24
                    font.bold: true
                    font.family: Style.textTitleFont
                    color: Style.netIfColor

                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.minimumWidth: 300
                Layout.preferredWidth: 350
                Layout.preferredHeight: parent.height
                Layout.maximumWidth: 400
                color: "transparent"

                Label {
                    text: "Interface: "+SelectionManager.selectedInterface
                    color: Style.textNormalColor
                    font.pixelSize: Style.textNormalSize
                    font.family: Style.textNormalFont

                    anchors.left: parent.left
                    anchors.leftMargin: 40
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.minimumWidth: 150
                Layout.preferredWidth: 150
                Layout.preferredHeight: parent.height
                color: "transparent"

                Label {
                    text: "REAL-TIME"
                    font.pixelSize: 16
                    font.family: Style.textNormalSize
                    color: Style.netIfColor

                    anchors.right: parent.right
                    anchors.rightMargin: 80
                    width: implicitWidth
                    anchors.margins: 40
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Style.borderNormalColor
        GridLayout {
            anchors.fill: parent

            anchors.topMargin: 5
            anchors.leftMargin: 2.5
            anchors.rightMargin: 2.5
            anchors.bottomMargin: 5

            clip: true

            rows: 3
            columns: 2

            rowSpacing: 5
            columnSpacing: 5

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                ProtChart {}
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                PacketDistribution {}
                //TestComponent {}
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    spacing: 7.5
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        color: "transparent"

                        TcpFlags {}
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.preferredWidth: 2
                        color: "transparent"

                        TopPortActivity {}
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                Layout.rowSpan: 2

                TopSourceIp {}
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                TopRules {}
            }
            Timer {
                id: fecthMetricsTimer
                interval: 20000
                running: true
                repeat: true
                triggeredOnStart: true

                onTriggered: fetchAnalitics()
            }

            Connections {
                target: SelectionManager

                function onSelectedInterfaceChanged() {
                    fetchAnalitics()
                }
            }
        }
    }

    function fetchAnalitics(){
        if(SelectionManager.selectedInterface != null){
            var inter = SelectionManager.selectedInterface

            var flags = interfaceModel.getTcpFlagByInterface(inter)
            flagModel.setFromList(flags)

            var blockedIps = interfaceModel.getBlockedIpsByInterface(inter)
            blockedIpsModel.setFromList(blockedIps)

            var ipHits = interfaceModel.getIpHitsByInterface(inter)
            ipHitsModel.setFromList(ipHits)

            var protStats = interfaceModel.getProtStatsByInterface(inter)
            protPieModel.setFromList(protStats)

            var portHits = interfaceModel.getPortHitsByInterface(inter)
            portHitsModel.setFromList(portHits)

            var packetDist = interfaceModel.getPacketDistributionByInterface(inter)
            packetDistModel.setFromList(packetDist)

            var ruleHits = interfaceModel.getRuleHitsByInterface(inter)
            ruleHitsModel.setFromList(ruleHits)
        }
    }
}
