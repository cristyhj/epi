#ifndef _UART_CONNECT_H_
#define _UART_CONNECT_H_

#define PORT_NAME "/dev/ttyPS0"

void uart_connect();
int uart_send(const char * buff, int len);
int uart_recv(char *buff, int max_len);
void uart_disconnect();

void uart_exec_command(int module_fd);


#endif	// _UART_CONNECT_H_