#ifndef ANALYSISFUNCTIONS_H
#define ANALYSISFUNCTIONS_H

#include "filteringmanager.h"

namespace AnalysisFunctions {
    QList<Flag> fetchTcpFlags(int map_fd);
    QList<Prot> fetchProtStats(int map_fd);
    QList<IpHit> fetchIpHits(int map_fd);
    QList<PortHit> fetchPortHits(int map_fd);
    QList<PacketDist> fetchPacketDist(int map_fd);
    QList<RuleHit> fetchRuleHits(int map_fd);
    QList<BlockedIp> fetchBlockedIps(int map_fd);
}
#endif // ANALYSISFUNCTIONS_H
