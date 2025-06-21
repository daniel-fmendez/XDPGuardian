import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Popup {
    property string netInterface
    property string ruleset

    id: popup
    width: 430
    height: 520
    modal: true
    focus: true
    anchors.centerIn: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    padding:0
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
    function openWithParameters(inter, rs){
        netInterface = inter
        ruleset = rs
        open()
    }

    onOpened: {
        inputName.text = ""
        inputIP.text = ""
        inputStartPort.text = ""
        inputEndPort.text = ""
        customCombo.currentIndex = -1
        enabledOpt.checked = false;
        disabledOpt.checked = false;
    }

    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: Style.windowDarkHeader


        Text {
            text: "Add New Rule to "+ ruleset
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
            id: ruleTitle
            text: "Rule Name:"
            color: Style.textNormalColor
            anchors.top: parent.top
            anchors.topMargin: 60
            anchors.left: parent.left
            anchors.leftMargin: 30
        }

        Rectangle {
            id: ruleBox
            color: Style.windowBackground
            radius: 5
            border.color: Style.borderNormalColor
            height: 40
            width: 325
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: ruleTitle.bottom
            anchors.topMargin: 2
            anchors.left: ruleTitle.left

            TextInput  {
                id: inputName
                focus: true
                anchors.fill: parent
                anchors.margins: 10
                maximumLength: 32
                font.pixelSize: 16
                color: Style.textNormalMuted
                verticalAlignment: Text.AlignVCenter

                autoScroll: true
                clip: true
            }

            Text {
                id: hint
                text: "'Rule Name'"
                color: Style.textNormalMuted
                anchors.fill: inputName
                font.pixelSize: 16

                verticalAlignment: Text.AlignVCenter
                visible: inputName.text.length === 0
            }
        }
        //IP
        Text {
            id: ipTitle
            text: "IP:"
            color: Style.textNormalColor
            anchors.top: ruleBox.bottom
            anchors.left: ruleTitle.left
            anchors.topMargin: 15
        }
        Rectangle {
            id: ipBox
            color: Style.windowBackground
            radius: 5
            border.color: Style.borderNormalColor
            height: 40
            width: 325
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: ipTitle.bottom
            anchors.topMargin: 2
            anchors.left: ruleTitle.left

            TextInput  {
                id: inputIP
                focus: true
                anchors.fill: parent
                anchors.margins: 10
                maximumLength: 24
                font.pixelSize: 16
                color: Style.textNormalMuted
                verticalAlignment: Text.AlignVCenter

                autoScroll: true
                clip: true

                validator: RegularExpressionValidator {
                    regularExpression: /^((25[0-5]|2[0-4][0-9]|1\d\d|[1-9]?\d)\.){3}(25[0-5]|2[0-4][0-9]|1\d\d|[1-9]?\d)$/
                }
            }

            Text {
                id: ipHint
                text: "'e.g. 192.168.1.10'"
                color: Style.textNormalMuted
                anchors.fill: inputIP
                font.pixelSize: 16

                verticalAlignment: Text.AlignVCenter
                visible: inputIP.text.length === 0
            }
        }
        //Ports

        //Start
        Text {
            id: portTitleStart
            text: "Port/Range:"
            color: Style.textNormalColor
            anchors.top: ipBox.bottom
            anchors.left: ruleTitle.left
            anchors.topMargin: 15
        }
        Rectangle {
            id: portStartBox
            color: Style.windowBackground
            radius: 5
            border.color: Style.borderNormalColor
            height: 40
            width: 170
            anchors.top: portTitleStart.bottom
            anchors.topMargin: 2
            anchors.left: ruleTitle.left

            TextInput  {
                id: inputStartPort
                focus: true
                anchors.fill: parent
                anchors.margins: 10
                maximumLength: 24
                font.pixelSize: 16
                color: Style.textNormalMuted
                verticalAlignment: Text.AlignVCenter
                validator: IntValidator { bottom: 0; top: 65535 }

                autoScroll: true
                clip: true

                onTextChanged: {
                    if(text.length>1){
                        var clean = text.replace(/[^0-9]/g, "");
                        if (clean !== text) {
                            text = clean;
                            return;
                        }

                        text = String(Number(text));
                        var value = parseInt(text);
                        if (!isNaN(value) && value > 65535) {
                            text = "65535";
                        }
                    }
                }
            }

            Text {
                id: portStartHint
                text: "'From (e.g. 80)'"
                color: Style.textNormalMuted
                anchors.fill: inputStartPort
                font.pixelSize: 16

                verticalAlignment: Text.AlignVCenter
                visible: inputStartPort.text.length === 0
            }
        }
        Text {
            id: portTitleEnd
            text: "To"
            color: Style.textNormalColor
            anchors.top: ipBox.bottom
            anchors.left: portEndBox.left
            anchors.topMargin: 15
        }
        Rectangle {
            id: portEndBox
            color: Style.windowBackground
            radius: 5
            border.color: Style.borderNormalColor
            height: 40
            width: 170
            anchors.top: portTitleStart.bottom
            anchors.topMargin: 2
            anchors.right: parent.right
            anchors.rightMargin: 30

            TextInput  {
                id: inputEndPort
                focus: true
                anchors.fill: parent
                anchors.margins: 10
                maximumLength: 24
                font.pixelSize: 16
                color: Style.textNormalMuted
                verticalAlignment: Text.AlignVCenter
                validator: IntValidator { bottom: 0; top: 65535 }

                autoScroll: true
                clip: true

                onTextChanged: {
                    if(text.length>1){
                        var clean = text.replace(/[^0-9]/g, "");
                        if (clean !== text) {
                            text = clean;
                            return;
                        }

                        text = String(Number(text));
                        var value = parseInt(text);
                        if (!isNaN(value) && value > 65535) {
                            text = "65535";
                        }
                    }
                }
            }

            Text {
                id: portEndHint
                text: "'To (optional)'"
                color: Style.textNormalMuted
                anchors.fill: inputEndPort
                font.pixelSize: 16

                verticalAlignment: Text.AlignVCenter
                visible: inputEndPort.text.length === 0
            }
        }

        Text {
            id: protocolTitle
            text: "Protocol:"
            color: Style.textNormalColor
            anchors.top: portStartBox.bottom
            anchors.left: ruleTitle.left
            anchors.topMargin: 15
        }
        ComboBox {
            id: customCombo
            model: protocolModel
            height: 40
            width: 325
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: protocolTitle.bottom
            anchors.topMargin: 2
            anchors.left: ruleTitle.left

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
                    text: modelData
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
            text: "Rule Status"
            color: Style.textNormalColor
            anchors.topMargin: 25
            anchors.top: customCombo.bottom
            anchors.left: ruleTitle.left
        }
        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: statusText.bottom
            anchors.topMargin: 2
            anchors.left: statusText.left

            RadioButton {
                id: enabledOpt
                text: "Enabled"
                contentItem: Text {
                    text: enabledOpt.text
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
    }
    Rectangle {
        height: 40
        width: 170
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
        width: 170
        radius: 7.5
        color: Style.metricsAllowed
        border.color: Style.borderNormalColor
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30

        Text {
            text: "Add Rule"
            color: "white"
            font.pixelSize: 24
            anchors.centerIn: parent
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                function isValidIP(ip) {
                    var ipRegex = /^((25[0-5]|2[0-4][0-9]|1\d\d|[1-9]?\d)\.){3}(25[0-5]|2[0-4][0-9]|1\d\d|[1-9]?\d)$/;
                    return ipRegex.test(ip);
                }
                function getPortsRange(start, end){
                    let ports = [];
                    for (let i = start; i <= end; ++i) {
                        ports.push(i);
                    }
                    return ports;
                }

                var checked = disabledOpt.checked || enabledOpt.checked
                var lengthInput = (inputName.length === 0)
                var interfaceInput = (customCombo.currentIndex === -1)
                var portStart = inputStartPort.length === 0
                var portOrder = false
                var ipInvalid = !isValidIP(inputIP.text)

                if(inputEndPort.length>0){
                    portOrder =  parseInt(inputEndPort.text) < parseInt(inputStartPort.text)
                }
                if(!checked || lengthInput || interfaceInput || portStart || portOrder || ipInvalid){
                    errorDialog.open()
                }else {
                    console.log("New Rule")
                    console.log("-------------------")
                    console.log("Name: " + inputName.text)
                    console.log("IP: " + inputIP.text)
                    let portRange
                    if(inputEndPort.length === 0 || inputEndPort.text===inputStartPort.text){
                        console.log("Port: " + inputStartPort.text)
                        portRange = getPortsRange(parseInt(inputStartPort.text), parseInt(inputStartPort.text))
                    }else {
                        console.log("Ports: " + inputStartPort.text + "-" + inputEndPort.text)
                        portRange = getPortsRange(parseInt(inputStartPort.text), parseInt(inputEndPort.text))
                    }
                    console.log(customCombo.currentText)
                    console.log("IsOn: "+enabledOpt.checked)

                    interfaceModel.addRuleToRuleset(netInterface, ruleset, {
                        name: inputName.text,
                        ip: inputIP.text,
                        ports: portRange,
                        protocol: customCombo.currentText,
                        status: enabledOpt.checked,
                        hits: 0
                    })
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
