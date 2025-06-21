extern "C" {
    #include <stdio.h>
    #include <stdlib.h>
    #include <unistd.h>
    #include <errno.h>
    #include <ctype.h>
    #include <bpf/libbpf.h>
    #include <bpf/bpf.h>
    #include <arpa/inet.h>
    // Usa la ruta relativa o asegúrate de que la ruta absoluta es correcta
    #include "packet.h"  // Cambia esto a la ruta correcta
}
#include <iostream>
#include <cstdint>
int open_bpf_map_by_name(const char *map_name) {
    int map_fd = 0;

    map_fd = bpf_obj_get(map_name);

    if (map_fd < 0) {  // Cambio importante: comprobar si es menor que 0, no si es falso
        perror("Error al abrir el objeto BPF");
        return -1;
    }
    return map_fd;
}

bool insertRule(const char *ipStr) {
    
    int map_fd_blacklist = open_bpf_map_by_name("/sys/fs/bpf/filter_blacklist_wlp2s0");
    int map_fd_index = open_bpf_map_by_name("/sys/fs/bpf/filter_index_wlp2s0");
    __u64 rule_id = static_cast<__u64>(1);
    /*
    if (map_fd_blacklist < 0 || map_fd_index < 0) {
        fprintf(stderr, "Error abriendo los mapas BPF\n");
        return false;  // Comprobar si los mapas se abrieron correctamente
    }

    struct in_addr addr;
    if (inet_pton(AF_INET, ipStr, &addr) != 1) {
        fprintf(stderr, "IP inválida: %s\n", ipStr);
        return false;
    }
    
    // Obtenemos la ip
    __u32 ip = ntohl(addr.s_addr);
    
    // ID
    __u64 id = static_cast<__u64>(1);
    
    rule_value_t rule_key = {
        .ip = ip,
        .rule_id = id
    };
    
    // Inicializar completamente la estructura port_value_t
    struct port_value_t port_value;
    memset(&port_value, 0, sizeof(port_value));  // Inicializa toda la estructura a 0
    
    port_value.protocol = 0;
    port_value.active = 1;
    
    // La inicialización de port_bitmap ya se hizo con memset

    if (bpf_map_update_elem(map_fd_blacklist, &rule_key, &port_value, 0) < 0) {
        fprintf(stderr, "Error al actualizar el mapa blacklist: %s\n", strerror(errno));
        close(map_fd_blacklist);
        close(map_fd_index);
        return false;
    }
    
    // Actualizamos el indice
    struct ip_index_value_t index_value;

    if (bpf_map_lookup_elem(map_fd_index, &ip, &index_value) < 0) {
        // No existe, inicializamos una nueva entrada
        memset(&index_value, 0, sizeof(index_value));  // Inicializar correctamente
        index_value.count = 0;

        index_value.rules_ids[0] = id;
        index_value.count++;

        if (bpf_map_update_elem(map_fd_index, &ip, &index_value, 0) < 0) {
            perror("Error al crear nueva entrada en índice");
            close(map_fd_blacklist);
            close(map_fd_index);
            return false;
        }
    } else {
        // La IP ya existe en el índice
        
        // Buscamos que no este ya dentro
        bool found = false;
        for (unsigned int i = 0; i < index_value.count; i++) {  // Usar unsigned int en vez de int
            if (index_value.rules_ids[i] == id) {
                found = true;
                break;
            }
        }

        // Si no se encontró y hay espacio, añadir
        if (!found && index_value.count < MAX_RULES_PER_IP) {
            index_value.rules_ids[index_value.count++] = id;

            if (bpf_map_update_elem(map_fd_index, &ip, &index_value, BPF_ANY) < 0) {
                perror("Error al actualizar el índice");
                close(map_fd_blacklist);
                close(map_fd_index);
                return false;
            }
        } else if (!found) {
            fprintf(stderr, "Error: máximo número de reglas alcanzado\n");
            close(map_fd_blacklist);
            close(map_fd_index);
            return false;
        }
    }

    // Cerrar los descriptores de archivo
    close(map_fd_blacklist);
    close(map_fd_index);
    return true;*/
    struct in_addr addr;
    if (inet_pton(AF_INET, ipStr, &addr) != 1) {
        fprintf(stderr, "Dirección IP no válida: %s\n", ipStr);
        return -1;
    }
    //Obtenemos la ip 
    __u32 ip = ntohl(addr.s_addr);
    fprintf(stdout, "IP correcta: %s (u32: %u)\n", ipStr, ip);
    
    struct rule_value_t rule_key = {
        .ip = ip,
        .rule_id = rule_id
    };
    std::cout << "Tamaño struct port_value_t: " << sizeof(port_value_t) << std::endl;

    struct port_value_t port_value = {
        .active = 1,
        .protocol = 0,
    };
    //Creamos la rule con los puertos vacios
    memset(&port_value.port_bitmap,0,sizeof(port_value.port_bitmap));

    if (bpf_map_update_elem(map_fd_blacklist, &rule_key, &port_value, 0) < 0) {
        fprintf(stderr, "Error al actualizar el mapa blacklist: %s\n", strerror(errno));
        return -1;
    }
    std::cout << "Tamaño de mi sport_value_t: " << sizeof(port_value) << std::endl;
    // Actualizamos indice
    struct ip_index_value_t index_value;
    //Buscamos en el indice
    if (bpf_map_lookup_elem(map_fd_index, &ip, &index_value) < 0) { 
        // No existe, inicializamos una nueva entrada
        memset(index_value.rules_ids,0,sizeof(index_value.rules_ids));
        index_value.count = 0;

        index_value.rules_ids[0] = rule_id;
        index_value.count++;
        
        if (bpf_map_update_elem(map_fd_index,&ip,&index_value,0)) {
            perror("Error al crear nueva entrada en índice");
            return -1;
        }

    }else {
        // La IP ya existe en el índice
        bool found = false;
        for (int i = 0; i < index_value.count; i++) {
            if (index_value.rules_ids[i] == rule_id) {
                found = true;
                break;
            }
        }

        // Si no se encontró y hay espacio, añadir
        if (!found && index_value.count < MAX_RULES_PER_IP) {
            index_value.rules_ids[index_value.count++] = rule_id;

            if (bpf_map_update_elem(map_fd_index, &ip, &index_value,0)) {
                perror("Error al actualizar el índice");
                return -1;
            }

        }else if (!found) {
            perror("Error al crear nueva entrada en índice");
            return -1;
        }
    }

    return 0;
}

int main(int argc, char *argv[]) {
    (void)argc;  // Evitar la advertencia de parámetro no utilizado
    
    if (argv[1] == NULL) {
        fprintf(stderr, "Uso: %s <dirección_ip>\n", argv[0]);
        return 1;
    }

    if (insertRule(argv[1])) {
        printf("Regla insertada con éxito.\n");
    } else {
        fprintf(stderr, "Error al insertar la regla.\n");
        return 1;
    }

    return 0;
}