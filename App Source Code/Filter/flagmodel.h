#ifndef FLAGMODEL_H
#define FLAGMODEL_H

#include <QString>
#include <qabstractitemmodel.h>

struct Flag {
    QString flagName;
    int value;
};

class FlagModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        ValueRole
    };

    FlagModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void clear();
    Q_INVOKABLE void setFromList(const QList<Flag> &list);
private:
    QList<Flag> m_data;
};

#endif // FLAGMODEL_H
