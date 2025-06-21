#ifndef TABIPMODEL_H
#define TABIPMODEL_H

#include <QAbstractTableModel>
#include <QVector>

struct TabEntry {
    int id;
    QString name;
    QString ip;  //TODO: multiples ip, rangos una linea
    QVector<int> ports;;
    QString protocol;
    QString action;
    QString status;
    int hits;
};

class TabIPModel : public  QAbstractTableModel {
    Q_OBJECT
public:
    explicit TabIPModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QVariant headerData(int section, Qt::Orientation orientation, int role) const override;

    void updateData(const QVector<TabEntry> &entries);
private:
    QVector<TabEntry> m_data;
};

#endif // TABIPMODEL_H
