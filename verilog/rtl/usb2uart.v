`default_nettype none

module usb2uart (
    input  clk48, // 48MHz Clock
    input  rst, // reset
    input  uart_rx, // uart in
    output uart_tx, // uart out
    inout  usb_p, // USB+
    inout  usb_n, // USB-
    output usb_pu,  // USB 1.5kOhm Pullup EN
    output usb_tx_en  // USB tx enabled
);

    wire             in_ready;
    wire [7:0]       in_data;
    wire             in_valid;
    wire             out_ready;
    wire [7:0]       out_data;
    wire             out_valid;

    uart # (
        .DATA_WIDTH(8)
    ) u_uart (
        .clk(clk48),
        .rst(rst),

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
        
        //115200 bauds from 48MHz clock
        .prescale(((48*1000000)+(115200*8)-1)/(115200*8))
    );

    wire             dp_pu;
    wire             dp_rx;
    wire             dn_rx;
    wire             dp_tx;
    wire             dn_tx;
    wire             tx_en;

    assign usb_p = tx_en ? dp_tx : 1'bz;
    assign dp_rx = usb_p;

    assign usb_n = tx_en ? dn_tx : 1'bz;
    assign dn_rx = usb_n;

    assign usb_pu = dp_pu;
    assign usb_tx_en = tx_en;

    usb_cdc #(
        .VENDORID(16'h1D50),
        .PRODUCTID(16'h6130)
    ) u_usb_cdc (
        .clk_i(clk48),
        .rstn_i(~rst),
        .app_clk_i(1'b0),

        //data output from usb rx
        .out_data_o(out_data),
        .out_valid_o(out_valid),
        .out_ready_i(out_ready),

        //data input to usb tx
        .in_data_i(in_data),
        .in_valid_i(in_valid),
        .in_ready_o(in_ready),

        .dp_pu_o(dp_pu),
        .tx_en_o(tx_en),
        .dp_tx_o(dp_tx),
        .dn_tx_o(dn_tx),
        .dp_rx_i(dp_rx),
        .dn_rx_i(dn_rx)
    );

endmodule

`default_nettype wire