#ifndef _EPI_DMA_H_
#define _EPI_DMA_H_

#include <linux/module.h>
#include "epi.h"


#define NO_WAIT 0
#define WAIT 1

typedef unsigned char u8;


int send_dma_packet(u8 *src, int length);
void axidma_transfer(char *src, int length, struct epi_dev *dev, int force_no_wait);
int epi_dma_probe(struct platform_device *pdev);
int epi_dma_remove(struct platform_device *pdev);

//////////////////////////////////////////////////////////////////
// DMA communication platform driver
//
//extern const struct of_device_id epi_dma_comm_of_ids[];

extern struct platform_driver epi_dma_comm;

struct dma_data {
	struct dma_chan *rx_channel;
	struct dma_chan *tx_channel;

	char   *dma_rx_buf;
	int 	response_received;

	unsigned int proc_time;
	unsigned int packet_processed; 

    struct platform_device *pdev;
};



#endif