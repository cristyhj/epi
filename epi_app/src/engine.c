#include "engine.h"

#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>

#include <sys/ioctl.h>

#include "../../include/epi_common.h"

void engine_set(int fd, int index, char *pattern, int len) {
    struct engine eng;
    int engines_nr;
    int max_pattern_len;
    unsigned int packets;
    int return_val;

    engines_nr = engine_get_maxnr(fd);
    max_pattern_len = engine_get_maxpatternlen(fd);
    
    if (index > engines_nr) {
        printf("Cannot set engine %d. Not enough engines!\n", index);
        return;
    }
    if (len > max_pattern_len) {
        printf("Cannot set engine pattern. Max pattern len is %d!\n", max_pattern_len);
        return;
    }

    eng.index = index;
    eng.config_reg = ENGINE_ON_LEN(len);
    memcpy(eng.pattern, pattern, len);

    return_val = ioctl(fd, EPI_IOC_SET_ENG_PATTERN, &eng);
}

void engine_set_cfgreg(int fd, int index, int pattern_len) {
        struct engine eng;
    int engines_nr;
    int max_pattern_len;
    unsigned int packets;
    int return_val;

    engines_nr = engine_get_maxnr(fd);
    max_pattern_len = engine_get_maxpatternlen(fd);
    
    if (index > engines_nr) {
        printf("Cannot set engine %d. Not enough engines!\n", index);
        return;
    }
    if (pattern_len > max_pattern_len) {
        printf("Cannot set engine pattern. Max pattern len is %d!\n", max_pattern_len);
        return;
    }

    eng.index = index;
    eng.config_reg = ENGINE_ON_LEN(pattern_len);

    ioctl(fd, EPI_IOC_SET_ENG_CFGREG, &eng);
}

int engine_get_pattern(int fd, int index, char *pattern_buff) {
    struct engine eng;
    int engines_nr;
    unsigned int packets;
    int return_val;
    int len;

    memset(&eng, 0, sizeof(eng));

    engines_nr = engine_get_maxnr(fd);
    
    if (index > engines_nr) {
        printf("Cannot get engine %d. Out of range!\n", index);
        return -1;
    }
    eng.index = index;
    return_val = ioctl(fd, EPI_IOC_GET_ENG_CFGREG, &eng);
    if ((eng.config_reg & 1) == 0) {
        return 0;
    }
    //printf("Config reg este %.8X\n", eng.config_reg);
    ioctl(fd, EPI_IOC_GET_ENG_PATTERN, &eng);
    len = (eng.config_reg >> 8) - 4;
    //printf("Len este = %d\n", len);
    memcpy(pattern_buff, eng.pattern, len);
    pattern_buff[len] = 0;
    return len;
}

int engine_get_maxnr(int fd) {
    int max_pattern_len;
    int return_val;
    return_val = ioctl(fd, EPI_IOC_GET_ENGINES_NR, &max_pattern_len);
    return max_pattern_len;
}

int engine_get_maxpatternlen(int fd) {
    int engines_nr;
    int return_val;
    return_val = ioctl(fd, EPI_IOC_MAX_PATTERN_LEN, &engines_nr);
    return engines_nr;
}

int engine_get_avgtime(int fd) {
    int packets;
    int return_val;
    return_val = ioctl(fd, EPI_IOC_DEBUG, &packets);
    return packets;
}

int engine_get_lineartime(int fd) {
    int packets;
    int return_val;
    return_val = ioctl(fd, EPI_IOC_LINEARTIME, &packets);
    return packets;
}

void engine_get_cfgreg(int fd, int index) {
    struct engine eng;
    int return_val;

    eng.index = index;

    return_val = ioctl(fd, EPI_IOC_GET_ENG_CFGREG, &eng);
    printf("Engine %d cfg reg %.8X\n", index, eng.config_reg);
}