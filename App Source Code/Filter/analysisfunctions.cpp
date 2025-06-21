#include "analysisfunctions.h"

namespace AnalysisFunctions {

    QList<Flag> fetchTcpFlags(int map_fd){
        QList<Flag> result;

        const char *flag_names[] = {
            "FIN", "SYN", "RST", "PSH", "ACK", "URG", "ECE", "CWR"
        };

        for (__u16 flag = 0; flag < 8; flag++) {
            __u64 count = 0;

            if (bpf_map_lookup_elem(map_fd, &flag, &count)!=0) {
                count = 0;
            }

            Flag newFlag;
            newFlag.flagName = flag_names[flag];
            newFlag.value = count;
            result.append(newFlag);
        }
        return result;
    }

    QList<Prot> fetchProtStats(int map_fd) {
        __u8 key = 0;
        __u8 next_key;
        struct protocol_stats_t value = {};

        QList<Prot> result;

        while (bpf_map_get_next_key(map_fd, &key, &next_key) == 0) {
            if (bpf_map_lookup_elem(map_fd, &next_key, &value) == 0) {

                Prot entry;
                switch (next_key) {
                    case IPPROTO_TCP:
                        entry.label = "TCP";
                        break;
                    case IPPROTO_UDP:
                        entry.label = "UDP";
                        break;
                    case IPPROTO_ICMP:
                        entry.label = "ICMP";
                        break;
                    default:
                        entry.label = "Other";
                        break;
                }

                entry.totalPackets = value.packets_total;
                entry.totalBytes = value.bytes_total;
                entry.lastSeen = value.last_seen;

                result.append(entry);
            }
            key = next_key;
        }
        return result;
    }
    QList<IpHit> fetchIpHits(int map_fd) {
        __u32 key = 0, next_key;
        struct ip_hit_t value = {};
        char ip_str[INET_ADDRSTRLEN];

        QList<IpHit> result;

        while (bpf_map_get_next_key(map_fd, &key, &next_key) == 0) {
            if (bpf_map_lookup_elem(map_fd, &next_key, &value) == 0) {
                // Convertir IP a formato legible
                __u32 ip_network_order = htonl(next_key);
                if (inet_ntop(AF_INET, &ip_network_order, ip_str, sizeof(ip_str)) == NULL) {
                    perror("inet_ntop");
                    snprintf(ip_str, sizeof(ip_str), "IP inválida");
                }

                IpHit entry;
                entry.ip = ip_str;
                entry.totalPackets = value.packets;
                entry.totalBytes = value.bytes;
                entry.lastSeen = value.last_seen;

                result.append(entry);
            }

            key = next_key;
        }

        return result;
    }

    QList<PortHit> fetchPortHits(int map_fd) {
        __u16 key, next_key;
        __u64 value;
        __u16 *lookup_key = NULL;

        QList<PortHit> result;

        while (bpf_map_get_next_key(map_fd, lookup_key, &next_key) == 0) {

            PortHit entry;
            if (bpf_map_lookup_elem(map_fd, &next_key, &value) == 0) {
                entry.port = next_key;
                entry.hits = value;
            }

            key = next_key;
            lookup_key = &key;

            result.append(entry);
        }

        return result;
    }

    QList<PacketDist> fetchPacketDist(int map_fd) {
        __u32 key;
        __u64 value;

        QList<PacketDist>  result;

        for (key = 0; key < 32; key++) {
            if (bpf_map_lookup_elem(map_fd, &key, &value) == 0) {
                PacketDist entry;
                if (value > 0) {
                    entry.bucket = key;
                    entry.packets = value;
                    result.append(entry);
                }
            }
        }

        return result;
    }
    QList<RuleHit> fetchRuleHits(int map_fd) {
        __u64 key, next_key;
        struct rule_hit_t value;
        __u64 *lookup_key = NULL;

        QList<RuleHit> result;

        while (bpf_map_get_next_key(map_fd, lookup_key, &next_key) == 0) {
            if (bpf_map_lookup_elem(map_fd, &next_key, &value) == 0) {
                RuleHit entry;

                entry.id = next_key;
                entry.hits = value.count;
                entry.bytes = value.bytes;
                entry.lastSeen = value.last_timestamp;

                result.append(entry);
            }
            key = next_key;
            lookup_key = &key;
        }

        return result;
    }

    QList<BlockedIp> fetchBlockedIps(int map_fd) {
        __u32 key = 0, next_key;
        __u64 expiry_time = 0;

        QList<BlockedIp> result;
        while (bpf_map_get_next_key(map_fd, &key, &next_key) == 0) {
            if (bpf_map_lookup_elem(map_fd, &next_key, &expiry_time) == 0) {
                BlockedIp entry;
                char ip_str[INET_ADDRSTRLEN];
                __u32 ip_network_order = htonl(next_key);
                inet_ntop(AF_INET, &ip_network_order, ip_str, sizeof(ip_str));

                entry.ip = ip_str;
                entry.expiryTime = expiry_time;
                result.append(entry);
            }

            key = next_key;
        }
        return result;
    }
}
