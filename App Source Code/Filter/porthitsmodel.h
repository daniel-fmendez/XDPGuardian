#ifndef PORTHITSMODEL_H
#define PORTHITSMODEL_H

#include <QString>
#include <qabstractitemmodel.h>

struct PortHit {
    uint16_t port;
    uint64_t hits;
};

class PortHitsModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        PortRole = Qt::UserRole + 1,
        HitsRole
    };

    PortHitsModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE QVariantMap get(int index);

    void clear();
    Q_INVOKABLE void setFromList(const QList<PortHit> &list);

signals:
    void listChanged();
private:
    QList<PortHit> m_data;
};


#endif
