#include "selectionmanager.h"

SelectionManager::SelectionManager(QObject *parent) : QObject(parent) {}

QString SelectionManager::selectedInterface() const {
    return m_selectedInterface;
}

QString SelectionManager::selectedRuleset() const {
    return m_selectedRuleset;
}

bool SelectionManager::selectedInterfaceIsActive() const {
    return m_selectedInterfaceIsActive;
}

bool SelectionManager::selectedRulesetIsActive() const {
    return m_selectedRulesetIsActive;
}

void SelectionManager::setSelectedInterface(const QString &iface) {
    if (m_selectedInterface != iface) {
        m_selectedInterface = iface;
        emit selectedInterfaceChanged();
        emit rulesetStatusChanged();
    }
}

void SelectionManager::setSelectedRuleset(const QString &ruleset) {
    if (m_selectedRuleset != ruleset) {
        m_selectedRuleset = ruleset;
        emit selectedRulesetChanged();
        emit rulesetStatusChanged();
    }
}
void SelectionManager::setSelectedInterfaceIsActive(const bool &ifaceIsActive) {
    m_selectedInterfaceIsActive = ifaceIsActive;
    emit selectedInterfaceIsActiveChanged();
    emit rulesetStatusChanged();
}

void SelectionManager::setSelectedRulesetIsActive(const bool &rulesetIsActive) {
    m_selectedRulesetIsActive = rulesetIsActive;
    emit selectedRulesetIsActiveChanged();
    emit rulesetStatusChanged();
}

void SelectionManager::updateRule() {
    emit rulesUpdated();
}

