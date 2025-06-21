#include "blockedfromfiltermodel.h"


BlockedFromFilterModel::BlockedFromFilterModel(QObject *parent) : QAbstractListModel(parent) {}

int BlockedFromFilterModel::rowCount(const QModelIndex &) const {
    return m_data.count();
}

QVariant BlockedFromFilterModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_data.size())
        return QVariant();

    const auto &data = m_data.at(index.row());

    switch (role) {
    case IpRole:
        return data.ip;
    case ExpiryRole:
        return QVariant::fromValue(static_cast<uint64_t> (data.expiryTime));
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> BlockedFromFilterModel::roleNames() const {
    return {
        {IpRole, "ip"},
        {ExpiryRole, "expiryTime"},
    };
}

QVariantMap BlockedFromFilterModel::get(int index) {
    QVariantMap result;

    if (index < 0 || index >= m_data.size())
        return result;

    const BlockedIp &item = m_data.at(index);
    result["ip"] = item.ip;
    result["expiryTime"] = QVariant::fromValue(static_cast<uint64_t>(item.expiryTime));

    return result;
}

void BlockedFromFilterModel::setFromList(const QList<BlockedIp> &list){
    beginResetModel();
    m_data = list;
    emit listChanged();
    endResetModel();
}

void BlockedFromFilterModel::clear(){
    beginResetModel();
    m_data.clear();
    endResetModel();
}

bool BlockedFromFilterModel::isBlocked(const QString ip){
    for(BlockedIp  blocked: m_data){
        if(ip == blocked.ip){
             return true;
        }
    }
    return false;
}
