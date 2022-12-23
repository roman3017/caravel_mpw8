module fpga_top (
   input  clk, // 16MHz Clock
   output led, // User LED ON=1, OFF=0
   input  uart_rx, // uart in
   output uart_tx, // uart out
   inout  usb_p, // USB+
   inout  usb_n, // USB-
   output usb_pu  // USB 1.5kOhm Pullup EN
);

   localparam BIT_SAMPLES       = 4;
   localparam c_CLOCK_MHZ       = BIT_SAMPLES*12;
   localparam c_UART_SPEED      = 115200;
   localparam c_CLKS_PER_BYTE   = (c_CLOCK_MHZ*1000000+c_UART_SPEED*8-1)/(c_UART_SPEED*8);

   wire             clk_pll; //48MHz clock
   wire             lock;

   wire             dp_pu;
   wire             dp_rx;
   wire             dn_rx;
   wire             dp_tx;
   wire             dn_tx;
   wire             tx_en;

   wire             in_ready;
   wire [7:0]       in_data;
   wire             in_valid;
   wire             out_ready;
   wire [7:0]       out_data;
   wire             out_valid;

   pll pll48( .clock_in(clk), .clock_out(clk_pll), .locked( lock ) );

   assign led = 1'b1;

   reg [1:0]        rstn_sync;
   wire             rstn;
   assign rstn = rstn_sync[0];
   always @(posedge clk_pll or negedge lock) begin
      if (~lock) begin
         rstn_sync <= 2'd0;
      end else begin
         rstn_sync <= {1'b1, rstn_sync[1]};
      end
   end

   uart # (
      .DATA_WIDTH(8)
   ) u_uart (
      .clk(clk_pll),
      .rst(~rstn),

      //data input to uart tx
      .s_axis_tdata(out_data),
      .s_axis_tvalid(out_valid),
      .s_axis_tready(out_ready),
      .txd(uart_tx),

      //data output from uart rx
      .m_axis_tdata(in_data),
      .m_axis_tvalid(in_valid),
      .m_axis_tready(in_ready),
      .rxd(uart_rx),

      .prescale(c_CLKS_PER_BYTE)
   );

   usb_cdc #(
      .VENDORID(16'h1D50),
      .PRODUCTID(16'h6130)
   ) u_usb_cdc (
      .clk_i(clk_pll), // 48MHz
      .rstn_i(rstn),
      .app_clk_i(1'b0),

      //data output from usb rx
      .out_data_o(out_data),
      .out_valid_o(out_valid),
      .out_ready_i(out_ready),

      //data input to usb tx
      .in_data_i(in_data),
      .in_valid_i(in_valid),
      .in_ready_o(in_ready),

      .frame_o(),
      .configured_o(),

      .dp_pu_o(dp_pu),
      .tx_en_o(tx_en),
      .dp_tx_o(dp_tx),
      .dn_tx_o(dn_tx),
      .dp_rx_i(dp_rx),
      .dn_rx_i(dn_rx)
   );

   SB_IO #(
      .PIN_TYPE(6'b101001),
      .PULLUP(1'b0)
   ) u_usb_p (
      .PACKAGE_PIN(usb_p),
      .OUTPUT_ENABLE(tx_en),
      .D_OUT_0(dp_tx),
      .D_IN_0(dp_rx),
      .D_OUT_1(1'b0),
      .D_IN_1(),
      .CLOCK_ENABLE(1'b0),
      .LATCH_INPUT_VALUE(1'b0),
      .INPUT_CLK(1'b0),
      .OUTPUT_CLK(1'b0));

   SB_IO #(
      .PIN_TYPE(6'b101001),
      .PULLUP(1'b0)
   ) u_usb_n (
      .PACKAGE_PIN(usb_n),
      .OUTPUT_ENABLE(tx_en),
      .D_OUT_0(dn_tx),
      .D_IN_0(dn_rx),
      .D_OUT_1(1'b0),
      .D_IN_1(),
      .CLOCK_ENABLE(1'b0),
      .LATCH_INPUT_VALUE(1'b0),
      .INPUT_CLK(1'b0),
      .OUTPUT_CLK(1'b0));

   // drive usb_pu to 3.3V or to high impedance
   SB_IO #(
      .PIN_TYPE(6'b101001),
      .PULLUP(1'b0))
   u_usb_pu (
      .PACKAGE_PIN(usb_pu),
      .OUTPUT_ENABLE(dp_pu),
      .D_OUT_0(1'b1),
      .D_IN_0(),
      .D_OUT_1(1'b0),
      .D_IN_1(),
      .CLOCK_ENABLE(1'b0),
      .LATCH_INPUT_VALUE(1'b0),
      .INPUT_CLK(1'b0),
      .OUTPUT_CLK(1'b0));

endmodule
