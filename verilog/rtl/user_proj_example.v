// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // User clock
    input user_clock2,

    // IRQ
    output [2:0] irq
);

    wire clk;
    wire rst;
    wire uart_rx;
    wire uart_tx;
    wire usb_p;
    wire usb_n;
    wire usb_pu;
    wire usb_tx_en;

    // WB
    assign wbs_dat_o = 32'h00000000;
    assign wbs_ack_o = 1'b0;

    // LA
    assign la_data_out = 128'h00000000000000000000000000000000;

    // IO
    assign io_out[`MPRJ_IO_PADS-6:0] = {(`MPRJ_IO_PADS-5){1'b0}};
    assign io_oeb[`MPRJ_IO_PADS-6:0] = {(`MPRJ_IO_PADS-5){1'b1}};

    // IRQ
    assign irq = 3'b000;

    assign clk = user_clock2;
    assign rst = wb_rst_i;

    // io_out[33] output uart_tx
    assign io_oeb[`MPRJ_IO_PADS-5] = 1'b0;
    assign io_out[`MPRJ_IO_PADS-5] = uart_tx;

    // io_out[34] input uart_rx
    assign io_oeb[`MPRJ_IO_PADS-4] = 1'b1;
    assign uart_rx = io_in[`MPRJ_IO_PADS-4];

    // io_out[35] output usb_pu
    assign io_oeb[`MPRJ_IO_PADS-3] = 1'b0;
    assign io_out[`MPRJ_IO_PADS-3] = usb_pu;

    // io_out[36] inout usb_n
    assign io_oeb[`MPRJ_IO_PADS-2] = ~usb_tx_en;
    assign io_out[`MPRJ_IO_PADS-2] = /* usb_tx_en ? */ usb_n;
    assign usb_n = io_in[`MPRJ_IO_PADS-2];

    // io_out[37] inout usb_p
    assign io_oeb[`MPRJ_IO_PADS-1] = ~usb_tx_en;
    assign io_out[`MPRJ_IO_PADS-1] = /* usb_tx_en ? */ usb_p;
    assign usb_p = io_in[`MPRJ_IO_PADS-1];

    usb2uart usb2uart (
        .clk48(clk),
        .rst(rst),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .usb_p(usb_p),
        .usb_n(usb_n),
        .usb_pu(usb_pu),
        .usb_tx_en(usb_tx_en)
    );

endmodule

`default_nettype wire
