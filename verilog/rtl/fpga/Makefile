# SPDX-License-Identifier: Apache-2.0

# Usage:
# make clean all
# make prog

NAME = fpga_top
DEPS = \
../usb_cdc/usb_cdc/phy_tx.v \
../usb_cdc/usb_cdc/phy_rx.v \
../usb_cdc/usb_cdc/sie.v \
../usb_cdc/usb_cdc/ctrl_endp.v \
../usb_cdc/usb_cdc/in_fifo.v \
../usb_cdc/usb_cdc/out_fifo.v \
../usb_cdc/usb_cdc/bulk_endp.v \
../usb_cdc/usb_cdc/usb_cdc.v \
../usb_cdc/examples/common/hdl/prescaler.v \
../usb_cdc/examples/common/hdl/fifo_if.v \
pll.v \
../verilog-uart/rtl/uart_rx.v \
../verilog-uart/rtl/uart_tx.v \
../verilog-uart/rtl/uart.v
PIN_DEF = fpga_pins.pcf

# TinyFPGA-BX
FPGA_SIZE = 8k
FPGA_TYPE = lp
FPGA_PACK = cm81

CLK_MHZ = 48

all: sint time

pll.v:
	icepll -i 16 -o $(CLK_MHZ) -m -f $@

sim: $(NAME)_tb.vcd
	gtkwave $< $(<:.vcd=.gtkw) &

$(NAME)_tb.vcd: $(NAME).v $(DEPS) $(NAME)_tb.v

sint: $(NAME).bin

$(NAME).json: $(NAME).v $(DEPS)

$(NAME).asc: $(NAME).json $(PIN_DEF)

prog: $(NAME).bin
	tinyprog -p $<

time: $(NAME).rpt

.SUFFIXES: .asc .bin .json .v .vcd .rpt

.asc.rpt:
	icetime -d $(FPGA_TYPE)$(FPGA_SIZE) -P $(FPGA_PACK) -mtr $@ $^

.v.vcd:
	iverilog $^ -o $(@:.vcd=.out)
	./$(@:.vcd=.out)

.v.json:
	yosys -p "$(foreach file,$^,read_verilog $(file);)" -p "synth_ice40 -json $@" $^

.json.asc:
	nextpnr-ice40 --$(FPGA_TYPE)$(FPGA_SIZE) --freq $(CLK_MHZ) --package $(FPGA_PACK) --pcf-allow-unconstrained --pcf $(PIN_DEF) --json $< --asc $@

.asc.bin:
	icepack $< $@

clean:
	rm -f *.bin *.asc *.json *.out *.vcd *.rpt

.PHONY: all sim sint prog clean time
