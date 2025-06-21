import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"
import "../../CustomComponents"
Popup {
    //Management
    property string netInterface
    property string ruleset
    //Rule properties
    property string ruleName
    property string ruleIp
    //Ports
    property string rulePorts
    property int protocolIndex
    property bool isActive

    id: popup
    width: 430
    height: 580
    modal: true
    focus: true
    //anchors.centerIn: Overlay.overlay
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
    function openWithParameters(inter, rs, name, ip,ports, index, status){
        netInterface = inter
        ruleset = rs
        ruleName=name
        ruleIp=ip
        rulePorts=ports
        protocolIndex=index
        isActive=status
        inputName.text = ruleName
        inputIP.text = ruleIp
        customCombo.currentIndex = protocolIndex
        portFlow.newPortList = []
        portFlow.originalPortList = portFlow.expandPorts(rulePorts)
        if(isActive){
            enabledOpt.checked = true;
            disabledOpt.checked = false;
        }else{
            enabledOpt.checked = false;
            disabledOpt.checked = true;
        }
        open()
    }
    Component.onCompleted: {
        popup.x = (parent.width - popup.width) / 2
        popup.y = (parent.height - popup.height) / 2
    }
    onOpened: {
        inputName.text = ruleName
        inputIP.text = ruleIp
        customCombo.currentIndex = protocolIndex
        portFlow.newPortList = []
        portFlow.originalPortList = portFlow.expandPorts(rulePorts)
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

        MouseArea {
            id: dragArea
            anchors.fill: parent

            // Excluir el área del botón de cierre para no interferir con él
            anchors.rightMargin: closeX.width * 2

            property point clickPos

            onPressed: {
                clickPos = Qt.point(mouse.x, mouse.y)
            }

            onPositionChanged: {
                if (pressed) {
                    // Calcular el desplazamiento desde donde se hizo clic
                    var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)

                    var newX = popup.x + delta.x
                    var newY = popup.y + delta.y

                    newX = Math.min(Math.max(0, newX),app.width-popup.width)
                    newY = Math.min(Math.max(0, newY),app.height-popup.height)

                    popup.x = newX
                    popup.y = newY
                }
            }
        }
        Text {
            text: "Edit rule "+ ruleset
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 20
            font.pixelSize: 16
            font.bold: true
            color: Style.windowBackground
        }
        //Close
        Rectangle {
            height: parent.height / 2
            width: height
            radius: height / 2
            color: Style.networkBlocked
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: width / 2

            Canvas {
                id: closeX
                // Hacer el canvas un poco más pequeño que el parent para dar margen
                width: parent.width * 0.7
                height: width
                anchors.centerIn: parent

                property color xColor: "white"

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    // Establecer estilo de línea
                    ctx.strokeStyle = xColor;
                    ctx.lineWidth = Math.max(2, width * 0.1); // Ajustar grosor proporcionalmente

                    // Calcular coordenadas exactas usando el centro
                    var center = width / 2;
                    var halfSize = width * 0.4; // Tamaño de medio brazo de la X

                    // Dibujar primera línea diagonal
                    ctx.beginPath();
                    ctx.moveTo(center - halfSize, center - halfSize);
                    ctx.lineTo(center + halfSize, center + halfSize);
                    ctx.stroke();

                    // Dibujar segunda línea diagonal
                    ctx.beginPath();
                    ctx.moveTo(center + halfSize, center - halfSize);
                    ctx.lineTo(center - halfSize, center + halfSize);
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
        //Start
        Text {
            id: portsTitle
            text: "Port/Range:"
            color: Style.textNormalColor
            anchors.top: ipBox.bottom
            anchors.left: ruleTitle.left
            anchors.topMargin: 15
        }
        Rectangle {
            id: portBox
            color: Style.windowBackground
            radius: 5
            border.color: Style.borderNormalColor
            height: 110
            width: 315
            anchors.top: portsTitle.bottom
            anchors.topMargin: 2
            anchors.left: ruleTitle.left
            clip:true

            ScrollView {
                id: portScrollView
                width: parent.width - 4
                height: parent.height - 4
                clip: true

                Flow {
                    id: portFlow
                    width: portScrollView.width - 16  // Restando el padding (8px por lado)
                    padding: 8
                    spacing: 10
                    flow: Flow.LeftToRight

                    property string portData: "20,40,50-59,80,82,83,8000,9000-10000"
                    property var badPortList: expandPorts(portData)
                    property var originalPortList: expandPorts(rulePorts)
                    property var newPortList: []

                    Repeater {
                        model: portFlow.originalPortList
                        delegate: PortTag {
                            textContent: modelData
                            fillColor: Style.windowHeader
                            onRemoveClicked: {
                                portFlow.removeOldPort(textContent)
                            }
                        }
                    }

                    Repeater {
                        model: portFlow.newPortList
                        delegate: PortTag {
                            textContent: modelData
                            fillColor: Style.windowBackground
                            onRemoveClicked: {
                                portFlow.removeNewPort(textContent)
                            }
                        }
                    }

                    function expandPorts(portString) {
                        return portString.split(",").map(function(p) {
                            return p.trim()
                        })
                    }
                    function removeOldPort(port) {
                        var index = originalPortList.indexOf(port)
                        if (index !== -1) {
                            originalPortList.splice(index, 1)
                            originalPortListChanged()
                        }
                    }
                    function removeNewPort(port) {
                        var index = newPortList.indexOf(port)
                        if (index !== -1) {
                            newPortList.splice(index, 1)
                            newPortListChanged()
                        }
                    }
                    function isPortInRangeOrList(port, portStrings) {
                        if(port.toString().includes("-")){
                            let range = port.split("-")
                            let start = parseInt(range[0])
                            let end = parseInt(range[1])

                            return isPortInRangeOrList(start,portStrings) ? true : isPortInRangeOrList(end,portStrings)
                        }else{
                            for (let i = 0; i < portStrings.length; ++i) {
                                let part = portStrings[i].toString().trim()

                                if (part.includes("-")) {
                                    let range = part.split("-")
                                    let start = parseInt(range[0])
                                    let end = parseInt(range[1])

                                    if (port >= start && port <= end) {
                                        return true
                                    }
                                } else {
                                    if (parseInt(part) === port) {
                                        return true
                                    }
                                }
                            }
                        }
                        return false
                    }
                    function addNewPort(newPort) {
                        if (!newPortList.includes(newPort)
                                && !originalPortList.includes(newPort)
                                && !isPortInRangeOrList(newPort, newPortList)
                                && !isPortInRangeOrList(newPort, originalPortList)) {

                            var newList = newPortList.slice()
                            newList.push(newPort)
                            newPortList = newList
                            portFlow.forceLayout()
                        }
                    }
                }
            }
        }

        Rectangle {
            id: portButton
            height: width
            radius: 5
            color: Style.metricsAllowed
            anchors.top: portBox.top
            anchors.left: portBox.right
            anchors.leftMargin: 10
            anchors.right: ipBox.right
            border.color: Style.borderNormalColor
            Canvas {
                id: plusCanvas
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    ctx.strokeStyle = "white"
                    ctx.lineWidth = 4

                    var centerX = width / 2
                    var centerY = height / 2
                    var length = width * 0.4  // Largo de cada línea de la cruz

                    // Línea horizontal
                    ctx.beginPath()
                    ctx.moveTo(centerX - length / 2, centerY)
                    ctx.lineTo(centerX + length / 2, centerY)
                    ctx.stroke()

                    // Línea vertical
                    ctx.beginPath()
                    ctx.moveTo(centerX, centerY - length / 2)
                    ctx.lineTo(centerX, centerY + length / 2)
                    ctx.stroke()
                }
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    portPopup.open()
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
                AddPortPopup{
                    id: portPopup
                    onSinglePortAdded: (port) => {
                        portFlow.addNewPort(port)
                    }
                    onRangePortAdded: (startPort,endPort) => {
                        portFlow.addNewPort(startPort+"-"+endPort)
                    }
                }
            }
        }


        Text {
            id: protocolTitle
            text: "Protocol:"
            color: Style.textNormalColor
            anchors.top: portBox.bottom
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
                function expandPorts(portList) {
                    var result = []

                    for (var i = 0; i < portList.length; i++) {
                        var part = portList[i].trim()
                        if (part.indexOf("-") !== -1) {
                            var range = part.split("-")
                            var start = parseInt(range[0])
                            var end = parseInt(range[1])

                            for (var p = start; p <= end; p++) {
                                result.push(p)
                            }
                        } else {
                            result.push(parseInt(part))
                        }
                    }

                    return result
                }

                var combinedPorts = portFlow.originalPortList.concat(portFlow.newPortList)
                var expandedPorts = expandPorts(combinedPorts)
                var allPorts = expandedPorts.sort(((a, b) => a - b)).filter((val, index, self) => self.indexOf(val) === index)

                var portSize = allPorts.length>0
                var checked = disabledOpt.checked || enabledOpt.checked
                var lengthInput = (inputName.length === 0)
                var interfaceInput = (customCombo.currentIndex === -1)

                var ipInvalid = !isValidIP(inputIP.text)


                if(!checked || lengthInput || interfaceInput || !portSize || ipInvalid){
                    errorDialog.open()
                }else {
                    var interfaceIndex = interfaceModel.getIndex(netInterface)
                    var rulesetIndex = interfaceModel.getIndexRuleset(interfaceIndex,ruleset)
                   interfaceModel.editRuleOnRuleset(interfaceIndex,rulesetIndex , ruleName,{
                        name: inputName.text,
                        ip: inputIP.text,
                        ports: allPorts,
                        protocol: customCombo.currentText,
                        status: enabledOpt.checked
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
