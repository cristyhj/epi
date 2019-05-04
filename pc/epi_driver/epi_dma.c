/*
*
* DMA communication logic
*
*
*/


#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/init.h>

#include <linux/kernel.h>	/* printk() */
#include <linux/slab.h>		/* kmalloc() */
#include <linux/fs.h>		/* everything... */
#include <linux/errno.h>	/* error codes */
#include <linux/types.h>	/* size_t */
#include <linux/cdev.h>
#include <linux/platform_device.h>
#include <linux/of_platform.h>
#include <linux/delay.h>
#include <linux/kthread.h>
#include <linux/dmaengine.h>
#include <linux/of_dma.h>
#include <linux/dma/xilinx_dma.h>

#include "epi_dma.h"

const struct of_device_id epi_dma_comm_of_ids[] = {
	{ .compatible = "xlnx,axi-dma-unit-1.0",},
	{}
};

struct platform_driver epi_dma_comm = {
	.driver = {
		.owner = THIS_MODULE,
		.name = "xilinx_axidma_unit",
		.of_match_table = epi_dma_comm_of_ids,
	},
	.probe = epi_dma_probe,
	.remove = epi_dma_remove,
};

struct dma_data *__dma_data;

/*
 * These are protected by dma_list_mutex since they're only used by
 * the DMA filter function callback
 */
static DECLARE_WAIT_QUEUE_HEAD(thread_wait);


struct dma_callback_data {
	struct epi_dev *private;
	struct completion *cmp;
};
struct dma_callback_data rx_callback_data;
struct dma_callback_data tx_callback_data;

static void epi_dma_slave_tx_callback(void *completion)
{
	//printk(KERN_INFO "epi: dma tx callback called!\n");
	complete(completion);
}

static void epi_dma_slave_rx_callback(void *completion)
{
	//printk(KERN_INFO "epi: dma rx callback called!\n");
	complete(completion);
} 

/* Handle a callback and indicate the DMA transfer is complete to another
 * thread of control
 */
static void axidma_sync_rx_callback(void *callback_data)
{
	//printk(KERN_INFO "epi: dma sync rx callback called!\n");
	struct dma_callback_data *callback = callback_data;
	callback->private->__dma_data->response_received = 1;
	complete(callback->cmp);
}
static void axidma_sync_tx_callback(void *callback_data)
{
	//printk(KERN_INFO "epi: dma sync tx callback called!\n");
	struct dma_callback_data *callback = callback_data;
	complete(callback->cmp);
}

/* Prepare a DMA buffer to be used in a DMA transaction, submit it to the DMA engine 
 * to queued and return a cookie that can be used to track that status of the 
 * transaction
 */
static dma_cookie_t axidma_prep_buffer(struct dma_chan *chan, dma_addr_t buf, size_t len, 
					enum dma_transfer_direction dir, struct dma_callback_data *callback_param, void (*callback)(void*)) 
{
	enum dma_ctrl_flags flags = DMA_CTRL_ACK | DMA_PREP_INTERRUPT;
	struct dma_async_tx_descriptor *chan_desc;
	dma_cookie_t cookie;

	chan_desc = dmaengine_prep_slave_single(chan, buf, len, dir, flags);

	if (!chan_desc) {
		printk(KERN_ERR "EPI: dmaengine_prep_slave_single error\n");
		cookie = -EBUSY;
	} else {

		chan_desc->callback = callback;
		chan_desc->callback_param = callback_param;

		cookie = dmaengine_submit(chan_desc);
	
	}
	return cookie;
}

/* Start a DMA transfer that was previously submitted to the DMA engine and then
 * wait for it complete, timeout or have an error
 */
