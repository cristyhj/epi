#ifndef _EPI_NETFILTER_
#define _EPI_NETFILTER_
#include <linux/semaphore.h>
#include "epi.h"

#define MAX_PACKET_LEN 1500
#define MAX_LOG_COUNT 25

struct _netfilter_log {
	char buff[MAX_LOG_COUNT][MAX_PACKET_LEN];
	int lens[MAX_LOG_COUNT];
	int current_log;
	int current_read;
	int packets_dropped;

	unsigned char protocol[MAX_LOG_COUNT];		// 17 = udp; 6 = tcp;

	unsigned int src_ip[MAX_LOG_COUNT];
	unsigned int dest_ip[MAX_LOG_COUNT];
	unsigned int src_port[MAX_LOG_COUNT];
	unsigned int dest_port[MAX_LOG_COUNT];
	//struct semaphore sem;	// unusable for the moment
};

extern struct _netfilter_log netfilter_log;

void epi_netfilter_kill(void);
void epi_netfilter_init(void);
void epi_netfilter_init_private(struct epi_dev *private);

int serialize_netfilter_log(char *dest, int i);

#endif