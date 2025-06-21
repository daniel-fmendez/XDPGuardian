#include "filteringmanager.h"
#include "Filter/dumpmetricsfunctions.h"
#include "Filter/analysisfunctions.h"



FilteringManager::FilteringManager(const QString& iface)
    : interfaceName(iface)
{
    ifindex = if_nametoindex(iface.toStdString().c_str());
    qDebug() << "Filter added: " + iface;
    if (!ifindex) {
        perror("if_nametoindex error");
    }
    blacklist_map_path = std::string(BLACKLIST_PATH) + "_" +interfaceName.toStdString();
    index_map_path = std::string(INDEX_PATH) + "_" +interfaceName.toStdString();
    hit_map_path = std::string(HITS_PATH) + "_" +interfaceName.toStdString();
    prot_map_path = std::string(PROT_PATH) + "_" +interfaceName.toStdString();
    packet_stats_map_path = std::string(PACKET_STATS_PATH) + "_" +interfaceName.toStdString();
    hit_rates_map_path = std::string(HIT_RATES_PATH) + "_" +interfaceName.toStdString();
    ip_hits_map_path = std::string(IP_HITS_PATH) + "_" +interfaceName.toStdString();
    port_hits_map_path = std::string(PORT_HITS_PATH) + "_" +interfaceName.toStdString();
    packet_dist_map_path = std::string(PACKET_DIST_PATH) + "_" +interfaceName.toStdString();
    tcp_flags_map_path = std::string(TCP_FLAGS_PATH) + "_" +interfaceName.toStdString();
    ip_flags_map_path = std::string(IP_FLAGS_PATH) + "_" +interfaceName.toStdString();
    syn_trackers_map_path = std::string(SYN_TRACKERS_PATH) + "_" +interfaceName.toStdString();
    ddos_blacklist_map_path = std::string(DDOS_BLACKLIS_PATH) + "_" +interfaceName.toStdString();
    attach();
}

FilteringManager::~FilteringManager() {
    detach();
    if (skel) {
        deletePinnedMap(blacklist_map_path);
        deletePinnedMap(index_map_path);
        deletePinnedMap(hit_map_path);
        deletePinnedMap(prot_map_path);
        deletePinnedMap(packet_stats_map_path);
        deletePinnedMap(hit_rates_map_path);
        deletePinnedMap(ip_hits_map_path);
        deletePinnedMap(port_hits_map_path);
        deletePinnedMap(packet_dist_map_path);
        deletePinnedMap(tcp_flags_map_path);
        deletePinnedMap(ip_flags_map_path);
        deletePinnedMap(syn_trackers_map_path);
        deletePinnedMap(ddos_blacklist_map_path);
        rule_bpf__destroy(skel);
    }
}

