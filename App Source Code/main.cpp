#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <Network/protocolmodel.h>
#include "Filter/flagmodel.h"
#include "Filter/protpiemodel.h"
#include "logtablemodel.h"
#include "TagHelper.h"
#include "networkinterfacesmodel.h"

//Network
#include "Network/selectionmanager.h"
#include "Network/interfacemodel.h"
#include "Network/rulemodel.h"
#include "Network/rulesetmodel.h"

#include <fstream>
#include <QMessageBox>
#include <QStyleHints>
#include <QStyleFactory>
uint64_t getBootTimeSec(){
    std::ifstream statFile("/proc/stat");
    std::string line;
    while (std::getline(statFile, line)) {
        if (line.rfind("btime", 0) == 0) { // comienza con "btime"
            return std::stoull(line.substr(6));
        }
    }
    return 0;
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/icons/icon.png"));
    if (getuid() != 0) {
        QMessageBox::critical(nullptr, "Permission error",
                              "This application must be run as an administrator.\n"
                              "Use: sudo ./app_name");
        return 1;
    }
    QQmlApplicationEngine engine;
    QString dirPath = QCoreApplication::applicationDirPath() + "/data";;
    const auto scheme = QGuiApplication::styleHints()->colorScheme();
    QString schemeString;
    if (scheme == Qt::ColorScheme::Dark) {
        schemeString = "dark";
    } else {
        schemeString = "light";
    }

    engine.rootContext()->setContextProperty("systemColorScheme", schemeString);
    engine.rootContext()->setContextProperty("dirPath", dirPath);

    uint64_t btime_sec = getBootTimeSec();
    engine.rootContext()->setContextProperty("bootTime", QString::number(btime_sec));

    time_t now = time(nullptr);

    // Hora local
    std::tm local_tm = *std::localtime(&now);
    local_tm.tm_isdst = -1;  // Muy importante
    time_t local_time = mktime(&local_tm);

    // Hora UTC
    std::tm gm_tm = *std::gmtime(&now);
    gm_tm.tm_isdst = -1;  // Aunque GMT no cambia, para estar seguros
    time_t gm_time = mktime(&gm_tm);

    int offset_seconds = static_cast<int>(difftime(local_time, gm_time));
    int offset_hours = offset_seconds / 3600;

    qDebug() << "Local: " << asctime(&local_tm)
              << "UTC:   " << asctime(&gm_tm)
              << "Offset (hours): " << offset_hours << "\n";

    engine.rootContext()->setContextProperty("gmtOffset", offset_hours);

    //LOG TABLE
    LogTableModel *logModel = new LogTableModel(&app);

    engine.rootContext()->setContextProperty("logTableModel", logModel);

    //new networks
    InterfaceModel interfaceModel;
    RulesetModel rulesetModel;
    RuleModel rulesModel;

    engine.rootContext()->setContextProperty("interfaceModel", &interfaceModel);
    engine.rootContext()->setContextProperty("rulesetModel", &rulesetModel);
    engine.rootContext()->setContextProperty("rulesModel", &rulesModel);

    SelectionManager selectionManager;
    engine.rootContext()->setContextProperty("SelectionManager", &selectionManager);

    ProtocolModel protocolModel = new ProtocolModel(&app);
    engine.rootContext()->setContextProperty("protocolModel", &protocolModel);
    //Register
    qmlRegisterType<TagHelper>("TagEnum", 1, 0, "TagHelper");
    qmlRegisterType<NetworkInterfacesModel>("NetworkInterfacesModel", 1, 0, "NetworkInterfacesModel");

    //Analysis
    FlagModel flagModel;
    engine.rootContext()->setContextProperty("flagModel", &flagModel);

    ProtPieModel protPieModel;
    engine.rootContext()->setContextProperty("protPieModel", &protPieModel);

    IpHitsModel ipHitsModel;
    engine.rootContext()->setContextProperty("ipHitsModel", &ipHitsModel);

    PortHitsModel portHitsModel;
    engine.rootContext()->setContextProperty("portHitsModel", &portHitsModel);

    PacketDistModel packetDistModel;
    engine.rootContext()->setContextProperty("packetDistModel", &packetDistModel);

    RuleHitsModel ruleHitsModel;
    engine.rootContext()->setContextProperty("ruleHitsModel", &ruleHitsModel);

    BlockedFromFilterModel blockedIpsModel;
    engine.rootContext()->setContextProperty("blockedIpsModel", &blockedIpsModel);

    //Metrics (same class differents models)
    IpHitsModel metricsIpHitsModel;
    engine.rootContext()->setContextProperty("metricsIpHitsModel", &metricsIpHitsModel);

    RuleHitsModel metricsRuleHitsModel;
    engine.rootContext()->setContextProperty("metricsRuleHitsModel", &metricsRuleHitsModel);

    ProtPieModel metricsProtStatsModel;
    engine.rootContext()->setContextProperty("metricsProtStatsModel", &metricsProtStatsModel);
    //Connect
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("NetFilterWin", "Main");

    QObject::connect(&app, &QCoreApplication::aboutToQuit, [&]() {
        interfaceModel.cleanup();
    });
    return app.exec();
}


