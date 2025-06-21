#ifndef PROTPIEMODEL_H
#define PROTPIEMODEL_H

#include <QString>
#include <qabstractitemmodel.h>

struct Prot {
    QString label;
    int totalPackets;
    int totalBytes;
    uint64_t lastSeen;
};

class ProtPieModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        LabelRole = Qt::UserRole + 1,
        TotalPackets,
        TotalBytes,
        LastSeen
    };

    ProtPieModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE QVariantMap get(int index);

    void clear();
    Q_INVOKABLE void setFromList(const QList<Prot> &list);

signals:
    void seriesChanged();
private:
    QList<Prot> m_data;
};

#endif // PROTPIEMODEL_H
