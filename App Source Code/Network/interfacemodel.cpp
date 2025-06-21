#include "interfacemodel.h"
#include "exportimporthelper.h"
InterfaceModel::InterfaceModel(QObject *parent) : QAbstractListModel(parent) {
    fetchNetworkInterfaces();
    //Timer actions
    fetchIfTimer = new QTimer(this);
    fetchHitsTimer =new QTimer(this);
    connect(fetchIfTimer, &QTimer::timeout, this, &InterfaceModel::updateInterfaces);
    fetchIfTimer->start(5000);

    connect(fetchHitsTimer, &QTimer::timeout, this, &InterfaceModel::updateHits);
    fetchHitsTimer->start(10000);
}

int InterfaceModel::rowCount(const QModelIndex &parent) const{
    Q_UNUSED(parent);
    return interfaces.size();
}

QVariant InterfaceModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= interfaces.size()) {
        return QVariant();
    }
    const auto &iface = interfaces.at(index.row());

    switch (role) {
        case NameRole: return iface.name;
        case IsOnRole: return iface.isOn;
        case RulesetsRole: return QVariant::fromValue(iface.rulesets);
        default: return QVariant();
    }
}

QHash<int, QByteArray> InterfaceModel::roleNames() const {
    return { {NameRole, "name"}, {IsOnRole, "isOn"}, {RulesetsRole, "rulesets"} };
}

void InterfaceModel::fetchNetworkInterfaces() {
    beginResetModel();
    interfaces.clear();

    struct ifaddrs* ptr_ifaddrs = nullptr;
    QVector<Interface> newInterfaces;

    if (getifaddrs(&ptr_ifaddrs) == 0) {
        for(
            struct ifaddrs* ptr_entry = ptr_ifaddrs;
            ptr_entry != nullptr;
            ptr_entry = ptr_entry->ifa_next
            ){
            if (ptr_entry->ifa_addr == nullptr) continue;

            QString name = ptr_entry->ifa_name;
            bool isActive = (ptr_entry->ifa_addr->sa_family == AF_INET);

            auto found = std::find_if(newInterfaces.begin(), newInterfaces.end(), [&name](const Interface& iface) {
                return iface.name == name;
            });

            if (found == newInterfaces.end()) {
                newInterfaces.append({name, isActive});
            } else if (!found->isOn && isActive) {
                found->isOn = true;
            }
        }
        freeifaddrs(ptr_ifaddrs);
    }
    if (newInterfaces != interfaces) {
        //beginResetModel();
        interfaces = newInterfaces;
        for(auto& iface: newInterfaces){
            auto* manager = new FilteringManager(iface.name);
            managers.insert(iface.name,manager);
        }
    }
    endResetModel();
}
void InterfaceModel::updateHits(){
    beginResetModel();
    for(Interface &inter: interfaces){
        for(Ruleset &rs: inter.rulesets){
            for(Rule &rule: rs.rules){
                rule.hits = managers[inter.name]->getHits(rule);
            }
        }
    }
    emit rulesAdded();
    endResetModel();
}

void InterfaceModel::updateInterfaces() {
    beginResetModel();

    struct ifaddrs* ptr_ifaddrs = nullptr;
    QVector<Interface> newInterfaces;

    if (getifaddrs(&ptr_ifaddrs) == 0) {
        for(
            struct ifaddrs* ptr_entry = ptr_ifaddrs;
            ptr_entry != nullptr;
            ptr_entry = ptr_entry->ifa_next
            ){
            if (ptr_entry->ifa_addr == nullptr) continue;

            QString name = ptr_entry->ifa_name;
            bool isActive = (ptr_entry->ifa_addr->sa_family == AF_INET);

            auto found = std::find_if(newInterfaces.begin(), newInterfaces.end(), [&name](const Interface& iface) {
                return iface.name == name;
            });

            if (found == newInterfaces.end()) {
                newInterfaces.append({name, isActive});
            } else if (!found->isOn && isActive) {
                found->isOn = true;
            }
        }
        freeifaddrs(ptr_ifaddrs);
    }
    for(auto& iface: newInterfaces){
        interfaces[getIndex(iface.name )].isOn = iface.isOn;
    }
    endResetModel();
}

