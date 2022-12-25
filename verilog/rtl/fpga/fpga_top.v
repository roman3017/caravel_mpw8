module fpga_top (
   input  clk, // 16MHz Clock
   input  uart_rx, // uart in
   output uart_tx, // uart out
   inout  usb_p, // USB+
   inout  usb_n, // USB-
   output usb_pu  // USB 1.5kOhm Pullup EN
);

   wire clk_pll;
   pll pll48( .clock_in(clk), .clock_out(clk_pll) );

   reg [5:0] reset_cnt = 0;
   wire rstn = &reset_cnt;
   always @(posedge clk_pll) reset_cnt <= reset_cnt + !rstn;

   usb2uart usb2uart (
      .clk48(clk_pll),
      .rst(~rstn),
      .uart_rx(uart_rx),
      .uart_tx(uart_tx),
      .usb_p(usb_p),
      .usb_n(usb_n),
      .usb_pu(usb_pu),
      .usb_tx_en()
   );

endmodule
