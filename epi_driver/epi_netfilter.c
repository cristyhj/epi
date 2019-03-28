/*
 * This file is part of the linuxapi package.
 * Copyright (C) 2011-2018 Mark Veltzer <mark.veltzer@gmail.com>
 *
 * linuxapi is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * linuxapi is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with linuxapi. If not, see <http://www.gnu.org/licenses/>.
 */

#include "epi_netfilter.h"

#include <linux/kernel.h>
#include <linux/module.h> /* for MODULE_*. module_* */
#include <linux/printk.h> /* for pr_* */
#include <linux/netfilter.h>
#include <linux/netfilter_ipv4.h>
#include <linux/netfilter_bridge.h>
#include <linux/skbuff.h>
#include <linux/udp.h>
#include <linux/ip.h>
#include <linux/icmp.h>
#include <net/ip.h>
#include <linux/printk.h> /* for pr_* */
#include <linux/proc_fs.h> /* Necessary because we use the proc fs */
#include <asm/uaccess.h> /* For copy_from_user */

#include "epi_dma.h"

static struct nf_hook_ops nfho; // net filter hook option struct

struct _netfilter_log netfilter_log;

static unsigned int hook_func(void *priv, struct sk_buff *skb, const struct nf_hook_state *state) 
{
	struct epi_dev *dev = priv;
	int i;
	int len;
	/*for (i = 0; i < skb->len; i++) {
		sprintf(buff + strlen(buff), "%2X ", skb->data[i]);
	}
	printk(KERN_INFO "epi: skb = %s \n", buff);
	
	printk(KERN_INFO "epi: epi_dev = %p\n", dev);*/
	int nr = 3;
	while (nr--)
	axidma_transfer(skb->data, skb->len, dev, 1);

	if(dev->__dma_data->dma_rx_buf[0] == 1)
	{
		printk(KERN_INFO "epi: packet found with intruder!\n");

		//if (down_interruptible(&netfilter_log.sem))
		//	return NF_ACCEPT;

		netfilter_log.packets_dropped++;
		if (skb->len > MAX_PACKET_LEN)
			len = MAX_PACKET_LEN;
		else
			len = skb->len;
		memcpy(netfilter_log.buff[netfilter_log.current_log], skb->data, len);
		netfilter_log.lens[netfilter_log.current_log] = len;
		printk(KERN_INFO "epi: packet = %s!\n", netfilter_log.buff[netfilter_log.current_log]);
		netfilter_log.current_log = (netfilter_log.current_log + 1) % MAX_LOG_COUNT;

		// the fifo start to overrwrite data if it's not read
		if (netfilter_log.current_log == netfilter_log.current_read) {
			netfilter_log.current_read = (netfilter_log.current_read + 1) % MAX_LOG_COUNT;
			printk(KERN_INFO "epi: fifo overflow!\n");
		}
		//up(&netfilter_log.sem);
	}

	return NF_ACCEPT;
}

void epi_netfilter_init_private(struct epi_dev *private)
{
	/*nfho.hook = hook_func;
	nfho.hooknum = NF_INET_PRE_ROUTING ; //NF_IP_PRE_ROUTING;
	nfho.pf = PF_INET; // PF_INET PF_BRIDGE
	nfho.priv = private;
	nfho.priority = NF_IP_PRI_FIRST;

	netfilter_log.current_log = 0;
	netfilter_log.current_read = 0;
	netfilter_log.packets_dropped = 0;

	nf_register_net_hook(&init_net, &nfho);
	pr_info("EPI: nethook filter added\n");*/
}

void epi_netfilter_init(void)
{
	int ret;

	nfho.hook = hook_func;
	nfho.hooknum = NF_INET_PRE_ROUTING;
	nfho.pf = PF_INET;
	nfho.priority = NF_IP_PRI_FIRST;
	ret = nf_register_net_hook(&init_net, &nfho);

	sema_init(&netfilter_log.sem, 1);

	if (ret) {
		pr_err("could not register netfilter hook\n");
	}
}

void epi_netfilter_kill(void)
{
	//nf_unregister_net_hook(&init_net, &nfho);
}
