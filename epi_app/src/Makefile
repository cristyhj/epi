export ARCH := arm
export CROSS_COMPILE := arm-linux-gnueabihf-

CC=$(CROSS_COMPILE)gcc

app:
	$(CC) -o ../bin/test main.c engine.c uart_connect.c

clean:
	rm ../bin/*

deploy:
	scp ../bin/test root@169.254.110.145:/root/kmodule/test

all:
	$(MAKE) app
	$(MAKE) deploy