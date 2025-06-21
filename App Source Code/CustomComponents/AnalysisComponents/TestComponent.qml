import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts

Item {
    id: root
    width: 800
    height: 600

    // Modelo de ejemplo para nuestro ListView
    ListModel {
        id: dataModel
        ListElement { categoria: "Enero"; valor: 10 }
        ListElement { categoria: "Febrero"; valor: 15 }
        ListElement { categoria: "Marzo"; valor: 8 }
        ListElement { categoria: "Abril"; valor: 12 }
        ListElement { categoria: "Mayo"; valor: 20 }
    }



    // Gráfico de barras
    ChartView {
        id: chartView
        anchors.fill: parent
        antialiasing: true
        animationOptions: ChartView.SeriesAnimations
        theme: ChartView.ChartThemeBlueCerulean

        BarSeries {
            id: barSeries
            axisX: BarCategoryAxis {
                id: axisX
            }
            axisY: ValuesAxis {
                id: axisY
                min: 0
                max: 25
            }
        }
    }

    // Función para actualizar el gráfico según los datos del ListView
    function actualizarGrafico() {
        // Limpiar series y categorías previas
        barSeries.clear()

        // Crear un nuevo conjunto de barras
        var barSet = barSeries.append("Data", [])

        // Obtener categorías
        var categorias = []

        // Añadir datos desde el modelo al gráfico
        for (var i = 0; i < dataModel.count; i++) {
            var item = dataModel.get(i)
            categorias.push(item.categoria)
            barSet.append(item.valor)
        }

        // Actualizar categorías en el eje X
        axisX.categories = categorias

        // Actualizar el rango del eje Y si es necesario
        var maxValor = 0
        for (var j = 0; j < dataModel.count; j++) {
            maxValor = Math.max(maxValor, dataModel.get(j).valor)
        }
        axisY.max = Math.ceil(maxValor * 1.2) // 20% más alto que el valor máximo
    }

    // Actualizar el gráfico al inicio
    Component.onCompleted: {
        actualizarGrafico()
    }
}
