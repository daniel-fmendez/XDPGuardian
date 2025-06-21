import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../Style"
import TagEnum 1.0
import ".."
Page {
    visible: true
    header: Rectangle {
        height: 90
        color: "black"

        ColumnLayout{
            anchors.fill: parent
            Layout.fillWidth: true
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                height: parent.height / 2
                color: Style.windowHeader
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
                            text: "System Logs"
                            font.pixelSize: 24
                            font.bold: true
                            font.family: Style.textTitleFont
                            color: Style.textTitleColor

                            anchors.left: parent.left
                            anchors.leftMargin: 20
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
                            text: "Source: " + customCombo.currentText
                            font.pixelSize: 16
                            font.family: Style.textNormalSize
                            color: Style.textNormalMuted

                            anchors.right: parent.right
                            anchors.rightMargin: 80
                            width: implicitWidth
                            anchors.margins: 40
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: parent.height / 2 + 10
                color: Style.tableRowA

                RowLayout{
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 10

                    Rectangle {
                        id: searchBar
                        Layout.fillWidth: true
                        Layout.minimumWidth: 350
                        height: 35
                        radius: 7.5
                        color: Style.windowBackground
                        border.color: Style.borderNormalColor
                        border.width: 2

                        TextInput  {
                            id: input
                            anchors.fill: parent
                            anchors.margins: 10
                            font.pixelSize: 16
                            color: Style.textNormalMuted
                            verticalAlignment: Text.AlignVCenter
                            focus: true

                            autoScroll: true
                            clip: true
                            onTextChanged: {
                                if(text.length>3){
                                    logTableModel.setSearchText(text)
                                }else{
                                    if(text.length===0){
                                        logTableModel.clearSearch()
                                    }
                                }
                            }
                        }

                        Text {
                            id: hint
                            text: "Search..."
                            color: Style.textNormalMuted
                            anchors.fill: input
                            font.pixelSize: 16

                            verticalAlignment: Text.AlignVCenter
                            visible: input.text.length === 0
                        }
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        clip: true
        spacing: 0
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 0
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 60
                color: Style.windowBackground
                clip: true
                Label {
                    id: filterTittle
                    text: "FILTER BY TYPE:"
                    font.pixelSize: 16
                    font.bold: true
                    font.family: Style.textTitleFont
                    color: Style.textTitleColor

                    height: 30  // Define una altura clara
                    verticalAlignment: Text.AlignVCenter

                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.top: parent.top
                    anchors.topMargin: 15
                }
                Flow {
                    id: tagFlow
                    anchors.left: filterTittle.right
                    anchors.leftMargin: 20
                    anchors.top: filterTittle.top
                    spacing: 10

                    flow: Flow.LeftToRight

                    property var tags: []
                    Component.onCompleted: {
                        var result = []
                        for(var i=0; i<4;i++){
                            var name = logTableModel.tagToString(i)
                            result.push({ name: name, isOn: true })
                        }
                        tagFlow.tags = result
                        logTableModel.setActiveTags(tagFlow.getActiveTags())
                    }
                    function getActiveTags() {
                        return tags.filter(t => t.isOn).map(t => t.name)
                    }

                    Repeater {
                        model: tagFlow.tags
                        Tag {
                            isInteractive: true
                            textContent: modelData.name
                            isOn: modelData.isOn

                            fillColor: Style.getTagFillColor(modelData.name)

                            borderColor: Style.getTagBorderColor(modelData.name)
                            onTagStatusChanged: {
                                var index = tagFlow.tags.findIndex(tag => tag.name === modelData.name)
                                if (index >= 0) {
                                    tagFlow.tags[index].isOn = !tagFlow.tags[index].isOn
                                }

                                logTableModel.setActiveTags(tagFlow.getActiveTags())
                            }
                        }
                    }
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 50
                color: Style.windowBackground
                clip: true

                ComboBox {
                    id: customCombo

                    property var sources: []

                    width: 275
                    height: 40
                    currentIndex: 0
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    model: sources

                    function getSources(){
                        var result = []
                        result.push({ text: "All" })
                        const orignalModel = interfaceModel
                        for(var i=0; i<orignalModel.rowCount();i++){
                            result.push({text: orignalModel.getInterfaceByIndex(i)})
                        }
                        var existingTexts = result.map(r => r.text)
                        var otherSources = logTableModel.getAllSources()

                        for (var j = 0; j < otherSources.length; j++) {
                            if (existingTexts.indexOf(otherSources[j]) === -1) {
                                result.push({ text: otherSources[j] })
                            }
                        }
                        return result
                    }

                    Connections {
                        target: logTableModel

                        function onLogAdded(){
                            customCombo.sources=customCombo.getSources()
                        }
                    }

                    Component.onCompleted: {
                        logTableModel.setSourceText("All")
                        sources = customCombo.getSources()
                    }

                    onCurrentTextChanged: {
                        logTableModel.setSourceText(customCombo.currentText)
                    }

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
                            text: modelData.text
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
            }
        }


        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"

            HorizontalHeaderView {
                id: logTableHeader
                syncView: tableLog
                Layout.fillWidth: true
                clip: true

                boundsBehavior: Flickable.StopAtBounds
                interactive: false
                resizableColumns: false


                delegate: Rectangle {
                    color: Style.windowHeader
                    //border.color: "black"
                    implicitHeight: 40
                    property var columnRatios: [0.20, 0.20, 0.40, 0.20]
                    implicitWidth: Math.max(100, tableLog.width * columnRatios[column])
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
                id: tableLog
                anchors.top: logTableHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                clip: true

                model: logTableModel
                delegate: Rectangle {
                    //Ratios
                    //ID, NOMBRE, IP, PUERTOS, PROTOCOL, ACTION, STATUS, HITS
                    property var columnRatios: [0.20, 0.20, 0.40, 0.20]
                    // Columnas con tamaños maximos
                    implicitWidth: tableLog.width * columnRatios[column]
                    implicitHeight: 60
                    color: row % 2 ? Style.tableRowA : Style.tableRowB

                    Loader {
                        id: loader
                        anchors.fill: parent
                        sourceComponent: column === 1 ? tagElement  : textLogElement
                    }
                    Component {
                        id: textLogElement
                        Text {
                            id: textItem
                            anchors.fill: parent
                            anchors.margins: 10
                            wrapMode: Text.WordWrap
                            elide: Text.ElideNone
                            verticalAlignment: Text.AlignVCenter
                            color: Style.textNormalColor
                            text: display
                        }
                    }
                    Component {
                        id: tagElement

                        Tag {
                            anchors.fill: parent
                            anchors.margins: 10
                            anchors.verticalCenter: parent.verticalCenter
                            isInteractive: false
                            textContent: display
                            isOn: true

                            fillColor: Style.getTagFillColor(display)
                            borderColor: Style.getTagBorderColor(display)
                        }
                    }
                }
            }
        }
    }
    Connections {
        id: errorConnection
        target: interfaceModel
        function onErrorLogRuleset(message, source){
            logTableModel.addLog(logTableModel.stringToTag("ERROR"),message,source)
        }
        function onLogEmited(tagType, message, source){
            logTableModel.addLog(tagType, message, source)
        }
    }
}

