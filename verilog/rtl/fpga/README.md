# FPGA tests

Use TinyFPGA to test.

## USB

See echo of slightly modified input.

```sh
cd ../usb_cdc/examples/TinyFPGA-BX/OSS_CAD_Suite/
tinyprog -l
make PROJ=soc clean all
make PROJ=soc prog
tinyprog -b

minicom -D /dev/ttyACM0
```

## USB2TTL

Attach another USB2TTL to pins 4,5 and see characters being passed between.

```sh
tinyprog -l
make clean all
make prog
tinyprog -b

minicom -D /dev/ttyACM0
minicom -D /dev/ttyUSB0
```
