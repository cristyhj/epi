#ifndef _ENGINE_H_
#define _ENGINE_H_


void engine_set(int fd, int index, char *pattern, int len);
int engine_get_maxnr(int fd);
int engine_get_maxpatternlen(int fd);
int engine_get_avgtime(int fd);
void engine_get_cfgreg(int fd, int index);
int engine_get_pattern(int fd, int index, char *pattern_buff);
void engine_set_cfgreg(int fd, int index, int pattern_len);
int engine_get_lineartime(int fd);


#endif