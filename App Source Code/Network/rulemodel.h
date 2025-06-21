#ifndef RULEMODEL_H
#define RULEMODEL_H

#include <QAbstractTableModel>
#include <QVector>

struct Rule {
    QString name;
    QString ip;  //TODO: multiples ip, rangos una linea
    QVector<int> ports;
    QString protocol;
    bool status; //Is active
    int hits;
    uint64_t id;
};

class RuleModel : public QAbstractTableModel
{
    Q_OBJECT
public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        IpRole,
        PortsRole,
        ProtocolRole,
        StatusRole,
        HitsRole
    };
    explicit RuleModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QVariant headerData(int section, Qt::Orientation orientation, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void setRules(const QVector<Rule> &rules);
private:
    QVector<Rule> m_data;
};

#endif // RULEMODEL_H
