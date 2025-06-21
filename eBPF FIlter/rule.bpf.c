#include <linux/bpf.h>
#include <bpf/bpf_endian.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_core_read.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <linux/tcp.h>
#include <linux/udp.h>
#include <arpa/inet.h>
#include "packet.h"

struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 8192);
    __type(key, __u32);             //IP en formato u32
    __type(value, struct ip_index_value_t);
} ip_rules_index SEC(".maps");

struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 8192);
    __type(key, __u64); //ID de reglas 
    __type(value, struct port_value_t);
} blacklist SEC(".maps");

struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 16384);
    __type(key, __u64);    // ID de regla
    __type(value, struct rule_hit_t);
} rule_hits SEC(".maps");

// Nuevos mapas
// Hits a una ip
struct {
    __uint(type, BPF_MAP_TYPE_LRU_HASH);
    __uint(max_entries, 4096);
    __type(key, __u32);    // IP de origen
    __type(value, struct ip_hit_t);
} ip_hits SEC(".maps");

// Estadísticas por protocolo
struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 256);         //TCP, UDP, etc
    __type(key, __u8);             // Tipo de protocolo
    __type(value, struct protocol_stats_t);
} protocol_stats SEC(".maps");

// Estadísticas de paquetes
struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 256);       //TCP, UDP, etc
    __type(key, __u8);             // Protocolo
    __type(value, struct packet_stats_t);
} packet_stats SEC(".maps");

// Tasas de trafico
struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 256);
    __type(key, __u64);            // ID de regla
    __type(value, struct hit_rate_t);
} hit_rates SEC(".maps");

//Distribucion de tamaños de reglas en cubetas
struct {
    __uint(type, BPF_MAP_TYPE_ARRAY);
    __uint(max_entries, 32); // 32 buckets de tamaño 64 (max 65536)
    __type(key, __u32);      // Índice del bucket
    __type(value, __u64);    // Contador
} packet_size_dist SEC(".maps");

// Contadores por puerto de destino
struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 65536); // Los mas activos
    __type(key, __u16);       // Puerto
    __type(value, __u64);     // Contador
} port_hits SEC(".maps");

// Contabilizar las flags para todas las conexiones
struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 8);         // 0 = FIN, 1 = SYN, 2 = RST, 3 = PSH, 4 = ACK, 5 = URG, 6 = ECE,  7 = CWR, (OMITIMOS NS)
    __type(key, __u8);             // Valor numerico de la flag
    __type(value, __u64);           // Contador
} tcp_flag_counts SEC(".maps");

// Contabilizar las flags por ip
struct {
    __uint(type, BPF_MAP_TYPE_LRU_HASH);
    __uint(max_entries, 2048);          // Aumentar para mayor rango de precision
    __type(key, __u32);                 // Valor numerico de la flag
    __type(value, struct ip_flag_t);    // Contador
} ip_flag_counts SEC(".maps");

// Defensa Automatica
// Mapa para seguimiento de conexiones SYN por IP origen
struct {
    __uint(type, BPF_MAP_TYPE_LRU_HASH);
    __uint(max_entries, 8192);
    __type(key, __u32);                // IP origen
    __type(value, struct syn_tracker_t);
} syn_trackers SEC(".maps");

// Mapa para lista negra dinámica (bloqueo temporal)
struct {
    __uint(type, BPF_MAP_TYPE_LRU_HASH);
    __uint(max_entries, 4096);          // Aumentar para mayor rango
    __type(key, __u32);                 // IP origen
    __type(value, __u64);               // Timestamp de expiración del bloqueo en ns
} ddos_blacklist SEC(".maps");

struct {
    __uint(type, BPF_MAP_TYPE_ARRAY);
    __uint(max_entries, 1);
    __type(key, __u32);                // Solo hay entrada 0
    __type(value, struct ddos_config_t);
} ddos_config SEC(".maps");

