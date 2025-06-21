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

    ListModel {
        id: packetSizeModel

        ListElement {category: "0 - 63"; value: 46}
        ListElement {category: "64 - 127"; value: 330}
        ListElement {category: "128 - 191"; value: 41}
        ListElement {category: "192 - 255"; value: 8}
        ListElement {category: "256 - 319"; value: 20}
        ListElement {category: "320 - 383"; value: 4555}
        ListElement {category: "384 - 447"; value: 3236}
        ListElement {category: "448 - 511"; value: 694}
        ListElement {category: "512 - 575"; value: 112}
        ListElement {category: "576 - 639"; value: 103}
        ListElement {category: "640 - 703"; value: 19}
        ListElement {category: "704 - 767"; value: 10}
        ListElement {category: "1472 - 1535"; value: 49}
    }

    property var categories: [
        "0 - 63", "64 - 127", "128 - 191", "192 - 255", "256 - 319", "320 - 383",
        "384 - 447", "448 - 511", "512 - 575", "576 - 639", "640 - 703", "704 - 767",
        "768 - 831", "832 - 895", "896 - 959", "960 - 1023", "1024 - 1087", "1088 - 1151",
        "1152 - 1215", "1216 - 1279", "1280 - 1343", "1344 - 1407", "1408 - 1471",
        "1472 - 1535", "1536 - 1599", "1600 - 1663", "1664 - 1727", "1728 - 1791",
        "1792 - 1855", "1856 - 1919", "1920 - 1983", "1984 - 2047", "2048 - 2111",
        "2112 - 2175", "2176 - 2239", "2240 - 2303", "2304 - 2367", "2368 - 2431",
        "2432 - 2495", "2496 - 2559", "2560 - 2623", "2624 - 2687", "2688 - 2751",
        "2752 - 2815", "2816 - 2879", "2880 - 2943", "2944 - 3007", "3008 - 3071",
        "3072 - 3135", "3136 - 3199", "3200 - 3263", "3264 - 3327", "3328 - 3391",
        "3392 - 3455", "3456 - 3519", "3520 - 3583", "3584 - 3647", "3648 - 3711",
        "3712 - 3775", "3776 - 3839", "3840 - 3903", "3904 - 3967", "3968 - 4031",
        "4032 - 4095"
    ]

    function updateChart() {
        // Limpiar valores actuales

        barSeries.clear()

        var barSet = barSeries.append("Data", [])
        // Actualizar categorías del eje X
        var categories = []

        barSet.color = Style.distributionBarsColors
        barSet.borderColor = Style.distributionBarsColors
        // Llenar las categorías y valores del gráfico desde el modelo
        for (var i = 0; i < packetDistModel.rowCount(); i++) {
            var item = packetDistModel.get(i)
            if(item.packets > 0){
                categories.push(root.categories[item.bucket])
                barSet.values.push(item.packets)
            }
        }

        // Actualizar categorías del eje X
        xAxis.categories = categories

        var maxValor = 0
        for (var j = 0; j < packetDistModel.rowCount(); j++) {
            maxValor = Math.max(maxValor, packetDistModel.get(j).packets)
        }
        yAxis.max = Math.ceil(maxValor)
    }
    Connections {
        target: packetDistModel

        function onListChanged(){
            root.updateChart()
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

                text: "PACKET SIZE DISTRIBUTION"
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

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            clip: true

            ChartView {
                id: chart
                anchors.fill: parent
                anchors.margins: -22
                legend.alignment: Qt.AlignBottom
                antialiasing: true
                legend.visible: false
                backgroundColor: "transparent"

                BarSeries {
                    id: barSeries

                    onClicked: function(index) {
                        chart.handleClick(index)
                    }
                    axisX: BarCategoryAxis {
                        id: xAxis


                        labelsColor: Style.textNormalColor
                        titleBrush: Style.textNormalColor

                        color: Style.axisColor
                        gridLineColor: Style.axisColor

                        labelsFont.pointSize: 8
                        labelsAngle: 45


                    }
                    axisY: ValuesAxis {
                        id: yAxis
                        min: 0
                        tickCount: 4
                        labelFormat: "%d"  // mostrar solo enteros

                        labelsColor: Style.textNormalColor
                        titleBrush: Style.textNormalColor

                        color: Style.axisColor
                        gridLineColor: Style.axisColor
                    }

                    BarSet {
                        id: barSet
                        label: "packets";

                        color: Style.distributionBarsColors
                        borderColor: Style.distributionBarsColors
                    }
                }

                function handleClick(ind) {
                    let value = barSeries.at(0).at(ind)
                    infoDialog.title = root.categories[ind]
                    infoDialog.text = "Value: "+value
                    infoDialog.open()
                }


                Dialog {
                    id: infoDialog
                    modal: false
                    focus: false
                    visible: false
                    width: 100
                    property string text: ""

                    onVisibleChanged: {
                        if (visible) {
                            // Evita el binding loop llamando más tarde
                            Qt.callLater(function() {
                                infoDialog.x = chart.width / 2 - infoDialog.width / 2
                                infoDialog.y = chart.height / 2 - infoDialog.height / 2
                            })
                        }
                    }

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
                }
            }
        }
    }
    Component.onCompleted: {
        updateChart()
    }
}
