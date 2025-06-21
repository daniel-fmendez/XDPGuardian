#include "dumpmetricsfunctions.h"

namespace DumpMetricsFucntions {
    void dumpBlacklist(QFile &file,int map_fd){
        QTextStream out(&file);

        __u64 key = 0, next_key;
        port_value_t value;

        out << "=== Content of BLACKLIST ===" << "\n";

        if (bpf_map_get_next_key(map_fd, NULL, &next_key) != 0) {
            out << "The map is empty." << "\n";
            return;
        }

        do {
            if (bpf_map_lookup_elem(map_fd, &next_key, &value) == 0) {
                QString line = QString::asprintf("Regla ID: %llu", next_key);
                out << line << "\n";

                line = QString::asprintf("  Active: %s", value.active ? "Yes" : "No");
                out << line << "\n";

                line = QString::asprintf("  Protocol: %u", value.protocol);
                out << line << "\n";

                out << "  Ports:" << "\n";

                int count = 0;

                int start = -1;
                int end = start;
                int in_range = 0;

                for (int i = 0; i < 65536; i++) {
                    int byte_idx = i / 8;
                    int bit_idx = i % 8;
                    int bit_set = value.port_bitmap[byte_idx] & (1 << bit_idx);

                    if (bit_set) {
                        if (!in_range) {
                            start = end = i;
                            in_range = 1;
                        } else {
                            end = i;
                        }
                    } else if (in_range) {
                        if (start == end) {
                            out << start << " ";
                        } else {
                            out << start << "-" << end << " ";
                        }
                        count++;
                        if (count % 10 == 0) out << "\n    ";
                        in_range = 0;
                    }
                }
                if (in_range) {
                    if (start == end) {
                        out << start << " ";
                    } else {
                        out << start << "-" << end << " ";
                    }
                }

                out << "\n\n";
            }

            key = next_key;
        } while (bpf_map_get_next_key(map_fd, &key, &next_key) == 0);

        out << "\n";
    }

    void dumpIndex(QFile &file, int map_fd){
        QTextStream out(&file);

        __u32 key = 0, next_key = 0;
        struct ip_index_value_t value = {};
        char ip_str[INET_ADDRSTRLEN];

        out << "=== Content of IP_INDEX ===" << "\n";

        QString line;

        while (bpf_map_get_next_key(map_fd, &key, &next_key) == 0) {
            if (bpf_map_lookup_elem(map_fd, &next_key, &value) == 0) {
                __u32 ip_network_order = htonl(next_key);
                inet_ntop(AF_INET, &ip_network_order, ip_str, sizeof(ip_str));

                line = QString::asprintf("IP: %s, Rules (%u): ", ip_str, value.count);
                out << line;

                for (int i = 0; i < value.count; i++) {
                    out << value.rules_ids[i] << " ";
                }
                out << "\n";
            } else {
                out << "Error reading elmentent from index";
            }
            key = next_key;
        }
        out << "\n";
    }

    void dumpRuleHits(QFile &file, int map_fd){
        QTextStream out(&file);

        __u64 key, next_key;
        struct rule_hit_t value;
        __u64 *lookup_key = NULL;
        int count = 0;

        out << "=== Content of RULE_HITS ===" << "\n";
        QString line;

        while (bpf_map_get_next_key(map_fd, lookup_key, &next_key) == 0) {
            if (bpf_map_lookup_elem(map_fd, &next_key, &value) == 0) {
                line = QString::asprintf("Rule ID: %-8llu \n\tHits: %-8llu \n\Last: %-14llu ns \n\tBytes: %-10llu\n",
                                         next_key, value.count, value.last_timestamp, value.bytes);
                out << line;
                count++;
            } else {
                out << "Error reading elmentent from rule_hits";
            }

            key = next_key;
            lookup_key = &key;
        }

        if (count == 0) {
            out << "(Empty map)" << "\n";
        }

        out << "\n";
    }
    void dumpProtocolStats(QFile &file, int map_fd) {
        QTextStream out(&file);

        __u8 key = 0;
        __u8 next_key;
        struct protocol_stats_t value = {};

        out << "=== Content of PROTOCOL_STATS ===" << "\n";
        QString line;
        while (bpf_map_get_next_key(map_fd, &key, &next_key) == 0) {
            if (bpf_map_lookup_elem(map_fd, &next_key, &value) == 0) {

                out << "Protocol: " << next_key;
                switch (next_key) {
                case IPPROTO_TCP:
                    out << " (TCP)";
                    break;
                case IPPROTO_UDP:
                    out << " (UDP)";
                    break;
                case IPPROTO_ICMP:
                    out << " (ICMP)";
                    break;
                default:
                    out << " (Otro)";
                    break;
                }
                out << "\n";
                out << " Total packets: " << value.packets_total << "\n";
                out << " Total bytes: " << value.bytes_total << "\n";
                out << " Last seen: " << value.last_seen << "\n";
                out << "\n";
            } else {
                out << "Error reading elmentent from protocol_stats";
            }
            key = next_key;
        }

        out << "\n";
    }

