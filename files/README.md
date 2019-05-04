# Contains
This folder contains generate files nedded to recreate the project.

## Boot files
`BOOT.bin` is generated using `bootgen` command or using the SDK tools provided by Xilinx.
It is created from: `fsbl.elf`, `u-boot.elf`, `system.bit`.

## Environment
Depending on u-boot compile and desired boot mode, `uEnv.txt` file may be used. The u-boot loads environment variables from it.
The one provided try to boot from SD once all others boot modes fail.

## Driver
The compiled driver file is `epi.ko`. You can load the driver with `insmod` command.

## Test
The test app is `test`. Run `./test help` for information.