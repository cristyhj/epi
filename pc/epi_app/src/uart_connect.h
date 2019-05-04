#ifndef _UART_CONNECT_H_
#define _UART_CONNECT_H_

#define PORT_NAME "/dev/ttyPS0"

void uart_connect();
int uart_send(const char * buff, unsigned char *data, int len);
int uart_recv(char *buff, int max_len, unsigned char *data);
void uart_disconnect();

int uart_exec_command(int module_fd);

void protocol_get_attribute(const char *string, char *key, char *dest);
void potocol_get_command(const char *string, char *dest);
int protocol_has_data(const char *string);


#endif	// _UART_CONNECT_H_