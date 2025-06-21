#ifndef NETWORKINTERFACESMODEL_H
#define NETWORKINTERFACESMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QString>
#include <QTimer>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <netinet/in.h>

struct NetworkInterfaceInfo {
    QString name;
    bool isOn;

    bool operator==(const NetworkInterfaceInfo& other) const {
        return name == other.name && isOn == other.isOn;
    }
};

class NetworkInterfacesModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        IsOn
    };

    explicit NetworkInterfacesModel(QObject *parent = nullptr);

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE void updateInterfaces();
private:
    QVector<NetworkInterfaceInfo> interfaces;
    void fetchNetworkInterfaces();
};

#endif // NETWORKINTERFACESMODEL_H
