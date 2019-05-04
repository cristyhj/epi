/*
*
*
*
*
*/

#include <linux/kernel.h>	/* printk() */
#include <linux/slab.h>		/* kmalloc() */
#include <linux/fs.h>		/* everything... */
#include <linux/errno.h>	/* error codes */
#include <linux/types.h>	/* size_t */
#include <linux/cdev.h>
#include <linux/uaccess.h>	/* copy_*_user */
#include <linux/platform_device.h>
#include <linux/of_platform.h>
#include <linux/io.h>

#include "epi_device.h"
#include "epi.h"
#include "epi_dma.h"
#include "epi_netfilter.h"
#include "../include/epi_common.h"

struct file_operations epi_fops = {
	.owner          = THIS_MODULE,
	.read           = epi_read,
	.write          = epi_write,
	.unlocked_ioctl = epi_ioctl,
	.open           = epi_open,
	.release        = epi_release,
};

#define ENGINE_OFFSET(index)  (index*max_pattern_len)
#define ENGINE_IN_RANGE ((_engine.index >= 0) && (_engine.index < max_engines_nr))
#define PATTERN_IN_RANGE (((_engine.config_reg >> 8) >= 0) && ((_engine.config_reg >> 8) < max_pattern_len))

extern int max_engines_nr;
extern int max_pattern_len;
extern struct dma_data *__dma_data;
/*
 * The EPI device is the single-open one,
 *  it has an hw structure and an open count
 */
static atomic_t epi_available = ATOMIC_INIT(1);

/*
 * functions to test againt linear computations 
 * 
 */
int findstr(const char *str, int str_len, const char *substr, int substr_len) {
	int i, j;
	int ok;
	for (i = 0; i < str_len - substr_len + 1; i++) {
		ok = 1;
		for (j = 0; j < substr_len; j++) {
			if (str[i + j] != substr[j]) {
				ok = 0;
				break;
			}
		}
		if (ok) {
			return 1;
		}
	}
	return 2;
}
int linear_test(char **engines, char *buff) {
	int i, r;
	
	for (i = 0; i < 16; i++) {
		r += findstr(buff, 1024, engines[i], 256);
	}
	return r;
}

/*
 * Open
 */
int epi_open(struct inode *inode, struct file *filp)
{
	struct epi_dev *dev; /* device information */
	
	// Check if the device is already opened by another process
	if (! atomic_dec_and_test (&epi_available)) {
		atomic_inc(&epi_available);
		return -EBUSY; /* already open */
	}

	dev = container_of(inode->i_cdev, struct epi_dev, cdev);
	if(unlikely(dev == NULL)) {
		pr_err("args: (<inode>, %p) failed\n", filp);
		return -ENODEV;
	}

	filp->private_data = dev; /* for other methods */

	/* now trim to 0 the length of the device if open was write-only */
	if ( (filp->f_flags & O_ACCMODE) == O_WRONLY) {
		up(&dev->sem);
	}

	printk(KERN_NOTICE "epi: EPI is open");
	return 0;
}

/*
 * Close
 */
int epi_release(struct inode *inode, struct file *filp)
{
	atomic_inc(&epi_available); /* release the device */
	printk(KERN_NOTICE "epi: EPI is closed ");
	return 0;
}

/*
 * Data management: read and write
 */
ssize_t epi_read(struct file *filp, char *buf, size_t count, loff_t *f_pos)
{
	struct epi_dev *dev = filp->private_data; 
	ssize_t retval = 0;
	char *buff;

	get_device(to_dev(dev));

	if (down_interruptible(&dev->sem))
		return -ERESTARTSYS;
	//if (down_interruptible(&netfilter_log.sem))
	//	return -ERESTARTSYS;
	printk("epi: read = %d, log = %d\n", netfilter_log.current_read, netfilter_log.current_log);
	if (netfilter_log.current_read + 1 != netfilter_log.current_log) {
		buff = kmalloc(3000 * sizeof(char), GFP_KERNEL);
		if (buff == NULL)
		{
			printk(KERN_ERR "epi: Allocating memory buffer failed\n");
			return -1;
		}
		retval = serialize_netfilter_log(buff, netfilter_log.current_read);
		if (copy_to_user(buf, buff, retval))
		{
			return 0;
		}
		kfree(buff);
		netfilter_log.current_read = (netfilter_log.current_read + 1) % MAX_LOG_COUNT;
	}
	*f_pos += retval;

	//up(&netfilter_log.sem);
	up(&dev->sem);
	return retval;
}

