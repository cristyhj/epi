export ARCH := arm
export CROSS_COMPILE := arm-linux-gnueabihf-

CC=$(CROSS_COMPILE)gcc

epi-objs += main.o epi_dma.o epi_device.o epi_netfilter.o
obj-m := epi.o

all:
	make -C /mnt/Documents/Licenta/Xilinux/linux-xlnx M=$(PWD) modules

windows:
	make -C /mnt/d/Documents/Licenta/Xilinux/linux-xlnx M=$(PWD) modules

clean:
	make -C /mnt/Documents/Licenta/Xilinux/linux-xlnx M=$(PWD) clean
	#make -C /mnt/d/Documents/Licenta/Xilinux/linux-xlnx M=$(PWD) clean

deploy:
	scp epi.ko root@169.254.110.145:/root/kmodule/epi.ko
