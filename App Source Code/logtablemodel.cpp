#include "logtablemodel.h"


//TAG
QString LogTableModel::tagToString(const TagType tag) const{
    static const std::map<TagType, QString> tagString {
        {ERROR, "ERROR"},
        {RULE_CREATED, "RULE CREATED"},
        {RULE_DELETED, "RULE DELETED"},
        //{ATTEMPT, "ATTEMPT"},
        {INFO, "INFO"}
    };

    auto it = tagString.find(tag);
    return (it != tagString.end()) ? it->second : "UNKNOWN";
}
TagType LogTableModel::stringToTag(const QString &str) const{
    static const std::map<QString, TagType> stringTag {
        {"ERROR", ERROR},
        {"RULE CREATED", RULE_CREATED},
        {"RULE DELETED", RULE_DELETED},
        //{"ATTEMPT", ATTEMPT},
        {"INFO", INFO}
    };

    auto it = stringTag.find(str);
    return (it != stringTag.end()) ? it->second : UNKNOWN; // O algún valor por defecto
}

//MODEL
LogTableModel::LogTableModel(QObject *parent): QAbstractTableModel(parent){}

int LogTableModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);

    return m_isFiltered ? m_filteredData.size() : m_data.size();
}

int LogTableModel::columnCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return 4;
}

QVariant LogTableModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || role != Qt::DisplayRole)
        return QVariant();

    const auto &source = m_isFiltered ? m_filteredData : m_data;
    const auto &entry = source.at(index.row());
    switch (index.column()) {
        case 0: return entry.timestamp.toString("yyyy-MM-dd hh:mm:ss:z");
        case 1: return tagToString(entry.type);
        case 2: return entry.message;
        case 3: return entry.source;
        default: return QVariant();
    }
}
QVariant LogTableModel::headerData(int section, Qt::Orientation orientation, int role) const {
    if (role != Qt::DisplayRole)
        return QVariant();

    if (orientation == Qt::Horizontal) {
        switch (section) {
        case 0: return "TIMESTAMP";
        case 1: return "TYPE";
        case 2: return "MESSAGE";
        case 3: return "SOURCE";
        default: return QVariant();
        }
    }
    return QVariant();
}

void LogTableModel::updateData(const QVector<LogTabEntry> &entries) {
    beginResetModel();
    m_data = entries;
    endResetModel();
}
const int MAX_LOGS = 2000;
void LogTableModel::addLog(const QString &type, const QString message, const QString source){
    if(type != "UNKNOW"){
        if(m_data.size()>=MAX_LOGS){
            m_data.removeLast();
        }
        TagType tagType = stringToTag(type);
        QDateTime timestamp = QDateTime::currentDateTime();
        LogTabEntry newEntry = {timestamp,tagType,message,source};

        beginInsertRows(QModelIndex(), 0, 0);  // Insertar al principio
        m_data.push_front(newEntry);
        endInsertRows();

        emit logAdded();
        applyFilters();
    }
}

void LogTableModel::addLog(const TagType type, const QString message, const QString source){
    QDateTime timestamp = QDateTime::currentDateTime();
    LogTabEntry newEntry = {timestamp,type,message,source};

    beginInsertRows(QModelIndex(), 0, 0);  // Insertar al principio
    m_data.push_front(newEntry);
    endInsertRows();

    emit logAdded();
    applyFilters();
}
void LogTableModel::clearSearch() {
    m_searchText = "";
    applyFilters();
}
void LogTableModel::setActiveTags(const QStringList &tags) {
    m_activeTags.clear();

    for (const QString &tagStr : tags) {
        TagType type = stringToTag(tagStr);

        if (type != UNKNOWN) {
            m_activeTags.insert(type);
        }
    }
    applyFilters();
}

void LogTableModel::setSearchText(const QString &text) {
    m_searchText = text;
    applyFilters();
}
void LogTableModel::setSourceText(const QString &text) {
    m_sourceText = text;
    applyFilters();
}

void LogTableModel::applyFilters() {
    beginResetModel();
    m_filteredData.clear();

    const bool useSearch = !m_searchText.trimmed().isEmpty();
    //Contiene menos tags que todas las activas
    const bool useTags = m_activeTags.size()!=5;
    const bool useSource = m_sourceText != "All";
    m_isFiltered = useSearch || useTags || useSource;

    for (const LogTabEntry &entry : m_data) {
        bool matchesText = !useSearch || entry.message.contains(m_searchText, Qt::CaseInsensitive);
        bool matchesTag = !useTags || m_activeTags.contains(entry.type);
        bool matchesSource = !useSource || entry.source == m_sourceText;

        if (matchesText && matchesTag && matchesSource) {
            m_filteredData.append(entry);
        }
    }

    endResetModel();
}

QStringList LogTableModel::getAllSources() const {

    QSet<QString> uniqueSources;

    for (const auto &entry : m_data) {
        uniqueSources.insert(entry.source);
    }

    QStringList result = uniqueSources.values();

    return result;
}