void FilteringManager::cleanup(){
    delete this;
}
void FilteringManager::deletePinnedMap(std::string path){
    std::string pin_path(path);
    try {
        if (std::filesystem::exists(path)) {
            if (std::filesystem::remove(path)) {
                qDebug() << "Map deleted: " << QString::fromStdString(path);
            } else {
                qDebug() << "Could not delete the map: " << QString::fromStdString(path);
            }
        }
    } catch (const std::filesystem::filesystem_error& e) {
        qDebug() << "Error deleting map: " << e.what();
    }
}
bool FilteringManager::attach() {
    skel = rule_bpf__open_and_load();

    if (!skel) {
        qWarning() << "Failed to open and load eBPF skeleton";
        return false;
    }
    if (bpf_map__pin(skel->maps.blacklist, blacklist_map_path.c_str())) {
        qWarning() << "Failed to pin blacklist map";
        return false;
    }
    if (bpf_map__pin(skel->maps.ip_rules_index, index_map_path.c_str())) {
        qWarning() << "Failed to pin index map";
        return false;
    }
    if (bpf_map__pin(skel->maps.rule_hits, hit_map_path.c_str())) {
        qWarning() << "Failed to pin hit map";
        return false;
    }
    if (bpf_map__pin(skel->maps.protocol_stats, prot_map_path.c_str())) {
        qWarning() << "Failed to pin prot map";
        return false;
    }
    if (bpf_map__pin(skel->maps.packet_stats, packet_stats_map_path.c_str())) {
        qWarning() << "Failed to pin packet_stats map";
        return false;
    }
    if (bpf_map__pin(skel->maps.hit_rates, hit_rates_map_path.c_str())) {
        qWarning() << "Failed to pin hit_rates map";
        return false;
    }
    if (bpf_map__pin(skel->maps.ip_hits, ip_hits_map_path.c_str())) {
        qWarning() << "Failed to pin ip_hits map";
        return false;
    }
    if (bpf_map__pin(skel->maps.port_hits, port_hits_map_path.c_str())) {
        qWarning() << "Failed to pin port hits map";
        return false;
    }
    if (bpf_map__pin(skel->maps.packet_size_dist, packet_dist_map_path.c_str())) {
        qWarning() << "Failed to pin packet distribution map";
        return false;
    }
    if (bpf_map__pin(skel->maps.tcp_flag_counts, tcp_flags_map_path.c_str())) {
        qWarning() << "Failed to pin tcp flags map";
        return false;
    }
    if (bpf_map__pin(skel->maps.ip_flag_counts, ip_flags_map_path.c_str())) {
        qWarning() << "Failed to pin ip flags map";
        return false;
    }
    if (bpf_map__pin(skel->maps.syn_trackers, syn_trackers_map_path.c_str())) {
        qWarning() << "Failed to pin syn trackers map";
        return false;
    }
    if (bpf_map__pin(skel->maps.ddos_blacklist, ddos_blacklist_map_path.c_str())) {
        qWarning() << "Failed to pin ddos blacklist map";
        return false;
    }
    if (bpf_xdp_attach(ifindex, bpf_program__fd(skel->progs.filter), 0, nullptr)) {
        qWarning() << "Failed to attach eBPF to interface" << interfaceName;
        return false;
    }

    return true;
}

bool FilteringManager::detach() {
    if (ifindex >= 0) {
        bpf_xdp_detach(ifindex, 0, nullptr);
        return true;
    }
    return false;
}

int open_bpf_map_by_name(const char *map_name) {
    int map_fd=0;

    map_fd=bpf_obj_get(map_name);

    if (!map_fd) {
        perror("Error opening the BPF objet");
        return -1;
    }
    return map_fd;
}

int FilteringManager::insertRule(const Ruleset& ruleset, const Rule& rule) {
    int map_fd_blacklist = open_bpf_map_by_name(blacklist_map_path.c_str());
    int map_fd_index = open_bpf_map_by_name(index_map_path.c_str());
    int map_fd_hit = open_bpf_map_by_name(hit_map_path.c_str());

    QByteArray ipBytes = rule.ip.toUtf8();
    const char* ipStr = ipBytes.constData();
    struct in_addr addr;
    if (inet_pton(AF_INET, ipStr, &addr) != 1) {
        return -1;
    }
    //Obtenemos la ip
    __u32 ip = ntohl(addr.s_addr);

    __u64 rule_id = rule.id;

    struct port_value_t port_value;

    if(rule.protocol =="IPv4"){
        port_value.protocol = 0; //ALL BLOCKED
    }else if(rule.protocol == "TCP"){
        port_value.protocol = 1; //TCP
    }else if(rule.protocol == "UDP") {
        port_value.protocol = 2; //UDP
    }else if(rule.protocol == "TCP/UDP"){
        port_value.protocol = 3;
    }else {
        port_value.protocol = 0; //NO PORTS, ALL BLOCKED
    }

    if(ruleset.isActive){
        port_value.active = rule.status;
    }else{
        port_value.active = 0;
    }

    //Creamos la rule con los puertos vacios
    memset(&port_value.port_bitmap,0,sizeof(port_value.port_bitmap));

    for (int port : rule.ports) {
        port_value.port_bitmap[port / 8] |= (1 << (port % 8));
    }
    if (bpf_map_update_elem(map_fd_blacklist, &rule_id, &port_value, 0) < 0) {
        return -1;
    }
    struct rule_hit_t hit_value;

    //hay datos previos los dejamos igual
    if(bpf_map_lookup_elem(map_fd_hit, &rule_id, &hit_value)<0){
        hit_value.count=0;
        hit_value.last_timestamp = 0;
        hit_value.bytes=0;
        //Insercion del hit
        if(bpf_map_update_elem(map_fd_hit, &rule_id, &hit_value, 0) < 0){
            return -1;
        }
    }

    //std::cout << "Tamaño de mi sport_value_t: " << sizeof(port_value) << std::endl;
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
            //perror("Error al crear nueva entrada en índice");
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
                return -1;
            }

        }else if (!found) {
            return -1;
        }
    }

    return 0;
}

