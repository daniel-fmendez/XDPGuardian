import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"
Popup {
    id: popup

    signal singlePortAdded(string port)
    signal rangePortAdded(string startPort, string endPort)

    width: 375
    height: 310
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
    function openWithParameters(){
        open()
    }

    onOpened: {
        singleOpt.checked = true;
        rangeOpt.checked = false;
    }

    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: Style.windowDarkHeader

        Text {
            text: "Add Ports"
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
            id: portTypeTitle
            text: "Port type:"
            color: Style.textNormalColor
            anchors.top: parent.top
            anchors.topMargin: 70
            anchors.left: parent.left
            anchors.leftMargin: 30
        }

        RowLayout {
            id: typeRow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: portTypeTitle.bottom
            anchors.topMargin: 2
            anchors.left: portTypeTitle.left

            RadioButton {
                id: singleOpt
                text: "Single Port"
                contentItem: Text {
                    text: singleOpt.text
                    //font: enabledOpt.font
                    font.pixelSize: 14
                    opacity: enabled ? 1.0 : 0.3
                    color: Style.textNormalColor
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: singleOpt.indicator.width + singleOpt.spacing
                }
                indicator: Rectangle {
                    implicitWidth: 26
                    implicitHeight: 26
                    x: singleOpt.leftPadding
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
                        color: Style.metricsAllowed
                        visible: singleOpt.checked
                    }
                }
            }

            RadioButton {
                id: rangeOpt
                text: "Port Range"
                contentItem: Text {
                    text: rangeOpt.text
                    //font: disabledOpt.font
                    font.pixelSize: 14
                    opacity: enabled ? 1.0 : 0.3
                    color: Style.textNormalColor
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: rangeOpt.indicator.width + rangeOpt.spacing
                }
                indicator: Rectangle {
                    implicitWidth: 26
                    implicitHeight: 26
                    x: rangeOpt.leftPadding
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
                        color: Style.metricsAllowed
                        visible: rangeOpt.checked
                    }
                }
            }
        }

        Loader {
            id: portLoader
            anchors.top: typeRow.bottom
            anchors.topMargin: 15
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.right: parent.right
            anchors.rightMargin: 30

            sourceComponent: singleOpt.checked ? singlePortComponent : rangePortComponent
        }
        Component {
            id: singlePortComponent
            Item {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: parent.right

                property alias portInput: singlePortInput
                Text{
                    id: singlePortTitle
                    text: "Port Number:"
                    color: Style.textNormalColor
                    anchors.left: parent.left
                    anchors.top: parent.top
                }
                Rectangle {
                    id: singlePortBox
                    color: Style.windowBackground
                    radius: 5
                    border.color: Style.borderNormalColor
                    height: 40
                    width: 325
                    //anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: singlePortTitle.bottom
                    anchors.topMargin: 2
                    anchors.left: parent.left
                    anchors.right: parent.right

                    TextInput  {
                        id: singlePortInput
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
                        id: singlePortHint
                        text: "'e.g. 80'"
                        color: Style.textNormalMuted
                        anchors.fill: singlePortInput
                        font.pixelSize: 16

                        verticalAlignment: Text.AlignVCenter
                        visible: singlePortInput.text.length === 0
                    }
                }
            }
        }

        Component {
            id: rangePortComponent
            Item {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: parent.right

                property alias startPortInput: inputStartPort
                property alias endPortInput: inputEndPort
                Column {
                    spacing: 2
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right

                    RowLayout{
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: parent.right
                        Text {
                            text: "Start Port:"
                            color: Style.textNormalColor
                        }

                        Text {
                            text: "End Port:"
                            color: Style.textNormalColor
                        }
                    }

                    RowLayout {
                        spacing: 20
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 40

                        Rectangle {
                            id: portStartBox
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1 // Usa proporciones si querés
                            height: 40
                            radius: 5
                            color: Style.windowBackground
                            border.color: Style.borderNormalColor

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
                                text: "'e.g. 5000'"
                                color: Style.textNormalMuted
                                anchors.fill: inputStartPort
                                font.pixelSize: 16

                                verticalAlignment: Text.AlignVCenter
                                visible: inputStartPort.text.length === 0
                            }
                        }

                        Rectangle {
                            id: portEndBox
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            height: 40
                            radius: 5
                            color: Style.windowBackground
                            border.color: Style.borderNormalColor

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
                                text: "'e.g. 5500'"
                                color: Style.textNormalMuted
                                anchors.fill: inputEndPort
                                font.pixelSize: 16

                                verticalAlignment: Text.AlignVCenter
                                visible: inputEndPort.text.length === 0
                            }
                        }
                    }
                }
            }
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
            text: "Add"
            color: "white"
            font.pixelSize: 24
            anchors.centerIn: parent
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(singleOpt.checked){
                    if(portLoader.item.portInput.text.length===0){
                        console.log("Please input correct values")
                        errorDialog.open()
                    }else{
                        singlePortAdded(portLoader.item.portInput.text)
                        popup.close()
                    }
                }else if(rangeOpt.checked){
                    if(portLoader.item.startPortInput.text.length===0 || portLoader.item.endPortInput.text.length===0){
                        console.log("Please input correct values")
                        errorDialog.open()
                    }else if(parseInt(portLoader.item.endPortInput.text) <= parseInt(portLoader.item.startPortInput.text)){
                        errorDialog.open()
                    }else{
                        rangePortAdded(portLoader.item.startPortInput.text,
                                       portLoader.item.endPortInput.text)
                        popup.close()
                    }
                }else{
                    console.log("Please input correct values")
                    errorDialog.open()
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