static void axidma_start_transfer(struct dma_chan *chan, struct completion *cmp, 
					dma_cookie_t cookie, int wait, struct epi_dev *private_data)
{
	unsigned long timeout = msecs_to_jiffies(30000);
	enum dma_status status;

	init_completion(cmp);
	dma_async_issue_pending(chan);

	if (wait) {
		//printk(KERN_ERR "EPI: dma transfer with timeout check!\n");
		timeout = wait_for_completion_timeout(cmp, timeout);
		status = dma_async_is_tx_complete(chan, cookie, NULL, NULL);

		// Determine if the transaction completed without a timeout and
		// withtout any errors
		//
		if (timeout == 0)  {
			printk(KERN_ERR "EPI: DMA timed out chan %s\n", dma_chan_name(chan));
			
		} 
		else if (status != DMA_COMPLETE)
		{
			printk(KERN_ERR "EPI: DMA returned completion callback status of: %s\n",
			       status == DMA_ERROR ? "error" : "in progress");
		}
	}
}


void axidma_transfer(char *src, int length, struct epi_dev *private_data, int force_no_wait)
{
	struct dma_chan *tx_chan;
	struct dma_chan *rx_chan;
	static struct completion tx_cmp;
	static struct completion rx_cmp;
	static dma_cookie_t tx_cookie;
	static dma_cookie_t rx_cookie;
	static dma_addr_t tx_dma_handle;
	static dma_addr_t rx_dma_handle;
	char *src_dma_buffer;
	char *dest_dma_buffer;

	if(length < 1)
	{
		printk(KERN_ERR "EPI: Data transfer len must be at least 1\n");
		return;
	}
	src_dma_buffer = src;
	dest_dma_buffer = private_data->__dma_data->dma_rx_buf;

	rx_chan = private_data->__dma_data->rx_channel;
	tx_chan = private_data->__dma_data->tx_channel;

	if (!src_dma_buffer || !dest_dma_buffer) {
		printk(KERN_ERR "EPI: Allocating DMA memory failed\n");
		return;
	}
	//printk(KERN_ERR "EPI: dma_map_single\n");
	tx_dma_handle = dma_map_single(tx_chan->device->dev, src_dma_buffer, length, DMA_TO_DEVICE);	
	rx_dma_handle = dma_map_single(rx_chan->device->dev, dest_dma_buffer, DMA_DST_SIZE, DMA_FROM_DEVICE);	
	
	/* Prepare the DMA buffers and the DMA transactions to be performed and make sure there was not
	 * any errors
	 */
	//printk(KERN_ERR "EPI: after dma_map_single, private data\n");
	tx_callback_data.private = private_data;
	tx_callback_data.cmp = &tx_cmp;

	rx_callback_data.private = private_data;
	rx_callback_data.cmp = &rx_cmp;

	//printk(KERN_ERR "EPI: axidma_prep_buffer\n");
	tx_cookie = axidma_prep_buffer(tx_chan, tx_dma_handle, length, DMA_MEM_TO_DEV, &tx_callback_data, axidma_sync_tx_callback);
	rx_cookie = axidma_prep_buffer(rx_chan, rx_dma_handle, DMA_DST_SIZE, DMA_DEV_TO_MEM, &rx_callback_data, axidma_sync_rx_callback);

	if (dma_submit_error(rx_cookie) || dma_submit_error(tx_cookie)) {
		printk(KERN_ERR "EPI: xdma_prep_buffer error\n");
		return;
	}

	/* Start both DMA transfers and wait for them to complete
	 */
	//printk(KERN_ERR "EPI: start_stranfer rx\n");
	axidma_start_transfer(rx_chan, &rx_cmp, rx_cookie, NO_WAIT, private_data);
	//printk(KERN_ERR "EPI: start_stranfer tx\n");
	axidma_start_transfer(tx_chan, &tx_cmp, tx_cookie, 1 - force_no_wait, private_data);


	dma_unmap_single(rx_chan->device->dev, rx_dma_handle, length, DMA_FROM_DEVICE);	
	dma_unmap_single(tx_chan->device->dev, tx_dma_handle, DMA_DST_SIZE, DMA_TO_DEVICE);
}

