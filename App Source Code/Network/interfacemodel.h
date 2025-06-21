#ifndef INTERFACEMODEL_H
#define INTERFACEMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QString>
#include <QTimer>

#include <QDebug>
#include <QVariantMap>
#include <QVariantList>

#include "Filter/filteringmanager.h"
#include "Network/uniqueidprovider.h"
#include "rulesetmodel.h"
#include "logtablemodel.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <netinet/in.h>

struct Interface {
    QString name;
    bool isOn;
    QVector<Ruleset> rulesets;
    bool operator==(const Interface& other) const {
        return name == other.name && isOn == other.isOn;
    }
};

class InterfaceModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        IsOnRole,
        RulesetsRole
    };

    explicit InterfaceModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addRuleSetToInterface(const QString &interfaceName, const QVariantMap &rulesetMap);
    Q_INVOKABLE void addRuleToRuleset(const QString &interfaceName, const QString &rulesetName, const QVariantMap &ruleData);
    Q_INVOKABLE void editRulesetOnInterface(const int ifPreviusIndex,const int ifNewIndex, const QString &rsLastName, const QVariantMap &rulesetMap);
    Q_INVOKABLE void editRuleOnRuleset(const int ifIndex,const int rsIndex, const QString &ruleLastName, const QVariantMap &ruleMap);

    Q_INVOKABLE QVector<Ruleset> getRulesetsForInterface(int index) const;
    Q_INVOKABLE QString getInterfaceByIndex(const int index) const;

    Q_INVOKABLE int getIndex(QString name) const;
    Q_INVOKABLE int getIndexRule(int interIndex, int rulesetIndex, QString ruleName) const;
    Q_INVOKABLE int getIndexRuleset(int interIndex, QString rulesetName) const;

    Q_INVOKABLE void removeRuleset(const int ifIndex, const int rsIndex);
    Q_INVOKABLE void removeRule(const int ifIndex, const int rsIndex, const int ruleIndex);

    Q_INVOKABLE void turnOnOffRuleOnRuleset(const int ifIndex,const int rsIndex, const QString &name);
    Q_INVOKABLE void turnOnOffRulesetOnInterface(const int ifIndex,const QString &name);

    Q_INVOKABLE void exportData();
    Q_INVOKABLE void importData(const QString &filePath);

    Q_INVOKABLE QString getIpByRuleId(uint64_t id, QString if_name);

    //Analysis
    Q_INVOKABLE QList<Flag> getTcpFlagByInterface(QString if_name);
    Q_INVOKABLE QList<Prot> getProtStatsByInterface(QString if_name);
    Q_INVOKABLE QList<IpHit> getIpHitsByInterface(QString if_name);
    Q_INVOKABLE QList<PortHit> getPortHitsByInterface(QString if_name);
    Q_INVOKABLE QList<PacketDist> getPacketDistributionByInterface(QString if_name);
    Q_INVOKABLE QList<RuleHit> getRuleHitsByInterface(QString if_name);
    Q_INVOKABLE QList<BlockedIp> getBlockedIpsByInterface(QString if_name);

    Q_INVOKABLE void dumpAll();
    void cleanup();

signals:
    void rulesetAdded();
    void logEmited(TagType type,QString message, QString source);
    void rulesAdded();
    void errorLogRuleset(QString message, QString source);

private:
    QTimer *fetchIfTimer;
    QTimer *fetchHitsTimer;
    QVector<Interface> interfaces;
    QMap<QString, FilteringManager*> managers;
    // /int selectedInterfaceIndex;
    void fetchNetworkInterfaces();
    bool containsRuleset(const int interfaceIndex,const QString &name) const;
private slots:
    void updateInterfaces();
    void updateHits();
};

#endif // INTERFACEMODEL_H
