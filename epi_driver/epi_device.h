#ifndef _EPI_DEVICE_H
#define _EPI_DEVICE_H

#include <linux/module.h>
#include <linux/types.h>
#include <linux/moduleparam.h>

int epi_open(struct inode *inode, struct file *filp);
int epi_release(struct inode *inode, struct file *filp);
ssize_t epi_read(struct file *filp, char *buf, size_t count, loff_t *f_pos);
ssize_t epi_write(struct file *filp, const char *buf, size_t count, loff_t *f_pos);
long epi_ioctl(struct file *filp, unsigned int cmd, unsigned long arg);

extern struct file_operations epi_fops;

#endif