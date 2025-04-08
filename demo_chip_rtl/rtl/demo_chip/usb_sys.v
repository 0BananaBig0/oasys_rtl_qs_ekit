module usb_sys (// WISHBONE Interface
		clk_i, rst_i, 
                wb_addr_i,  wb_data_i,  wb_data_o,
		wb_we_i,    wb_stb_i,   inta_o, intb_o,

		// UTMI Interface
		phy_clk_pad_i, phy_rst_pad_o,
		DataOut_pad_o, TxValid_pad_o, TxReady_pad_i,

		RxValid_pad_i, RxActive_pad_i, RxError_pad_i,
// QSG		DataIn_pad_i,  LineState_pad_i, power_control, power_ack
		DataIn_pad_i,  LineState_pad_i

        	);

//QSG input power_control;
//QSG output power_ack;
input		clk_i;
input		rst_i;
input	[17:0]	wb_addr_i;
input	[31:0]	wb_data_i;
output	[31:0]	wb_data_o;
input		wb_we_i;
input		wb_stb_i;
output		inta_o;
output		intb_o;

input		phy_clk_pad_i;
output		phy_rst_pad_o;

output	[7:0]	DataOut_pad_o;
output		TxValid_pad_o;
input		TxReady_pad_i;

input	[7:0]	DataIn_pad_i;
input		RxValid_pad_i;
input		RxActive_pad_i;
input		RxError_pad_i;

input	[1:0]	LineState_pad_i;

wire    [13:0]  usb_buf_addr;
wire    [31:0]  usb_buf_dout;
wire    [31:0]  usb_buf_din;
wire            usb_buf_wen;
wire            usb_buf_ren;

usbf_top i_usbf (
//QSG                .power_control(power_control),
//QSG                .power_ack(power_ack),

                // WISHBONE Interface
                .clk_i(clk_i),
                .rst_i(rst_i),
                .wb_addr_i(wb_addr_i), 
                .wb_data_i(wb_data_i), 
                .wb_data_o(wb_data_o),
                .wb_ack_o(), 
                .wb_we_i(wb_we_i), 
                .wb_stb_i(wb_stb_i), 
                .wb_cyc_i(1'b0), 
                .inta_o(inta_o), 
                .intb_o(intb_o),
                .dma_req_o(), 
                .dma_ack_i(16'b0), 
                .susp_o(), 
                .resume_req_i(1'b0),
		// UTMI Interface
		.phy_clk_pad_i(phy_clk_pad_i), 
                .phy_rst_pad_o(phy_rst_pad_o),
		.DataOut_pad_o(DataOut_pad_o), 
                .TxValid_pad_o(TxValid_pad_o), 
                .TxReady_pad_i(TxReady_pad_i),





                .RxValid_pad_i      (RxValid_pad_i), 
                .RxActive_pad_i     (RxActive_pad_i), 
                .RxError_pad_i      (RxError_pad_i),
		.DataIn_pad_i       (DataIn_pad_i), 
                .XcvSelect_pad_o    (), 
                .TermSel_pad_o      (),
		.SuspendM_pad_o     (), 
                .LineState_pad_i    (LineState_pad_i),

		.OpMode_pad_o(), 
                .usb_vbus_pad_i(1'b0),
		.VControl_Load_pad_o(), 
                .VControl_pad_o(), 
                .VStatus_pad_i(8'b0),

		// Buffer Memory Interface
		.sram_adr_o(usb_buf_addr), 
                .sram_data_i(usb_buf_dout), 
                .sram_data_o(usb_buf_din), 
                .sram_re_o(usb_buf_ren), 
                .sram_we_o(usb_buf_wen)


		);


MemGen_32_14 usb_buffer_mem (
   .chip_en(1'b1),
   .clock(clk_i),  
   .addr(usb_buf_addr), 
   .rd_data(usb_buf_dout),
   .rd_en(usb_buf_ren),
   .wr_data(usb_buf_din),
   .wr_en(usb_buf_wen )
	);

endmodule
