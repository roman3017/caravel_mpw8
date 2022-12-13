# FPGA tests

Use TinyFPGA to test.

## USB

```sh
cd ../usb_cdc/examples/TinyFPGA-BX/OSS_CAD_Suite/
tinyprog -l
make all PROJ=soc
make prog PROJ=soc
minicom -D /dev/ttyACM0
```

