#ifndef RULESETMODEL_H
#define RULESETMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include "rulemodel.h"

struct Ruleset {
    QString name;
    bool isActive;
    QVector<Rule> rules;
};

class RulesetModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        StatusRole,
        RuleRole
    };
    explicit RulesetModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void setRulesets(const QVector<Ruleset> &newRulesets);
    Q_INVOKABLE QVector<Rule> getRulesForRulesets(int index) const;
signals:
    void rulesetSelected(QVector<Rule> rules);
    void rulesetChanged();
private:
    QVector<Ruleset> rulesets;
};

#endif // RULESETMODEL_H
