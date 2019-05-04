# epi
Ethernet Packet Inspection

## epi_vivado
The vivado project

Contains: 
- main design 	(src/bd)
- main IP 		(repo/packet_analyzer_core)

## pc/epi_driver
The linux char driver that controls the design.

Contains:
- main.c 			(char driver instantiation)
- epi_dma.c 		(dma functionalities)
- epi_device.c 		(device's interaction with files)
- epi_netfilter.c 	(netfilter hook)

## pc/epi_app
The linux user-space application that interacts with the driver

Contains:
- engine.c 			(functions communicating with the engine)
- uart_connect.c 	(functions communicating with hosts computers via UART)

## pc/epi_siem
The Windows SIEM application interface.

## pc/include
Contains common definiotions for both epi_app and epi_driver.

## files
Contains generated files, usefull to run the project without any compile.