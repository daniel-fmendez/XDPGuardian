#include "rulemodel.h"

RuleModel::RuleModel(QObject *parent) : QAbstractTableModel(parent) {}

int RuleModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return m_data.size();

}

int RuleModel::columnCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return 6;
}

QVariant RuleModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid())
        return QVariant();

    const auto &entry = m_data.at(index.row());

    // Manejo de roles específicos
    if (role == NameRole)
        return entry.name;
    else if (role == IpRole)
        return entry.ip;
    else if (role == PortsRole) {
        QStringList portStrings;
        for (int port : entry.ports) {
            portStrings.append(QString::number(port));
        }
        return portStrings.join(", ");
    }
    else if (role == ProtocolRole)
        return entry.protocol;
    else if (role == StatusRole)
        return entry.status;
    else if (role == HitsRole)
        return entry.hits;

    // Manejo tradicional de DisplayRole por columna
    if (role == Qt::DisplayRole) {
        switch (index.column()) {
        case 0: return entry.name;
        case 1: return entry.ip;
        case 2: {
            QStringList portStrings;
            for (int port : entry.ports) {
                portStrings.append(QString::number(port));
            }
            return portStrings.join(", ");
        }
        case 3: return entry.protocol;
        case 4: return entry.status;
        case 5: return entry.hits;
        default: return QVariant();
        }
    }

    return QVariant();
}

QVariant RuleModel::headerData(int section, Qt::Orientation orientation, int role) const {
    if (role != Qt::DisplayRole)
        return QVariant();


    if (orientation == Qt::Horizontal) {
        switch (section) {
            case 0: return "Name";
            case 1: return "IP";
            case 2: return "Ports";  // Puede que necesites formatear como QString
            case 3: return "Protocol";
            case 4: return "Status";
            case 5: return "Hits";
            default: return QVariant();
        }
    }
    return QVariant();
}

void RuleModel::setRules(const QVector<Rule> &rules) {
    beginResetModel();
    m_data = rules;
    endResetModel();
}

QHash<int, QByteArray> RuleModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[Qt::DisplayRole] = "display";
    roles[NameRole] = "name";
    roles[IpRole] = "ip";
    roles[PortsRole] = "ports";
    roles[ProtocolRole] = "protocol";
    roles[StatusRole] = "status";
    roles[HitsRole] = "hits";
    return roles;
}
