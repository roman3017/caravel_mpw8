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
klayout -l $PDK_ROOT/$PDK/libs.tech/klayout/tech/$PDK.lyp gds/user_proj_example.gds
magic -rcfile $PDK_ROOT/$PDK/libs.tech/magic/$PDK.magicrc gds/user_proj_example.gds

make user_project_wrapper
klayout -l $PDK_ROOT/$PDK/libs.tech/klayout/tech/$PDK.lyp gds/user_project_wrapper.gds
magic -rcfile $PDK_ROOT/$PDK/libs.tech/magic/$PDK.magicrc gds/user_project_wrapper.gds

make verify-usb2uart-rtl
make verify-usb2uart-gl

#make extract-parasitics
make create-spef-mapping
#make caravel-sta

rm -rf ~/mpw_precheck/
make precheck
make run-precheck
#make compress
```

## References

 - [MPW-8](https://platform.efabless.com/shuttles/MPW-8) Shuttle projects (project 1758)
 - [USB](https://github.com/ulixxe/usb_cdc) IP taken from ulixxe
 - [UART](https://github.com/alexforencich/verilog-uart) IP taken from alexforencich
 - [Harness](https://caravel-harness.readthedocs.io/en/latest) Harness specification
 - [OpenLane](https://openlane.readthedocs.io/en/latest) OpenLane documentation
 - [Board](https://github.com/efabless/caravel_board) Test board
 - [PLL ](https://github.com/kbeckmann/caravel-pll-calculator) PLL registers calculator
 - [QSG](https://caravel-user-project.readthedocs.io/en/latest) Quick start guide
 - [README](docs/source/index.rst) A sample project documentation
