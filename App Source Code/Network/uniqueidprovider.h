#ifndef UNIQUEIDPROVIDER_H
#define UNIQUEIDPROVIDER_H

#include <queue>
class UniqueIdProvider
{
public:
    UniqueIdProvider() = delete;

    static long getId();
    static void releaseId(long id);

private:
    static long current_id;
    static std::queue<long> unused_ids;
};

#endif // UNIQUEIDPROVIDER_H
