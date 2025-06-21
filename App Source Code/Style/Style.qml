pragma Singleton
import QtQuick

QtObject {
    property string scheme: "dark"
    // Propiedades simplificadas para la ventana
    property color windowHeader: "#ebeef2"
    property color windowDarkHeader: "#2c3e50"
    property color windowBackground: "#ffffff"
    property color windowSelected: "#d1d8e0"
    property color windowHover: Qt.darker(windowBackground)
    property color menuSelected: "#e8ebed"

    // Propiedades simplificadas para el borde
    property int borderNormalWidth: 1
    property int borderBigWidth: 3
    property color borderNormalColor: "#d1d5db"

    // Propiedades simplificadas para el texto
    property string textTitleFont: "Arial"
    property int textTitleSize: 18
    property bool textTitleBold: true
    property color textTitleColor: "#2c3e50"
    property color textTitleLight: "#ffffff"

    property string textSubtitleFont: "Arial"
    property int textSubtitleSize: 12
    property bool textSubtitleBold: true
    property color textSubtitleColor: "#2c3e50"

    property string textNormalFont: "Arial"
    property int textNormalSize: 16
    property color textNormalColor: "#2c3e50"
    property color textNormalMuted: "#64748b"

    property string textMenuFont: "Arial"
    property int textMenuSize: 12
    property color textMenuColor: "#4b5563"
    property color textMenuActive: "#2c3e50"

    // Propiedades simplificadas para el itemList
    property color itemListBackground: "#ffffff"
    property color itemListHover: Qt.darker(itemListBackground)

    property color netIfHoverColor: "#77c4f7"
    property color netIfHoverFill: "#f2f9fc"
    property color netIfColor: "#217dbb"
    property color netIfFill: "#ccecff"

    property color ruleIfColor: "#e74c3c"
    property color ruleIfFill: "#fff1f0"
    property color ruleIfHoverColor: "#f76e62"
    property color ruleIfHoverFill: "#fff7f6"

    // Propiedades simplificadas para la tabla
    property color tableHeader: "#ebeef2"
    property color tableRowA: "#f8fafc"
    property color tableRowB: "#ffffff"

    // Propiedades simplificadas para el estado de la red
    property color networkEnabled: "#27ae60"
    property color networkDisabled: "#7f8c8d"
    property color networkBlocked: "#e74c3c"

    // Propiedades simplificadas para métricas
    property color metricsAllowed: "#3498db"
    property color metricsBlocked: "#e74c3c"
    property color metricsTraffic: "#3498db"

    property color tagOffFill: "#ffffff"
    property color tagOffBorder: "#d1d5db"
    property color tagOffText: "#94a3b8"

    property var tagColors: ({
        "ERROR": {"fill": "#ffeeee", "border": "#e74c3c" },
        "RULE CREATED": { "fill": "#e6fffa", "border": "#27ae60" },
        "RULE DELETED": { "fill": "#f8f0ed", "border": "#8b4513" },
        //"ATTEMPT": { "fill": "#fdf5e6", "border": "#f39c12" },
        "INFO": { "fill": "#e6f7ff", "border": "#3498db" }
    })
    property var pieChartColors: ({
        "TCP": "#3498db",
        "UDP": "#2ecc71",
        "ICMP": "#e74c3c",
        "Other": "#f39c12"
    })

    property color axisColor: "#c1c5cb"
    property color distributionBarsColors: "#a0d2eb"

    property var flagsColors: ({
        "FIN": "#ff6b6b",
        "SYN": "#ff9f43",
        "RST": "#feca57",
        "PSH": "#1dd1a1",
        "ACK": "#54a0ff",
        "URG": "#5f27cd",
        "ECE": "#a55eea",
        "CWR": "#fd79a8"
    })
    property color portProgressBar : "#3498db"
    property color ruleProgressBar : "#d1c4e9"
    property color autoBlocked: "#ff7d70"

    function getTagFillColor(tagType) {
        return tagColors[tagType] ? tagColors[tagType].fill : "white";
    }

    function getTagBorderColor(tagType) {
        return tagColors[tagType] ? tagColors[tagType].border : "white";
    }

    function getPieColor(protocol) {
        return pieChartColors[protocol] ? pieChartColors[protocol] : "#bdc3c7"; // Gris claro como default
    }

    function setLightTheme(){
        scheme = "light"
        windowHeader = "#ebeef2"
        windowDarkHeader = "#2c3e50"
        windowBackground = "#ffffff"
        windowSelected = "#d1d8e0"
        windowHover = Qt.darker(windowHeader)
        menuSelected = "#e8ebed"

       // Propiedades simplificadas para el borde
        borderNormalWidth = 1
        borderBigWidth = 3
        borderNormalColor = "#d1d5db"

       // Propiedades simplificadas para el texto
        textTitleFont = "Arial"
        textTitleSize = 18
        textTitleBold = true
        textTitleColor = "#2c3e50"
        textTitleLight = "#ffffff"

        textSubtitleFont = "Arial"
        textSubtitleSize = 12
        textSubtitleBold = true
        textSubtitleColor = "#2c3e50"

        textNormalFont = "Arial"
        textNormalSize = 16
        textNormalColor = "#2c3e50"
        textNormalMuted = "#64748b"

        textMenuFont = "Arial"
        textMenuSize = 12
        textMenuColor = "#4b5563"
        textMenuActive = "#2c3e50"

       // Propiedades simplificadas para el itemList
        itemListBackground = "#ffffff"
        itemListHover = Qt.darker(itemListBackground)

        netIfHoverColor = "#77c4f7"
        netIfHoverFill = "#f2f9fc"
        netIfColor = "#217dbb"
        netIfFill = "#ccecff"

        ruleIfColor = "#e74c3c"
        ruleIfFill = "#fff1f0"
        ruleIfHoverColor = "#f76e62"
        ruleIfHoverFill = "#fff7f6"

       // Propiedades simplificadas para la tabla
        tableHeader = "#ebeef2"
        tableRowA = "#f8fafc"
        tableRowB = "#ffffff"

       // Propiedades simplificadas para el estado de la red
        networkEnabled = "#27ae60"
        networkDisabled = "#7f8c8d"
        networkBlocked = "#e74c3c"

       // Propiedades simplificadas para métricas
        metricsAllowed = "#3498db"
        metricsBlocked = "#e74c3c"

        tagOffFill = "#ffffff"
        tagOffBorder = "#d1d5db"
        tagOffText = "#94a3b8"

        tagColors = ({
             "ERROR": {"fill": "#ffeeee", "border": "#e74c3c" },
             "RULE CREATED": { "fill": "#e6fffa", "border": "#27ae60" },
             "RULE DELETED": { "fill": "#f8f0ed", "border": "#8b4513" },
             //"ATTEMPT": { "fill": "#fdf5e6", "border": "#f39c12" },
             "INFO": { "fill": "#e6f7ff", "border": "#3498db" }
        })

        axisColor = "#c1c5cb"
    }

    function setDarkTheme() {
        // Main window colors
        scheme = "dark"
        windowHeader = "#1a1f26"
        windowDarkHeader = "#151920"
        windowBackground = "#232830"
        windowSelected = "#2c3e50"
        windowHover = Qt.darker(windowHeader)
        menuSelected = "#1e2228"

        // Border properties
        borderNormalWidth = 1
        borderBigWidth = 3
        borderNormalColor = "#151920"

        // Text properties - titles
        textTitleFont = "Arial"
        textTitleSize = 18
        textTitleBold = true
        textTitleColor = "#e0e0e0"
        textTitleLight = "#e0e0e0"

        textSubtitleFont = "Arial"
        textSubtitleSize = 12
        textSubtitleBold = true
        textSubtitleColor = "#e0e0e0"

        textNormalFont = "Arial"
        textNormalSize = 16
        textNormalColor = "#e0e0e0"
        textNormalMuted = "#a0a0a0"

        textMenuFont = "Arial"
        textMenuSize = 12
        textMenuColor = "#a0a0a0"
        textMenuActive = "#e0e0e0"

        // Item list properties
        itemListBackground = "#232830"
        itemListHover = Qt.darker(itemListBackground)

        netIfHoverColor = "#77c4f7"
        netIfHoverFill = "#1e2228"
        netIfColor = "#3498db"
        netIfFill = "#151920"

        ruleIfColor = "#e74c3c"
        ruleIfFill = "#151920"
        ruleIfHoverColor = "#f76e62"
        ruleIfHoverFill = "#1a1f26"

        // Table properties
        tableHeader = "#151920"
        tableRowA = "#1a1f26"
        tableRowB = "#232830"

        // Network status properties
        networkEnabled = "#27ae60"
        networkDisabled = "#7f8c8d"
        networkBlocked = "#e74c3c"

        // Metrics properties
        metricsAllowed = "#3498db"
        metricsBlocked = "#e74c3c"

        tagOffFill = "#232830"
        tagOffBorder = "#445566"
        tagOffText = "#a0a0a0"

        // Tag colors for different statuses
        tagColors = ({
            "ERROR": {"fill": "#331111", "border": "#e74c3c" },
            "RULE CREATED": { "fill": "#113322", "border": "#27ae60" },
            "RULE DELETED": { "fill": "#332211", "border": "#8b4513" },
            //"ATTEMPT": { "fill": "#332200", "border": "#f39c12" },
            "INFO": { "fill": "#112233", "border": "#3498db" }
        })

        axisColor = "#11141a"
    }
}
