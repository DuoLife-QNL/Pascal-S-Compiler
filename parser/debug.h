//
// Created by 侯崴瀛 on 2020-06-25.
//

#ifndef DEBUG_H
#define DEBUG_H
#include <iostream>
#include <string>

#define DEBUG 7

#define ERR_FLAG 1
#define WARN_FLAG 2
#define INFO_FLAG 4

#define err(file, line, msg) debug(ERR_FLAG,file,line,msg)
#define warn(file, line, msg) debug(WARN_FLAG,file,line,msg)
#define info(file, line, msg) debug(INFO_FLAG,file,line,msg)

void debug(const int level, const char *file, int line, std::string msg);

#endif