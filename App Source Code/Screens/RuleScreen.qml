import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../Style"

Page {
    visible: true
    header: Rectangle {
        height: 45
        color: Style.ruleIfFill

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
                    text: SelectionManager.selectedRuleset
                    font.pixelSize: 24
                    font.bold: true
                    font.family: Style.textTitleFont
                    color: Style.networkBlocked

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
                    id: statusLabel
                    text: SelectionManager.selectedRulesetIsActive ? "ENABLED" : "DISABLED"
                    font.pixelSize: 16
                    font.family: Style.textNormalSize
                    color: SelectionManager.selectedRulesetIsActive ? Style.networkEnabled : Style.networkBlocked

                    anchors.right: parent.right
                    anchors.rightMargin: 80
                    width: implicitWidth
                    anchors.margins: 40
                    anchors.verticalCenter: parent.verticalCenter
                }
                Connections {
                    target: SelectionManager
                    function onSelectedRulesetIsActiveChanged() {
                        updateStatusLabel()
                    }
                    function onRulesetStatusChanged() {
                        updateStatusLabel()
                    }

                    function updateStatusLabel() {
                        statusLabel.color = SelectionManager.selectedRulesetIsActive ? Style.networkEnabled : Style.networkBlocked
                        statusLabel.text = SelectionManager.selectedRulesetIsActive ? "ENABLED" : "DISABLED"
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        clip: true

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Style.windowBackground

            HorizontalHeaderView {
                id: ruleTableHeader
                syncView: tableRule
                Layout.fillWidth: true
                clip: true

                boundsBehavior: Flickable.StopAtBounds
                interactive: false
                resizableColumns: false // Permite modificar el ancho de las columnas
                delegate: Rectangle {
                    property var columnRatios: [0.33, 0.17, 0.20, 0.10, 0.10, 0.10]
                    color: Style.windowHeader
                    //border.color: "black"
                    implicitHeight: 40
                    implicitWidth: Math.max(tableRule.width * columnRatios[column])
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: display
                        color: Style.textNormalColor
                    }
                }
            }

            TableView {
                id: tableRule
                anchors.top: ruleTableHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                clip: true

                model: rulesModel
                delegate: Rectangle {
                    //Ratios
                    //Name, IP, ports, protocol, STATUS, HITS
                    property var columnRatios: [0.30, 0.18, 0.20, 0.10, 0.12, 0.10]

                    //property var columnMinWidths: [40, 200, 150, 150 ,75, 75, 75, 200, 50 ]
                    //property var columnMaxWidths: [50, 300]

                    //implicitWidth: Math.max(Math.min(tableRule.width * columnRatios[column], columnMaxWidths[column]), columnMinWidths[column])  // Columnas con tamaños maximos
                    implicitWidth: Math.max(tableRule.width * columnRatios[column])
                    implicitHeight: 30 + textElement.contentHeight
                    color: row % 2 ? Style.tableRowA : Style.tableRowB

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: (mouse) => {
                           if (mouse.button === Qt.RightButton){
                                contexMenu.popup()
                           }
                       }

                        Menu {
                            id: contexMenu
                            MenuItem {
                                text: "Edit"
                                action: Action {
                                    onTriggered:  {
                                        function groupPorts(portString) {
                                            if (!portString)
                                                return ""
                                            var ports = portString.split(",").map(function(p) { return parseInt(p.trim()) });
                                            ports.sort(function(a, b) { return a - b });

                                            var result = []
                                            var start = ports[0]
                                            var end = start

                                            for (var i = 1; i < ports.length; ++i) {
                                                if (ports[i] === end + 1) {
                                                    end = ports[i]
                                                } else {
                                                    result.push(start === end ? start.toString() : start + "-" + end)
                                                    start = ports[i]
                                                    end = start
                                                }
                                            }

                                            result.push(start === end ? start.toString() : start + "-" + end)
                                            return result.join(", ")
                                        }

                                        editRulePopup.openWithParameters(SelectionManager.selectedInterface, SelectionManager.selectedRuleset,
                                                                         name, ip,groupPorts(ports) ,protocolModel.getIndex(protocol), status)
                                    }
                                }
                            }
                            MenuItem {
                                text: status ? "Turn Off" : "Turn On"
                                action: Action {
                                    onTriggered: {
                                        var interfaceIndex = interfaceModel.getIndex(SelectionManager.selectedInterface)
                                        var rulesetIndex = interfaceModel.getIndexRuleset(interfaceIndex,SelectionManager.selectedRuleset)
                                        interfaceModel.turnOnOffRuleOnRuleset(interfaceIndex,rulesetIndex, name)
                                    }
                                }
                            }
                            MenuSeparator {}
                            MenuItem {
                                text: "Delete"
                                action: Action {
                                    onTriggered: {

                                        var interfaceIndex = interfaceModel.getIndex(SelectionManager.selectedInterface)
                                        var rulesetIndex = interfaceModel.getIndexRuleset(interfaceIndex,SelectionManager.selectedRuleset)

                                        interfaceModel.removeRule(interfaceIndex, rulesetIndex, row)
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        id: textElement
                        anchors.fill: parent
                        anchors.margins: 10
                        anchors.verticalCenter: parent.verticalCenter
                        wrapMode: Text.WordWrap
                        elide: Text.ElideNone
                        verticalAlignment: Text.AlignVCenter

                        text: {
                            if (column === 4) {
                                return display.toString() === "true" ? "ENABLED" : "DISABLED"
                            } else if (column === 2) { // Puerto
                                return groupPorts(display)
                            } else {
                                return display
                            }
                        }
                        color: column === 4 ? (display.toString() === "true" ? Style.networkEnabled : Style.networkBlocked) : Style.textNormalColor

                        //Generamos agrupaciones
                        function groupPorts(portString) {
                            if (!portString)
                                return ""
                            var ports = portString.split(",").map(function(p) { return parseInt(p.trim()) });
                            ports.sort(function(a, b) { return a - b });

                            var result = []
                            var start = ports[0]
                            var end = start

                            for (var i = 1; i < ports.length; ++i) {
                                if (ports[i] === end + 1) {
                                    end = ports[i]
                                } else {
                                    result.push(start === end ? start.toString() : start + "-" + end)
                                    start = ports[i]
                                    end = start
                                }
                            }

                            result.push(start === end ? start.toString() : start + "-" + end)
                            return result.join(", ")
                        }
                    }
                }
            }
        }
    }
}