static void updateProtStats(__u8 protocol_key, __u64 pkt_len){

    struct protocol_stats_t *proto_stats = bpf_map_lookup_elem(&protocol_stats, &protocol_key);
    __u64 now = bpf_ktime_get_boot_ns();

    if (proto_stats) {
        proto_stats->packets_total++;
        proto_stats->bytes_total += pkt_len;
        proto_stats->last_seen = now;
    } else {
        struct protocol_stats_t new_stats = {
            .packets_total = 1,
            .bytes_total = pkt_len,
            .last_seen = now
        };
        bpf_map_update_elem(&protocol_stats, &protocol_key, &new_stats, BPF_ANY);
    }
}

static void updatePacketStats(__u8 protocol_key, __u64 pkt_len, __u8 ttl){
    struct packet_stats_t *pkt_stats = bpf_map_lookup_elem(&packet_stats, &protocol_key);
    if (pkt_stats) {
        if (pkt_len < pkt_stats->min_size) pkt_stats->min_size = pkt_len;
        if (pkt_len > pkt_stats->max_size) pkt_stats->max_size = pkt_len;
        pkt_stats->size_sum += pkt_len;
        pkt_stats->count++;
        // Actualizar distribución TTL (limitado por verificaciones del verificador BPF)
        if (ttl < 64) {
            pkt_stats->ttl_distribution[ttl]++;
        }
    } else {
        struct packet_stats_t new_pkt_stats = {
            .min_size = pkt_len,
            .max_size = pkt_len,
            .size_sum = pkt_len,
            .count = 1
        };
        // Inicializar distribución TTL
        if (ttl < 64) {
            new_pkt_stats.ttl_distribution[ttl] = 1;
        }
        bpf_map_update_elem(&packet_stats, &protocol_key, &new_pkt_stats, BPF_ANY);
    }
}

static void updateIpHIts(__u32 ip, __u64 pkt_size){
    struct ip_hit_t *ip_stat;
    ip_stat = bpf_map_lookup_elem(&ip_hits, &ip);
    if (ip_stat) {
        ip_stat->packets++;
        ip_stat->bytes += pkt_size;
        ip_stat->last_seen = bpf_ktime_get_boot_ns();
    } else {
        struct ip_hit_t new_stat = {1, pkt_size, bpf_ktime_get_boot_ns()};
        bpf_map_update_elem(&ip_hits, &ip, &new_stat, BPF_ANY);
    }
}

static void updatePktSizeDist(__u64 pkt_size){
    __u32 size_bucket = pkt_size / 64;  // Buckets de 64 bytes
    if (size_bucket >= 32) size_bucket = 31;
        __u64 *size_count = bpf_map_lookup_elem(&packet_size_dist, &size_bucket);
    if (size_count) 
        (*size_count)++;
}