    void dumpPacketStats(QFile &file, int map_fd) {
        QTextStream out(&file);

        __u8 key = 0;
        __u8 next_key;
        struct packet_stats_t value = {};

        out << "=== Content of PACKET_STATS ===" << "\n";
        QString line;

        while (bpf_map_get_next_key(map_fd, &key, &next_key) == 0) {
            if (bpf_map_lookup_elem(map_fd, &next_key, &value) == 0) {
                out << "Protocolo: " << next_key;
                switch (next_key) {
                case IPPROTO_TCP:
                    out << " (TCP)";
                    break;
                case IPPROTO_UDP:
                    out << " (UDP)";
                    break;
                case IPPROTO_ICMP:
                    out << " (ICMP)";
                    break;
                default:
                    out << " (Otro)";
                    break;
                }
                out << "\n";
                out << "  Minimum size: " << value.min_size << "bytes" << "\n";
                out << "  Max size: " << value.max_size << "bytes" << "\n";
                out << "  Total packets: " << value.count << "\n";

                if (value.count > 0) {
                    double promedio = (double)value.size_sum / value.count;
                    line = QString::asprintf("  Average size: %.2f bytes\n", promedio);
                    out << line;
                } else {
                    out << "  Average sizeo: " << "N/A" << "\n";
                }

                out << "  TTL distribution:" << "\n    ";

                for (int i = 0; i < 64; ++i) {
                    if (value.ttl_distribution[i] > 0) {
                        line = QString::asprintf("[%d]=%u ", i, value.ttl_distribution[i]);
                        out << line;
                    }

                }
                out << "\n\n";
            } else {
                out << "Error reading elmentent from packet_stats";
            }

            key = next_key;
        }

        out << "\n";
    }

    void dumpHitRates(QFile &file, int map_fd) {
        QTextStream out(&file);
        __u64 key = 0;
        __u64 next_key;
        struct hit_rate_t value;

        out << "=== Content of HIT_RATES ===" << "\n";

        // Inicializar value con ceros
        memset(&value, 0, sizeof(value));

        int res = bpf_map_get_next_key(map_fd, NULL, &next_key);
        while (res == 0) {
            // Limpiar value antes de cada lookup
            memset(&value, 0, sizeof(value));

            if (bpf_map_lookup_elem(map_fd, &next_key, &value) == 0) {
                out << "Rule ID: " << next_key << "\n";
                out << "  Last Update: " << value.last_update << " ns" << "\n";
                out << "  Current Hits: " << value.hits_current_window << "\n";
                out << "  Current Bytes: " << value.bytes_current_window << "\n";
                out << "  Hits/sec history: ";
                for (int i = 0; i < 16; i++) {
                    out << value.hit_rate_history[i] << " ";
                }
                out << "\n";
                out << "  Bytes/sec history: ";
                for (int i = 0; i < 16; i++) {
                    out << value.byte_rate_history[i] << " ";
                }
                out << "\n\n";
            }

            key = next_key;
            res = bpf_map_get_next_key(map_fd, &key, &next_key);
        }
        out << "\n";
    }

    void dumpIpHits(QFile &file, int map_fd) {
        QTextStream out(&file);

        __u32 key = 0, next_key;
        struct ip_hit_t value = {};
        char ip_str[INET_ADDRSTRLEN];


        out << "=== Content of IP_HITS ===" << "\n";

        while (bpf_map_get_next_key(map_fd, &key, &next_key) == 0) {
            if (bpf_map_lookup_elem(map_fd, &next_key, &value) == 0) {
                // Convertir IP a formato legible
                __u32 ip_network_order = htonl(next_key);
                if (inet_ntop(AF_INET, &ip_network_order, ip_str, sizeof(ip_str)) == NULL) {
                    perror("inet_ntop");
                    snprintf(ip_str, sizeof(ip_str), "IP inválida");
                }

                out << "IP origin: " << ip_str << "\n";
                out << "  Total packets: " << value.packets << "\n";
                out << "  Total bytes: " << value.bytes << "\n";
                out << "  Last seen: " << value.last_seen << " ns" <<"\n";
                out << "\n";

            } else {
                out << "Error reading elmentent fromip_hits";
            }

            key = next_key;
        }

        out << "\n";
    }

    void dumpPortHits(QFile &file, int map_fd) {
        QTextStream out(&file);

        __u16 key, next_key;
        __u64 value;
        __u16 *lookup_key = NULL;
        int count = 0;

        out << "=== Content of PORT_HITS ===" << "\n";
        QString line;
        while (bpf_map_get_next_key(map_fd, lookup_key, &next_key) == 0) {
            if (bpf_map_lookup_elem(map_fd, &next_key, &value) == 0) {
                line = QString::asprintf("(%5u: %8llu)  ", next_key, value);
                out << line;
                count++;

                if (count % 4 == 0) {
                    out << "\n";
                }
            } else {
                out << "Error reading elmentent from port_hits map";
            }

            key = next_key;
            lookup_key = &key;
        }

        if (count % 4 != 0) {
            out << "\n";
        }

        out << "\n";
    }

