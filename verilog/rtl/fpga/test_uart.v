/*
 * Usage:
 * iverilog test_uart.v ../rtl/uart.v ../rtl/uart_rx.v ../rtl/uart_tx.v -o test_uart.out
 * ./test_uart.out
 * gtkwave test_uart.vcd [test_uart.gtkw]
 */

`timescale 1 ns / 1 ps

module test_uart;

// Testbench uses a 48 MHz clock
// Want to interface to 115200 baud UART
// 10000000 / 115200 = 87 Clocks Per Bit.
parameter c_CLOCK_MHZ       = 48;
parameter c_UART_SPEED      = 115200;

parameter c_CLOCK_PERIOD_NS = 1000/c_CLOCK_MHZ;
parameter c_CLKS_PER_BIT    = c_CLOCK_MHZ*1000000/c_UART_SPEED;
parameter c_CLKS_PER_BYTE   = (c_CLKS_PER_BIT+7)/8;
parameter c_BIT_PERIOD      = c_CLKS_PER_BIT*c_CLOCK_PERIOD_NS;

integer i;
integer j;

reg [15:0] prescale = c_CLKS_PER_BYTE;
reg clk = 0;
reg rst = 0;

// Inputs
reg m_axis_tready = 0;
reg rxd = 1;
// Outputs
wire [7:0] m_axis_tdata;
wire m_axis_tvalid;
wire rx_busy;
wire rx_overrun_error;
wire rx_frame_error;

// Inputs
reg [7:0] s_axis_tdata = 8'd0;
reg s_axis_tvalid = 1'b0;
reg [9:0] r_Tx_Data = 0;
// Outputs
wire s_axis_tready;
wire txd;
wire tx_busy;

// Write a byte to RX pin
task UART_WRITE_RX_AND_RCV;
    input [7:0] i_Data;
    integer     ii;
begin
    m_axis_tready <= 1;

    // Write Start Bit
    #(c_BIT_PERIOD) rxd <= 1'b0;

    // Write Data
    for (ii=0; ii<8; ii=ii+1)
    begin
        #(c_BIT_PERIOD) rxd <= i_Data[ii];
    end

    // Write Stop Bit
    #(c_BIT_PERIOD) rxd <= 1'b1;

    @(posedge m_axis_tvalid);
end
endtask

// Send a byte and read back data from TX pin
task UART_SEND_AND_READ_TX;
    output [9:0] o_Data;
    integer      ii;
begin
    // Send byte
    @(posedge clk);
    s_axis_tvalid <= 1'b1;
    @(posedge clk);
    s_axis_tvalid <= 1'b0;

    @(posedge tx_busy);

    // Read Data
    for (ii=0; ii<10; ii=ii+1)
    begin
        #(c_BIT_PERIOD) o_Data[ii] <= txd;
    end

    @(posedge s_axis_tready);
end
endtask

always
#(c_CLOCK_PERIOD_NS/2) clk <= !clk;

initial begin
    $dumpfile("test_uart.vcd");
    $dumpvars(0, test_uart);

    // Exercise Rx
    j=0;
    for (i=0; i<256; i=i+1)
    begin
        UART_WRITE_RX_AND_RCV(i);
        if (m_axis_tdata == i)
            j=j+1;
        else
            $display("RX Test Failed - Incorrect Byte Received");
    end
    if (j == 256)
        $display("RX Test Passed - Correct Bytes Received");

    // Exercise Tx
    j=0;
    for (i=0; i<256; i=i+1)
    begin
        s_axis_tdata <= i;
        UART_SEND_AND_READ_TX(r_Tx_Data);
        // Check that the correct byte was sent
        if (r_Tx_Data[8:1] == i)
            j=j+1;
        else
            $display("TX Test Failed - Incorrect Byte Sent");
    end
    if (j == 256)
        $display("TX Test Passed - Correct Bytes Sent");

    $finish;
end

uart #(
    .DATA_WIDTH(8)
)
UUT (
    .clk(clk),
    .rst(rst),
    // axi output
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    // input
    .rxd(rxd),
    // status
    .rx_busy(rx_busy),
    .rx_overrun_error(rx_overrun_error),
    .rx_frame_error(rx_frame_error),
    // axi input
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    // output
    .txd(txd),
    // status
    .tx_busy(tx_busy),
    // configuration
    .prescale(prescale)
);

endmodule