void InterfaceModel::addRuleSetToInterface(const QString &interfaceName, const QVariantMap &rulesetMap) {
    int inter = getIndex(interfaceName);
    QString newName = rulesetMap.value("name").toString();
    if(containsRuleset(inter,newName)){
        //Emitimos un log error

        emit errorLogRuleset("Failed to add Ruleset: Name already exists",interfaceName);
    }else {
        Ruleset newSet;
        newSet.name = newName;
        newSet.isActive = rulesetMap.value("isActive").toBool();
        QVariantList rulesList = rulesetMap.value("rules").toList();
        for (const QVariant &ruleVar : rulesList) {
            QVariantMap ruleMap = ruleVar.toMap();
            Rule rule;
            rule.name = ruleMap.value("name").toString();
            rule.ip = ruleMap.value("ip").toString();
            rule.protocol = ruleMap.value("protocol").toString();
            rule.hits = ruleMap.value("hits").toInt();
            rule.status = ruleMap.value("status").toBool();

            QVariantList portList = ruleMap.value("ports").toList();

            for (const QVariant &val : portList) {
                rule.ports.append(val.toInt());
            }
            newSet.rules.append(rule);
        }

        Interface &iface = interfaces[inter];
        if (iface.name == interfaceName) {
            beginResetModel();
            iface.rulesets.append(newSet);
            endResetModel();
            emit rulesetAdded();

            return;
        }
    }
}

void InterfaceModel::addRuleToRuleset(const QString &interfaceName, const QString &rulesetName, const QVariantMap &ruleData){
    for(Interface &inter: interfaces){
        if(inter.name == interfaceName){
            for(Ruleset &rs : inter.rulesets){
                if(rs.name == rulesetName){
                    Rule newRule;
                    newRule.name = ruleData.value("name").toString();
                    newRule.ip = ruleData.value("ip").toString();
                    newRule.protocol = ruleData.value("protocol").toString();
                    newRule.hits = ruleData.value("hits").toInt();
                    newRule.status = ruleData.value("status").toBool();
                    newRule.id = UniqueIdProvider::getId();

                    QVariantList portList = ruleData.value("ports").toList();

                    for (const QVariant &val : portList) {
                        newRule.ports.append(val.toInt());
                    }

                    rs.rules.append(newRule);
                    emit rulesAdded();
                    managers[interfaceName]->insertRule(rs,newRule);
                    emit logEmited(RULE_CREATED,"Rule "+ newRule.name +" added to ruleset "+rs.name,inter.name);
                    return;
                }
            }
        }
    }
}

void InterfaceModel::editRulesetOnInterface(const int ifPreviusIndex,const int ifNewIndex, const QString &rsLastName, const QVariantMap &rulesetMap){
    Interface &inter = interfaces[ifPreviusIndex];

    if (ifPreviusIndex == ifNewIndex) {
        // Misma interfaz, cambio de propiedades
        for (Ruleset &rs : inter.rulesets) {
            if (rs.name == rsLastName) {
                QString newName = rulesetMap.value("name").toString();
                if(newName==rsLastName){
                    rs.name = newName;
                    rs.isActive = rulesetMap.value("isActive").toBool();
                    emit rulesetAdded();
                    return;

                }else{
                    if(containsRuleset(ifPreviusIndex,newName)){
                        emit errorLogRuleset("Failed to edit Ruleset "+ rsLastName +": Name already exists",inter.name);
                        return;
                    }else {
                        rs.name = newName;
                        rs.isActive = rulesetMap.value("isActive").toBool();
                        emit rulesetAdded();
                        return;
                    }
                }
            }
        }
    } else {
        // Distinta interfaz, mover ruleset
        for (int i = inter.rulesets.size() - 1; i >= 0; --i) {
            if (inter.rulesets[i].name == rsLastName) {
                Ruleset rs = inter.rulesets[i]; // copia antes de borrar
                QString newName = rulesetMap.value("name").toString();

                if(containsRuleset(ifNewIndex,newName)){
                    //Ya hay una con ese nombre, log error
                    emit errorLogRuleset("Failed to edit Ruleset "+ rsLastName +": Name already exists",inter.name);
                    return;
                }else {
                    rs.name = newName;
                    rs.isActive = rulesetMap.value("isActive").toBool();

                    interfaces[ifNewIndex].rulesets.append(rs);
                    inter.rulesets.removeAt(i);

                    emit rulesetAdded();
                    return;
                }
            }
        }
    }
}

