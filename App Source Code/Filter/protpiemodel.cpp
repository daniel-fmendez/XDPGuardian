#include "protpiemodel.h"

ProtPieModel::ProtPieModel(QObject *parent) : QAbstractListModel(parent) {}

int ProtPieModel::rowCount(const QModelIndex &) const {
    return m_data.count();
}

QVariant ProtPieModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_data.size())
        return QVariant();

    const auto &data = m_data.at(index.row());

    switch (role) {
    case LabelRole:
        return data.label;
    case TotalPackets:
        return data.totalPackets;
    case TotalBytes:
        return data.totalBytes;
    case LastSeen:
        return QVariant::fromValue(static_cast<uint64_t> (data.lastSeen));
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> ProtPieModel::roleNames() const {
    return {
        {LabelRole, "label"},
        {TotalPackets, "totalPackets"},
        {TotalBytes, "totalBytes"},
        {LastSeen, "lastSeen"},
    };
}

QVariantMap ProtPieModel::get(int index) {
    QVariantMap result;

    if (index < 0 || index >= m_data.size())
        return result;

    const Prot &item = m_data.at(index);
    result["label"] = item.label;
    result["totalPackets"] = item.totalPackets;
    result["totalBytes"] = item.totalBytes;
    result["lastSeen"] = QVariant::fromValue(static_cast<qulonglong>(item.lastSeen));

    return result;
}

void ProtPieModel::setFromList(const QList<Prot> &list){
    beginResetModel();
    m_data = list;
    emit seriesChanged();
    endResetModel();
}

void ProtPieModel::clear(){
    beginResetModel();
    m_data.clear();
    endResetModel();
}
