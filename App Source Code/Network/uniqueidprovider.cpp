#include "uniqueidprovider.h"

long UniqueIdProvider::current_id = 0;
std::queue<long> UniqueIdProvider::unused_ids;

long UniqueIdProvider::getId() {
    if(unused_ids.empty()){
        return current_id++;
    }else{
        long id = unused_ids.front();
        unused_ids.pop();
        return id;
    }
}

void UniqueIdProvider::releaseId(long id){
    unused_ids.push(id);
}
