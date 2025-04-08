////////////////////////////////////////////////////////////////////
// Design    : nova_wrapper
// Author(s) : 
// Creation date : August 13,2013
// Copyright (C) ...
////////////////////////////////////////////////////////////////////
// Description: Includes nova module and associated registers
//
////////////////////////////////////////////////////////////////////


module nova_wrapper(
    input clk,
    input clk_reg,
    input reset_n,
    input power_control,
    output power_ack,

    //---register access---
    output [15:0] per_dout,
    input [13:0] per_addr,
    input [15:0] per_din,
    input per_en,
    input [1:0] per_we,

    input [15:0] BitStream_buffer_input,
    output BitStream_ram_ren,
    output [16:0] BitStream_ram_addr,

    //---ext_frame_RAM0---
    output ext_frame_RAM0_cs_n,
    output ext_frame_RAM0_wr,
    output [13:0] ext_frame_RAM0_addr,
    input [31:0] ext_frame_RAM0_data,
    
    //---ext_frame_RAM1---
    output ext_frame_RAM1_cs_n,
    output ext_frame_RAM1_wr,
    output [13:0] ext_frame_RAM1_addr,
    input [31:0] ext_frame_RAM1_data,
    
    output [31:0] dis_frame_RAM_din
    );

	//assign power_ack=power_control;//To ask RnD how to declare control
	//and acknowledgement of power switch chains in RTL
    // nova pins stored in registers
    wire slice_header_s6;
    wire [5:0] pic_num;
    wire freq_ctrl0, freq_ctrl1, pin_disable_DF;

    ///////////////
    // Registers //
    ///////////////
    // Code copied and modified from Opencores  openMSP430 periph/template_periph_16b.v

    // 1)  PARAMETER DECLARATION

    // Register base address (must be aligned to decoder bit width)
    parameter       [14:0] BASE_ADDR   = 15'h0190;

    // Decoder bit width (defines how many bits are considered for address decoding)
    parameter              DEC_WD      =  3;

    // Register addresses offset
    parameter [DEC_WD-1:0] CNTRL1      = 'h0,
                           CNTRL2      = 'h2;

    // Register one-hot decoder utilities
    parameter              DEC_SZ      =  (1 << DEC_WD);
    parameter [DEC_SZ-1:0] BASE_REG    =  {{DEC_SZ-1{1'b0}}, 1'b1};

    // Register one-hot decoder
    parameter [DEC_SZ-1:0] CNTRL1_D    = (BASE_REG << CNTRL1),
                           CNTRL2_D    = (BASE_REG << CNTRL2);

    // 2)  REGISTER DECODER

    // Local register selection
    wire              reg_sel   =  per_en & (per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);

    // Register local address
    wire [DEC_WD-1:0] reg_addr  =  {per_addr[DEC_WD-2:0], 1'b0};

    // Register address decode
    wire [DEC_SZ-1:0] reg_dec   =  (CNTRL1_D  &  {DEC_SZ{(reg_addr == CNTRL1 )}})  |
                                   (CNTRL2_D  &  {DEC_SZ{(reg_addr == CNTRL2 )}});

    // Read/Write probes
    wire              reg_write =  |per_we & reg_sel;
    wire              reg_read  = ~|per_we & reg_sel;

    // Read/Write vectors
    wire [DEC_SZ-1:0] reg_wr    = reg_dec & {DEC_SZ{reg_write}};
    wire [DEC_SZ-1:0] reg_rd    = reg_dec & {DEC_SZ{reg_read}};

    // 3) REGISTERS
    
    // CNTRL1 Register
    wire  [15:0] cntrl1;
    assign cntrl1 = {slice_header_s6, 9'b0, pic_num[5:0]};

   
    // CNTRL2 Register
    reg  [15:0] cntrl2;
    wire        cntrl2_wr = reg_wr[CNTRL2];
    always @ (posedge clk_reg or negedge reset_n)
      if (!reset_n)       cntrl2 <=  16'h0000;
      else if (cntrl2_wr) cntrl2 <=  per_din;

    // Reset sync
    reg reset_n_sync;
    always @ (posedge clk_reg or negedge reset_n)
        begin
            if (!reset_n)       
                reset_n_sync <=  1'b0;
            else 
                reset_n_sync <=  reset_n;
        end

    assign freq_ctrl0 = cntrl2[0];
    assign freq_ctrl1 = cntrl2[1];
    assign pin_disable_DF = cntrl2[2];

    // 4) DATA OUTPUT GENERATION

    // Data output mux
    wire [15:0] cntrl1_rd  = cntrl1  & {16{reg_rd[CNTRL1]}};
    wire [15:0] cntrl2_rd  = cntrl2  & {16{reg_rd[CNTRL2]}};

    assign per_dout   =  cntrl1_rd  | cntrl2_rd  ;


    //////////////////	
    // NOVA decoder //
    //////////////////	

    nova nova (
    .clk(clk),
    .reset_n(reset_n_sync),
    .freq_ctrl0(freq_ctrl0),
    .freq_ctrl1(freq_ctrl1),
    .BitStream_buffer_input(BitStream_buffer_input),
    .BitStream_ram_ren(BitStream_ram_ren),
    .BitStream_ram_addr(BitStream_ram_addr),
    .pic_num(pic_num),
    .pin_disable_DF(pin_disable_DF),
    .ext_frame_RAM0_cs_n(ext_frame_RAM0_cs_n),
    .ext_frame_RAM0_wr(ext_frame_RAM0_wr),
    .ext_frame_RAM0_addr(ext_frame_RAM0_addr),
    .ext_frame_RAM0_data(ext_frame_RAM0_data),
    .ext_frame_RAM1_cs_n(ext_frame_RAM1_cs_n),
    .ext_frame_RAM1_wr(ext_frame_RAM1_wr),
    .ext_frame_RAM1_addr(ext_frame_RAM1_addr),
    .ext_frame_RAM1_data(ext_frame_RAM1_data), 
    .dis_frame_RAM_din(dis_frame_RAM_din),
    .slice_header_s6(slice_header_s6)
    );

endmodule
