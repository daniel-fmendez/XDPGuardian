#include "porthitsmodel.h"

PortHitsModel::PortHitsModel(QObject *parent) : QAbstractListModel(parent) {}

int PortHitsModel::rowCount(const QModelIndex &) const {
    return m_data.count();
}

QVariant PortHitsModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_data.size())
        return QVariant();

    const auto &data = m_data.at(index.row());

    switch (role) {
    case PortRole:
        return QVariant::fromValue(static_cast<uint16_t>(data.port));
    case HitsRole:
        return QVariant::fromValue(static_cast<uint64_t> (data.hits));
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> PortHitsModel::roleNames() const {
    return {
        {PortRole, "port"},
        {HitsRole, "hits"}
    };
}

QVariantMap PortHitsModel::get(int index) {
    QVariantMap result;

    if (index < 0 || index >= m_data.size())
        return result;

    const PortHit &item = m_data.at(index);
    result["port"] = QVariant::fromValue(static_cast<uint16_t>(item.port));
    result["hits"] = QVariant::fromValue(static_cast<uint64_t>(item.hits));

    return result;
}

void PortHitsModel::setFromList(const QList<PortHit> &list){
    beginResetModel();
    m_data = list;
    std::sort(m_data.begin(), m_data.end(), [](const PortHit &a, const PortHit &b) {
        return a.hits > b.hits;  // Descendente
    });
    emit listChanged();
    endResetModel();
}

void PortHitsModel::clear(){
    beginResetModel();
    m_data.clear();
    endResetModel();
}
