#include "uart_connect.h"

#include <errno.h>
#include <fcntl.h> 
#include <string.h>
#include <termios.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

#include "engine.h"

static int uart_fd;


/*
*   Functions for solving UART data
*/
void potocol_get_command(const char *string, char *dest) {
    char *p;
    char copy[1024];
    strcpy(copy, string);

    p = strtok(copy, ":\n");
    strcpy(dest, p);
}

void protocol_get_attribute(const char *string, char *key, char *dest) {
    char *p;
    char *q;
    char copy[1024];
    strcpy(copy, string);

    p = strtok(copy, ":\n");    // for command
    p = strtok(NULL, ":\n");    // to begin
    while (p) {
        if (strstr(p, "=")) {
            printf("Debug: Found an attribute = %s\n", p);
            q = strstr(p, key);
            if (q) {
                strcpy(dest, q + strlen(key) + 1);
                printf("Debug: And the value of attribute is = %s\n", dest);
                return;
            }
        }
        p = strtok(NULL, ":\n");
    }
}

int protocol_has_data(const char *string) {
    char *p;
    char copy[1024];
    strcpy(copy, string);

    p = strtok(copy, ":\n");    // for command
    /*p = strtok(NULL, ":\n");    // for "HasData"
    if (p == NULL) {
        return 0;
    }
    if (strcmp(p, "HasData") == 0) {
        return 1;
    }*/
    while (p) {
        if (strcmp(p, "HasData") == 0) {
            return 1;
        }
        p = strtok(NULL, ":\n");
    }
    return 0;
}




static void uart_stop_getty() {
    system("systemctl mask serial-getty@ttyPS0.service");
    system("systemctl stop serial-getty@ttyPS0.service");
}
static void uart_start_getty() {
    system("systemctl unmask serial-getty@ttyPS0.service");
    system("systemctl start serial-getty@ttyPS0.service");
}

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
    uart_stop_getty();
    uart_fd = open(PORT_NAME, O_RDWR | O_NOCTTY | O_SYNC);
    if (uart_fd < 0)
    {
        printf("error %d opening %s: %s", errno, PORT_NAME, strerror(errno));
        return;
    }
    set_interface_attribs(B115200, 0);  // set speed to 115,200 bps, 8n1 (no parity)
    set_blocking(1);                    // set blocking
}

int uart_send(const char * buff, unsigned char *data, int len) {
    int sent = write(uart_fd, buff, strlen(buff));
    usleep((strlen(buff) + 25) * 100);
    if (data != NULL) {
        sent += write(uart_fd, data, len);
        usleep((len + 25) * 100);
    }
    return sent;
}

void pretty_print(unsigned char *data, int len) {
    int i;
    for (i = 0; i < len; i++) {
        printf("%.2X ", data[i]);
    }
    printf("\n");
}

int uart_recv(char *buff, int max_len, unsigned char *data) {
    int total = 0;
    char token[100];
    FILE *file = fdopen(uart_fd, "rb+");
    if (buff != NULL) {
        fgets(buff, max_len, file);
    }
    if (protocol_has_data(buff)) {
        protocol_get_attribute(buff, "DataLength", token);
        total = atoi(token);
        total = fread(data, sizeof(unsigned char), total, file);
        printf("---Data read from uart---\n");
        pretty_print(data, total);
        printf("----------len = %d-------\n", total);
    }
    return total;
}

void uart_disconnect() {
    uart_start_getty();
    close(uart_fd);
}

int uart_exec_command(int module_fd) {
    char buff[1024];
    unsigned char data[1024];
    char token[100];
    char *p;
    int index;
    int len = 0;

    printf("Uart Exec Command!\n");
    
    uart_recv(buff, 1024, data);
    printf("Debug: Command received --> %s", buff);

    potocol_get_command(buff, token);

    if (strcmp(token, "SetEnginePattern") == 0) {
        protocol_get_attribute(buff, "Engine", token);
        index = atoi(token);
        protocol_get_attribute(buff, "DataLength", token);
        len = atoi(token);

        engine_set(module_fd, index, data, len);

        sprintf(buff, "Ok\n");
        uart_send(buff, NULL, 0);
    }


    if (strcmp(token, "GetEnginePattern") == 0) {
        protocol_get_attribute(buff, "Engine", token);
        index = atoi(token);


        printf("Debug: Engine = %s\n", token);
        len = engine_get_pattern(module_fd, index, data);

        printf("Debug: Data with len = %d; got from fpga = %s\n", len, data);
        if (len > 0) { 
            sprintf(buff, "Ok:HasData:DataLength=%d\n", len);
            uart_send(buff, data, len);
        } else {
            sprintf(buff, "Warning:Message=Engine not set!\n");
            uart_send(buff, NULL, 0);
        }   
    }

    if (strcmp(token, "Exit") == 0) {
        return 0;
    }



}
