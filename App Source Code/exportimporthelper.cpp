#include "exportimporthelper.h"

namespace ExportImportHelper {
    namespace {
        QString getDefaultExportPath() {
            return "/filter/exports";
        }
    }

    QJsonObject ruleToJson(const Rule& rule) {
        QJsonObject json;
        json["name"] = rule.name;
        json["ip"] = rule.ip;
        json["protocol"] = rule.protocol;
        json["status"] = rule.status;
        json["hits"] = rule.hits;
        json["id"] = QString::number(rule.id);

        QJsonArray portArray;
        for(int port : rule.ports){
            portArray.append(port);
        }
        json["ports"] = portArray;

        return json;
    }

    QJsonObject rulesetToJson(const Ruleset& ruleset) {
        QJsonObject json;
        json["name"] = ruleset.name;
        json["isActive"] = ruleset.isActive;

        QJsonArray ruleArray;
        for(Rule rule : ruleset.rules){
            ruleArray.append(ruleToJson(rule));
        }
        json["rules"] = ruleArray;

        return json;
    }

    QJsonObject interfaceToJson(const Interface& interface) {
        QJsonObject json;
        json["name"] = interface.name;
        json["isOn"] = interface.isOn;

        QJsonArray rulesetArray;
        for(Ruleset ruleset : interface.rulesets){
            rulesetArray.append(rulesetToJson(ruleset));
        }
        json["rulesets"] = rulesetArray;

        return json;
    }

    void exportRulesToJson(QVector<Interface> interfaces) {

        QJsonArray interfacesArray;
        for(Interface interface : interfaces){
            interfacesArray.append(interfaceToJson(interface));
        }
        QJsonDocument doc(interfacesArray);

        QString exportPath = getDefaultExportPath();

        QDir dir(exportPath);
        if (!dir.exists()) {
            if (!dir.mkpath(".")) {
                qWarning() << "No se pudo crear la carpeta:" << exportPath;
            }else{
                QProcess process;
                process.start("chmod", QStringList() << "777" << exportPath);
                process.waitForFinished();
            }
        }


        QString timestamp = QString::number(QDateTime::currentSecsSinceEpoch());
        QString filename = timestamp + ".json";
        QString filePath = exportPath + "/" + filename;
        QFile file(filePath);
        if (file.open(QIODevice::WriteOnly)) {
            file.write(doc.toJson(QJsonDocument::Indented));
            file.close();

            QProcess process;
            process.start("chmod", QStringList() << "666" << filePath);
            process.waitForFinished();
        } else {
            qWarning() << "Error saving the file" << filePath;
        }
    }

    Rule jsonToRule(const QJsonObject& json){
        Rule rule;
        rule.name = json["name"].toString();
        rule.ip = json["ip"].toString();
        rule.protocol = json["protocol"].toString();
        rule.status = json["status"].toBool();
        //rule.hits = json["hits"].toInt();
        rule.hits = 0;
        //rule.id = json["id"].toString().toLongLong(); // Por manejo de IDs esto no es correcto
        rule.id = UniqueIdProvider::getId();

        QJsonArray portArray = json["ports"].toArray();
        for (const QJsonValue& value : portArray) {
            rule.ports.append(value.toInt());
        }

        return rule;
    }

    Ruleset jsonToRuleset(const QJsonObject& json){
        Ruleset ruleset;
        ruleset.name = json["name"].toString();
        ruleset.isActive = json["isActive"].toBool();

        QJsonArray ruleArray = json["rules"].toArray();
        for (const QJsonValue& value : ruleArray) {
            ruleset.rules.append(jsonToRule(value.toObject()));
        }

        return ruleset;
    }

    Interface jsonToInterface(const QJsonObject& json){
        Interface interface;
        interface.name = json["name"].toString();
        interface.isOn = json["isOn"].toBool();

        QJsonArray rulesetArray = json["rulesets"].toArray();
        for (const QJsonValue& value : rulesetArray) {
            interface.rulesets.append(jsonToRuleset(value.toObject()));
        }

        return interface;
    }
    QVector<Interface> importRulesFromJson(const QString& filePath) {
        QVector<Interface> interfaces;

        QFile file(filePath);
        if (!file.open(QIODevice::ReadOnly)) {
            qWarning() << "No se pudo abrir el archivo:" << filePath;
            return interfaces;
        }

        QByteArray data = file.readAll();
        file.close();

        QJsonDocument doc = QJsonDocument::fromJson(data);
        if (doc.isArray()) {
            QJsonArray interfacesArray = doc.array();
            for (const QJsonValue& value : interfacesArray) {
                interfaces.append(jsonToInterface(value.toObject()));
            }
        } else {
            qWarning() << "El archivo no contiene un array JSON válido";
        }

        return interfaces;
    }
}
