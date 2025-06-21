#ifndef EXPORTIMPORTHELPER_H
#define EXPORTIMPORTHELPER_H


#include "Network/rulemodel.h"
#include "Network/rulesetmodel.h"
#include "Network/interfacemodel.h"
#include <QString>
#include <QJsonObject>
#include <QJsonArray>
#include <QCoreApplication>
#include <QJsonDocument>
#include <QDir>
#include <QFile>
#include <QProcess>

class InterfaceModel;
namespace ExportImportHelper {

    QString getExportPath();
    void setExportPath(const QString& path);

    QJsonObject ruleToJson(const Rule& rule);
    QJsonObject rulesetToJson(const Ruleset& ruleset);
    QJsonObject interfaceToJson(const Interface& interface);

    Rule jsonToRule(const QJsonObject& json);
    Ruleset jsonToRuleset(const QJsonObject& json);
    Interface jsonToInterface(const QJsonObject& json);

    void exportRulesToJson(QVector<Interface> interfaces);
    QVector<Interface> importRulesFromJson(const QString& filePath);
}

#endif // EXPORTIMPORTHELPER_H
