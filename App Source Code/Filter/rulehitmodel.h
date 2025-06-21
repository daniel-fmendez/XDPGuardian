#ifndef RULEHITMODEL_H
#define RULEHITMODEL_H

#include <QString>
#include <qabstractitemmodel.h>

struct RuleHit {
    uint64_t id;
    uint64_t hits;
    uint64_t bytes;
    uint64_t lastSeen;
};

class RuleHitsModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        HitsRole,
        BytesRole,
        LastSeenRole
    };

    RuleHitsModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE QVariantMap get(int index);

    void clear();
    Q_INVOKABLE void setFromList(const QList<RuleHit> &list);

signals:
    void listChanged();
private:
    QList<RuleHit> m_data;
};

#endif // RULEHITMODEL_H
