#include "protocolmodel.h"

ProtocolModel::ProtocolModel(QObject *parent) : QAbstractListModel(parent) {

    m_protocols << "IPv4" << "TCP" << "UDP" << "TCP/UDP";
}


int ProtocolModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_protocols.size();
}
QVariant ProtocolModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_protocols.size())
        return QVariant();

    if (role == NameRole)
        return m_protocols.at(index.row());

    return QVariant();
}

QHash<int, QByteArray> ProtocolModel::roleNames() const
{
    return {
        { NameRole, "name" }
    };
}
int ProtocolModel::getIndex(const QString &name) const {
    return m_protocols.indexOf(name);
}
