#ifndef DUMPMETRICSFUNCTIONS_H
#define DUMPMETRICSFUNCTIONS_H

#include "filteringmanager.h"

namespace DumpMetricsFucntions {
    void dumpBlacklist(QFile &file, int map_fd);
    void dumpIndex(QFile &file,int map_fd);
    void dumpRuleHits(QFile &file, int map_fd);

    void dumpProtocolStats(QFile &file, int map_fd);
    void dumpPacketStats(QFile &file, int map_fd);
    void dumpHitRates(QFile &file, int map_fd);
    void dumpIpHits(QFile &file, int map_fd);
    void dumpPortHits(QFile &file, int map_fd);
    void dumpPacketSizeDistribution(QFile &file, int map_fd);
    void dumpTcpFlagsCount(QFile &file, int map_fd);
    void dumpIpFlagsCount(QFile &file, int map_fd);

    void dumpSynTrackers(QFile &file, int map_fd);
    void dumpDdosBlacklist(QFile &file, int map_fd);
}

#endif // DUMPMETRICSFUNCTIONS_H