    void dumpPacketSizeDistribution(QFile &file, int map_fd) {
        QTextStream out(&file);

        __u32 key;
        __u64 value;

        out << "=== Packets size distribution  ===" << "\n";
        out << "Each bucket represents a 64 bytes range" << "\n\n";
        QString line;
        for (key = 0; key < 32; key++) {
            if (bpf_map_lookup_elem(map_fd, &key, &value) == 0) {
                if (value > 0) {
                    __u32 start = key * 64;
                    __u32 end = start + 63;
                    line = QString::asprintf("Size %4u - %4u bytes: %llu packets", start, end, value);
                    out << line << "\n";
                }
            } else {
                out << "Error reading elmentent from packet_size_dist map";
            }
        }

        out << "\n";
    }

    void dumpTcpFlagsCount(QFile &file, int map_fd) {
        QTextStream out(&file);

        const char *flag_names[] = {
            "FIN", "SYN", "RST", "PSH", "ACK", "URG", "ECE", "CWR"
        };

        out << "=== TCP Flag Counts ===" << "\n";
        QString line;
        for (__u16 flag = 0; flag < 8; flag++) {
            __u64 count = 0;

            if (bpf_map_lookup_elem(map_fd, &flag, &count)!=0) {
                count = 0;

            }
            line = QString::asprintf("Flag %-4s (bit %d): %llu veces", flag_names[flag], flag, count);
            out << line << "\n";
        }

        out << "\n";
    }

    void dumpIpFlagsCount(QFile &file, int map_fd) {
        QTextStream out(&file);

        __u32 key, next_key;
        struct ip_flag_t value;

        char ip_str[INET_ADDRSTRLEN];

        out << "=== IP TCP Flag Counts ===" << "\n";
        key = 0;
        while (bpf_map_get_next_key(map_fd, &key, &next_key) == 0) {
            if (bpf_map_lookup_elem(map_fd, &next_key, &value) == 0) {
                __u32 ip_network_order = htonl(next_key);
                inet_ntop(AF_INET, &ip_network_order, ip_str, sizeof(ip_str));
                out << "IP " << ip_str << ":\n";
                out << "  FIN: " << value.fin_flag << "\n";
                out << "  SYN: " << value.syn_flag << "\n";
                out << "  RST: " << value.rst_flag << "\n";
                out << "  PSH: " << value.psh_flag << "\n";
                out << "  ACK: " << value.ack_flag << "\n";
                out << "  URG: " << value.urg_flag << "\n";
                out << "  ECE: " << value.ece_flag << "\n";
                out << "  CWR: " << value.cwr_flag << "\n";
                out << "\n";
            }
            key = next_key;
        }
        out << "\n";
    }
    void dumpSynTrackers(QFile &file, int map_fd){
        QTextStream out(&file);
        __u32 key = 0, next_key;
        struct syn_tracker_t value = {};

        out << "=== SYN_TRACKERS ===" << "\n";
        char ip_str[INET_ADDRSTRLEN];

        QString line;
        while (bpf_map_get_next_key(map_fd, &key, &next_key) == 0) {
            if (bpf_map_lookup_elem(map_fd, &next_key, &value) == 0) {

                __u32 ip_network_order = htonl(next_key);
                inet_ntop(AF_INET, &ip_network_order, ip_str, sizeof(ip_str));

                line = QString::asprintf("IP origen:       %s\n", ip_str);
                out << line;

                line = QString::asprintf("  SYNs:          %llu\n", value.syn_count);
                out << line;

                line = QString::asprintf("  ACKs:          %llu\n", value.ack_count);
                out << line;

                line = QString::asprintf("  Último SYN:    %llu ns\n", value.last_syn_time);
                out << line;

                line = QString::asprintf("  SYN/s:         %llu\n", value.syn_rate);
                out << line;

                line = QString::asprintf("  Blocked?:   %s\n", value.blocked ? "Sí" : "No");
                out << line;

                if (value.blocked) {
                    line = QString::asprintf("  Block expires:%llu ns\n", value.block_expiry);
                    out << line;
                }
                out << "\n";
            }

            key = next_key;
        }
    }

    void dumpDdosBlacklist(QFile &file, int map_fd){
        QTextStream out(&file);
        __u32 key = 0, next_key;
        __u64 expiry_time = 0;

        char ip_str[INET_ADDRSTRLEN];

        out << "=== DDOS_BLACKLIST ===" << "\n";
        QString line;

        while (bpf_map_get_next_key(map_fd, &key, &next_key) == 0) {
            if (bpf_map_lookup_elem(map_fd, &next_key, &expiry_time) == 0) {

                __u32 ip_network_order = htonl(next_key);
                inet_ntop(AF_INET, &ip_network_order, ip_str, sizeof(ip_str));

                line = QString::asprintf("IP blocked:    %s\n", ip_str);
                out << line;

                line = QString::asprintf("  Expires:     %llu ns\n", expiry_time);
                out << line;

                out << "\n";
            }

            key = next_key;
        }
    }
}

