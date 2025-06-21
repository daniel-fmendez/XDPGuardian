import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../Style"
import "../CustomComponents"
import NetworkInterfacesModel 1.0
Page {
    id: interfaces
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
                text: qsTr("Network Interfaces")
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
        id: interfacesList
        width: parent.width
        height: parent.height
        clip: true
        model: interfaceModel
        spacing: 40
        header: Item {
            width: parent.width
            height: 10
        }

        property int selectedIndex: -1
        Connections {
            target: interfaceModel

            function onRulesetAdded(){
                // Obtén la interfaz seleccionada con el índice
                if(interfacesList.selectedIndex>=0){
                    var rulesets = interfaceModel.getRulesetsForInterface(interfacesList.selectedIndex)

                    rulesetModel.setRulesets(rulesets)
                }
            }
            function onRulesAdded(){
                if(interfacesList.selectedIndex>=0){
                    var rulesets = interfaceModel.getRulesetsForInterface(interfacesList.selectedIndex)

                    rulesetModel.setRulesets(rulesets)
                    SelectionManager.updateRule()
                }
            }
        }
        delegate: CustomBox {
            id: customBox
            width: ListView.view.width
            customText: name
            circleColor: isOn ? Style.networkEnabled : Style.networkBlocked
            isSelected: index === interfacesList.selectedIndex
            hoverBorderColor: Style.netIfHoverColor
            hoverFillColor: Style.netIfHoverFill
            selectedBorderColor: Style.netIfColor
            selectedFillColor: Style.netIfFill
            onLeftClicked: {
                interfacesList.selectedIndex = index  // Actualiza el índice seleccionado
                //Manejo de interfaces
                SelectionManager.selectedInterface = customBox.customText
                SelectionManager.selectedInterfaceIsActive = isOn
                SelectionManager.selectedRuleset = ""
                // Load data in rulesetModel
                rulesetModel.setRulesets(rulesets)
            }
            onRightClicked: {
                contextMenu.popup()
            }
            Menu {
                id: contextMenu
                MenuItem{
                    text: "New Ruleset"
                    action: Action {
                        onTriggered: {
                            rulesetPopup.openWithParameters(index)
                        }
                    }
                }
            }
        }
    }
}
