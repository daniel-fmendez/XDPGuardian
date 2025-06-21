#ifndef SELECTIONMANAGER_H
#define SELECTIONMANAGER_H

#include <QObject>

class SelectionManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString selectedInterface READ selectedInterface WRITE setSelectedInterface NOTIFY selectedInterfaceChanged)
    Q_PROPERTY(QString selectedRuleset READ selectedRuleset WRITE setSelectedRuleset NOTIFY selectedRulesetChanged)
    Q_PROPERTY(bool selectedInterfaceIsActive READ selectedInterfaceIsActive WRITE setSelectedInterfaceIsActive NOTIFY selectedInterfaceIsActiveChanged)
    Q_PROPERTY(bool selectedRulesetIsActive READ selectedRulesetIsActive WRITE setSelectedRulesetIsActive NOTIFY selectedRulesetIsActiveChanged)

public:
    explicit SelectionManager(QObject *parent = nullptr);

    QString selectedInterface() const;
    QString selectedRuleset() const;
    bool selectedInterfaceIsActive() const;
    bool selectedRulesetIsActive() const;
    Q_INVOKABLE void updateRule();

public slots:
    void setSelectedInterface(const QString &iface);
    void setSelectedRuleset(const QString &ruleset);
    void setSelectedInterfaceIsActive(const bool &ifaceIsActive);
    void setSelectedRulesetIsActive(const bool &rulesetIsActive);

signals:
    void selectedInterfaceChanged();
    void selectedRulesetChanged();
    void selectedInterfaceIsActiveChanged();
    void selectedRulesetIsActiveChanged();
    void rulesetStatusChanged();

    void rulesUpdated();
private:
    QString m_selectedInterface;
    QString m_selectedRuleset;
    bool m_selectedInterfaceIsActive;
    bool m_selectedRulesetIsActive;
};

#endif // SELECTIONMANAGER_H
