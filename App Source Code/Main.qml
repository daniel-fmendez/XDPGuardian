import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "Style"
import TagEnum 1.0
import "Screens"
import "Screens/PopUps"
import "CustomComponents"

ApplicationWindow {
    id: app
    width: 960
    height: 720

    visible: true
    title: qsTr("XDPGuardian")
    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowSystemMenuHint | Qt.WindowMinimizeButtonHint | Qt.WindowMaximizeButtonHint | Qt.WindowCloseButtonHint


    palette {
        window: Style.windowBackground
        text: Style.textNormalColor
        base: Style.windowBackground
        highlight: Style.scheme === "dark" ? Qt.lighter(Style.windowBackground, 1.3) : Qt.darker(Style.windowBackground, 1.35)
    }
    menuBar: CustomMenu {
        id: mainMenu

        onShowMetrics: (value) => {
            metricsPart.visible = value
        }
    }

    NewRuleSetPopUp {
        id: rulesetPopup
    }
    NewRulePopUp {
        id: rulePopup
    }
    EditRuleSetPopup {
        id: editRulesetPopup
    }
    EditRulePopup{
        id: editRulePopup
    }
    onClosing: {
        Qt.quit()
    }

    //Windows
    SplitView {
        id: horizontalSplit
        orientation: Qt.Horizontal
        anchors.fill: parent

        handle: Rectangle {
            implicitWidth: 4
            implicitHeight: 4
            color: Style.borderNormalColor
        }

        //CELDA IZQUIERDA: Contiene otra SplitView en vertical
        SplitView {
            orientation: Qt.Vertical
            SplitView.preferredWidth: 200
            SplitView.minimumWidth: 100
            SplitView.maximumWidth: app.width * 0.35
            clip: true

            //BORDE
            handle: Rectangle {
                implicitWidth: 4
                implicitHeight: 4
                color: Style.borderNormalColor
            }

            NetworkInterfacesList {}

            RuleSetList {}

            Loader {
                id: metricsPart
                sourceComponent: SelectionManager &&
                                 SelectionManager.selectedInterface &&
                                 SelectionManager.selectedInterface.length > 0
                                 ? interfaceOn
                                 : interfaceOff
            }
            Component {
                id: interfaceOff

                Page {
                    id: root
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
                                text: qsTr("Traffic Analysis")
                                font.pixelSize: 18
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 5
                                color: Style.textTitleColor
                            }
                        }
                    }
                }
            }

            Component {
                id: interfaceOn
                MetricsScreen {

                }
            }
        }

        // CELDA DERECHA
        Item {
            width: parent.width
            height: parent.heigth
            //Borde
            Rectangle {
                width: parent.width
                height: 2  // Grosor del borde
                color: Style.borderNormalColor
                anchors.top: parent.top
            }

            TabBar {
                id: tabBar
                width: parent.width
                height: 30
                anchors.top: parent.top
                anchors.topMargin: 1

                background: Rectangle {
                    color: Style.windowHeader
                    height: parent.height
                    width: parent.width
                }
                TabButton {
                    width: 120
                    background: Rectangle {
                        color: parent.checked ? Style.windowSelected : Style.windowHeader
                        height: parent.parent.height
                    }

                    contentItem: Label {
                        anchors.centerIn: parent
                        color: Style.textNormalColor
                        text: "Rules"
                    }
                }
                TabButton {
                    width: 120
                    background: Rectangle {
                        color: parent.checked ? Style.windowSelected : Style.windowHeader
                        height: parent.parent.height
                    }
                    contentItem: Label {
                        anchors.centerIn: parent
                        color: Style.textNormalColor
                        text: "Analysis"
                    }
                }
                TabButton {
                    width: 120
                    background: Rectangle {
                        color: parent.checked ? Style.windowSelected : Style.windowHeader
                        height: parent.parent.height
                    }
                    contentItem: Label {
                        anchors.centerIn: parent
                        color: Style.textNormalColor
                        text: "Logs"
                    }
                }

                onCurrentIndexChanged: stack.currentIndex = currentIndex
            }

            StackLayout {
                id: stack
                anchors.top: tabBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                currentIndex: tabBar.currentIndex

                Loader {
                    sourceComponent: SelectionManager &&
                                     SelectionManager.selectedInterface &&
                                     SelectionManager.selectedRuleset &&
                                     SelectionManager.selectedInterface.length > 0 &&
                                     SelectionManager.selectedRuleset.length > 0
                                     ? ruleOn
                                     : ruleOff
                }

                //RULES
                Component {
                    id: ruleOff
                    Rectangle {
                        height: 300
                        width: 400
                        anchors.centerIn: parent
                        color: Style.windowBackground
                    }
                }

                Component {
                    id: ruleOn
                    RuleScreen {}
                }

                //ANALYSIS
                Loader {
                    sourceComponent: SelectionManager &&
                                     SelectionManager.selectedInterface &&
                                     SelectionManager.selectedInterface.length > 0
                                     ? analysisOn
                                     : analysisOff
                }
                Component {
                    id: analysisOff
                    Rectangle {
                        height: 300
                        width: 400
                        anchors.centerIn: parent
                        color: Style.windowBackground
                    }
                }

                Component {
                    id: analysisOn
                    AnalysisScreen {}
                }


                //LOGS

                LogScreen {}
            }
        }
    }
}
