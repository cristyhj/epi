# epi
Ethernet Packet Inspection

## epi_vivado
The vivado project

Contains: 
- main design 	(src/bd)
- main IP 		(repo/inspection_unit_v1_0_project)

## epi_driver
The linux char driver that controls the design.

Contains:
- main.c 			(char driver instantiation)
- epi_dma.c 		(dma functionalities)
- epi_device.c 		(device's interaction with files)
- epi_netfilter.c 	(netfilter hook)

## epi_app
The linux user-space application that interacts with the driver

Contains:
- engine.c 		(functions communicating with the engine)
- uart_connect 	(functions communicating with hosts computers via UART)

### include folder
Contains common definiotions for both epi_app and epi_driver.