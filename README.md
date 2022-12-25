# MPW shuttle (WIP)
## USB2UART

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
#make extract-parasitics
make create-spef-mapping
#make caravel-sta
rm -rf ~/mpw_precheck/
make precheck
make run-precheck
#make compress
```

## References
[QUICKSTART] (https://caravel-user-project.readthedocs.io/en/latest) for a QSG.
[README](docs/source/index.rst) for a sample project documentation. 
