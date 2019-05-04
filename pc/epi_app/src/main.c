#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

#include "engine.h"
#include "uart_connect.h"
#include <sys/ioctl.h>

#include "../../include/epi_common.h"

#define LENN 4096

int main(int argc, char **argv) {
    unsigned int packets;
    unsigned int avg_lineartime;
    unsigned int avg_paralleltime;
    int return_val;
    int i;
    char message[LENN];
    unsigned char data[LENN];
    char token[30];
    char mem[8];
    int nr = 0;
    int engines;
    int module_fd;
    int ret_val;
    FILE *file;
    int len;


    module_fd = open("s", O_RDWR);
    if (module_fd == -1) {
        printf("Some error open dev file!\n");
        return 1;
    }
    engines = engine_get_maxnr(module_fd);

    /*struct engine eng;
    eng.index = 0;
    eng.config_reg = ENGINE_ON_LEN(5);
    memcpy(eng.pattern, "anananananan", 12);
    return_val = ioctl(module_fd, EPI_IOC_SET_ENG_CFGREG, &eng);

    eng.config_reg = 0;

    return_val = ioctl(module_fd, EPI_IOC_GET_ENG_CFGREG, &eng);
    printf("AM citit %.8X\n", eng.config_reg);
    return 0;*/

    /*engine_set_cfgreg(module_fd, 0, 7);
    engine_get_cfgreg(module_fd, 0);
    engine_get_pattern(module_fd, 0, message);
    printf("Test: meessaage = %s\n", message);
    return 0;*/

    if (argc <= 1) {
        printf("Running user input test!\n");
        printf("Engine 0 set with pattern \"ana\".\n");
        printf("Type \"exit\" to end the program execution!\n");
        engine_set(module_fd, 0, "ana", 3);
        while (1) {
            printf("Message = ");
            fgets(message, LENN, stdin);
            if (strncmp(message, "exit", 4) == 0) {
                break;
            }
            return_val = write(module_fd, message, strlen(message) - 1);
            return_val = write(module_fd, message, strlen(message) - 1);
            return_val = write(module_fd, message, strlen(message) - 1);
            printf("Pattern %sfound!\n", return_val == 1 ? "" : "NOT ");
        }
        return 0;
    }
    if (strcmp(argv[1], "stress") == 0) {
        printf("Sending 1000 packets!\n");
        strcpy(message, "Hello there, ananan ...");
        memset(message + 23, 'a', 999);
        message[1023] = 0;
        for (i = 0; i < 1000; i++) {
            write(module_fd, message, LENN);
        }
        printf("Statistics about speed:\n");
        avg_paralleltime = engine_get_avgtime(module_fd);
        printf("\tAvg time parallel processing = %d\n", avg_paralleltime);
        avg_lineartime = engine_get_lineartime(module_fd);
        printf("\tAvg time linear   processing = %d\n", avg_lineartime);
        printf("\tSpeed-up = %1.3f\n", (float)avg_lineartime / (float)avg_paralleltime);

    } else if (strcmp(argv[1], "set") == 0) {
        printf("Setting patterns from file \"pattern.txt\"!\n");
        file = fopen("pattern.txt", "r");
        if (!file) {
            printf("Error opening pattern file!\n");
            return 2;
        }
        for (i = 0; i < engines; i++) {
            fgets(message, LENN, file);
            engine_set(module_fd, i, message, strlen(message) - 1);
        }
        printf("All engines set! Enter engine number to verify:\n");
        while (1) {
            printf("Message = ");
            fgets(message, LENN, stdin);
            if (strncmp(message, "exit", 4) == 0) {
                break;
            }
            return_val = atoi(message);
            engine_get_pattern(module_fd, return_val, message);
            engine_get_cfgreg(module_fd, return_val);
            printf("Engine %d pattern:\n-----\n%s\n-----\n\n", return_val, message);
        }
        fclose(file);

    } else if (strcmp(argv[1], "uart") == 0) {
        uart_connect();
        while (uart_exec_command(module_fd));
        uart_disconnect();
    } else if (strcmp(argv[1], "logs") == 0) {
        message[0] = 0;
        printf("Logs:\n");
        return_val = read(module_fd, message, LENN);
        if (return_val == 0) {
            printf("Read was 0!\n");
        }
        while (return_val > 0) {
            printf("----Packet:----\n");
            printf("%s", message);
            printf("\n---------------\n");
            return_val = read(module_fd, message, LENN);
        }
    } else if (strcmp(argv[1], "listen") == 0) {
        uart_connect();
        while (1) {
            return_val = read(module_fd, message, LENN);
            if (return_val > 0) {
                printf("Intruder!!! %s\n", message);
                protocol_get_attribute(message, "DataLength", token);
                len = atoi(token);
                printf("got attribute Data len = %d, from token %s\n", len, token);
                memcpy(data, message + return_val - len, len);
                uart_send(message, data, len);
                printf("Waiting in uart_recv!\n");
                uart_recv(message, 1024, data);
                printf("Exit from uart_recv!\n");
                potocol_get_command(message, token);
                if (strcmp(token, "Exit") == 0) {
                    printf("Received Exit command! Bye!\n");
                    break;
                }
            }
        }
        uart_disconnect();
    } else if (strcmp(argv[1], "packet1") == 0) {
        uart_connect();
        strcpy(message, "Ok:HasData:SourceIp=-1871774039:DestinationIp=-1854996823:SourcePort=0:DestinationPort=0:Protocol=1:DataLength=84\n");
        strcpy((char*)data, "SampleDataSampleDataSampleDataSampleDataSampleDataSampleDataSampleDataSampleData1234");
        len = 84;

        printf("Sending the message!\n");
        return_val = uart_send(message, data, len);
        printf("Sent %d bytes! Waiting in uart_recv!\n", return_val);
        return_val = uart_recv(message, 1024, data);
        printf("Recv %d bytes! Exit from uart_recv!\n", return_val);
        potocol_get_command(message, token);
        if (strcmp(token, "Exit") == 0) {
            printf("Received Exit command! Bye!\n");
            return 1;
        }
    } else if (strcmp(argv[1], "packet2") == 0) {
        uart_connect();
        strcpy(message, "Ok:HasData:SourceIp=-1871774039:DestinationIp=-1854996823:SourcePort=1087:DestinationPort=80:Protocol=6:DataLength=94\n");
        strcpy((char*)data, "HTTPdata~~HTTPdata~~HTTPdata~~HTTPdata~~HTTPdata~~HTTPdata~~HTTPdata~~HTTPdata~~~HTTPdata~~~~~");
        len = 94;

        printf("Sending the message!\n");
        return_val = uart_send(message, data, len);
        printf("Sent %d bytes! Waiting in uart_recv!\n", return_val);
        return_val = uart_recv(message, 1024, data);
        printf("Recv %d bytes! Exit from uart_recv!\n", return_val);
        potocol_get_command(message, token);
        if (strcmp(token, "Exit") == 0) {
            printf("Received Exit command! Bye!\n");
            return 1;
        } 
    } else {
        printf("Usage:\n\ttest [stress][set][uart][logs][listen][packet]\n");
    }

    close(module_fd);

    return 0;
    
}
