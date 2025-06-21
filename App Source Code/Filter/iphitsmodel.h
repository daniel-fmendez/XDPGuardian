#ifndef IPHITSMODEL_H
#define IPHITSMODEL_H

#include <QString>
#include <qabstractitemmodel.h>

struct IpHit {
    QString ip;
    int totalPackets;
    uint64_t totalBytes;
    uint64_t lastSeen;
};

class IpHitsModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        IpRole = Qt::UserRole + 1,
        TotalPackets,
        TotalBytes,
        LastSeen
    };

    IpHitsModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE QVariantMap get(int index);

    void clear();
    Q_INVOKABLE void setFromList(const QList<IpHit> &list);

signals:
    void listChanged();
private:
    QList<IpHit> m_data;
};

#endif // IPHITSMODEL_H
