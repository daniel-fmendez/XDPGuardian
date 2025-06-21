#include "tabipmodel.h"

TabIPModel::TabIPModel(QObject *parent) : QAbstractTableModel(parent) {}

int TabIPModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return m_data.size();

}

int TabIPModel::columnCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return 8;
}

QVariant TabIPModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || role != Qt::DisplayRole)
        return QVariant();

    const auto &entry = m_data.at(index.row());
    switch (index.column()) {
        case 0: return entry.id;
        case 1: return entry.name;
        case 2: return entry.ip;
        case 3: {
            QStringList portStrings;
            for (int port : entry.ports) {
                portStrings.append(QString::number(port));
            }
            return portStrings.join(", ");
        }
        case 4: return entry.protocol;
        case 5: return entry.action;
        case 6: return entry.status;
        case 7: return entry.hits;
        default: return QVariant();
    }
}
QVariant TabIPModel::headerData(int section, Qt::Orientation orientation, int role) const {
    if (role != Qt::DisplayRole)
        return QVariant();

    if (orientation == Qt::Horizontal) {
        switch (section) {
        case 0: return "ID";
        case 1: return "Name";
        case 2: return "IP";
        case 3: return "Ports";
        case 4: return "Protocol";
        case 5: return "Action";
        case 6: return "Status";
        case 7: return "Hits";
        default: return QVariant();
        }
    }
    return QVariant();
}

void TabIPModel::updateData(const QVector<TabEntry> &entries) {
    beginResetModel();
    m_data = entries;
    endResetModel();
}