bool FilteringManager::deleteRule(const Rule& rule) {
    int map_fd_blacklist = open_bpf_map_by_name(blacklist_map_path.c_str());
    int map_fd_index = open_bpf_map_by_name(index_map_path.c_str());
    int map_fd_hit = open_bpf_map_by_name(hit_map_path.c_str());

    QByteArray ipBytes = rule.ip.toUtf8();
    const char* ipStr = ipBytes.constData();
    struct in_addr addr;
    if (inet_pton(AF_INET, ipStr, &addr) != 1) {
        return -1;
    }
    //Obtenemos la ip
    __u32 ip = ntohl(addr.s_addr);
    __u64 rule_id = rule.id;
    struct ip_index_value_t index_value;
    //Borramos el hits
    bpf_map_delete_elem(map_fd_hit,&rule_id);

    if (bpf_map_lookup_elem(map_fd_index, &ip, &index_value) > 0){

        if(index_value.count <=1){
            bpf_map_delete_elem(map_fd_index, &ip);
        }else{
            for (int i = 0; i < index_value.count; i++) {
                if (index_value.rules_ids[i] == rule_id) {

                    for(int j = i; j< index_value.count; j++){
                        index_value.rules_ids[j] = index_value.rules_ids[j + 1];
                    }
                    index_value.rules_ids[index_value.count - 1] = 0;
                    index_value.count--;

                    if (bpf_map_update_elem(map_fd_index, &ip, &index_value, 0) < 0) {
                        perror("Error updating the index after having removed the rule");

                    }
                    break;
                }
            }
        }
    }


    if (bpf_map_delete_elem(map_fd_blacklist,&rule_id)) {
        perror("Error deleting IP from the blacklist");
        return false;
    }
    return true;
}

int FilteringManager::getHits(Rule& rule){
    int map_fd_hit = open_bpf_map_by_name(hit_map_path.c_str());
    struct rule_hit_t hit_value;
    __u64 rule_id = rule.id;

    if (bpf_map_lookup_elem(map_fd_hit, &rule_id, &hit_value)==0){
        if (hit_value.count > INT_MAX) {
            // Manejar error o ajustar
            rule.hits = INT_MAX;
            return INT_MAX;
        } else {

            rule.hits = static_cast<int>(hit_value.count);
            return static_cast<int>(hit_value.count);
        }
    }
    return 0;
}

