#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

MODULE_INFO(vermagic, VERMAGIC_STRING);
MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__attribute__((section(".gnu.linkonce.this_module"))) = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

static const struct modversion_info ____versions[]
__used
__attribute__((section("__versions"))) = {
	{ 0x64cd2ee2, __VMLINUX_SYMBOL_STR(module_layout) },
	{ 0x38faf0a7, __VMLINUX_SYMBOL_STR(cdev_del) },
	{ 0xcbc3f1f, __VMLINUX_SYMBOL_STR(kmalloc_caches) },
	{ 0x12da5bb2, __VMLINUX_SYMBOL_STR(__kmalloc) },
	{ 0x2e5e2fe1, __VMLINUX_SYMBOL_STR(cdev_init) },
	{ 0xf9a482f9, __VMLINUX_SYMBOL_STR(msleep) },
	{ 0xf88c3301, __VMLINUX_SYMBOL_STR(sg_init_table) },
	{ 0xff178f6, __VMLINUX_SYMBOL_STR(__aeabi_idivmod) },
	{ 0x15710358, __VMLINUX_SYMBOL_STR(mem_map) },
	{ 0x6d190f40, __VMLINUX_SYMBOL_STR(param_ops_int) },
	{ 0xd8e484f0, __VMLINUX_SYMBOL_STR(register_chrdev_region) },
	{ 0x7adffe2c, __VMLINUX_SYMBOL_STR(arm_dma_ops) },
	{ 0x1afae5e7, __VMLINUX_SYMBOL_STR(down_interruptible) },
	{ 0x7adeb8d4, __VMLINUX_SYMBOL_STR(ktime_get) },
	{ 0x5b7355d9, __VMLINUX_SYMBOL_STR(devm_ioremap_resource) },
	{ 0x28cc25db, __VMLINUX_SYMBOL_STR(arm_copy_from_user) },
	{ 0x7485e15e, __VMLINUX_SYMBOL_STR(unregister_chrdev_region) },
	{ 0xd9ff87c, __VMLINUX_SYMBOL_STR(__platform_driver_register) },
	{ 0xf4fa543b, __VMLINUX_SYMBOL_STR(arm_copy_to_user) },
	{ 0x93de854a, __VMLINUX_SYMBOL_STR(__init_waitqueue_head) },
	{ 0xe707d823, __VMLINUX_SYMBOL_STR(__aeabi_uidiv) },
	{ 0xfa2a45e, __VMLINUX_SYMBOL_STR(__memzero) },
	{ 0x5f754e5a, __VMLINUX_SYMBOL_STR(memset) },
	{ 0xd50e525e, __VMLINUX_SYMBOL_STR(dma_request_slave_channel) },
	{ 0x27e1a049, __VMLINUX_SYMBOL_STR(printk) },
	{ 0xc7f5162b, __VMLINUX_SYMBOL_STR(platform_get_resource) },
	{ 0x21a9414f, __VMLINUX_SYMBOL_STR(init_net) },
	{ 0x2da5f68, __VMLINUX_SYMBOL_STR(nf_register_net_hook) },
	{ 0xa3fefda0, __VMLINUX_SYMBOL_STR(cdev_add) },
	{ 0xc6cbbc89, __VMLINUX_SYMBOL_STR(capable) },
	{ 0xaf26042f, __VMLINUX_SYMBOL_STR(kmem_cache_alloc) },
	{ 0xcd233ba6, __VMLINUX_SYMBOL_STR(get_device) },
	{ 0x822137e2, __VMLINUX_SYMBOL_STR(arm_heavy_mb) },
	{ 0x799eecc, __VMLINUX_SYMBOL_STR(dma_release_channel) },
	{ 0x37a0cba, __VMLINUX_SYMBOL_STR(kfree) },
	{ 0x9d669763, __VMLINUX_SYMBOL_STR(memcpy) },
	{ 0x4be7fb63, __VMLINUX_SYMBOL_STR(up) },
	{ 0x32e693d1, __VMLINUX_SYMBOL_STR(set_user_nice) },
	{ 0x8b972ecd, __VMLINUX_SYMBOL_STR(class_destroy) },
	{ 0xefd6cf06, __VMLINUX_SYMBOL_STR(__aeabi_unwind_cpp_pr0) },
	{ 0x676bbc0f, __VMLINUX_SYMBOL_STR(_set_bit) },
	{ 0x689e06e, __VMLINUX_SYMBOL_STR(complete) },
	{ 0xeb127095, __VMLINUX_SYMBOL_STR(platform_driver_unregister) },
	{ 0x224f2d3b, __VMLINUX_SYMBOL_STR(devm_kmalloc) },
	{ 0x29dec96f, __VMLINUX_SYMBOL_STR(wait_for_completion_timeout) },
	{ 0x8044ba6a, __VMLINUX_SYMBOL_STR(__class_create) },
	{ 0x29537c9e, __VMLINUX_SYMBOL_STR(alloc_chrdev_region) },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=";

MODULE_ALIAS("of:N*T*Cxlnx,packet-inspection-1.1");
MODULE_ALIAS("of:N*T*Cxlnx,packet-inspection-1.1C*");
