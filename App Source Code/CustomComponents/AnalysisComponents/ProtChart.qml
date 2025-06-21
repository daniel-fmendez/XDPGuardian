import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts
import "../../Style"

Rectangle {
    id: root
    anchors.fill: parent
    radius: 7.5
    color: Style.windowBackground

    property int maxPackets: -1
    property int totalPackects: 0
    property int totalData: 0
    property int numberOfIps: 0

    function updatePieChart() {
        var max = -1
        var now = Date.now()
        var lastMinute = now - 60000
        var lastMinuteNs = lastMinute * 1000000
        totalPackects = 0
        totalData = 0

        numberOfIps = getUniqueIps();
        pieSeries.clear();

        for (var i = 0; i < protPieModel.rowCount(); i++) {
            var element = protPieModel.get(i);

            var slice = pieSeries.append(element.label, element.totalPackets);
            slice.color = Style.getPieColor(element.label);
            slice.borderColor = slice.color;
            slice.borderWidth = 2;

            totalPackects += element.totalPackets
            if(element.totalPackets > max){
                max = element.totalPackets
            }

            totalData += element.totalBytes
        }
        maxPackets = max
    }

    function getUniqueIps() {
        var count = 0

        for(var i = 0; i < ipHitsModel.rowCount(); i++){
            count++
            var element = ipHitsModel.get(i);
        }

        return count
    }

    Connections {
        target: protPieModel

       function onSeriesChanged(){
           root.updatePieChart()
       }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: header

            Layout.fillWidth: true
            Layout.minimumHeight: 45
            Layout.preferredHeight: 45

            color: Style.windowHeader
            height: 45
            radius: 7.5

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 16

                text: "TRAFFIC DISTRIBUTION BY PROTOCOL"
                font.pixelSize: 14
                font.bold: true
                color: Style.textTitleColor
            }

            // Separator line
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.radius
                color: Style.windowHeader
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1.25
                color: "transparent"

                ChartView {
                    id: chart

                    anchors.fill: parent
                    anchors.margins: -30
                    legend.visible: false
                    antialiasing: true
                    backgroundColor: "transparent"

                    property PieSlice selectedSlice: null

                    PieSeries {
                        id: pieSeries
                        size: 0.95

                        onClicked: function(slice) {
                            chart.handleClick(slice)
                        }
                    }

                    function handleClick(slice) {
                        // Reset previous selection
                        if (selectedSlice && selectedSlice !== slice) {
                            selectedSlice.exploded = false
                        }

                        // Toggle current slice
                        slice.exploded = !slice.exploded
                        selectedSlice = slice.exploded ? slice : null

                        // Show dialog if exploded
                        if (slice.exploded) {
                            infoDialog.title = slice.label
                            infoDialog.text = "Value: " + slice.value
                            infoDialog.open()
                        } else {
                            infoDialog.close()
                        }
                    }

                    Dialog {
                        id: infoDialog
                        modal: false
                        focus: false
                        width: 100
                        x: chart.width / 2 - width / 2
                        y: chart.height / 2 - height / 2

                        background: Rectangle {
                           color: Style.windowBackground
                           border.color: Style.windowHeader
                           border.width: 1
                        }

                        contentItem: Text {
                           text: infoDialog.text
                           color: Style.textNormalColor
                           font.pixelSize: 14
                           padding: 12
                           wrapMode: Text.WordWrap
                        }


                        onVisibleChanged: {
                           if (!visible && chart.selectedSlice) {
                               chart.selectedSlice.exploded = false
                               chart.selectedSlice = null
                           }
                        }

                        property string text: ""
                        property string titleText: ""
                    }
                }
                Component.onCompleted: {
                    updatePieChart();
                }
            }
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                color: "transparent"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 5
                    spacing: 0

                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredHeight: 1.75

                        columns: 2
                        rows: 2

                        columnSpacing: 4
                        rowSpacing: 4

                        Repeater {
                            model: protPieModel

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                clip: true

                                ColumnLayout {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    clip: true

                                    Rectangle {
                                        width: 14
                                        height: 14
                                        color: Style.getPieColor(model.label)
                                    }

                                    Text {
                                        property real percent: (model.totalPackets / totalPackects * 100).toFixed(1)
                                        property string packets: {
                                            if(model.totalPackets>1000){
                                                return (model.totalPackets / 1000).toFixed(1) +"k"
                                            }else {
                                                return model.totalPackets
                                            }
                                        }

                                        text: model.label + ": " + percent + "% (" + packets + " packets)"
                                        font.pixelSize: 16
                                        color: Style.textNormalColor
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                    Rectangle {
                        id: textContainer
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredHeight: 1.65
                        color: "transparent"
                        clip: true

                        function formatBytes(bytes) {
                            if (bytes < 1024)
                                return bytes + " B";
                            else if (bytes < 1024 * 1024)
                                return (bytes / 1024).toFixed(2) + " KB";
                            else if (bytes < 1024 * 1024 * 1024)
                                return (bytes / (1024 * 1024)).toFixed(2) + " MB";
                            else
                                return (bytes / (1024 * 1024 * 1024)).toFixed(2) + " GB";
                        }

                        ColumnLayout {
                            spacing: parent.height /12.5
                            Text {
                                Layout.fillHeight: true
                                text: "Total packets: " + totalPackects
                                font.pixelSize: 16
                                color: Style.textNormalColor
                            }

                            Text {
                                Layout.fillHeight: true
                                text: "Total data: " + textContainer.formatBytes(totalData)
                                font.pixelSize: 16
                                color: Style.textNormalColor
                            }

                            Text {
                                Layout.fillHeight: true
                                text: "Unique IPs: " + numberOfIps
                                font.pixelSize: 16
                                color: Style.textNormalColor
                            }
                        }
                    }
                }
            }
        }
    }
}