// Function used to sent ethernet packet to
// PL inspection using DMA channels
// and wait for a response
int send_dma_packet(u8* src, int length)
{
	struct dma_chan *tx_chan;
	struct dma_chan *rx_chan;
	dma_cookie_t tx_cookie;
	dma_cookie_t rx_cookie;
	enum dma_status status;
	enum dma_ctrl_flags flags;
	struct dma_device *tx_dev;
	struct dma_device *rx_dev;
	struct dma_async_tx_descriptor *txd;
	struct dma_async_tx_descriptor *rxd;
	dma_addr_t dma_src;
	dma_addr_t dma_dst;
	struct completion rx_cmp;
	struct completion tx_cmp;
	struct scatterlist tx_sg[1];
	struct scatterlist rx_sg[1];
	unsigned long rx_tmo;
	unsigned long tx_tmo;
	u8 align;
	int ret;

	ret = -ENOMEM;

	smp_rmb();
	rx_chan = __dma_data->rx_channel;
	tx_chan = __dma_data->tx_channel;
	set_user_nice(current, 10);

	flags = DMA_CTRL_ACK | DMA_PREP_INTERRUPT;

	align = 0;
	tx_dev = tx_chan->device;
	rx_dev = rx_chan->device;
	txd = NULL;
	rxd = NULL;
	rx_tmo = msecs_to_jiffies(300000); /* RX takes longer */
	tx_tmo = msecs_to_jiffies(30000);

	/* honor larger alignment restrictions */
	align = tx_dev->copy_align;
	if (rx_dev->copy_align > align)
		align = rx_dev->copy_align;

	if (1 << align > length) {
		pr_err("%u-byte buffer too small for %d-byte alignment\n",
			length, 1 << align);
		return ret;
	}

	// Set source buffer
	dma_src = dma_map_single(tx_dev->dev, src, length, DMA_MEM_TO_DEV);

	// Sed destination buffer
	dma_dst = dma_map_single(rx_dev->dev, __dma_data->dma_rx_buf, DMA_DST_SIZE, DMA_DEV_TO_MEM);

	sg_init_table(tx_sg, 1);
	sg_init_table(rx_sg, 1);
	
	sg_dma_address(tx_sg) = dma_src;
	sg_dma_address(rx_sg) = dma_dst;
	sg_dma_len(tx_sg) = length;
	sg_dma_len(rx_sg) = DMA_DST_SIZE;

	rxd = rx_dev->device_prep_slave_sg(rx_chan, rx_sg, 1, DMA_DEV_TO_MEM, flags, NULL);

	txd = tx_dev->device_prep_slave_sg(tx_chan, tx_sg, 1, DMA_MEM_TO_DEV, flags, NULL);

	if (!rxd || !txd) {
		dma_unmap_single(tx_dev->dev, dma_src, length, DMA_MEM_TO_DEV);
		dma_unmap_single(rx_dev->dev, dma_dst, DMA_DST_SIZE, DMA_DEV_TO_MEM);
		pr_warn("epi_send_dma: buffers error (packet length %d) ", length);
		msleep(100);
		return ret;
	}

	init_completion(&rx_cmp);
	rxd->callback = epi_dma_slave_rx_callback;
	rxd->callback_param = &rx_cmp;
	rx_cookie = rxd->tx_submit(rxd);

	init_completion(&tx_cmp);
	txd->callback = epi_dma_slave_tx_callback;
	txd->callback_param = &tx_cmp;
	tx_cookie = txd->tx_submit(txd);

	if (dma_submit_error(rx_cookie) || dma_submit_error(tx_cookie)) {
		pr_warn( "epi_send_dma submit error: %d/%d \n", rx_cookie, tx_cookie);
		msleep(100);
		return ret;
	}
	dma_async_issue_pending(tx_chan);
	dma_async_issue_pending(rx_chan);

	tx_tmo = wait_for_completion_timeout(&tx_cmp, tx_tmo);

	status = dma_async_is_tx_complete(tx_chan, tx_cookie, NULL, NULL);

	if (tx_tmo == 0) {
		pr_warn("epi_send_dma error: tx timed out\n");
		return ret;
	} else if (status != DMA_COMPLETE) {
		pr_warn( "epi_send_dma: tx got completion callback");
		pr_warn("but status is \'%s\'\n", status == DMA_ERROR ? "error" : "in progress");
		return ret;
	}

	rx_tmo = wait_for_completion_timeout(&rx_cmp, rx_tmo);
	status = dma_async_is_tx_complete(rx_chan, rx_cookie, NULL, NULL);

	if (rx_tmo == 0) {
		pr_warn("epi_send_dma error: rx timed out\n");
		return ret;
	} else if (status != DMA_COMPLETE) {
		pr_warn("epi_send_dma: rx got completion callback, ");
		pr_warn("but status is \'%s\'\n", status == DMA_ERROR ? "error" : "in progress");
		return ret;
	}

	dma_unmap_single(rx_dev->dev, dma_dst, DMA_DST_SIZE, DMA_DEV_TO_MEM);

	return 0;
}