static void updateHitRates(__u64 id, __u64 pkt_size){
    struct hit_rate_t *rate = bpf_map_lookup_elem(&hit_rates, &id);
    __u64 now = bpf_ktime_get_boot_ns();
    
    if (rate) {
        // Calcular diferencia de tiempo
        __u64 time_diff = now - rate->last_update;
        
        // Verificar que el tiempo sea válido (evitar valores negativos por overflow)
        if (time_diff > 1000000000ULL && time_diff < 10000000000ULL) { // Entre 1 y 10 segundos
            // Mover historial hacia la derecha
            #pragma unroll
            for (int i = 15; i > 0; i--) {
                rate->hit_rate_history[i] = rate->hit_rate_history[i-1];
                rate->byte_rate_history[i] = rate->byte_rate_history[i-1];
            }
            
            // Calcular tasas con protección contra división por cero
            __u64 hits_per_sec = 0;
            __u64 bytes_per_sec = 0;
            
            if (time_diff > 0) {
                // Usar divisores seguros para evitar overflow
                hits_per_sec = (rate->hits_current_window * 1000000000ULL) / time_diff;
                bytes_per_sec = (rate->bytes_current_window * 1000000000ULL) / time_diff;
                
                // Limitar valores máximos para evitar desbordamiento
                if (hits_per_sec > 1000000) hits_per_sec = 1000000;
                if (bytes_per_sec > 1000000000ULL) bytes_per_sec = 1000000000ULL;
            }
            
            rate->hit_rate_history[0] = hits_per_sec;
            rate->byte_rate_history[0] = bytes_per_sec;
            
            // Reiniciar contadores
            rate->hits_current_window = 1;
            rate->bytes_current_window = pkt_size;
            rate->last_update = now;
            
        } else if (time_diff <= 1000000000ULL) {
            // Acumular en ventana actual
            rate->hits_current_window++;
            rate->bytes_current_window += pkt_size;
            
        } else {
            // Si time_diff es demasiado grande, reiniciar
            rate->hits_current_window = 1;
            rate->bytes_current_window = pkt_size;
            rate->last_update = now;
            
            // Limpiar historial
            #pragma unroll
            for (int i = 0; i < 16; i++) {
                rate->hit_rate_history[i] = 0;
                rate->byte_rate_history[i] = 0;
            }
        }
        
    } else {
        // Crear nueva entrada con inicialización completa
        struct hit_rate_t new_rate = {};  // Inicializar todo a cero
        
        new_rate.last_update = now;
        new_rate.hits_current_window = 1;
        new_rate.bytes_current_window = pkt_size;
        
        // Inicializar arrays explícitamente
        #pragma unroll
        for (int i = 0; i < 16; i++) {
            new_rate.hit_rate_history[i] = 0;
            new_rate.byte_rate_history[i] = 0;
        }
        
        bpf_map_update_elem(&hit_rates, &id, &new_rate, BPF_NOEXIST);
    }
}
//Defensa ante SYN FLOOD
static int check_syn_flood(__u32 src_ip, int is_syn, int is_ack, __u64 now){
    struct syn_tracker_t *tracker = bpf_map_lookup_elem(&syn_trackers, &src_ip);

    __u64 syn_threshold = 100;
    __u64 block_duration = 10000000000; // 10 segundos por defecto

    //Posible configuracion personalizada

    //__u32 config_key = 0;
    //struct ddos_config_t *config = bpf_map_lookup_elem(&ddos_config, &config_key);

    /*if(config){
        syn_threshold = config->syn_threshold;
        block_duration = config->block_duration;
    }*/
    
    
    // Comprobar si la IP está en la blacklist
    __u64 *expiry = bpf_map_lookup_elem(&ddos_blacklist, &src_ip);

    // Verificar si la IP está bloqueada y si el bloqueo ha expirado
    if (expiry) {
        // Verificar si la expiración ha pasado
        if (*expiry <= now) {
            // El bloqueo ha expirado, eliminar de la blacklist
            bpf_map_delete_elem(&ddos_blacklist, &src_ip);
            
            // Actualizar también el tracker si existe
            if (tracker) {
                tracker->blocked = 0;
                tracker->block_expiry = 0;
            }
        } else {
            // Todavía está bloqueado
            return 1; // Mantener bloqueado
        }
    }

    // Si no hay tracker para esta IP pero hay actividad, crear uno nuevo
    if (!tracker && (is_syn || is_ack)) {
        struct syn_tracker_t new_tracker = {
            .syn_count = is_syn ? 1 : 0,
            .ack_count = is_ack ? 1 : 0,
            .last_syn_time = now,
            .syn_rate = 0,
            .blocked = 0,
            .block_expiry = 0
        };
        bpf_map_update_elem(&syn_trackers, &src_ip, &new_tracker, BPF_ANY);
        return 0; // No bloqueado, es nuevo
    }

    // Si existe tracker, verificar si estaba marcado como bloqueado pero no está en blacklist
    if (tracker && tracker->blocked) {
        if (tracker->block_expiry <= now) {
            // El bloqueo ha expirado según el tracker
            tracker->blocked = 0;
            tracker->block_expiry = 0;
            
        } else {
            // Debería estar bloqueado según el tracker, verificar si está en blacklist
            if (!expiry) {
                // No está en blacklist pero debería estarlo, reañadir
                bpf_map_update_elem(&ddos_blacklist, &src_ip, &tracker->block_expiry, BPF_ANY);
            }
            return 1; // Mantener bloqueado
        }
    }

    // A partir de aquí, la IP no está bloqueada, actualizar estadísticas
    if (tracker) {
        if (is_ack) {
            tracker->ack_count++;
        }
        if (is_syn) {
            tracker->syn_count++;
            __u64 time_diff = now - tracker->last_syn_time;
            if (time_diff > 1000000000) { // 1 segundo en ns
                // Calcular tasa de SYNs por segundo
                
                tracker->syn_rate = (tracker->syn_count * 1000000000) / time_diff;
                
                // Detectar SYN flood                             
                if (tracker->syn_rate > syn_threshold && 
                    (tracker->ack_count * 2) < tracker->syn_count) {
                    
                    // Añadir a blacklist
                    __u64 block_time = now + block_duration;
                    bpf_map_update_elem(&ddos_blacklist, &src_ip, &block_time, BPF_ANY);

                    // Actualizar tracker
                    tracker->blocked = 1;
                    tracker->block_expiry = block_time;
                    
                    return 1; // Bloquear
                }
                
                
                // Resetear para nueva ventana si pasó mucho tiempo
                if (time_diff > 10000000000) { // 10 segundos
                    tracker->syn_count = is_syn ? 1 : 0;
                    tracker->ack_count = is_ack ? 1 : 0;
                }
                
                tracker->last_syn_time = now;
            }
        }
    }
    
    return 0; // No bloqueado
}
//Programa XDP
SEC("xdp")
int filter(struct xdp_md *ctx){
    void *data_end = (void *)(long)ctx->data_end;
    void *data = (void *)(long)ctx->data;

    struct ethhdr *eth = data;
    long protocol=0;
    if (data + sizeof(struct ethhdr) > data_end)
        return XDP_DROP;
    protocol=bpf_ntohs(eth->h_proto);

    //Tratamos IPV4
    if(protocol==ETH_P_IP){

        struct iphdr *iphdr=(void *)(data+sizeof(struct ethhdr));
        
        if(data + sizeof(struct ethhdr) + sizeof(struct iphdr)> data_end){
            return XDP_DROP;
        }
        
        //Traducimos de big-endian (NET) a little-endian (PC) (o de ser un dispositivo big-endian se queda igual)
        __u32 src = bpf_ntohl(iphdr->saddr);
        __u32 dest = bpf_ntohl(iphdr->daddr);
        // A falta de funciones helper  Inet_ntop casero
        char src_str[16];  // Buffer Source
        char dest_str[16];  // Buffer Destino
        __u64 dataArr[4];  // Array de 64 bits

        // Obtenemos direcciones
        dataArr[0] = ((src >> 24) & 0xFF);
        dataArr[1] = ((src >> 16) & 0xFF);
        dataArr[2] = ((src >> 8) & 0xFF);
        dataArr[3] = ((src) & 0xFF);
        // Escribimos en el buffer la direccion
        __builtin_memset(src_str, 0, sizeof(dest_str));  
        bpf_snprintf(src_str, sizeof(src_str), "%d.%d.%d.%d", &dataArr, sizeof(dataArr));

        // Empaquetar los octetos en un solo valor de 64 bits
        dataArr[0] = ((dest >> 24) & 0xFF);
        dataArr[1] = ((dest >> 16) & 0xFF);
        dataArr[2] = ((dest >> 8) & 0xFF);
        dataArr[3] = ((dest) & 0xFF);

        __builtin_memset(dest_str, 0, sizeof(dest_str));  
        bpf_snprintf(dest_str, sizeof(dest_str), "%d.%d.%d.%d", &dataArr, sizeof(dataArr));
        
        // Muestra por /sys/kernel/tracing/trace_pipe los paquetes entrantes
        bpf_printk("src: %s dest %s \n",src_str,dest_str);
        
        // Analisis por TCP, previo al bloqueo
        if(iphdr->protocol==6){
            struct tcphdr *tcphdr=(void *)(data+sizeof(struct ethhdr)+sizeof(struct iphdr));
                           
            if(data + sizeof(struct ethhdr) + sizeof(struct iphdr) + sizeof(struct tcphdr)> data_end){
                return XDP_DROP;
            }
            __u64 now = bpf_ktime_get_boot_ns();

            int syn_detected = tcphdr->syn ? 1 : 0;
            int ack_detected = tcphdr->ack ? 1 : 0;

            int block_syn = check_syn_flood(src, syn_detected, ack_detected, now);
            if (block_syn) {
                //bpf_printk("SYN flood bloqueado: %s", src_str);
                return XDP_DROP;
            }

            __u16 port = bpf_ntohs(tcphdr->dest);
            
            // Contabilizar puertos
            __u64 *port_count = bpf_map_lookup_elem(&port_hits, &port);
            if (port_count) (*port_count)++;
            else {
                __u64 val = 1;
                bpf_map_update_elem(&port_hits, &port, &val, BPF_ANY);
            }

            //Contabilizar flags
            //Formamos el byte de flags (ns es de control, no accesible)
            __u8 flags = 0;
            flags |= (tcphdr->fin) ? 1 : 0;
            flags |= (tcphdr->syn) ? 2 : 0;
            flags |= (tcphdr->rst) ? 4 : 0;
            flags |= (tcphdr->psh) ? 8 : 0;
            flags |= (tcphdr->ack) ? 16 : 0;
            flags |= (tcphdr->urg) ? 32 : 0;
            flags |= (tcphdr->ece) ? 64 : 0;
            flags |= (tcphdr->cwr) ? 128 : 0;
            
            //Bucle para recorre el byte de flags
            for (int i = 0; i < 8; i++) {
                if (flags & (1 << i)) {
                    __u16 flag_key = i;
                    __u64 *flag_val = bpf_map_lookup_elem(&tcp_flag_counts, &flag_key);
                    if (flag_val) {
                        __sync_fetch_and_add(flag_val, 1);
                    } else {
                        __u64 init_val = 1;
                        bpf_map_update_elem(&tcp_flag_counts, &flag_key, &init_val, BPF_ANY);
                    }
                }
            }

            //Parte para ips
            struct ip_flag_t *ip_flag = bpf_map_lookup_elem(&ip_flag_counts, &src);
            if(ip_flag){
                if(tcphdr->fin) (ip_flag->fin_flag++);
                if(tcphdr->syn) (ip_flag->syn_flag++);
                if(tcphdr->rst) (ip_flag->rst_flag++);
                if(tcphdr->psh) (ip_flag->psh_flag++);
                if(tcphdr->ack) (ip_flag->ack_flag++);
                if(tcphdr->urg) (ip_flag->urg_flag++);
                if(tcphdr->ece) (ip_flag->ece_flag++);
                if(tcphdr->cwr) (ip_flag->cwr_flag++);
            } else {
                struct ip_flag_t new_ip_flag = {
                    .fin_flag = tcphdr->fin ? 1 : 0,
                    .syn_flag = tcphdr->syn ? 1 : 0,
                    .rst_flag = tcphdr->rst ? 1 : 0,
                    .psh_flag = tcphdr->psh ? 1 : 0,
                    .ack_flag = tcphdr->ack ? 1 : 0,
                    .urg_flag = tcphdr->urg ? 1 : 0,
                    .ece_flag = tcphdr->ece ? 1 : 0,
                    .cwr_flag = tcphdr->cwr ? 1 : 0
                };

                bpf_map_update_elem(&ip_flag_counts, &src, &new_ip_flag, BPF_ANY);
            }
        //UDP
        } else if (iphdr->protocol == 17) {
            struct udphdr *udphdr=(void *)(data+sizeof(struct ethhdr)+sizeof(struct iphdr));
        
            if (data + sizeof(struct ethhdr) + sizeof(struct iphdr) + sizeof(struct udphdr) > data_end) {
                bpf_printk("Paquete demasiado pequeño para ajustar");
                return XDP_DROP;
            }
        
            __u16 port = bpf_ntohs(udphdr->dest);

            __u64 *port_count = bpf_map_lookup_elem(&port_hits, &port);
            if (port_count) (*port_count)++;
            else {
                __u64 val = 1;
                bpf_map_update_elem(&port_hits, &port, &val, BPF_ANY);
            }
        }
        //Analisis por protocolo
        __u8 protocol_key = iphdr->protocol;
        __u32 pkt_size = ctx->data_end - ctx->data;

        updateProtStats(protocol_key, pkt_size);
        //Fin de protocolo 

        //Analisis de paquetes
        updatePacketStats(protocol_key,pkt_size, iphdr->ttl);
        //Fin de paquetes
        
        // Analisis por IP
        updateIpHIts(src, pkt_size);
        
        // Mapeo por cubetas
        updatePktSizeDist(pkt_size);
        //Inicio del proceso de bloqueo
        struct ip_index_value_t *src_index=(struct ip_index_value_t *) bpf_map_lookup_elem(&ip_rules_index,&src);

        // No estan en el indice, no hay bloqueo
        if (!src_index) {
            return XDP_PASS;
        }
        
        // Bucle para el origen
        for (int i = 0; i < MAX_RULES_PER_IP; i++) {
            
            if (i >= src_index->count)
                break;
            __u64 id = src_index->rules_ids[i];

            //bpf_printk("SRC: %u RULE_ID: %lu",key.ip,key.rule_id);
            //Buscamos los puertos
            struct port_value_t *block = bpf_map_lookup_elem(&blacklist, &id);
            struct rule_hit_t *hit = bpf_map_lookup_elem(&rule_hits, &id);

            if(block && hit){
                __u64 pkt_len = ctx->data_end - ctx->data;
                //La denegacion se hará aquí
                if(block->active){
                    //Nuevo para analisis
                    
                    //Caso de 0, se bloquea todo lo que llegue
                    if(!block->protocol){
                        //bpf_printk("Bloqueado From: %s To:%s Type:%d\n",src_str,dest_str,iphdr->protocol);
                        
                        hit->count++;
                        hit->last_timestamp = bpf_ktime_get_boot_ns();
                        hit->bytes+= pkt_len;
                        
                        updateHitRates(id, pkt_len);
                        return XDP_DROP;
                    }
                    if(iphdr->protocol==6 && (block->protocol==1 || block->protocol==3)){
                        struct tcphdr *tcphdr=(void *)(data+sizeof(struct ethhdr)+sizeof(struct iphdr));
                           
                        if(data + sizeof(struct ethhdr) + sizeof(struct iphdr) + sizeof(struct tcphdr)> data_end){
                            return XDP_DROP;
                        }
                        
                        __u16 port = bpf_ntohs(tcphdr->dest);


                        //Bloqueamos
                        if(block->port_bitmap[port/8] & (1 << (port%8))){
                            //bpf_printk("Bloqueado From: %s To:%s Type:%d\n",src_str,dest_str,iphdr->protocol);

                            hit->count++;
                            hit->last_timestamp = bpf_ktime_get_boot_ns();
                            hit->bytes+= pkt_len;
                            updateHitRates(id, pkt_len);
                            return XDP_DROP;
                        }
        
                    } else if(iphdr->protocol==17 && (block->protocol==2 || block->protocol==3)){
                              
                        struct udphdr *udphdr=(void *)(data+sizeof(struct ethhdr)+sizeof(struct iphdr));
        
                        if (data + sizeof(struct ethhdr) + sizeof(struct iphdr) + sizeof(struct udphdr) > data_end) {
                            return XDP_DROP;
                        }
        
                        __u16 port = bpf_ntohs(udphdr->dest);

                        if(block->port_bitmap[port/8] & (1 << (port%8))){
                            //bpf_printk("Bloqueado From: %s To:%s Port:%d\n",src_str,dest_str,port);
                            
                            hit->count++;
                            hit->last_timestamp = bpf_ktime_get_boot_ns();
                            hit->bytes+= pkt_len;
                            updateHitRates(id, pkt_len);
                            return XDP_DROP;
                        }
                    }
                }
            }else{
                bpf_printk("Error with look up elem");
            }
        }
        return XDP_PASS;       
    }
    return XDP_PASS;
}
char _license[] SEC("license") = "GPL";