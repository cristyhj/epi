#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

#include "engine.h"
#include "uart_connect.h"

int main() {
    printf("Am intrat\n");
    unsigned int packets;
    unsigned int avg_lineartime;
    unsigned int avg_paralleltime;
    int return_val;
    int i;
    char message[1024];
    int nr = 0;
    int engines;
    int module_fd;
    FILE *file;

    module_fd = open("s", O_RDWR);
    if (module_fd == -1) {
        printf("Some error open dev file!\n");
        return 1;
    }

    file = fopen("pattern.txt", "r");
    if (!file) {
        printf("Some error open pattern file!\n");
        return 2;
    }

    engines = engine_get_maxnr(module_fd);


    /*uart_connect();
    while(1)
    uart_exec_command(module_fd);
    uart_disconnect();
    return 1;*/

    for (i = 0; i < engines; i++) {
        fgets(message, 1024, file);
        engine_set(module_fd, i, message, strlen(message) - 1);
    }
    int enr = 1;
    engine_set(module_fd, enr, "ana", 3);
    
    engine_get_cfgreg(module_fd, enr);
    char mama[200];
    int len = engine_get_pattern(module_fd, enr, mama);
    printf("Pattern-ul citit este: %s\n", mama);

    /*int da = read(module_fd, mama, 200);
    printf("log: %s - %d\n", mama, da);*/
    
    //engine_set(module_fd, 1, "ana", 3);
    //engine_set_cfgreg(module_fd, 1, 5);
    //engine_get_cfgreg(module_fd, 1);
    //return 1;
    /*while (1) {
        printf("message = ");
        fgets(message, 1024, stdin);
        //printf("number = ");
        //scanf("%d", &nr);
        //nr = 3;
        //while (nr--)
        return_val = write(module_fd, message, strlen(message) - 1);
        printf("Write exit witl ret = %d\n", return_val);
        if (strncmp(message, "da", 2) == 0) {
            break;
        }
    //return_val = ioctl(module_fd, EPI_IOC_GET_ENG_PATTERN, &eng);
    }*/

    /*printf("Sending 1000 packets!\n");
    int gg = 1000;
    strcpy(message, "ce mai faci, anaia? ...");
    memset(message + 23, 'a', 999);
    message[1023] = 0;
    for (i = 0; i < gg; i++) {
        write(module_fd, message, 1024);
    }
    
    printf("Statistics about speed:\n");
    avg_paralleltime = engine_get_avgtime(module_fd);
    printf("\tAvg time packets precessed = %d\n", avg_paralleltime);
    avg_lineartime = engine_get_lineartime(module_fd);
    printf("\tAvg time linear precessing = %d\n", avg_lineartime);
    printf("\tSpeed-up = %1.3f\n", (float)avg_lineartime / (float)avg_paralleltime);
    */
    message[0] = 0;

    printf("\nLogs:\n");
    return_val = read(module_fd, message, 1024);
    while (return_val > 0) {
        printf("~~~ Packet: ~~~\n");
        for (i = 0; i < return_val; i++)
            printf("%c", message[i]);
        printf("\n");
        return_val = read(module_fd, message, 1024);
    }
    return 0;
}