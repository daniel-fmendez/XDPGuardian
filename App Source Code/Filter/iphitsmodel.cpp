#include "iphitsmodel.h"

IpHitsModel::IpHitsModel(QObject *parent) : QAbstractListModel(parent) {}

int IpHitsModel::rowCount(const QModelIndex &) const {
    return m_data.count();
}

QVariant IpHitsModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_data.size())
        return QVariant();

    const auto &data = m_data.at(index.row());

    switch (role) {
    case IpRole:
        return data.ip;
    case TotalPackets:
        return data.totalPackets;
    case TotalBytes:
        return QVariant::fromValue(static_cast<qulonglong>(data.totalBytes));
    case LastSeen:
        return QVariant::fromValue(static_cast<uint64_t> (data.lastSeen));
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> IpHitsModel::roleNames() const {
    return {
        {IpRole, "ip"},
        {TotalPackets, "totalPackets"},
        {TotalBytes, "totalBytes"},
        {LastSeen, "lastSeen"},
    };
}

QVariantMap IpHitsModel::get(int index) {
    QVariantMap result;

    if (index < 0 || index >= m_data.size())
        return result;

    const IpHit &item = m_data.at(index);
    result["ip"] = item.ip;
    result["totalPackets"] = item.totalPackets;
    result["totalBytes"] = QVariant::fromValue(static_cast<qulonglong>(item.totalBytes));
    result["lastSeen"] = QVariant::fromValue(static_cast<qulonglong>(item.lastSeen));

    return result;
}

void IpHitsModel::setFromList(const QList<IpHit> &list){
    beginResetModel();
    m_data = list;
    std::sort(m_data.begin(), m_data.end(), [](const IpHit &a, const IpHit &b) {
        return a.totalPackets > b.totalPackets;  // Descendente
    });
    emit listChanged();
    endResetModel();
}

void IpHitsModel::clear(){
    beginResetModel();
    m_data.clear();
    endResetModel();
}
