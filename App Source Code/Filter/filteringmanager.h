#ifndef FILTERINGMANAGER_H
#define FILTERINGMANAGER_H
#pragma once

extern "C" {
    #include <bpf/libbpf.h>
    #include <bpf/bpf.h>
    #include <netinet/in.h>
    #include <stdlib.h>
    #include <unistd.h>
    #include <arpa/inet.h>
    #include <net/if.h>
    #include "packet.h"
    #include "rule.skel.h"
}
#include "Network/rulemodel.h"
#include "Network/rulesetmodel.h"
#include "flagmodel.h"
#include "protpiemodel.h"
#include "iphitsmodel.h"
#include "porthitsmodel.h"
#include "packetdistmodel.h"
#include "rulehitmodel.h"
#include "blockedfromfiltermodel.h"

#include <QString>
#include <QDebug>
#include <QUuid>
#include <cstring>
#include <QDateTime>
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QProcess>
class FilteringManager
{
public:
    FilteringManager(const QString& iface);
    ~FilteringManager();

    bool attach();
    bool detach();
    int insertIp(const Ruleset& ruleset, const Rule& rule);
    int insertRule(const Ruleset& ruleset, const Rule& rule);
    int editRule(const Ruleset& ruleset, const Rule& rule);
    bool deleteRule(const Rule& rule);
    int getHits(Rule& rule);
    void cleanup();

    //Analysis
    QList<Flag> fetchTcpFlags();
    QList<Prot> fetchProtStats();
    QList<IpHit> fetchIpHits();
    QList<PortHit> fetchPortHits();
    QList<PacketDist> fetchPacketDist();
    QList<RuleHit> fetchRuleHits();
    QList<BlockedIp> fetchBlockedIps();

    void dumpAll();

private:
    void deletePinnedMap(std::string path);

    QString interfaceName;
    std::string blacklist_map_path;
    std::string index_map_path;
    std::string hit_map_path;
    std::string prot_map_path;
    std::string packet_stats_map_path;
    std::string hit_rates_map_path;
    std::string ip_hits_map_path;
    std::string port_hits_map_path;
    std::string packet_dist_map_path;
    std::string tcp_flags_map_path;
    std::string ip_flags_map_path;
    std::string syn_trackers_map_path;
    std::string ddos_blacklist_map_path;

    int ifindex = 0;
    rule_bpf* skel = nullptr;
};

#endif // FILTERINGMANAGER_H
