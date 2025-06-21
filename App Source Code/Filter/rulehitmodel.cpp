#include "rulehitmodel.h"

RuleHitsModel::RuleHitsModel(QObject *parent) : QAbstractListModel(parent) {}

int RuleHitsModel::rowCount(const QModelIndex &) const {
    return m_data.count();
}

QVariant RuleHitsModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_data.size())
        return QVariant();

    const auto &data = m_data.at(index.row());



    switch (role) {
    case IdRole:
        return QVariant::fromValue(static_cast<uint64_t>(data.id));
    case HitsRole:
        return QVariant::fromValue(static_cast<uint64_t> (data.hits));
    case BytesRole:
        return QVariant::fromValue(static_cast<uint64_t> (data.bytes));
    case LastSeenRole:
        return QVariant::fromValue(static_cast<uint64_t> (data.lastSeen));
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> RuleHitsModel::roleNames() const {
    return {
        {IdRole, "id"},
        {HitsRole, "hits"},
        {BytesRole, "bytes"},
        {LastSeenRole, "lastSeen"}
    };
}

QVariantMap RuleHitsModel::get(int index) {
    QVariantMap result;

    if (index < 0 || index >= m_data.size())
        return result;

    const RuleHit &item = m_data.at(index);
    result["id"] = QVariant::fromValue(static_cast<uint64_t>(item.id));
    result["hits"] = QVariant::fromValue(static_cast<uint64_t>(item.hits));
    result["bytes"] = QVariant::fromValue(static_cast<uint64_t>(item.bytes));
    result["lastSeen"] = QVariant::fromValue(static_cast<uint64_t>(item.lastSeen));

    return result;
}

void RuleHitsModel::setFromList(const QList<RuleHit> &list){
    beginResetModel();
    m_data = list;
    std::sort(m_data.begin(), m_data.end(), [](const RuleHit &a, const RuleHit &b) {
        return a.hits > b.hits;  // Descendente
    });
    emit listChanged();
    endResetModel();
}

void RuleHitsModel::clear(){
    beginResetModel();
    m_data.clear();
    endResetModel();
}

