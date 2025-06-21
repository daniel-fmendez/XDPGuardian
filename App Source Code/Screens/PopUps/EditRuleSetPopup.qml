import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Popup {
    property string rulesetName
    property bool isActive
    property int interfaceIndex
    property string lastInterface
    id: popup
    width: 375
    height: 440
    modal: true
    focus: true
    anchors.centerIn: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    padding:0

    function openWithParameters(name,active,index){
        rulesetName = name
        isActive = active
        interfaceIndex = index
        inputName.text = ""
        customCombo.currentIndex = interfaceIndex
        lastInterface = customCombo.currentText
        hint.text = name
        if(isActive){
            enabledOpt.checked = true;
            disabledOpt.checked = false;
        }else{
            enabledOpt.checked = false;
            disabledOpt.checked = true;
        }
        open()
    }

    //Color del overlay
    Overlay.modal: Rectangle {
        color: "#80000000"
    }

    background:Rectangle {
        anchors.fill: parent
        color: Style.windowBackground
        border.color: Style.borderNormalColor
        border.width: 2
    }

    onOpened: {
        inputName.text = ""
        customCombo.currentIndex = interfaceIndex
        lastInterface = customCombo.currentText
        hint.text = name
        if(isActive){
            enabledOpt.checked = true;
            disabledOpt.checked = false;
        }else{
            enabledOpt.checked = false;
            disabledOpt.checked = true;
        }
    }

    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: Style.windowDarkHeader

        Text {
            text: "Edit Rule Set " + rulesetName
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 20
            font.pixelSize: 16
            font.bold: true
            color: "white"
        }
        //Close
        Rectangle {
            height: parent.height / 2
            width: height
            radius: height / 2
            color: Style.networkBlocked // Rojo menos intenso
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: width / 2

            Canvas {
                id: closeX
                width: parent.width * 0.6  // Ajuste para que la X se vea mejor
                height: width
                anchors.centerIn: parent
                property color xColor: "white"
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    ctx.strokeStyle = xColor; // Color de la X
                    ctx.lineWidth = 2; // Grosor de la línea

                    // Márgenes para evitar que toque los bordes
                    var margin = ctx.lineWidth;

                    // Dibujar "X" centrada
                    ctx.beginPath();
                    ctx.moveTo(margin, margin);
                    ctx.lineTo(width - margin, height - margin);
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.moveTo(width - margin, margin);
                    ctx.lineTo(margin, height - margin);
                    ctx.stroke();
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: { popup.close()}
                hoverEnabled: true
                onEntered: {
                    //closeX.xColor = Qt.darker(parent.color, 1.1)
                    parent.color = Qt.darker(parent.color, 1.1)
                }
                onExited: {
                    //closeX.xColor = Qt.lighter(parent.color, 1.1)
                    parent.color = Qt.lighter(parent.color, 1.1)
                }
            }
        }

        Text {
            id: ruleSetTittle
            text: "Rule Set Name:"
            color: Style.textNormalColor
            anchors.top: parent.top
            anchors.topMargin: 60
            anchors.left: parent.left
            anchors.leftMargin: 30
        }

        Rectangle {
            id: ruleSetBox
            color: Style.windowBackground
            radius: 5
            border.color: Style.borderNormalColor
            height: 40
            width: 325
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: ruleSetTittle.bottom
            anchors.topMargin: 2
            anchors.left: ruleSetTittle.left

            TextInput  {
                id: inputName
                focus: true
                selectByMouse: true
                anchors.fill: parent
                anchors.margins: 10
                maximumLength: 32
                font.pixelSize: 16
                color: Style.textNormalColor
                verticalAlignment: Text.AlignVCenter

                autoScroll: true
                clip: true
            }

            Text {
                id: hint
                text: "'Ruleset Name'"
                color: Style.textNormalMuted
                anchors.fill: inputName
                font.pixelSize: 16

                verticalAlignment: Text.AlignVCenter
                visible: inputName.text.length === 0
            }
        }

        // Change with DropBox
        Text {
            id: interfaceSelectTtitle
            text: "Associated Interface:"
            color: Style.textNormalColor
            anchors.top: ruleSetBox.bottom
            anchors.left: ruleSetTittle.left
            anchors.topMargin: 15
        }

        // Change with DropBox
        ComboBox {
            id: customCombo
            model: interfaceModel
            height: 40
            width: 325
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: interfaceSelectTtitle.bottom
            anchors.topMargin: 2
            anchors.left: interfaceSelectTtitle.left

            textRole: "name"

            indicator: Canvas {
                id: canvas
                width: 20
                height: 20
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 10
                contextType: "2d"

                Connections {
                    target: customCombo.popup
                    function onVisibleChanged() { canvas.requestPaint(); }
                }

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.beginPath();
                    ctx.strokeStyle = customCombo.popup.visible ? Style.borderNormalColor : Style.windowDarkHeader;// Color cuando se abre/cierra
                    ctx.lineWidth = 2;
                    ctx.lineJoin = "round";

                    ctx.beginPath();

                    if (customCombo.popup.visible) {
                        //Flecha hacia arriba ^
                        ctx.moveTo(4, 10);
                        ctx.lineTo(8, 6);
                        ctx.lineTo(12, 10);
                    } else {
                        //Flecha hacia abajo v
                        ctx.moveTo(4, 6);
                        ctx.lineTo(8, 10);
                        ctx.lineTo(12, 6);
                    }

                    ctx.stroke();
                }
            }
            //Texto
            contentItem: Text {
                text: customCombo.currentText
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
                color: Style.textNormalColor
                leftPadding: 10
            }
            background: Rectangle {
                radius: 7.5
                border.width: 2
                color: Style.windowBackground
                border.color: Style.borderNormalColor
            }
            popup: Popup {
                y: customCombo.height
                width: customCombo.width
                implicitHeight: contentItem.implicitHeight
                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: customCombo.popup.visible ? customCombo.delegateModel : null
                    currentIndex: customCombo.highlightedIndex

                    ScrollIndicator.vertical: ScrollIndicator { }
                }
                background: Rectangle {
                    color: Style.windowHeader
                    radius: 7.5  // Biselado del menú desplegable
                    border.color: Style.borderNormalColor
                    border.width: 2
                }
            }

            delegate: ItemDelegate {
                width: customCombo.width
                anchors.left: parent.left
                anchors.right: parent.right
                contentItem: Text {
                    text: name
                    font.pixelSize: 16
                    color: Style.textNormalColor
                    leftPadding: 15  // Margen del texto dentro del desplegable
                }
                highlighted: customCombo.highlightedIndex === index
                background: Rectangle {

                    color: highlighted ? Style.windowSelected : Style.windowHeader  // Color de selección
                    radius: 7.5
                }
            }
        }
        Text {
            id: statusText
            text: "Status"
            color: Style.textNormalColor
            anchors.topMargin: 25
            anchors.top: customCombo.bottom
            anchors.left: ruleSetTittle.left
        }
        RowLayout {
            id: statusRow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: statusText.bottom
            anchors.topMargin: 2
            anchors.left: statusText.left

            RadioButton {
                id: enabledOpt
                text: "Enabled"
                contentItem: Text {
                    text: enabledOpt.text
                    //font: enabledOpt.font
                    font.pixelSize: 14
                    opacity: enabled ? 1.0 : 0.3
                    color: Style.textNormalColor
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: enabledOpt.indicator.width + enabledOpt.spacing
                }
                indicator: Rectangle {
                    implicitWidth: 26
                    implicitHeight: 26
                    x: enabledOpt.leftPadding
                    y: parent.height / 2 - height / 2
                    radius: 20
                    color: Qt.lighter(Style.windowBackground,1.3)
                    border.color: Style.borderNormalColor

                    Rectangle {
                        width: 14
                        height: 14
                        x: 6
                        y: 6
                        radius: 7
                        color: Style.networkEnabled
                        visible: enabledOpt.checked
                    }
                }
            }

            RadioButton {
                id: disabledOpt
                text: "Disabled"
                contentItem: Text {
                    text: disabledOpt.text
                    //font: disabledOpt.font
                    font.pixelSize: 14
                    opacity: enabled ? 1.0 : 0.3
                    color: Style.textNormalColor
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: disabledOpt.indicator.width + disabledOpt.spacing
                }
                indicator: Rectangle {
                    implicitWidth: 26
                    implicitHeight: 26
                    x: disabledOpt.leftPadding
                    y: parent.height / 2 - height / 2
                    radius: 20
                    color: Qt.lighter(Style.windowBackground,1.3)
                    border.color: Style.borderNormalColor

                    Rectangle {
                        width: 14
                        height: 14
                        x: 6
                        y: 6
                        radius: 7
                        color: Style.networkBlocked
                        visible: disabledOpt.checked
                    }

                }
            }
        }
        //Estado anterior
        Text {
            id: lastStateTitle
            text: "Current configuration: "
            color: Style.textNormalMuted
            anchors.top: statusRow.bottom
            anchors.topMargin: 20
            anchors.left: ruleSetTittle.left
        }
        Text{
            id: lastState
            text: isActive ? "- "+rulesetName +" is Active on " + lastInterface :  "- "+rulesetName +" is Disabled on " + lastInterface
            color: Style.textNormalMuted
            anchors.left: ruleSetTittle.left
            anchors.leftMargin: 20
            anchors.top: lastStateTitle.bottom
            anchors.topMargin: 10
        }
    }
    Rectangle {
        height: 40
        width: 140
        radius: 7.5
        color: Style.windowHeader
        border.color: Style.borderNormalColor
        anchors.left: parent.left
        anchors.leftMargin: 30
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30

        Text {
            text: "Cancel"
            color: Style.textNormalColor
            font.pixelSize: 24
            anchors.centerIn: parent
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                popup.close()
            }
            hoverEnabled: true
            onEntered: {
                parent.color = Qt.darker(parent.color,1.05)
                parent.border.color = Qt.darker(parent.border.color,1.25)
            }
            onExited: {
                parent.color = Qt.lighter(parent.color,1.05)
                parent.border.color = Qt.lighter(parent.border.color, 1.25)
            }
        }
    }
    Dialog {
        id: errorDialog
        title: "Error"
        modal: true
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        width: 200

        contentItem: Label {
            text: "Please input correct values"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
    Rectangle {
        height: 40
        width: 140
        radius: 7.5
        color: Style.metricsAllowed
        border.color: Style.borderNormalColor
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30

        Text {
            text: "Save"
            color: "white"
            font.pixelSize: 24
            anchors.centerIn: parent
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var checked = disabledOpt.checked || enabledOpt.checked
                var lengthInput = (inputName.length === 0)
                var interfaceInput = (customCombo.currentIndex === -1)

                if(!checked || interfaceInput){
                    console.log("Please input correct values")
                    errorDialog.open()
                }else {
                    var newName = inputName.length > 0 ? inputName.text : hint.text

                    interfaceModel.editRulesetOnInterface(interfaceIndex,customCombo.currentIndex,rulesetName, {
                        name: newName,
                        isActive: enabledOpt.checked
                    });
                    if(SelectionManager.selectedRuleset===rulesetName){
                        SelectionManager.selectedRulesetIsActive = isActive
                        if(interfaceIndex!==customCombo.currentIndex){
                            SelectionManager.selectedRuleset=""
                        }
                    }

                    popup.close()
                }
            }
            hoverEnabled: true
            onEntered: {
                parent.color = Qt.darker(parent.color, 1.05)
                parent.border.color = Qt.darker(parent.border.color, 1.25)
            }
            onExited: {
                parent.color = Qt.lighter(parent.color,1.05)
                parent.border.color = Qt.lighter(parent.border.color, 1.25)
            }
        }
    }
}