ssize_t epi_write(struct file *filp, const char *buf, size_t count, loff_t *f_pos)
{
	struct epi_dev *dev = filp->private_data;
	ssize_t retval = -ENOMEM;
	char *src_buf;

	ktime_t start;
	ktime_t end;
	ktime_t delta;


	if (down_interruptible(&dev->sem))
	{
		return -ERESTARTSYS;
	}

	src_buf = kmalloc(count*sizeof(char), GFP_KERNEL);
	if (src_buf == NULL)
	{
		printk(KERN_ERR "Allocating DMA Rx memory buffer failed\n");
		return -1;
	}

	if (copy_from_user(src_buf, buf, count)) 
	{
		printk(KERN_ERR "Can not copy data from user space\n");
		return -1;
	}
	// ?? src_buf[count - 1] = 0;
	//printk(KERN_INFO "epi: write: src_buff = %s; len = %d\n", src_buf, count);
	if(unlikely(dev == NULL)) {
		pr_err(" --- No private_data \n");
		return -EINVAL;
	}

	start = ktime_get();

	//int nr = 3;
	//while (nr--)
	axidma_transfer(src_buf, count, dev, 0);
	//send_dma_packet(src_buf, count);
	
	end = ktime_get();
	delta = ktime_sub(end, start);
	
	kfree(src_buf);

	*f_pos = *__dma_data->dma_rx_buf;
	retval = *__dma_data->dma_rx_buf;


	dev->__dma_data->proc_time += ktime_to_ns(delta);
	dev->__dma_data->packet_processed += 1;

	up(&dev->sem);
	//printk(KERN_INFO "epi: write rturned with %d", retval);
	return retval;
}

/*
 * The ioctl() implementation
 */
