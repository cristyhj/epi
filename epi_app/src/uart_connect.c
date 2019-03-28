#include "uart_connect.h"

#include <errno.h>
#include <fcntl.h> 
#include <string.h>
#include <termios.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

#include "engine.h"

int uart_fd;

int set_interface_attribs(int speed, int parity)
{
        struct termios tty;
        memset(&tty, 0, sizeof tty);
        if(tcgetattr(uart_fd, &tty) != 0)
        {
                printf("error %d from tcgetattr", errno);
                return -1;
        }

        cfsetospeed(&tty, speed);
        cfsetispeed(&tty, speed);

        tty.c_cflag =(tty.c_cflag & ~CSIZE) | CS8;     // 8-bit chars
        // disable IGNBRK for mismatched speed tests; otherwise receive break
        // as \000 chars
        tty.c_iflag &= ~IGNBRK;         // disable break processing
        tty.c_lflag = 0;                // no signaling chars, no echo,
                                        // no canonical processing
        tty.c_oflag = 0;                // no remapping, no delays
        tty.c_cc[VMIN]  = 0;            // read doesn't block
        tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

        tty.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl

        tty.c_cflag |= (CLOCAL | CREAD);// ignore modem controls,
                                        // enable reading
        tty.c_cflag &= ~(PARENB | PARODD);      // shut off parity
        tty.c_cflag |= parity;
        tty.c_cflag &= ~CSTOPB;
        tty.c_cflag &= ~CRTSCTS;

        if(tcsetattr(uart_fd, TCSANOW, &tty) != 0)
        {
                printf("error %d from tcsetattr", errno);
                return -1;
        }
        return 0;
}

void set_blocking(int should_block)
{
        struct termios tty;
        memset(&tty, 0, sizeof tty);
        if(tcgetattr(uart_fd, &tty) != 0)
        {
            printf("error %d from tggetattr", errno);
            return;
        }

        tty.c_cc[VMIN]  = should_block ? 1 : 0;
        tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

        if(tcsetattr(uart_fd, TCSANOW, &tty) != 0)
            printf("error %d setting term attributes", errno);
}

void uart_connect() {
    uart_fd = open(PORT_NAME, O_RDWR | O_NOCTTY | O_SYNC);
    if (uart_fd < 0)
    {
        printf("error %d opening %s: %s", errno, PORT_NAME, strerror(errno));
        return;
    }
    set_interface_attribs(B115200, 0);  // set speed to 115,200 bps, 8n1 (no parity)
    set_blocking(1);                   // set blocking
}

int uart_send(const char * buff, int len) {
    int sent = write(uart_fd, buff, len);
    usleep((len + 25) * 100);
    return sent;
}

int uart_recv(char *buff, int max_len) {
    int total = 0;
    int nread = read(uart_fd, buff, max_len);
    set_blocking(0);
    //printf("read %d\n", nread);
    while (nread != 0) {
        total += nread;
        nread = read(uart_fd, buff + total, max_len - total);
        //printf("re read %d\n", nread);
    }
    set_blocking(1);
    printf("uart_recv: Received %d bytes = %s\n", total, buff);
    buff[total] = 0;
    return total;
}

void uart_disconnect() {
    close(uart_fd);
}

void uart_exec_command(int module_fd) {
    char buff[1024];
    char *p;
    int index;
    int len = 0;
    
    uart_recv(buff, 1024);
    p = strtok(buff, ":");

    if (strcmp(p, "SetEngine") == 0) {
        p = strtok(NULL, ":");
        index = atoi(p);
        p = strtok(NULL, ":");
        printf("Setting engine %d with %s of len %d\n", index, p, strlen(p));
        engine_set(module_fd, index, p, strlen(p));
        uart_send("Set!\n", 5);
    }
    if (strcmp(p, "TestData") == 0) {
        p = strtok(NULL, ":");
        p = strtok(NULL, ":");
        printf("Testing with %s of len %d\n", p, strlen(p));
        index = write(module_fd, p, strlen(p));
        sprintf(buff, "Result: %d\n", index);
        uart_send(buff, strlen(buff));
    }
    if (strcmp(p, "GetEngine") == 0) {
        p = strtok(NULL, ":");
        index = atoi(p);
        len = engine_get_pattern(module_fd, index, buff);
        if (len == 0) {
            printf("Engine-ul %d nu este setat!\n", index);
            sprintf(buff, "Engine not set!\n");
            uart_send(buff, strlen(buff));
            return;
        }
        printf("Pattern-ul citit este: %s\n", buff);
        buff[len] = '\n';
        buff[len + 1] = 0;
        uart_send(buff, strlen(buff));
    }
    if (strcmp(p, "TestStress") == 0) {
        p = strtok(NULL, ":");
        len = atoi(p);
        strcpy(buff, "ce mai faci, maria? ...");
        memset(buff + 23, 'a', 999);
        buff[1023] = 0;
        printf("Enter in for\n");
        for (index = 0; index < len; index++) {
            write(module_fd, buff, 1024);
        }
        printf("Exit from for\n");
        len = engine_get_avgtime(module_fd);
        index = engine_get_lineartime(module_fd);
        sprintf(buff, "%d:%d\n", len, index);
        printf("Average time taken: %s\n", buff);
        uart_send(buff, strlen(buff));
    }
    if (strcmp(p, "GetLogs") == 0) {
        //p = strtok(NULL, ":");
        len = read(module_fd, buff, 1024);
        printf("First read len = %d\n", len);
        while (len > 0) {
            uart_send("Get!\n", 5);
            uart_send(buff, len);
            usleep((len + 25) * 100);
            printf("Uart sent: %s <> len=%d\n", buff, len);
            len = read(module_fd, buff, 1024);
            printf("Second read len = %d\n", len);
        }
        uart_send("Set!\n", 5);
    }
}
