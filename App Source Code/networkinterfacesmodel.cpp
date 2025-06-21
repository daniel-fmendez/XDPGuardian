#include "networkinterfacesmodel.h"


NetworkInterfacesModel::NetworkInterfacesModel(QObject *parent)
    : QAbstractListModel(parent) {
    fetchNetworkInterfaces();
}
int NetworkInterfacesModel::rowCount(const QModelIndex &parent) const{
    Q_UNUSED(parent);
    return interfaces.size();
}

QVariant NetworkInterfacesModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= interfaces.size()) {
        return QVariant();
    }
    const auto &iface = interfaces.at(index.row());

    switch (role) {
        case NameRole: return iface.name;
        case IsOn: return iface.isOn;
        default: return QVariant();
    }
}

void NetworkInterfacesModel::updateInterfaces() {
    fetchNetworkInterfaces();
}
QHash<int, QByteArray> NetworkInterfacesModel::roleNames() const {
    return {
        { NameRole, "name" },
        { IsOn, "isOn" },
    };
}

void NetworkInterfacesModel::fetchNetworkInterfaces() {
    beginResetModel();
    interfaces.clear();

    struct ifaddrs* ptr_ifaddrs = nullptr;
    QVector<NetworkInterfaceInfo> newInterfaces;

    if (getifaddrs(&ptr_ifaddrs) == 0) {
        for(
            struct ifaddrs* ptr_entry = ptr_ifaddrs;
            ptr_entry != nullptr;
            ptr_entry = ptr_entry->ifa_next
        ){
            if (ptr_entry->ifa_addr == nullptr) continue;

            QString name = ptr_entry->ifa_name;
            bool isActive = (ptr_entry->ifa_addr->sa_family == AF_INET);

            auto found = std::find_if(newInterfaces.begin(), newInterfaces.end(), [&name](const NetworkInterfaceInfo& iface) {
                return iface.name == name;
            });

            if (found == newInterfaces.end()) {
                newInterfaces.append({name, isActive});
            } else if (!found->isOn && isActive) {
                found->isOn = true;
            }
        }
        freeifaddrs(ptr_ifaddrs);
    }
    if (newInterfaces != interfaces) {
        beginResetModel();
        interfaces = newInterfaces;
        endResetModel();
    }
}

