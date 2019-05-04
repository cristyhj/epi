/*
 * main.c -- the epi (Ethernet Packets Inspection) char module
 *
 * Copyright (C) 2018 Andrei Nicolae Georgian
 *
 * The source code in this file can be freely used, adapted,
 * and redistributed in source or binary form, so long as an
 * acknowledgment appears in derived source files. No warranty is attached;
 * i cannot take responsibility for errors or fitness for use.
 *
 */
#include "epi_netfilter.h"
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/init.h>

#include <linux/kernel.h>	/* printk() */
#include <linux/slab.h>		/* kmalloc() */
#include <linux/fs.h>		/* everything... */

#include <linux/cdev.h>
#include <linux/platform_device.h>
#include <linux/of_platform.h>

#include "epi.h"		/* local definitions */
#include "../include/epi_common.h"

#include "epi_dma.h"
#include "epi_device.h"


#define DRV_NAME "epi"
#define AXI_LITE_SLAVE_ADDR 0x43c00000

#define WAIT 	1
#define NO_WAIT 0

#define RESPONSE_DROP 0x01
#define RESPONSE_OK 0x02

/*
 *Parameters which can be set at load time.
 */
int epi_major    =  EPI_MAJOR;
int epi_minor    =  0;

module_param(epi_major, int, S_IRUGO);
module_param(epi_minor, int, S_IRUGO);

MODULE_AUTHOR("Andrei Nicolae Georgian");
MODULE_LICENSE("GPL v2");



struct epi_dev epi_device;
dev_t epi_chardev;
extern struct dma_data *__dma_data;

static struct class *epi_dev_class;

void init_dev_priv(struct epi_dev *dev_priv)
{
	spin_lock_init(&(dev_priv->lock));
}

/*
 * Those variables are initialized at startup
 */
int max_engines_nr = 16; // EPI maximum string engines
int max_pattern_len = 256; // EPI maximum string length for a string engine

/*
 * Declaration of engine object used to copy
 * and read configuration from user space
 */
struct engine _engine;


static int epi_dev_probe(struct platform_device *pdev)
{
	int err, devno;
	struct epi_dev *dev_priv;
	struct resource *res;
		
	dev_priv = devm_kzalloc(&(pdev->dev), sizeof(*dev_priv), GFP_KERNEL);
	if(dev_priv == NULL) {
		pr_err("EPI: args: (%p) failed \n", pdev);
		return -ENOMEM;
	}
	init_dev_priv(dev_priv);
	dev_priv->pdev = pdev;
	platform_set_drvdata(pdev, dev_priv);
	
	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if(res == NULL) {
		pr_err("EPI: args: (%p) failed \n", pdev);
		return -ENOMEM;
	}

	dev_priv->__dma_data = __dma_data;
	dev_priv->region_size = resource_size(res);
	dev_priv->region = devm_ioremap_resource(&(pdev->dev), res);
	if (IS_ERR(dev_priv->region)) {
		pr_err("EPI: args: (%p) failed: %ld\n", pdev, PTR_ERR(dev_priv->region));
		return PTR_ERR(dev_priv->region);
	}
	pr_info("EPI: region=%p\n", dev_priv->region);
	
    /* Initialize device. */
	sema_init(&(dev_priv->sem), 1);
	devno = MKDEV(epi_major, epi_minor);
    
	cdev_init(&dev_priv->cdev, &epi_fops);
	dev_priv->cdev.owner = THIS_MODULE;
	dev_priv->cdev.ops = &epi_fops;
	err = cdev_add (&dev_priv->cdev, devno, 1);
	if(err < 0) {
		pr_err("EPI: unable to add cdev - err: %d\n", err);
		return err;
	}

	pr_info("EPI: epi device probe completed\n");
	
	epi_netfilter_init_private(dev_priv);

	return 0;
}

static int epi_dev_remove(struct platform_device *pdev)
{
	struct epi_dev *dev_priv;
		
	dev_priv = platform_get_drvdata(pdev);
	if(dev_priv == NULL) {
		pr_err("args: (%p) no drvdata\n", pdev);
		return -EINVAL;
	}
	
	pr_info("EPI: epi device remove completed\n");
	return 0;
}


//////////////////////////////////////////////////////////////////
// Ethernet packet inspecion driver
//
static const struct of_device_id epi_of_match[] = {
	{ .compatible = "xlnx,packet-inspection-1.1", },
	{}
};
MODULE_DEVICE_TABLE(of, epi_of_match);

static struct platform_driver epi_dev_driver = {
	.driver = {
		.owner = THIS_MODULE,
		.name = DRV_NAME,
		.of_match_table = epi_of_match,
	},
	.probe = epi_dev_probe,
	.remove = epi_dev_remove,
};
//////////////////////////////////////////////////////////////////


static void epi_dev_exit(void)
{
	platform_driver_unregister(&epi_dev_driver);
	platform_driver_unregister(&epi_dma_comm);
	class_destroy(epi_dev_class);
}

/*
 * The cleanup function is used to handle initialization failures as well.
 * Thefore, it must be careful to work correctly even if some of the items
 * have not been initialized
 */
void _cleanup_module(void)
{
	dev_t devno = MKDEV(epi_major, epi_minor);

	epi_dev_exit();
	
	/* Get rid of our char dev entry */
	cdev_del(&epi_device.cdev);
	//nf_unregister_net_hook(&init_net, &nfho);
	epi_netfilter_kill();
	/* cleanup_module is never called if registering failed */
	unregister_chrdev_region(devno, 1);
	pr_info("EPI: module cleanup completed\n");
}

/*
 * Initialization function
 */
static int _init_module(void)
{
	int err;

	epi_dev_class = class_create(THIS_MODULE, DRV_NAME);
	if (IS_ERR(epi_dev_class)) {
		err = PTR_ERR(epi_dev_class);
		pr_err("EPI:couldn't create class: %d\n", err);
		return err;
	}

    /*
     * Get a range of minor numbers to work with, asking for a dynamic
     * major unless directed otherwise at load time.
     */
	if (epi_major) {
		err = register_chrdev_region(epi_chardev, 1, "epi");
	} else {
		err = alloc_chrdev_region(&epi_chardev, epi_minor, 1, "epi");
		epi_major = MAJOR(epi_chardev);
	}
	if (err < 0) {
		printk(KERN_WARNING "epi: can't get major %d\n", epi_major);
		_cleanup_module();
		class_destroy(epi_dev_class);
		return err;
	}

	err = platform_driver_register(&epi_dma_comm);
	if (err) {
		pr_err("EPI:unable to register EPI DMA platform driver: %d\n", err);
		return err;
	}

	err = platform_driver_register(&epi_dev_driver);
	if (err) {
		pr_err("EPI:unable to register EPI platform driver: %d\n", err);
		class_destroy(epi_dev_class);
		return err;
	}

	pr_info("EPI: module init completed\n");
	return 0;
}


module_init(_init_module);
module_exit(_cleanup_module);