static
int dma_add_slave_channels(struct dma_chan *tx_chan, struct dma_chan *rx_chan)
{
	__dma_data = kmalloc(sizeof(struct dma_data), GFP_KERNEL);
	__dma_data->response_received = 0;
	__dma_data->proc_time = 0;
	__dma_data->packet_processed  = 0;

	if (!__dma_data) {
		pr_warn("epi_dma: No memory for dma data \n");
		return -ENOMEM;
	}

	__dma_data->rx_channel = rx_chan;
	__dma_data->tx_channel = tx_chan;

	__dma_data->dma_rx_buf = kmalloc(DMA_DST_SIZE*sizeof(char), GFP_KERNEL);
	if (!__dma_data->dma_rx_buf) {
		pr_warn("dmatest: No memory for rx buffer");
		return -ENOMEM;
	}

	pr_info("epi_dma: Initialized dma channels: tx=%s rx=%s\n", dma_chan_name(tx_chan), dma_chan_name(rx_chan));
	return 0;
}







int epi_dma_probe(struct platform_device *pdev)
{
	struct dma_chan *chan, *rx_chan;
    dma_cap_mask_t mask;
	int err;

    dma_cap_zero(mask);
	dma_cap_set(DMA_SLAVE | DMA_PRIVATE, mask);

	chan = dma_request_slave_channel(&pdev->dev, "axidma0");
	if (IS_ERR(chan)) {
		pr_err("EPI: epi_dma: No Tx channel\n");
		return PTR_ERR(chan);
	}

	rx_chan = dma_request_slave_channel(&pdev->dev, "axidma1");
	if (IS_ERR(rx_chan)) {
		err = PTR_ERR(rx_chan);
		pr_err("EPI: epi_dma: No Rx channel\n");
		goto free_tx;
	}

	err = dma_add_slave_channels(chan, rx_chan);
	if (err) {
		pr_err("EPI: epi_dma: Unable to add channels\n");
		goto free_rx;
	}

	return 0;

free_rx:
	dma_release_channel(rx_chan);
free_tx:
	dma_release_channel(chan);

	return err;
}

int epi_dma_remove(struct platform_device *pdev)
{
	pr_info("epi_dma: dropped channel %s\n",
	dma_chan_name(__dma_data->rx_channel));
	dmaengine_terminate_all(__dma_data->rx_channel);
	dma_release_channel(__dma_data->rx_channel);
	
	pr_info("epi_dma: dropped channel %s\n",
	dma_chan_name(__dma_data->tx_channel));
	dmaengine_terminate_all(__dma_data->tx_channel);
	dma_release_channel(__dma_data->tx_channel);

	kfree(__dma_data->dma_rx_buf);
	kfree(__dma_data);
	return 0;
}

