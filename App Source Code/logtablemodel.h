#ifndef LOGTABLEMODEL_H
#define LOGTABLEMODEL_H

#include <QAbstractTableModel>
#include <QDateTime>

enum TagType{
    UNKNOWN = -1,
    ERROR,
    RULE_CREATED,
    RULE_DELETED,
    //ATTEMPT,
    INFO
};
struct LogTabEntry {
    QDateTime timestamp;
    TagType type;
    QString message;
    QString source;
};

class LogTableModel : public  QAbstractTableModel
{
    Q_OBJECT
public:

    explicit LogTableModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QVariant headerData(int section, Qt::Orientation orientation, int role) const override;

    void updateData(const QVector<LogTabEntry> &entries);
    Q_INVOKABLE void addLog(const QString &type, const QString message, const QString source);
    Q_INVOKABLE void addLog(const TagType type, const QString message, const QString source);

    void applyFilters();

    Q_INVOKABLE QString tagToString(const TagType tag)const;
    Q_INVOKABLE TagType stringToTag(const QString &str) const;
    Q_INVOKABLE void clearSearch();
    Q_INVOKABLE void setActiveTags(const QStringList &tags);
    Q_INVOKABLE void setSearchText(const QString &text);
    Q_INVOKABLE void setSourceText(const QString &text);
    Q_INVOKABLE QStringList getAllSources() const;

signals:
    void logAdded();

private:

    QVector<LogTabEntry> m_data;
    QVector<LogTabEntry> m_filteredData;
    bool m_isFiltered = false;

    QString m_searchText;
    QString m_sourceText;
    QSet<TagType> m_activeTags;
};

#endif // LOGTABLEMODEL_H
