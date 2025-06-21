#include "flagmodel.h"

FlagModel::FlagModel(QObject *parent) : QAbstractListModel(parent) {}

int FlagModel::rowCount(const QModelIndex &) const {
    return m_data.count();
}

QVariant FlagModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_data.size())
        return QVariant();

    const auto &data = m_data.at(index.row());

    switch (role) {
    case NameRole:
        return data.flagName;
    case ValueRole:
        return data.value;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> FlagModel::roleNames() const {
    return {
        {NameRole, "flagName"},
        {ValueRole, "value"}
    };
}

void FlagModel::setFromList(const QList<Flag> &list){
    beginResetModel();
    m_data = list;
    endResetModel();
}

void FlagModel::clear(){
    beginResetModel();
    m_data.clear();
    endResetModel();
}
