/*
 * epi_common.c -- the epi (Ethernet Packets Inspection) char module
 *
 * Copyright (C) 2018 Andrei Nicolae Georgian
 *
 * The source code in this file can be freely used, adapted,
 * and redistributed in source or binary form, so long as an
 * acknowledgment appears in derived source files. No warranty is attached;
 * i cannot take responsibility for errors or fitness for use.
 *
 */

#ifndef _EPICOMMON_H_
#define _EPICOMMON_H_

#include <linux/ioctl.h>

/*
 * Ioctl definitions
 */
/* Use 'e' as magic number */
#define EPI_IOC_MAGIC  'e'
#define EPI_IOCRESET    _IO(EPI_IOC_MAGIC, 0)
/*
 * S means "Set" through a ptr,
 * T means "Tell" directly with the argument value
 * G means "Get": reply by setting through a pointer
 * Q means "Query": response is on the return value
 * X means "eXchange": switch G and S atomically
 * H means "sHift": switch T and Q atomically
 */
// Get engine configuration register
#define EPI_IOC_GET_ENG_CFGREG     _IOR(EPI_IOC_MAGIC, 1, int)
// Set engine configuration register
#define EPI_IOC_SET_ENG_CFGREG     _IOW(EPI_IOC_MAGIC, 2, int)
// Get engine pattern
#define EPI_IOC_GET_ENG_PATTERN    _IOR(EPI_IOC_MAGIC, 3, int)
// Set engine pattern
#define EPI_IOC_SET_ENG_PATTERN    _IOW(EPI_IOC_MAGIC, 4, int)
// Get the maximum engines available
#define EPI_IOC_GET_ENGINES_NR     _IOR(EPI_IOC_MAGIC, 5, int)
// Get the maximum pattern lenth of an engine
#define EPI_IOC_MAX_PATTERN_LEN    _IOR(EPI_IOC_MAGIC, 6, int)
// Make debug operations
#define EPI_IOC_DEBUG              _IOR(EPI_IOC_MAGIC, 7, int)
// Get linear time for stress test
#define EPI_IOC_LINEARTIME         _IOR(EPI_IOC_MAGIC, 8, int)
// Get how many packets were dropped
#define EPI_IOC_PACKETSDROPPED     _IOR(EPI_IOC_MAGIC, 9, int)

#define EPI_IOC_MAXNR 9


#define ENGINE_ACCESS_RES_ERROR   1
#define ENGINE_ACCESS_RES_OK     -1

#define PATTERN_FOUNDED 0x01
#define PATTERN_NOT_FOUNDED 0x02

#define ENGINE_ON 0x00000001
#define ENGINE_OFF 0x00000000
#define ENGINE_ON_LEN(len) (ENGINE_ON | (len << 8))

typedef unsigned char  byte;
typedef unsigned int   _u32;
typedef unsigned short _u16;
typedef unsigned char  _8;

struct engine {
    
    int    index;         // index inside hash engine pool
    char   pattern[512]; // for now the lenght is harcoded
    _u32   config_reg;
};

#endif /* _EPICOMMON_H_ */
