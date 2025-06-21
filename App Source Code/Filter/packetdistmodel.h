#ifndef PACKETDISTMODEL_H
#define PACKETDISTMODEL_H

#include <QString>
#include <qabstractitemmodel.h>

struct PacketDist {
    uint16_t bucket;
    uint64_t packets;
};

class PacketDistModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        BucketRole = Qt::UserRole + 1,
        PacketRole
    };

    PacketDistModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE QVariantMap get(int index);

    void clear();
    Q_INVOKABLE void setFromList(const QList<PacketDist> &list);
signals:
    void listChanged();
private:
    QList<PacketDist> m_data;
};

#endif // PACKETDISTMODEL_H
