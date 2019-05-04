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

#ifndef _EPI_H_
#define _EPI_H_

#include <linux/ioctl.h> /* needed for the _IOW etc stuff used later */
#include <linux/cdev.h>

#define EPI_DBG_

/*
 * Macros to help debugging
 */

#undef PDEBUG             /* undef it, just in case */
#ifdef EPI_DEBUGd
#  ifdef __KERNEL__
     /* This one if debugging is on, and kernel space */
#    define PDEBUG(fmt, args...) printk( KERN_DEBUG "epi: " fmt, ## args)
#  else
     /* This one for user space */
#    define PDEBUG(fmt, args...) fprintf(stderr, fmt, ## args)
#  endif
#else
#  define PDEBUG(fmt, args...) /* not debugging: nothing */
#endif

#undef PDEBUGG
#define PDEBUGG(fmt, args...) /* nothing: it's a placeholder */

#ifndef EPI_MAJOR
#define EPI_MAJOR 0   /* dynamic major by default */
#endif

#ifndef EPI_NR_DEVS
#define EPI_NR_DEVS 1    /* just one device */
#endif

#ifndef DMA_DST_SIZE
#define DMA_DST_SIZE 4
#endif

#ifndef CONFIG_DMA_ENGINE
#define CONFIG_DMA_ENGINE
#endif

/*
 * Split minors in two parts
 */
#define TYPE(minor)	(((minor) >> 4) & 0xf)	/* high nibble */
#define NUM(minor)	((minor) & 0xf)		/* low  nibble */

/*
 * The different configurable parameters
 */
extern int epi_major;     /* main.c */

/*
 * Define data types
 */
typedef unsigned char BYTE;

/*
* Epi device structure, hold necessary data for this device
*/

struct epi_dev {
    struct semaphore sem;     /* mutual exclusion semaphore     */
	struct cdev cdev;	  /* Char device structure		*/

    struct platform_device *pdev;
	void __iomem *region;
	size_t region_size;
	spinlock_t lock;
	struct dma_data *__dma_data;
};

#define to_dev(dev_priv) (&(dev_priv->pdev->dev))

/*
 * Prototypes for shared functions
 */

#endif /* _EPI_H_ */
