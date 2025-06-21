#define ETH_P_IP	0x0800		/* Internet Protocol packet	*/
#define ETH_P_IPV6	0x86DD		/* IPv6 over bluebook		*/
#define ETH_P_ARP	0x0806		/* Address Resolution packet	*/
#define ETH_P_8021Q	0x8100          /* 802.1Q VLAN Extended Header  */

#define BLACKLIST_PATH "/sys/fs/bpf/filter_blacklist"
#define INDEX_PATH "/sys/fs/bpf/filter_index"
#define HITS_PATH "/sys/fs/bpf/filter_hits"
#define PROT_PATH "/sys/fs/bpf/filter_prot"
#define PACKET_STATS_PATH "/sys/fs/bpf/filter_packet_stats"
#define HIT_RATES_PATH "/sys/fs/bpf/filter_packet_hit_rates"
#define IP_HITS_PATH "/sys/fs/bpf/filter_ip_hits"
#define PORT_HITS_PATH "/sys/fs/bpf/filter_port_hits"
#define PACKET_DIST_PATH "/sys/fs/bpf/filter_packet_size_dist"
#define TCP_FLAGS_PATH "/sys/fs/bpf/filter_tcp_flags"
#define IP_FLAGS_PATH "/sys/fs/bpf/filter_ip_flags"
#define SYN_TRACKERS_PATH "/sys/fs/bpf/filter_syn_trackers"
#define DDOS_BLACKLIS_PATH "/sys/fs/bpf/filter_ddos_blacklist"

#define MAX_RULES_PER_IP 128

struct ip_value_t {
    char ip_str[16];    
};

struct rule_value_t {
    __u32 ip;
    __u64 rule_id;
};

struct ip_index_value_t {
    __u32 count;            // Número de rulesets que contienen esta IP
    __u64 rules_ids[MAX_RULES_PER_IP];  // Array con los IDs de ruleset
};

typedef struct port_value_t {
    __u8 active;
    __u8 protocol;
    __u8 port_bitmap[8192];
} port_value_t;

struct rule_hit_t {
    __u64 count;           // Número de hits (paquetes por rule)
    __u64 last_timestamp;  // Último hit (tiempo Unix en ns) desde boot
    __u64 bytes;           // Total de bytes
};

// Nuevas estructuras
struct protocol_stats_t {
    __u64 packets_total;    // Total de paquetes vistos para este protocolo
    __u64 bytes_total;      // Total de bytes procesados para este protocolo
    __u64 last_seen;        // Último timestamp donde se vio este protocolo
};

struct packet_stats_t {
    __u32 min_size;         // Tamaño mínimo de paquete visto
    __u32 max_size;         // Tamaño máximo de paquete visto
    __u64 size_sum;         // Suma de tamaños (para calcular promedio)
    __u64 count;            // Conteo de paquetes
    __u8 ttl_distribution[64]; // Distribución de valores TTL (para detectar spoofing)
};

struct ip_hit_t {
    __u64 packets;
    __u64 bytes;
    __u64 last_seen;
};

//16 segundos de ventana
struct hit_rate_t {
    __u64 last_update;              // Último timestamp de actualización
    __u32 hits_current_window;      // Hits en la ventana actual
    __u32 bytes_current_window;     // Bytes en la ventana actual
    __u32 hit_rate_history[16];      // Historial de tasas de hit (hits/segundo)
    __u32 byte_rate_history[16];     // Historial de tasas de bytes (bytes/segundo)
};

// 0 = FIN, 1 = SYN, 2 = RST, 3 = PSH, 4 = ACK, 5 = URG, 6 = ECE,  7 = CWR, (OMITIMOS NS)
struct ip_flag_t {
    __u64 fin_flag;
    __u64 syn_flag;
    __u32 rst_flag;
    __u32 psh_flag;
    __u64 ack_flag;
    __u16 urg_flag;
    __u16 ece_flag;
    __u16 cwr_flag;
};

// Valores para todos los puertos
struct port_stats {
    __u64 last_update;
    __u32 current_hits;
    __u32 current_bytes;
    __u32 hits_history[16];
    __u32 bytes_history[16];
};

// Para seguimiento de conexiones SYN por IP
struct syn_tracker_t {
    __u64 syn_count;           // Cantidad de SYNs recibidos
    __u64 ack_count;           // Cantidad de ACKs recibidos
    __u64 last_syn_time;       // Timestamp del último SYN
    __u64 syn_rate;            // Tasa de SYNs por segundo
    __u8 blocked;              // Estado de bloqueo (0=no, 1=sí)
    __u64 block_expiry;        // Timestamp cuando expira el bloqueo en ns (desde boot)
};

// Para configuración de umbrales
struct ddos_config_t {
    __u64 syn_threshold;       // Máximo SYNs por segundo permitidos
    __u64 syn_ack_ratio;       // Ratio mínimo permitido de ACK/SYN
    __u64 block_duration;      // Duración del bloqueo en ns (desde boot)
    __u64 pps_threshold;       // Paquetes por segundo máximos
};