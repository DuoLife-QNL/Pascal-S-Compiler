//
// Created by 侯崴瀛 on 2020-06-25.
//

#include "debug.h"

void debug(const int level, const char *file, int line, std::string msg) {
    std::string level_head;
    switch (level) {
        case INFO_FLAG:level_head = "\033[32m[info]\033[0m ";
            break;
        case WARN_FLAG:level_head = "\033[33m[warn]\033[0m ";
            break;
        case ERR_FLAG:level_head = "\033[31m[error]\033[0m ";
            break;
        default:level_head = "[unknow]";
            break;
    }

    if (level & DEBUG) {
        std::cout << level_head << file << "#" << line << ": " << msg
                  << std::endl;
    }
}

