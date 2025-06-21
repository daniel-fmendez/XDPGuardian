import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../Style"
import "../CustomComponents"
import "./PopUps"
Page {
    id: ruleScreen
    SplitView.preferredHeight: 150
    SplitView.minimumHeight: 100

    background: Rectangle {
        color: Style.windowBackground
    }

    header: ColumnLayout{
        Rectangle {
            height: 30
            Layout.fillWidth: true
            color: Style.windowHeader

            Label {
                text: qsTr("Rule Sets")
                font.pixelSize: 18
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 5
                color: Style.textTitleColor
            }
        }

    }

    ListView {
        id: rulesetList
        width: parent.width
        height: parent.height
        clip: true
        model: rulesetModel
        spacing: 40     // Espacio entre elementos

        header: Item {
            width: parent.width
            height: 10  // Ajusta esta altura según el espacio que necesites
        }
        Connections {
            target: SelectionManager

            function onRulesUpdated(){
                if(rulesetList.selectedIndex>=0){
                    var rules=rulesetModel.getRulesForRulesets(rulesetList.selectedIndex)
                    rulesModel.setRules(rules)
                }
            }
            function onSelectedRulesetChanged(){
                if(SelectionManager.selectedRuleset===""){
                    rulesetList.selectedIndex = -1
                }
            }
        }
        property int selectedIndex: -1
        delegate: CustomBox {
            id: customBox
            width: ListView.view.width
            customText: name
            circleColor: isActive ? Style.networkEnabled : Style.networkBlocked
            isSelected: index === rulesetList.selectedIndex
            hoverBorderColor: Style.ruleIfHoverColor
            hoverFillColor: Style.ruleIfHoverFill
            selectedBorderColor: Style.ruleIfColor
            selectedFillColor: Style.ruleIfFill

            onLeftClicked: {
                rulesetList.selectedIndex = index  // Actualiza el índice seleccionado
                //Manejo de interfaces

                SelectionManager.selectedRulesetIsActive = isActive
                SelectionManager.selectedRuleset = customBox.customText

                rulesModel.setRules(rules)
            }
            onRightClicked: {
                contextMenu.popup()
            }
            Menu {
                id: contextMenu
                MenuItem{
                    text: "New Rule"
                    action: Action {
                        onTriggered: {
                            if(SelectionManager.selectedInterface.length>0){
                                rulePopup.openWithParameters(SelectionManager.selectedInterface,name)
                            }
                        }
                    }
                }
                MenuSeparator {}

                MenuItem {
                    text: "Edit"
                    action: Action {
                        onTriggered:  {
                            editRulesetPopup.openWithParameters(name,isActive,interfaceModel.getIndex(SelectionManager.selectedInterface))
                        }
                    }
                }
                MenuItem {
                    text: isActive ? "Turn Off" : "Turn On"
                    action: Action {
                        onTriggered: {
                            var status = isActive
                            if(SelectionManager.selectedRuleset===name){
                                SelectionManager.selectedRulesetIsActive = !isActive
                            }
                            var statusText =  status ? " deactivated" : " activated"
                            logTableModel.addLog(logTableModel.stringToTag("INFO"),"Ruleset "+name + statusText,SelectionManager.selectedInterface)
                            interfaceModel.turnOnOffRulesetOnInterface(interfaceModel.getIndex(SelectionManager.selectedInterface), name);
                        }
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: "Delete"
                    action: Action {
                        onTriggered: {
                            if(SelectionManager.selectedRuleset===name){
                                SelectionManager.selectedRulesetIsActive = ""
                                SelectionManager.selectedRuleset=""
                            }
                            interfaceModel.removeRuleset(interfaceModel.getIndex(SelectionManager.selectedInterface),index)
                        }
                    }
                }
            }
            Connections {
                target: SelectionManager

                function onSelectedInterfaceChanged() {
                    rulesetList.selectedIndex = -1
                }
            }
        }
    }
}