void FilteringManager::dumpAll(){
    QString timestamp = QString::number(QDateTime::currentSecsSinceEpoch());
    QString exportPath = "/filter/dumps/"+timestamp;

    QDir dir(exportPath);
    if (!dir.exists()) {
        if (!dir.mkpath(".")) {
            qWarning() << "The folder could not be created:" << exportPath;
        }else{
            QProcess process;
            process.start("chmod", QStringList() << "777" << exportPath);
            process.waitForFinished();
        }
    }


    QString filename = timestamp + "_" + interfaceName + ".txt";
    QString filePath = exportPath + "/" + filename;
    QFile file(filePath);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Couldn't open the write file: " << filePath;
        return;
    }

    int map_fd_blacklist = open_bpf_map_by_name(blacklist_map_path.c_str());
    DumpMetricsFucntions::dumpBlacklist(file, map_fd_blacklist);

    int map_fd_index = open_bpf_map_by_name(index_map_path.c_str());
    DumpMetricsFucntions::dumpIndex(file, map_fd_index);

    int map_fd_hits = open_bpf_map_by_name(hit_map_path.c_str());
    DumpMetricsFucntions::dumpRuleHits(file, map_fd_hits);

    int map_fd_prot_stats = open_bpf_map_by_name(prot_map_path.c_str());
    DumpMetricsFucntions::dumpProtocolStats(file, map_fd_prot_stats);

    int map_fd_packet_stats = open_bpf_map_by_name(packet_stats_map_path.c_str());
    DumpMetricsFucntions::dumpPacketStats(file, map_fd_packet_stats);

    int map_fd_hit_rates = open_bpf_map_by_name(hit_rates_map_path.c_str());
    DumpMetricsFucntions::dumpHitRates(file, map_fd_hit_rates);

    int map_fd_ip_hits = open_bpf_map_by_name(ip_hits_map_path.c_str());
    DumpMetricsFucntions::dumpIpHits(file, map_fd_ip_hits);

    int map_fd_port_hits = open_bpf_map_by_name(port_hits_map_path.c_str());
    DumpMetricsFucntions::dumpPortHits(file, map_fd_port_hits);

    int map_fd_packet_size_dist = open_bpf_map_by_name(packet_dist_map_path.c_str());
    DumpMetricsFucntions::dumpPacketSizeDistribution(file, map_fd_packet_size_dist);

    int map_fd_tcp_flags = open_bpf_map_by_name(tcp_flags_map_path.c_str());
    DumpMetricsFucntions::dumpTcpFlagsCount(file, map_fd_tcp_flags);

    int map_fd_ip_flags = open_bpf_map_by_name(ip_flags_map_path.c_str());
    DumpMetricsFucntions::dumpIpFlagsCount(file, map_fd_ip_flags);

    int map_fd_syn_trackers = open_bpf_map_by_name(syn_trackers_map_path.c_str());
    DumpMetricsFucntions::dumpSynTrackers(file, map_fd_syn_trackers);

    int map_fd_ddos_blacklist = open_bpf_map_by_name(ddos_blacklist_map_path.c_str());
    DumpMetricsFucntions::dumpDdosBlacklist(file, map_fd_ddos_blacklist);

    file.close();
}

QList<Flag> FilteringManager::fetchTcpFlags(){
    int map_fd = open_bpf_map_by_name(tcp_flags_map_path.c_str());
    return AnalysisFunctions::fetchTcpFlags(map_fd);
}

QList<Prot> FilteringManager::fetchProtStats(){
    int map_fd = open_bpf_map_by_name(prot_map_path.c_str());
    return AnalysisFunctions::fetchProtStats(map_fd);
}

QList<IpHit> FilteringManager::fetchIpHits() {
    int map_fd = open_bpf_map_by_name(ip_hits_map_path.c_str());
    return AnalysisFunctions::fetchIpHits(map_fd);
}

QList<PortHit> FilteringManager::fetchPortHits() {
    int map_fd = open_bpf_map_by_name(port_hits_map_path.c_str());
    return AnalysisFunctions::fetchPortHits(map_fd);
}

QList<PacketDist> FilteringManager::fetchPacketDist() {
    int map_fd = open_bpf_map_by_name(packet_dist_map_path.c_str());
    return AnalysisFunctions::fetchPacketDist(map_fd);
}

QList<RuleHit> FilteringManager::fetchRuleHits() {
    int map_fd = open_bpf_map_by_name(hit_map_path.c_str());
    return AnalysisFunctions::fetchRuleHits(map_fd);
}

QList<BlockedIp> FilteringManager::fetchBlockedIps() {
    int map_fd = open_bpf_map_by_name(ddos_blacklist_map_path.c_str());
    return AnalysisFunctions::fetchBlockedIps(map_fd);
}
