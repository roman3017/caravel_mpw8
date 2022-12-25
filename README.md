# MPW shuttle

## USB2UART

Full speed USB2 to 115200 bauds UART module for TTL logic at 3V3. It requires 48MHz clock from user_clock2.

See verilog/rtl/fpga folder for FPGA tests.

```sh
mkdir -p dependencies
export OPENLANE_ROOT=$(pwd)/dependencies/openlane_src
export PDK_ROOT=$(pwd)/dependencies/pdks
export PDK=sky130A
make setup

make user_proj_example
klayout -l dependencies/pdks/sky130A/libs.tech/klayout/tech/sky130A.lyp gds/user_proj_example.gds

make user_project_wrapper
klayout -l dependencies/pdks/sky130A/libs.tech/klayout/tech/sky130A.lyp gds/user_project_wrapper.gds

make verify
make SIM=GL verify
#make extract-parasitics
make create-spef-mapping
#make caravel-sta
rm -rf ~/mpw_precheck/
make precheck
make run-precheck
#make compress
```

## References

 - [QUICKSTART](https://caravel-user-project.readthedocs.io/en/latest) For a QSG.
 - [README](docs/source/index.rst) For a sample project documentation.
 - [USB CDC](https://github.com/ulixxe/usb_cdc) IP taken from ulixxe
 - [UART](https://github.com/alexforencich/verilog-uart) IP taken from alexforencich
 - [MPW shuttle](https://platform.efabless.com/shuttles/MPW-8) Submitted project 1758
