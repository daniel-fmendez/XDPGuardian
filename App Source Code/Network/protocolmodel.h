#ifndef PROTOCOLMODEL_H
#define PROTOCOLMODEL_H

#include <QAbstractListModel>
class ProtocolModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum ProtocolRoles {
        NameRole = Qt::UserRole + 1
    };

    ProtocolModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE int getIndex(const QString &name) const;
private:
    QStringList m_protocols;
};

#endif // PROTOCOLMODEL_H