void InterfaceModel::editRuleOnRuleset(const int ifIndex,const int rsIndex, const QString &ruleLastName, const QVariantMap &ruleMap){
    Interface &inter = interfaces[ifIndex];
    Ruleset &rs = inter.rulesets[rsIndex];
    for(Rule &rule : rs.rules){
        managers[inter.name]->deleteRule(rule);
        rule.name = ruleMap.value("name").toString();
        rule.ip = ruleMap.value("ip").toString();
        rule.protocol = ruleMap.value("protocol").toString();
        rule.status = ruleMap.value("status").toBool();

        QVariantList portList = ruleMap.value("ports").toList();
        rule.ports.clear();
        for (const QVariant &val : portList) {
            rule.ports.append(val.toInt());
        }
        managers[inter.name]->insertRule(rs,rule);
        emit rulesAdded();
        return;
    }
}



QVector<Ruleset> InterfaceModel::getRulesetsForInterface(int index) const {
    if (index >= 0 && index < interfaces.size()) {
        return interfaces.at(index).rulesets;
    }
    return QVector<Ruleset>();
}

QString InterfaceModel::getInterfaceByIndex(const int index) const {
    return interfaces.at(index).name;
}

int InterfaceModel::getIndex(QString name) const {
    for (int i=0;i<interfaces.size();i++){
        if(interfaces.at(i).name==name){
            return i;
        }
    }
    return -1;
}

int InterfaceModel::getIndexRule(int interIndex, int rulesetIndex, QString ruleName) const {
    Ruleset rs = interfaces[interIndex].rulesets[rulesetIndex];
    for (int i=0;i<rs.rules.size();i++){
        if(rs.rules.at(i).name==ruleName){
            return i;
        }
    }
    return -1;
}

int InterfaceModel::getIndexRuleset(int interIndex, QString rulesetName) const{
    Interface inter = interfaces[interIndex];
    for (int i=0;i < inter.rulesets.size();i++){
        if(inter.rulesets.at(i).name==rulesetName){
            return i;
        }
    }
    return -1;
}

void InterfaceModel::removeRuleset(const int ifIndex, const int rsIndex){
    Interface &inter = interfaces[ifIndex];
    //Copia
    Ruleset rs = inter.rulesets[rsIndex];
    for(Rule rule : rs.rules){
        managers[inter.name]->deleteRule(rule);
        UniqueIdProvider::releaseId(rule.id);
    }
    inter.rulesets.removeAt(rsIndex);
    emit rulesetAdded();
}

void InterfaceModel::removeRule(const int ifIndex, const int rsIndex, const int ruleIndex) {
    Interface &inter = interfaces[ifIndex];
    Ruleset &rs = inter.rulesets[rsIndex];
    //Copia
    Rule rule = rs.rules.at(ruleIndex);
    managers[inter.name]->deleteRule(rule);
    rs.rules.removeAt(ruleIndex);
    UniqueIdProvider::releaseId(rule.id);
    emit rulesAdded();
    emit logEmited(RULE_DELETED, "Rule "+ rule.name +" removed from ruleset "+rs.name,inter.name);
}

