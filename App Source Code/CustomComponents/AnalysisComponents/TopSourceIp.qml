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

    // Definir proporciones de columnas
    property var columnRatios: [0.30, 0.15, 0.20, 0.20, 0.15]
    property int tableWidth: width - 10

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
                text: "TOP SOURCE IPs"
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
            height: 40
            color: Style.tableHeaderColor || Qt.darker(Style.windowBackground, 1.1)

            Row {
                anchors.fill: parent

                Rectangle {
                    width: parent.width * columnRatios[0]
                    height: parent.height
                    color: "transparent"

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: "IP Address"
                        font.pixelSize: 12
                        font.bold: true
                        color: Style.textHeaderColor || Style.textNormalColor
                    }
                }

                Rectangle {
                    width: parent.width * columnRatios[1]
                    height: parent.height
                    color: "transparent"

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: "Packets"
                        font.pixelSize: 12
                        font.bold: true
                        color: Style.textHeaderColor || Style.textNormalColor
                    }
                }

                Rectangle {
                    width: parent.width * columnRatios[2]
                    height: parent.height
                    color: "transparent"

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: "Bytes"
                        font.pixelSize: 12
                        font.bold: true
                        color: Style.textHeaderColor || Style.textNormalColor
                    }
                }

                Rectangle {
                    width: parent.width * columnRatios[3]
                    height: parent.height
                    color: "transparent"

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: "Last Seen"
                        font.pixelSize: 12
                        font.bold: true
                        color: Style.textHeaderColor || Style.textNormalColor
                    }
                }

                Rectangle {
                    width: parent.width * columnRatios[4]
                    height: parent.height
                    color: "transparent"

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: "Actions"
                        font.pixelSize: 12
                        font.bold: true
                        color: Style.textHeaderColor || Style.textNormalColor
                    }
                }
            }
        }

        // Table Content
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            clip: true

            ListView {
                id: tableView
                anchors.fill: parent
                model: ipHitsModel
                delegate: Rectangle {
                    width: tableView.width
                    height: 50
                    color: index % 2 === 0 ? Style.tableRowA : Style.tableRowB
                    clip: true
                    Row {
                        anchors.fill: parent
                        clip: true
                        Rectangle {
                            width: parent.width * columnRatios[0]
                            height: parent.height
                            color: "transparent"

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                text: ip
                                font.pixelSize: 14
                                color: Style.textNormalColor
                            }
                        }

                        Rectangle {
                            width: parent.width * columnRatios[1]
                            height: parent.height
                            color: "transparent"

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                text: totalPackets
                                font.pixelSize: 14
                                color: Style.textNormalColor
                            }
                        }

                        Rectangle {
                            width: parent.width * columnRatios[2]
                            height: parent.height
                            color: "transparent"

                            function formatBytes(bytes) {
                                if (bytes < 1024)
                                    return bytes + " B";
                                else if (bytes < 1024 * 1024)
                                    return (bytes / 1024).toFixed(2) + " KB";
                                else if (bytes < 1024 * 1024 * 1024)
                                    return (bytes / (1024 * 1024)).toFixed(2) + " MB";
                                else
                                    return (bytes / (1024 * 1024 * 1024)).toFixed(2) + " GB";
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                text: parent.formatBytes(totalBytes)
                                font.pixelSize: 14
                                color: Style.textNormalColor
                            }
                        }

                        Rectangle {
                            width: parent.width * columnRatios[3]
                            height: parent.height
                            color: "transparent"

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                text: root.getTimeStamp(lastSeen)
                                font.pixelSize: 14
                                color: Style.textNormalColor
                            }
                        }

                        Rectangle {
                            width: parent.width * columnRatios[4]
                            height: parent.height
                            color: "transparent"


                            Button {
                                property bool isBlocked: blockedIpsModel.isBlocked(ip)

                                id: actionButton
                                anchors.centerIn: parent
                                width: 70
                                height: 30
                                text: {

                                    if(actionButton.isBlocked){
                                        return "Auto-Blocked"
                                    }else{
                                        return "Block"
                                    }

                                }

                                background: Rectangle {
                                    radius: 7.5
                                    color: actionButton.pressed
                                           ? Qt.darker(actionButton.isBlocked ? Style.autoBlocked : Style.networkBlocked, 1.2)
                                           : (actionButton.isBlocked ? Style.autoBlocked : Style.networkBlocked)
                                    Behavior on color {
                                        ColorAnimation { duration: 100 }
                                    }
                                }

                                contentItem: Text {
                                    text: actionButton.text
                                    color: "#FFFFFF"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }

                                onClicked: {
                                    blockIp(ip)
                                }
                                Component.onCompleted: {
                                    isBlocked = Qt.binding(function() {
                                        return blockedIpsModel && blockedIpsModel.isBlocked ? blockedIpsModel.isBlocked(ip) : false;
                                    });
                                }

                                function blockIp(ip){
                                    var interfaceIndex = interfaceModel.getIndex(SelectionManager.selectedInterface)
                                    var rulesetIndex = interfaceModel.getIndexRuleset(interfaceIndex, "Analysis Screen")

                                    if(rulesetIndex === -1){
                                        interfaceModel.addRuleSetToInterface(SelectionManager.selectedInterface, {
                                            name: "Analysis Screen",
                                            isActive: true
                                        });

                                        interfaceModel.addRuleToRuleset(SelectionManager.selectedInterface, "Analysis Screen", {
                                            name: ip,
                                            ip: ip,
                                            ports: [0],
                                            protocol: "IPv4",
                                            status: true,
                                            hits: 0
                                        })

                                    }else {
                                        //Encendemos el ruleset
                                        interfaceModel.editRulesetOnInterface(interfaceIndex,interfaceIndex,"Analysis Screen", {
                                            name: "Analysis Screen",
                                            isActive: true
                                        });
                                        var ruleIndex = interfaceModel.getIndexRule(interfaceIndex,rulesetIndex,ip)

                                        if(ruleIndex === -1){
                                            //interfaceModel.addRuleToRuleset(SelectionManager.selectedInterface, "Analysis Screen", ip)
                                            interfaceModel.addRuleToRuleset(SelectionManager.selectedInterface, "Analysis Screen", {
                                                name: ip,
                                                ip: ip,
                                                ports: [0],
                                                protocol: "IPv4",
                                                status: true,
                                                hits: 0
                                            })
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
