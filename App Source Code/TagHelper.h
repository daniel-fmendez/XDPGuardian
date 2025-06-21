#ifndef TAGHELPER_H
#define TAGHELPER_H
#include <QObject>


class TagHelper : public QObject {
    Q_OBJECT
public:
    enum TagType {
        ERROR,
        RULE_CREATED,
        RULE_DELETED,
        ATTEMPT,
        INFO
    };
    Q_ENUM(TagType)  // Esto permite usar el enum en QML

    static QString tagToString(TagType tag);
};


#endif // TAGHELPER_H
