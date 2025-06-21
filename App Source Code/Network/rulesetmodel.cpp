#include "rulesetmodel.h"

RulesetModel::RulesetModel(QObject *parent) : QAbstractListModel(parent) {}

int RulesetModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid()) return 0;
    return rulesets.size();
}


QVariant RulesetModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= rulesets.size()) return QVariant();

    const Ruleset &ruleset = rulesets[index.row()];
    if (role == NameRole) return ruleset.name;
    if (role == StatusRole) return ruleset.isActive;
    if (role == RuleRole) return QVariant::fromValue(ruleset.rules);

    return QVariant();
}

QHash<int, QByteArray> RulesetModel::roleNames() const {
    return { {NameRole, "name"}, {StatusRole, "isActive"}, {RuleRole, "rules"} };
}

void RulesetModel::setRulesets(const QVector<Ruleset> &newRulesets) {
    beginResetModel();
    rulesets = newRulesets;
    emit rulesetChanged();
    endResetModel();
}

QVector<Rule> RulesetModel::getRulesForRulesets(int index) const {
    if (index >= 0 && index < rulesets.size()) {
        return rulesets.at(index).rules;
    }
    return QVector<Rule>();
}
