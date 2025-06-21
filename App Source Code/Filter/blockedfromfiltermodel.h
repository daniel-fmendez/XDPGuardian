#ifndef BLOCKEDFROMFILTERMODEL_H
#define BLOCKEDFROMFILTERMODEL_H

#include <qabstractitemmodel.h>
#include <QString>

struct BlockedIp {
    QString ip;
    uint64_t expiryTime;
};

class BlockedFromFilterModel: public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        IpRole = Qt::UserRole + 1,
        ExpiryRole
    };

    BlockedFromFilterModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE QVariantMap get(int index);

    void clear();
    Q_INVOKABLE void setFromList(const QList<BlockedIp> &list);
    Q_INVOKABLE bool isBlocked(const QString ip);

signals:
    void listChanged();
private:
    QList<BlockedIp> m_data;
};

#endif // BLOCKEDFROMFILTERMODEL_H
