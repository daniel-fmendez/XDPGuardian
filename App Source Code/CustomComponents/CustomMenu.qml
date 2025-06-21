import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Dialogs
import "../Style"
MenuBar {
    signal showMetrics(bool value)
    Menu {
        title: qsTr("File")

        Menu {
            title: qsTr("Import")

            MenuItem {
                text: qsTr("From JSON")
                action: Action{
                    onTriggered:{
                        fileDialog.open()
                    }
                }

                FileDialog {
                    id: fileDialog
                    title: "Selecciona un archivo JSON para importar"
                    nameFilters: ["Archivos JSON (*.json)"]
                    currentFolder: dirPath
                    fileMode: FileDialog.OpenFile

                    onAccepted: {
                        const localPath = fileDialog.selectedFile.toString().replace("file://", "");
                        console.log("File path:", localPath);
                        interfaceModel.importData(localPath)
                    }
                }
            }
        }

        Menu {

            title: qsTr("Export")

            MenuItem {
                text: qsTr("To JSON")
                action: Action{
                    onTriggered: {
                        interfaceModel.exportData()
                    }
                }
            }

        }

        MenuSeparator{}

        MenuItem {
            text: qsTr("Quit")
            onTriggered: Qt.quit()
        }
    }

    //View
    Menu {
        Component.onCompleted: {
            if(systemColorScheme==="dark"){
                dark.checked = true
                light.checked = false

                Style.setDarkTheme()
            }else{
                light.checked = true;
                dark.checked = false;

                Style.setLightTheme()
            }
        }

        title: qsTr("View")

        Menu {

            title: qsTr("Theme")
            MenuItem{
                id: light
                text: qsTr("Light")
                checkable: true
                checked: true
                onTriggered: {
                    light.checked = true;
                    dark.checked = false;

                    Style.setLightTheme()
                }
            }
            MenuItem{
                id: dark
                text: qsTr("Dark")
                checkable: true
                checked: !light.checked

                onTriggered: {
                    dark.checked = true;
                    light.checked = false;

                    Style.setDarkTheme()
                }
            }
        }

        MenuItem {
            text: qsTr("Statistics Panel")
            checkable: true
            checked: true
            onCheckedChanged: {
                showMetrics(checked)
            }
        }

        /*MenuItem {
            text: qsTr("Rule Visualization")
            checkable: true
            checked: true
        }*/
    }

    //Rules
    Menu {
        title: qsTr("Rules")
        MenuItem {
            text: qsTr("New Rule Set")
            action: Action{
                id: newRuleSetAction
                onTriggered: rulesetPopup.open()
            }
        }

        MenuSeparator {}
        MenuItem {
            text: qsTr("New Rule")
            action: Action{
                id: newRuleAction
                onTriggered: {
                    if(SelectionManager.selectedInterface.length>0 && SelectionManager.selectedRuleset.length>0){
                        rulePopup.openWithParameters(SelectionManager.selectedInterface,SelectionManager.selectedRuleset)
                    }
                }
            }
        }
    }

    background: Rectangle {
       implicitWidth: 40
       implicitHeight: 40
       color: Style.windowBackground

        Rectangle {
          color: Style.borderNormalColor
          width: parent.width
          height: 1
          anchors.bottom: parent.bottom
        }
    }
    delegate: MenuBarItem {
        id: menuBarItem

        contentItem: Text {
            text: menuBarItem.text
            color: Style.textTitleColor
            font.pixelSize: 13
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 40
            implicitHeight: 30
            radius: 5
            color: menuBarItem.highlighted ? Style.menuSelected : "transparent"
        }
    }
    Menu {
        title: qsTr("Analysis")
        MenuItem {
            text: qsTr("Dump All")
            action: Action{
                id: dumpAllAction
                onTriggered: {
                    interfaceModel.dumpAll()
                }
            }
        }
    }
}