void InterfaceModel::turnOnOffRuleOnRuleset(const int ifIndex,const int rsIndex, const QString &name){
    Interface &inter = interfaces[ifIndex];
    Ruleset &rs = inter.rulesets[rsIndex];
    for(Rule &rule : rs.rules){
        if(rule.name==name){
            rule.status = !rule.status;
            managers[inter.name]->insertRule(rs,rule);
            emit rulesAdded();
            return;
        }
    }
}

void InterfaceModel::turnOnOffRulesetOnInterface(const int ifIndex,const QString &name){
    Interface &inter = interfaces[ifIndex];
    for(Ruleset &rs : inter.rulesets){
        if(rs.name==name){
            rs.isActive=!rs.isActive;
            for (Rule &rule : rs.rules) {
                managers[inter.name]->insertRule(rs,rule);
            }
            emit rulesAdded();
            return;
        }
    }
}

bool InterfaceModel::containsRuleset(const int interfaceIndex,const QString &name) const{
    Interface inter = interfaces[interfaceIndex];
    for(Ruleset ruleset : inter.rulesets){
        if(ruleset.name == name){
            return true;
        }
    }
    return false;
}
void InterfaceModel::exportData() {
    qDebug() << "Exporting data";
    ExportImportHelper::exportRulesToJson(interfaces);
    emit logEmited(INFO, "New exported file added to folder /data ", "App");
}

void InterfaceModel::importData(const QString &filePath) {
    if (!filePath.isEmpty()) {
        beginResetModel();
        QVector<Interface> importedIf = ExportImportHelper::importRulesFromJson(filePath);

        for(Interface inter : importedIf){
            int index = getIndex(inter.name);

            if(index!=-1){
                Interface &old_interface = interfaces[index];
                old_interface.rulesets.append(inter.rulesets);
                for(Ruleset rs : inter.rulesets){
                    for(Rule rule : rs.rules){
                        managers[inter.name]->insertRule(rs, rule);
                    }
                }
            }
        }

        endResetModel();
        emit logEmited(INFO, "Imported data from file:  "+filePath, "App");
        emit rulesetAdded();
        emit rulesAdded();
    } else {
        emit logEmited(ERROR, "Import process canceled", "App");
    }
}
void InterfaceModel::dumpAll() {
    for(Interface inter : interfaces){
        managers[inter.name]->dumpAll();
    }
}

void InterfaceModel::cleanup(){
    for(auto& manager : managers){
        manager->cleanup();
    }
}

QString InterfaceModel::getIpByRuleId(uint64_t id, QString if_name) {
    int index = getIndex(if_name);
    QVector<Ruleset> rulesets = getRulesetsForInterface(index);
    for(Ruleset rs : rulesets){
        for(Rule rule : rs.rules){
            if(rule.id == id){
                return rule.ip;
            }
        }
    }
    return "";
}

//Analysis
QList<Flag> InterfaceModel::getTcpFlagByInterface(QString if_name) {
    return managers[if_name]->fetchTcpFlags();
}

QList<Prot> InterfaceModel::getProtStatsByInterface(QString if_name) {
    return managers[if_name]->fetchProtStats();
}

QList<IpHit> InterfaceModel::getIpHitsByInterface(QString if_name) {
    return managers[if_name]->fetchIpHits();
}

QList<PortHit> InterfaceModel::getPortHitsByInterface(QString if_name) {
    return managers[if_name]->fetchPortHits();
}

QList<PacketDist> InterfaceModel::getPacketDistributionByInterface(QString if_name) {
    return managers[if_name]->fetchPacketDist();
}

QList<RuleHit> InterfaceModel::getRuleHitsByInterface(QString if_name){
    return managers[if_name]->fetchRuleHits();
}

QList<BlockedIp> InterfaceModel::getBlockedIpsByInterface(QString if_name) {
    return managers[if_name]->fetchBlockedIps();
}
