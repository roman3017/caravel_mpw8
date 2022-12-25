# Simulation tests

## UART

```sh
iverilog test_uart.v ../verilog-uart/rtl/uart.v ../verilog-uart/rtl/uart_rx.v ../verilog-uart/rtl/uart_tx.v -o test_uart.out

./test_uart.out
gtkwave test_uart.vcd
```

## USB

```sh
cd ../usb_cdc/
git apply ../0001-usb_cdc-fix-make-targets.patch

cd examples/TinyFPGA-BX/OSS_CAD_Suite/
make PROJ=soc clean sim
make PROJ=soc wave
```

# FPGA tests

Use TinyFPGA_BX to test.

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

## USB2UART

Attach another USB2UART to the first three pins on TinyFPGA_BX: GND, 1(RX), and 2(TX). One should see characters being passed between.

```sh
tinyprog -l
make clean all
make prog
tinyprog -b

minicom -D /dev/ttyACM0
minicom -D /dev/ttyUSB0
```
