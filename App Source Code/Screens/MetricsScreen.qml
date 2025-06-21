import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts 2.9
import "../Style"

Page {
    id: root
    SplitView.preferredHeight: 150
    SplitView.minimumHeight: 100

    background: Rectangle {
        color: Style.windowBackground
    }

    property var interfaceMetrics: ({})
    property string currentInterfaceId: ""

    // Last
    property int lastTotalPackets: 0
    property int lastBlockedPackets: 0
    property int lastAllowedPackets: 0

    // Current
    property int totalPackets: 0
    property int blockedPackets: 0
    property int allowedPackets: 0
    //Rates
    property int blockedRate: 0
    property int allowedRate: 0
    property int trafficRate: 0

    function loadInterfaceData(interfaceId) {
        // Save current interface data first if we have an interface selected
        if (currentInterfaceId !== "") {
            saveCurrentInterfaceData()
        }

        // Set new interface as current
        currentInterfaceId = interfaceId

        if (!interfaceMetrics[interfaceId]) {
            interfaceMetrics[interfaceId] = {
                totalPackets: 0,
                blockedPackets: 0,
                allowedPackets: 0,
                lastTotalPackets: 0,
                lastBlockedPackets: 0,
                lastAllowedPackets: 0,
                blockedRate: 0,
                allowedRate: 0,
                trafficRate: 0,
                blockedValues: [],
                trafficValues: [],
                counter: 0
            }
        }

        // Load data for this interface
        var data = interfaceMetrics[interfaceId]
        totalPackets = data.totalPackets
        blockedPackets = data.blockedPackets
        allowedPackets = data.allowedPackets
        lastTotalPackets = data.lastTotalPackets
        lastBlockedPackets = data.lastBlockedPackets
        lastAllowedPackets = data.lastAllowedPackets
        blockedRate = data.blockedRate
        allowedRate = data.allowedRate
        trafficRate = data.trafficRate

        // Clear existing series data
        blockedSeries.clear()
        trafficSeries.clear()

        // Load chart data points for this interface
        for (var i = 0; i < data.blockedValues.length; i++) {
            var block = data.blockedValues[i]
            var traffic = data.trafficValues[i]

            blockedSeries.append(block.x, block.y)
            trafficSeries.append(traffic.x, traffic.y)
        }

        // Adjust axis if needed
        if (data.blockedValues.length > 0) {
            var lastX = data.blockedValues[data.blockedValues.length - 1].x
            axisX.min = Math.max(0, lastX - 60)
            axisX.max = Math.max(60, lastX + 5)
            updateTimer.counter = data.counter || lastX + 5
        } else {
            axisX.min = 0
            axisX.max = 60
            updateTimer.counter = 0
        }

        updateTimer.updateVisibleMaximum()

        // Update the progress bar based on current rates
        progressBlocked.value = trafficRate > 0 ? blockedRate / trafficRate : 0
    }

    function saveCurrentInterfaceData() {
        if (currentInterfaceId === "") return

        // Make a deep copy of the values arrays to prevent shared references
        var blockedValuesCopy = []
        var trafficValuesCopy = []

        for (var i = 0; i < updateTimer.blockedValues.length; i++) {
            blockedValuesCopy.push({
                x: updateTimer.blockedValues[i].x,
                y: updateTimer.blockedValues[i].y
            })

            trafficValuesCopy.push({
                x: updateTimer.trafficValues[i].x,
                y: updateTimer.trafficValues[i].y
            })
        }

        interfaceMetrics[currentInterfaceId] = {
            totalPackets: totalPackets,
            blockedPackets: blockedPackets,
            allowedPackets: allowedPackets,
            lastTotalPackets: lastTotalPackets,
            lastBlockedPackets: lastBlockedPackets,
            lastAllowedPackets: lastAllowedPackets,
            blockedRate: blockedRate,
            allowedRate: allowedRate,
            trafficRate: trafficRate,
            blockedValues: blockedValuesCopy,
            trafficValues: trafficValuesCopy,
            counter: updateTimer.counter
        }
    }

    function getBlockedPackets() {
        var total = 0

        for(var i = 0; i < metricsRuleHitsModel.rowCount(); i++){
            var element = metricsRuleHitsModel.get(i)
            total += element.hits
        }

        lastBlockedPackets = blockedPackets
        blockedPackets = total
        blockedRate = blockedPackets - lastBlockedPackets

        if (currentInterfaceId !== "") {
            interfaceMetrics[currentInterfaceId].lastBlockedPackets = lastBlockedPackets
        }

        updateAllowedPackets()
        return total;
    }

    function getTotalPackets() {
        var total = 0

        for(var i = 0; i < metricsProtStatsModel.rowCount(); i++){
            var element = metricsProtStatsModel.get(i)
            total += element.totalPackets
        }

        lastTotalPackets = totalPackets
        totalPackets = total
        trafficRate = totalPackets - lastTotalPackets

        if (currentInterfaceId !== "") {
            interfaceMetrics[currentInterfaceId].lastTotalPackets = lastTotalPackets
        }

        updateAllowedPackets()
        return total;
    }

    function updateAllowedPackets() {
        lastAllowedPackets = allowedPackets
        allowedPackets = totalPackets - blockedPackets
        allowedRate = allowedPackets - lastAllowedPackets

        if (currentInterfaceId !== "") {
            interfaceMetrics[currentInterfaceId].lastAllowedPackets = lastAllowedPackets
        }
    }

    function fetchMetrics() {
        if (SelectionManager.selectedInterface != null && SelectionManager.selectedInterface !== "") {
            var inter = SelectionManager.selectedInterface

            try {
                var ipHits = interfaceModel.getIpHitsByInterface(inter)
                if (ipHits) {
                    metricsIpHitsModel.setFromList(ipHits)
                }

                var ruleHits = interfaceModel.getRuleHitsByInterface(inter)
                if (ruleHits) {
                    metricsRuleHitsModel.setFromList(ruleHits)
                }

                var protHits = interfaceModel.getProtStatsByInterface(inter)
                if (protHits) {
                    metricsProtStatsModel.setFromList(protHits)
                }
            } catch (e) {
                console.error("Error fetching protocol stats:", e)
            }
        }
    }

    Connections {
        target: metricsRuleHitsModel

        function onListChanged(){
            root.getBlockedPackets()
        }
    }

    Connections {
        target: metricsProtStatsModel

        function onSeriesChanged(){
            root.getTotalPackets()
        }
    }

    Connections {
        target: SelectionManager

        function onSelectedInterfaceChanged() {
            updateTimer.stop() // Stop timer before switching
            loadInterfaceData(SelectionManager.selectedInterface)
            fetchMetrics()
            updateTimer.restart()
        }
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

    Component.onCompleted: {
        if (SelectionManager.selectedInterface != null && SelectionManager.selectedInterface !== "") {
            loadInterfaceData(SelectionManager.selectedInterface)
            fetchMetrics()
            updateTimer.restart()
        }
    }

    //Grafico
    ColumnLayout {
        spacing: 0
        anchors.fill: parent
        anchors.centerIn: parent
        Rectangle {
            id: chartContainer
            color: Style.windowBackground
            Layout.preferredHeight: parent.height * 0.90
            Layout.fillWidth: true

            ColumnLayout {
                id: textBox
                spacing: 5

                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 10

                Text{
                    text: "Packets Processed: " + totalPackets
                    color: Style.textNormalColor
                }
                Text{
                    property real blockedPercentage: totalPackets > 0 ? (blockedPackets / totalPackets * 100) : 0
                    text: "Blocked: "+blockedPackets + " (" + blockedPercentage.toFixed(2) + "%)"
                    color: Style.textNormalColor
                }
                Text{
                    property real allowedPercentage: totalPackets > 0 ? (allowedPackets / totalPackets * 100) : 0
                    text: "Allowed: "+allowedPackets + " (" + allowedPercentage.toFixed(2) + "%)"
                    color: Style.textNormalColor
                }
            }

            Text {
                id: chartTitle
                text: "Packets per minute - " + (currentInterfaceId || "No interface selected")
                font.bold: true
                font.pixelSize: 18
                color: Style.textNormalColor

                anchors.top: textBox.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: parent.width
                color: "transparent"

                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.right: parent.right
                anchors.rightMargin: 5.5
                anchors.top: chartTitle.bottom
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5

                ChartView {
                    id: chartView
                    antialiasing: true
                    backgroundColor: "transparent"
                    legend.visible: false
                    anchors { fill: parent; margins: -15}
                    margins { top: 0; bottom: 0; left: 0; right: 0 }

                    ValuesAxis {
                        id: axisX
                        min: 0
                        max: 60  // 60 minutos visibles
                        visible: false // ocultamos el eje X
                    }

                    ValuesAxis {
                        id: axisY
                        min: 0
                        max: 100
                        titleText: "Datos por minuto"
                        titleFont: Style.textNormalFont
                        labelFormat: "%d"

                        labelsColor: Style.textNormalColor
                        titleBrush: Style.textNormalColor

                        color: Style.axisColor
                        gridLineColor: Style.axisColor
                    }

                    LineSeries {
                        id: blockedSeries
                        name: "Blocked Series"
                        width: 2
                        axisX: axisX
                        axisY: axisY
                        color: Style.metricsBlocked

                        pointsVisible: true
                        pointLabelsVisible: false
                    }

                    LineSeries {
                        id: trafficSeries
                        name: "Traffic Series"
                        width: 2
                        axisX: axisX
                        axisY: axisY
                        color: Style.metricsTraffic

                        pointsVisible: true
                        pointLabelsVisible: false
                    }
                }

                Timer {
                    id: updateTimer
                    interval: 60000 // 1 minuto en ms
                    repeat: true
                    running: false  // Start explicitly after interface is selected

                    property int counter: 0

                    property int maxVisibleValue: 5
                    property var blockedValues: []
                    property var trafficValues: []

                    function updateVisibleMaximum() {
                        let maxValue = 10 // Valor mínimo predeterminado

                        // Encontrar el valor máximo en el rango visible
                        for (let i = 0; i < trafficValues.length; i++) {
                            if (trafficValues[i].x >= axisX.min && trafficValues[i].x <= axisX.max) {
                                maxValue = Math.max(maxValue, blockedValues[i].y, trafficValues[i].y)
                            }
                        }

                        maxValue = Math.ceil(maxValue)
                        // Actualizar el eje Y con el nuevo máximo
                        axisY.max = maxValue
                    }

                    function removeInvisiblePoints() {
                        // Solo conservamos los puntos que están dentro del rango visible
                        // o ligeramente fuera (para evitar problemas de renderizado)
                        let minX = axisX.min - 5

                        // Filtramos arrays de datos para mantener solo los puntos visibles
                        let newBlockedValues = []
                        let newTrafficValues = []

                        for (let i = 0; i < blockedValues.length; i++) {
                            if (blockedValues[i].x >= minX) {
                                newBlockedValues.push(blockedValues[i])
                                newTrafficValues.push(trafficValues[i])
                            }
                        }

                        blockedValues = newBlockedValues
                        trafficValues = newTrafficValues

                        // Ahora actualizamos las series
                        blockedSeries.clear()
                        trafficSeries.clear()

                        for (let i = 0; i < blockedValues.length; i++) {
                            blockedSeries.append(blockedValues[i].x, blockedValues[i].y)
                            trafficSeries.append(trafficValues[i].x, trafficValues[i].y)
                        }
                    }

                    function updateChart(){
                        // Crear nuevos objetos para evitar referencias compartidas
                        let blockedPoint = { x: counter, y: blockedRate }
                        let trafficPoint = { x: counter, y: trafficRate }

                        blockedValues.push(blockedPoint)
                        trafficValues.push(trafficPoint)

                        blockedSeries.append(counter, blockedRate)
                        trafficSeries.append(counter, trafficRate)

                        counter += 5
                        progressBlocked.value = trafficRate > 0 ? blockedRate / trafficRate : 0
                        updateVisibleMaximum()

                        // Desplazar ventana si se supera el límite
                        if (counter > axisX.max) {
                            axisX.min += 5
                            axisX.max += 5
                            removeInvisiblePoints()
                        }

                        if (currentInterfaceId !== "") {
                            saveCurrentInterfaceData()
                        }
                    }

                    onTriggered: {
                        fetchMetrics()
                        updateChart()
                    }
                }
            }
        }

        Rectangle {
            color: Style.windowBackground
            Layout.preferredHeight: 40
            Layout.fillWidth: true

            RowLayout {
                id: grid
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    id: blockedContainer
                    color: "transparent"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 75

                    Text{
                        id: blockedTitle
                        text: "Blocked/min"
                        color: Style.textNormalColor
                        font.pixelSize: 14
                        font.bold:true
                        anchors.left: parent.left
                        anchors.leftMargin: 7.5
                    }

                    ProgressBar {
                        id: progressBlocked
                        value: 0
                        padding: 2
                        anchors.top: blockedTitle.bottom
                        anchors.topMargin: 5
                        anchors.horizontalCenter: blockedContainer.horizontalCenter

                        background: Rectangle {
                            implicitWidth: blockedContainer.width -15
                            implicitHeight: 6
                            color: Style.windowHeader
                            radius: 3
                        }

                        contentItem: Item {
                            implicitWidth: blockedContainer.width -15
                            implicitHeight: 4

                            // Progress indicator for determinate state.
                            Rectangle {
                                width: progressBlocked.visualPosition * parent.width
                                height: parent.height
                                radius: 2
                                color: blockedSeries.color
                                visible: !progressBlocked.indeterminate
                            }

                            // Scrolling animation for indeterminate state.
                            Item {
                                anchors.fill: parent
                                visible: progressBlocked.indeterminate
                                clip: true

                                Row {
                                    spacing: 20

                                    Repeater {
                                        model: progressBlocked.width / 40 + 1

                                        Rectangle {
                                            color: blockedSeries.color
                                            width: 20
                                            height: progressBlocked.height
                                        }
                                    }
                                    XAnimator on x {
                                        from: 0
                                        to: -40
                                        loops: Animation.Infinite
                                        running: progressBlocked.indeterminate
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
