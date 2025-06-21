#include "packetdistmodel.h"

PacketDistModel::PacketDistModel(QObject *parent) : QAbstractListModel(parent) {}

int PacketDistModel::rowCount(const QModelIndex &) const {
    return m_data.count();
}

QVariant PacketDistModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_data.size())
        return QVariant();

    const auto &data = m_data.at(index.row());

    switch (role) {
    case BucketRole:
        return QVariant::fromValue(static_cast<uint16_t>(data.bucket));
    case PacketRole:
        return QVariant::fromValue(static_cast<uint64_t> (data.packets));
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> PacketDistModel::roleNames() const {
    return {
        {BucketRole, "bucket"},
        {PacketRole, "packets"}
    };
}

QVariantMap PacketDistModel::get(int index) {
    QVariantMap result;

    if (index < 0 || index >= m_data.size())
        return result;

    const PacketDist &item = m_data.at(index);
    result["bucket"] = QVariant::fromValue(static_cast<uint16_t>(item.bucket));
    result["packets"] = QVariant::fromValue(static_cast<uint64_t>(item.packets));

    return result;
}

void PacketDistModel::setFromList(const QList<PacketDist> &list){
    beginResetModel();
    m_data = list;
    emit listChanged();
    endResetModel();
}

void PacketDistModel::clear(){
    beginResetModel();
    m_data.clear();
    endResetModel();
}