long epi_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
	int err = 0;
	int retval = 0;
	int i;
	char *addr;
	u32 aux_val;
	struct epi_dev *dev_priv; 
	unsigned int average_proc_time;
    struct engine _engine;
	int lentt;
	char *buff;
	char *engines[16];

	ktime_t start;
	ktime_t end;
	ktime_t delta;
	unsigned int avg_linear_time;

	/*
	 * extract the type and number bitfields, and don't decode
	 * wrong cmds: return ENOTTY (inappropriate ioctl) before access_ok()
	 */
	if (_IOC_TYPE(cmd) != EPI_IOC_MAGIC) return -ENOTTY;
	if (_IOC_NR(cmd) > EPI_IOC_MAXNR) return -ENOTTY;

	/*
	 * the direction is a bitmask, and VERIFY_WRITE catches R/W
	 * transfers. `Type' is user-oriented, while
	 * access_ok is kernel-oriented, so the concept of "read" and
	 * "write" is reversed
	 */
	if (_IOC_DIR(cmd) & _IOC_READ)
		err = !access_ok(VERIFY_WRITE, (void *)arg, _IOC_SIZE(cmd));
	else if (_IOC_DIR(cmd) & _IOC_WRITE)
		err =  !access_ok(VERIFY_READ, (void *)arg, _IOC_SIZE(cmd));
	if (err) return -EFAULT;

	dev_priv = filp->private_data;
	if(unlikely(dev_priv == NULL)) {
		pr_err("args: (%p, %X, %lX) no private_data\n", 
			filp, cmd, arg);
		return -EINVAL;
	}

	switch(cmd) {

		case EPI_IOC_GET_ENGINES_NR:  /* Get: the number of string FPGA engines*/
			retval = __put_user(max_engines_nr, (int *)arg);
		break;

		case EPI_IOC_MAX_PATTERN_LEN:  /* Get the maximum pattern lenth of an engine */
			retval = __put_user(max_pattern_len, (int *)arg);
		break;

		case EPI_IOC_GET_ENG_CFGREG:  /* Get engine configuration register */

			if (!capable(CAP_SYS_ADMIN))
			{
				return -EPERM;
			}

			// Copy engine structure from user space
			if (copy_from_user((char*)(&_engine), (char*)(arg), sizeof(struct engine)))
			{
				return -EFAULT;
			}
			
			// Check if the index is in engines range
			if(!ENGINE_IN_RANGE)
			{
				return ENGINE_ACCESS_RES_ERROR;
			}

			// get engine configation register from FPGA
			printk(KERN_INFO "epi: get cfg reg before 0x%x\n", _engine.config_reg);
			_engine.config_reg = ioread32(dev_priv->region + ENGINE_OFFSET(_engine.index));
			printk(KERN_INFO "epi: get cfg reg after  0x%x\n", _engine.config_reg);
			if (copy_to_user((char*)(arg), (char*)(&_engine), sizeof(struct engine)))
			{			
				return -EFAULT;
			}			
		break;

		case EPI_IOC_SET_ENG_CFGREG:  /* Set engine configuration register */
	
			if (!capable(CAP_SYS_ADMIN))
			{
				return -EPERM;
			}

			// Copy engine structure from user space
			if (copy_from_user((char*)(&_engine), (char*)(arg), sizeof(struct engine)))
			{
				return -EFAULT;
			}
			
			// Check if the index is in engines range
			if(!ENGINE_IN_RANGE)
			{
				return ENGINE_ACCESS_RES_ERROR;
			}

			// write engine configration register to FPGA
			printk(KERN_INFO "epi: Writing config_reg = 0x%.8x\n", _engine.config_reg);
			iowrite32(_engine.config_reg, dev_priv->region + ENGINE_OFFSET(_engine.index));
			_engine.config_reg = ioread32(dev_priv->region + ENGINE_OFFSET(_engine.index));
			printk(KERN_INFO "epi: But aft config_reg = 0x%.8x\n", _engine.config_reg);
		break;

		case EPI_IOC_GET_ENG_PATTERN:  /* Get engine pattern */
	
			if (!capable(CAP_SYS_ADMIN))
			{
				return -EPERM;
			}

			// Copy engine structure from user space
			if (copy_from_user((char*)(&_engine), (char*)(arg), sizeof(struct engine)))
			{
				return -EFAULT;
			}
			
			// Check if the index is in engines range
			if(!ENGINE_IN_RANGE)
			{
				return ENGINE_ACCESS_RES_ERROR;
			}

			// get engine configation register from FPGA
			_engine.config_reg = ioread32(dev_priv->region + ENGINE_OFFSET(_engine.index));
			// this must be fixed!!!
			addr = dev_priv->region + ENGINE_OFFSET(_engine.index) + 4;
			lentt = (_engine.config_reg >> 8) - 4;
			printk(KERN_INFO "epi: pattern lentt = %d\n", lentt);
			for(i = 0; i < (_engine.config_reg >> 8) - 4; i += 4)
			{
				aux_val = ioread32(addr + i);
				printk(KERN_INFO "epi: ioread pattern at %d = 0x%.8X\n", i, aux_val);
				_engine.pattern[i+0] = aux_val;
				_engine.pattern[i+1] = aux_val >> 8;
				_engine.pattern[i+2] = aux_val >> 16;
				_engine.pattern[i+3] = aux_val >> 24;
			}

			printk(KERN_INFO "epi: pattern at get = %s\n", _engine.pattern);

			if (copy_to_user((char*)(arg), (char*)(&_engine), sizeof(struct engine)))
			{			
				return -EFAULT;
			}	
		break;

		case EPI_IOC_SET_ENG_PATTERN:  /* Set engine pattern */
	
			if (!capable(CAP_SYS_ADMIN))
			{
				return -EPERM;
			}

			// Copy engine structure from user space
			if (copy_from_user((char*)(&_engine), (char*)(arg), sizeof(struct engine)))
			{
				return -EFAULT;
			}
			
			// Check if the index is in engines range
			if(!ENGINE_IN_RANGE)
			{
				return ENGINE_ACCESS_RES_ERROR;
			}

			// Check if pattern lenght is in range
			if(!PATTERN_IN_RANGE)
			{
				return ENGINE_ACCESS_RES_ERROR;
			}
			
			addr = dev_priv->region + ENGINE_OFFSET(_engine.index) + 4;
			for(i = 0; i < _engine.config_reg >> 8; i += 4)
			{
				aux_val = 0;
				aux_val = aux_val | (_engine.pattern[i+0] << 0);
				aux_val = aux_val | (_engine.pattern[i+1] << 8);
				aux_val = aux_val | (_engine.pattern[i+2] << 16);
				aux_val = aux_val | (_engine.pattern[i+3] << 24);
				iowrite32(aux_val, addr + i);
			}

			iowrite32(_engine.config_reg, dev_priv->region + ENGINE_OFFSET(_engine.index));
		break;

		case EPI_IOC_DEBUG:
			
			if (!capable(CAP_SYS_ADMIN))
			{
				return -EPERM;
			}
			if (dev_priv->__dma_data->packet_processed != 0) {
				average_proc_time = dev_priv->__dma_data->proc_time / dev_priv->__dma_data->packet_processed;
			} else {
				average_proc_time = 0;
			}
			
			dev_priv->__dma_data->proc_time = 0;
			dev_priv->__dma_data->packet_processed = 0;
			if(copy_to_user((unsigned int*)(arg), (unsigned int*)(&average_proc_time), sizeof(unsigned int)))
			{			
				return -EFAULT;
			}	
		break;

		case EPI_IOC_LINEARTIME:
			if (!capable(CAP_SYS_ADMIN))
			{
				return -EPERM;
			}
			
			buff = kmalloc(1024 * sizeof(char), GFP_KERNEL);
			for (i = 0; i < 16; i++) {
				engines[i] = kmalloc(256 * sizeof(char), GFP_KERNEL);
				memset(engines[i], 'a' + i, 256);
			}
			memset(buff, 'b', 256);

			start = ktime_get();

			retval = linear_test(engines, buff);

			end = ktime_get();
			delta = ktime_sub(end, start);
			avg_linear_time = ktime_to_ns(delta);
			
			if(copy_to_user((unsigned int*)(arg), (unsigned int*)(&avg_linear_time), sizeof(unsigned int)))
			{			
				return -EFAULT;
			}	
		break;
		case EPI_IOC_PACKETSDROPPED:
			if (!capable(CAP_SYS_ADMIN))
			{
				return -EPERM;
			}
			// just using this variable
			avg_linear_time = netfilter_log.packets_dropped;

			if(copy_to_user((unsigned int*)(arg), (unsigned int*)(&avg_linear_time), sizeof(unsigned int)))
			{			
				return -EFAULT;
			}	
		break;
	    default:  /* redundant, as cmd was checked against MAXNR */
			return -ENOTTY;
	}

	return retval;
}



