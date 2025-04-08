////////////////////////////////////////////////////////////////////
// Design    : demo_chip
// Author(s) : 
// Creation date : August 9,2013
// Copyright (C) ...
////////////////////////////////////////////////////////////////////
// Description:  demo_chip instantiates the following modules:
//     1    MIPS 32r1 CPU
//     2    nova decoder wrapper
//     3    4 * HPDMC DDR controllers
//     4    USB controller + PHY
//
////////////////////////////////////////////////////////////////////


module demo_chip(

    output mclk,             // Main system clock    (used by external memories)
    input reset_n,


    //
    // First H264 Decoder Pins
    //

    input   [15:0]  BS_data_0,
    output          BS_ren_0,
    output  [16:0]  BS_addr_0,


    //
    // Second H264 Decoder Pins
    //

    input   [15:0]  BS_data_1,
    output          BS_ren_1,
    output  [16:0]  BS_addr_1,


    //
    // Microcontroller pins
    //
    input lfxt_clk,          // Low frequency reference (typ 10MHz)
    input nmi,               // Non-maskable interrupt (asynchronous and non-glitchy)
    

    // DDR0
    output ddr0_cke,
    output ddr0_cs_n,
    output ddr0_we_n,
    output ddr0_cas_n,
    output ddr0_ras_n,
    output [12:0] ddr0_adr,
    output [1:0]  ddr0_ba,

    output [3:0]  ddr0_dm,
    inout  [31:0] ddr0_dq,
    inout  [3:0]  ddr0_dqs,
    
    // DDR1
    output ddr1_cke,
    output ddr1_cs_n,
    output ddr1_we_n,
    output ddr1_cas_n,
    output ddr1_ras_n,
    output [12:0] ddr1_adr,
    output [1:0]  ddr1_ba,

    output [3:0]  ddr1_dm,
    inout  [31:0] ddr1_dq,
    inout  [3:0]  ddr1_dqs,
    
    // DDR2
    output ddr2_cke,
    output ddr2_cs_n,
    output ddr2_we_n,
    output ddr2_cas_n,
    output ddr2_ras_n,
    output [12:0] ddr2_adr,
    output [1:0]  ddr2_ba,

    output [3:0]  ddr2_dm,
    inout  [31:0] ddr2_dq,
    inout  [3:0]  ddr2_dqs,
    
    // DDR3
    output ddr3_cke,
    output ddr3_cs_n,
    output ddr3_we_n,
    output ddr3_cas_n,
    output ddr3_ras_n,
    output [12:0] ddr3_adr,
    output [1:0]  ddr3_ba,

    output [3:0]  ddr3_dm,
    inout  [31:0] ddr3_dq,
    inout  [3:0]  ddr3_dqs,
    
    // USB
    inout usb_plus, usb_minus,
    
    // 
    
    input scan_mode,
    input sysclk_byp,
    input usbclk_byp
    
);
    


// Internal chip side pad connections

    wire lfxt_clk_i;             // Main system clock    (used by external memories)
    wire reset_n_i;
    wire nmi_i;                  // Non-maskable interrupt (asynchronous and non-glitchy)
    wire mclk_i;                 // Main system clock    (used by external memories)

    wire scan_mode_i;
    wire sysclk_byp_i;
    wire usbclk_byp_i;

    // DDR
    wire    ddr0_cke_i, ddr0_cs_n_i, ddr0_we_n_i, ddr0_cas_n_i, ddr0_ras_n_i,
            ddr1_cke_i, ddr1_cs_n_i, ddr1_we_n_i, ddr1_cas_n_i, ddr1_ras_n_i,
            ddr2_cke_i, ddr2_cs_n_i, ddr2_we_n_i, ddr2_cas_n_i, ddr2_ras_n_i,
            ddr3_cke_i, ddr3_cs_n_i, ddr3_we_n_i, ddr3_cas_n_i, ddr3_ras_n_i;
    wire [12:0] ddr0_adr_i, ddr1_adr_i, ddr2_adr_i, ddr3_adr_i;
    wire [1:0]  ddr0_ba_i,  ddr1_ba_i,  ddr2_ba_i,  ddr3_ba_i;
    wire [3:0]  ddr0_dm_i,  ddr1_dm_i,  ddr2_dm_i,  ddr3_dm_i;


    wire [15:0] BitStream_buffer_input_0_i;
    wire BitStream_ram_ren_0_i;
    wire [16:0] BitStream_ram_addr_0_i;
    wire [15:0] BitStream_buffer_input_1_i;
    wire BitStream_ram_ren_1_i;
    wire [16:0] BitStream_ram_addr_1_i;
//    wire [15:0] BS_data_0;         //added by sudhish for missing declarations on pads 
//    wire [15:0] BS_data_1; 
    

    wire [31:0] dmem_din;           // Data Memory data input
    wire [29:0] dmem_addr;          // Data Memory address
    wire [3:0] dmem_wen;            // Data Memory write enable (low active)
    wire dmem_cen;                  // Data Memory write enable (low active)

    wire [31:0] power_control;      // Power switch powerdwon control
    wire [31:0] power_iso;          // Power switch isolation control
    wire [31:0] power_ack;          // Power switch acknowledge
    wire power_control_0;
    wire power_ack_0;
// QSG    wire power_ack_2;
// QSG    wire power_control_2;

    wire smclk;
    wire pll_clk, pll_clk_o;
    wire aclk;
    wire dco_clk;
    reg  enable_nova0, enable_nova1;
    wire mclk_nova0,   mclk_nova1;

    wire ext_frame_RAM0_cs_n;
    wire ext_frame_RAM0_wr;
    wire [13:0] ext_frame_RAM0_addr;
    wire [31:0] ext_frame_RAM0_data;
    wire [63:0] fml_do_ddr0;
    
    wire ext_frame_RAM1_cs_n;
    wire ext_frame_RAM1_wr;
    wire [13:0] ext_frame_RAM1_addr;
    wire [31:0] ext_frame_RAM1_data;
    wire [63:0] fml_do_ddr1;

    wire [31:0] dis_frame_RAM_din_0;

    wire ext_frame_RAM2_cs_n;
    wire ext_frame_RAM2_wr;
    wire [13:0] ext_frame_RAM2_addr;
    wire [31:0] ext_frame_RAM2_data;
    wire [63:0] fml_do_ddr2;
    
    wire ext_frame_RAM3_cs_n;
    wire ext_frame_RAM3_wr;
    wire [13:0] ext_frame_RAM3_addr;
    wire [31:0] ext_frame_RAM3_data;
    wire [63:0] fml_do_ddr3;

    wire [31:0] dis_frame_RAM_din_1;

    //  USB
    wire    usb_clk, usb_clk_o;
    wire	    usb_txdp, usb_txdn, usb_txoe;
    wire	    usb_rxd,  usb_rxdp, usb_rxdn;
    wire    [7:0]   usb_DataOut;
    wire            usb_TxValid;
    wire            usb_TxReady;
    wire    [7:0]   usb_DataIn;
    wire            usb_RxValid;
    wire            usb_RxActive;
    wire            usb_RxError;
    wire    [1:0]   usb_LineState;
    wire            usb_inta, usb_intb;
    wire    [4:0]   Interrupts;            // 5 general-purpose hardware interrupts


    // Define clocks - all from PLL
    
    assign smclk        = pll_clk;
    assign mclk_i         = pll_clk;
    assign mclk_n       = !pll_clk;
    assign dqs_clk      = pll_clk;
    assign dqs_clk_n    = !pll_clk;
    assign aclk         = pll_clk;
    assign mclk_i         = pll_clk;
    assign dco_clk      = pll_clk;


//  ---------------------------------
//     External pads (non-DDR)
//  ---------------------------------



PADBID lfxt_clk_pad ( .I(1'b0),   .OEN(1'b1), .PAD(lfxt_clk),   .C(lfxt_clk_i) );
PADBID reset_n_pad  ( .I(1'b0),   .OEN(1'b1), .PAD(reset_n),    .C(reset_n_i) );
PADBID nmi_pad      ( .I(1'b0),   .OEN(1'b1), .PAD(nmi),        .C(nmi_i) );
PADBID mclk_pad     ( .I(mclk_i), .OEN(1'b0), .PAD(mclk),       .C() );

PADBID BS_ren_0_pad ( .I(BitStream_ram_ren_0_i), .OEN(1'b0), .PAD(BS_ren_0), .C() );
PADBID BS_ren_1_pad ( .I(BitStream_ram_ren_1_i), .OEN(1'b0), .PAD(BS_ren_1), .C() );

PADBID scan_mode_pad   ( .I(1'b0),   .OEN(1'b1), .PAD(scan_mode),    .C(scan_mode_i) );
// PADBID sysclk_byp_pad  ( .I(1'b0),   .OEN(1'b1), .PAD(sysclk_byp),   .C(sysclk_byp_i) );
//PADBID usbclk_byp_pad  ( .I(1'b0),   .OEN(1'b1), .PAD(usbclk_byp),   .C(usbclk_byp_i) );
PADCLK sysclk_byp_pad  (  .PAD(sysclk_byp),   .C(sysclk_byp_i) );
PADCLK usbclk_byp_pad  (  .PAD(usbclk_byp),   .C(usbclk_byp_i) );

genvar i, ddr;

// Data buses
generate
    for (i = 0; i <= 15; i = i + 1) begin
        PADBID BS_data_0_pad ( .I(1'b0), .OEN(1'b1), .PAD(BS_data_0[i]), .C(BitStream_buffer_input_0_i[i]) );
        PADBID BS_data_1_pad ( .I(1'b0), .OEN(1'b1), .PAD(BS_data_1[i]), .C(BitStream_buffer_input_1_i[i]) );
    end
endgenerate

// Address buses
generate
    for (i = 0; i <= 16; i = i + 1) begin
        PADBID BS_addr_0_pad ( .I(BitStream_ram_addr_0_i[i]), .OEN(1'b0), .PAD(BS_addr_0[i]),  .C() );
        PADBID BS_addr_1_pad ( .I(BitStream_ram_addr_1_i[i]), .OEN(1'b0), .PAD(BS_addr_1[i]),  .C() );
    end
endgenerate

PADBID i_usb_pad_plus  ( .I(usb_txdp), .OEN(usb_txoe), .PAD(usb_plus),  .C(usb_rxdp) );
PADBID i_usb_pad_minus ( .I(usb_txdn), .OEN(usb_txoe), .PAD(usb_minus), .C(usb_rxdn) );
assign usb_rxd = usb_rxdp && usb_rxdn;

//  ---------------------------------
//     DDR output pads (data pads are in the PHY module
//  ---------------------------------
PADBID ddr0_cke_pad   ( .I(ddr0_cke_i),    .OEN(1'b0), .PAD(ddr0_cke),   .C() );
PADBID ddr0_cs_n_pad  ( .I(ddr0_cs_n_i),   .OEN(1'b0), .PAD(ddr0_cs_n),  .C() );
PADBID ddr0_we_n_pad  ( .I(ddr0_we_n_i),   .OEN(1'b0), .PAD(ddr0_we_n),  .C() );
PADBID ddr0_cas_n_pad ( .I(ddr0_cas_n_i),  .OEN(1'b0), .PAD(ddr0_cas_n), .C() );
PADBID ddr0_ras_n_pad ( .I(ddr0_ras_n_i),  .OEN(1'b0), .PAD(ddr0_ras_n), .C() );
PADBID ddr1_cke_pad   ( .I(ddr1_cke_i),    .OEN(1'b0), .PAD(ddr1_cke),   .C() );
PADBID ddr1_cs_n_pad  ( .I(ddr1_cs_n_i),   .OEN(1'b0), .PAD(ddr1_cs_n),  .C() );
PADBID ddr1_we_n_pad  ( .I(ddr1_we_n_i),   .OEN(1'b0), .PAD(ddr1_we_n),  .C() );
PADBID ddr1_cas_n_pad ( .I(ddr1_cas_n_i),  .OEN(1'b0), .PAD(ddr1_cas_n), .C() );
PADBID ddr1_ras_n_pad ( .I(ddr1_ras_n_i),  .OEN(1'b0), .PAD(ddr1_ras_n), .C() );
PADBID ddr2_cke_pad   ( .I(ddr2_cke_i),    .OEN(1'b0), .PAD(ddr2_cke),   .C() );
PADBID ddr2_cs_n_pad  ( .I(ddr2_cs_n_i),   .OEN(1'b0), .PAD(ddr2_cs_n),  .C() );
PADBID ddr2_we_n_pad  ( .I(ddr2_we_n_i),   .OEN(1'b0), .PAD(ddr2_we_n),  .C() );
PADBID ddr2_cas_n_pad ( .I(ddr2_cas_n_i),  .OEN(1'b0), .PAD(ddr2_cas_n), .C() );
PADBID ddr2_ras_n_pad ( .I(ddr2_ras_n_i),  .OEN(1'b0), .PAD(ddr2_ras_n), .C() );
PADBID ddr3_cke_pad   ( .I(ddr3_cke_i),    .OEN(1'b0), .PAD(ddr3_cke),   .C() );
PADBID ddr3_cs_n_pad  ( .I(ddr3_cs_n_i),   .OEN(1'b0), .PAD(ddr3_cs_n),  .C() );
PADBID ddr3_we_n_pad  ( .I(ddr3_we_n_i),   .OEN(1'b0), .PAD(ddr3_we_n),  .C() );
PADBID ddr3_cas_n_pad ( .I(ddr3_cas_n_i),  .OEN(1'b0), .PAD(ddr3_cas_n), .C() );
PADBID ddr3_ras_n_pad ( .I(ddr3_ras_n_i),  .OEN(1'b0), .PAD(ddr3_ras_n), .C() );

generate
    for (i = 0; i <= 12; i = i + 1) begin
        PADBID ddr0_adr_pad   ( .I(ddr0_adr_i[i]),   .OEN(1'b0), .PAD(ddr0_adr[i]),   .C() );
        PADBID ddr1_adr_pad   ( .I(ddr1_adr_i[i]),   .OEN(1'b0), .PAD(ddr1_adr[i]),   .C() );
        PADBID ddr2_adr_pad   ( .I(ddr2_adr_i[i]),   .OEN(1'b0), .PAD(ddr2_adr[i]),   .C() );
        PADBID ddr3_adr_pad   ( .I(ddr3_adr_i[i]),   .OEN(1'b0), .PAD(ddr3_adr[i]),   .C() );
    end
endgenerate
generate
    for (i = 0; i <= 1; i = i + 1) begin
        PADBID ddr0_ba_pad   ( .I(ddr0_ba_i[i]),     .OEN(1'b0), .PAD(ddr0_ba[i]),    .C() );
        PADBID ddr1_ba_pad   ( .I(ddr1_ba_i[i]),     .OEN(1'b0), .PAD(ddr1_ba[i]),    .C() );
        PADBID ddr2_ba_pad   ( .I(ddr2_ba_i[i]),     .OEN(1'b0), .PAD(ddr2_ba[i]),    .C() );
        PADBID ddr3_ba_pad   ( .I(ddr3_ba_i[i]),     .OEN(1'b0), .PAD(ddr3_ba[i]),    .C() );
    end
endgenerate
generate
    for (i = 0; i <= 3; i = i + 1) begin
        PADBID ddr0_dm_pad   ( .I(ddr0_dm_i[i]),     .OEN(1'b0), .PAD(ddr0_dm[i]),    .C() );
        PADBID ddr1_dm_pad   ( .I(ddr1_dm_i[i]),     .OEN(1'b0), .PAD(ddr1_dm[i]),    .C() );
        PADBID ddr2_dm_pad   ( .I(ddr2_dm_i[i]),     .OEN(1'b0), .PAD(ddr2_dm[i]),    .C() );
        PADBID ddr3_dm_pad   ( .I(ddr3_dm_i[i]),     .OEN(1'b0), .PAD(ddr3_dm[i]),    .C() );
    end
endgenerate
    
//  ---------------------------------
//  Peripheral Interface bus
//  ---------------------------------

    wire [15:0] per_dout;        // Register data output to microcontroller
    wire [15:0] per_dout_nova0;  // Register data output from nova0
    wire [15:0] per_dout_nova1;  // Register data output from nova1
    wire [31:0] per_dout_ddr0;   // Register data output from ddr0
    wire [31:0] per_dout_ddr1;   // Register data output from ddr0
    wire [31:0] per_dout_ddr2;   // Register data output from ddr0
    wire [31:0] per_dout_ddr3;   // Register data output from ddr0
    wire [31:0] per_dout_usb;    // Register data output from USB
    wire [31:0] per_dout_pctl;   // Register data output from USB
    wire [13:0] per_addr;        // Register address
    wire [31:0] per_din;         // Register data input
    wire [1:0]  per_we;          // Register write enable (high active)
    wire per_en;                 // Register enable (high active)
    wire per_rd;                 // Register read
assign per_din      = dmem_din;
assign per_dout     =  {15'h0000,per_dout_nova0}        || 
                       {15'h0000,per_dout_nova1[15:0]}  || 
                       per_dout_ddr0                    ||
                       per_dout_ddr1                    ||
                       per_dout_ddr2                    ||
                       per_dout_ddr3                    ||
                       per_dout_usb                     ||
                       per_dout_pctl                    ||
                       32'h00000000;
assign per_en       = dmem_addr[29];
assign per_we[0]    = dmem_addr[29] && dmem_wen[0];
assign per_we[1]    = dmem_addr[29] && dmem_wen[1];
assign per_rd       = per_en && !per_we[0];
assign per_addr     = dmem_addr[13:0];
//assign DataMem_In   = dmem_addr[29] ? per_dout : dmem_dout;

    wire  NMI;                         // Non-maskable interrupt
    wire  DataMem_Ready;
    wire DataMem_Read; 
    wire [3:0]  DataMem_Write;        // 4-bit Write; one for each byte in word.
    wire [29:0] DataMem_Address;      // Addresses are words; not bytes.
    wire [31:0] DataMem_Out;
    // Instruction Memory Interface
    wire  [31:0] InstMem_In;
    wire [29:0] InstMem_Address;      // Addresses are words; not bytes.
    wire  InstMem_Ready;
    wire InstMem_Read;
    wire [7:0] IP;                    // Pending interrupts (diagnostic)

assign Interrupts = { 3'b0, usb_inta, usb_intb } ;

//  ---------------------------------
//    MIPS CPU
//  ---------------------------------

cpu_sys i_cpu_sys (
    .clock(smclk),
    .reset(reset_n_i),
    .Interrupts(Interrupts),                  // 5 general-purpose hardware interrupts
    .NMI(nmi_i),                         // Non-maskable interrupt
    // Data Memory Interface
    .per_dout(per_dout),
    .DataMem_Read(dmem_rd), 
    .DataMem_Write(dmem_wen),                 // 4-bit Write, one for each byte in word.
    .DataMem_Address(dmem_addr),                 // Addresses are words, not bytes.
    .DataMem_Out(dmem_din)

);



//  ---------------------------------
//   Powerdown register
//  ---------------------------------

// Tie off pre-layout - will connect to power switches
// assign power_ack = 32'hffff_ffff;

powerdown_control powerdown_control (
    .clk(mclk_i),
    .reset_n(reset_n_i),
    .per_addr(per_addr),
    .per_din(per_din),
    .per_en(per_en),
    .per_we(per_we[0]),
    .per_rd(per_rd),
    .per_dout(per_dout_pctl),
    .power_control(power_control),
    .power_ack(power_ack),
    .power_iso(power_iso)
);

//dummy_connector dummy_connector (.power_control(power_control), .power_iso(power_iso), .power_ack(power_ack) );

// NOVA 0 clock gate
always @(negedge mclk_i ) enable_nova0 <= power_iso[0];
AND2_X1_HVT i_nova0_cg (.A1(mclk_i), .A2(enable_nova0), .ZN(mclk_nova0) );

    ///////////////////	
    // NOVA decoders //
    ///////////////////	
    nova_wrapper nova0 (
    .clk(mclk_nova0),
    .clk_reg(smclk),
    .reset_n(reset_n_i),
    .per_dout(per_dout_nova0),
    .per_addr(per_addr),
    .per_din(per_din[15:0]),
    .per_en(per_en),
    .per_we(per_we),
    .BitStream_buffer_input(BitStream_buffer_input_0_i),
    .BitStream_ram_ren(BitStream_ram_ren_0_i),
    .BitStream_ram_addr(BitStream_ram_addr_0_i),
    .ext_frame_RAM0_cs_n(ext_frame_RAM0_cs_n),
    .ext_frame_RAM0_wr(ext_frame_RAM0_wr),
    .ext_frame_RAM0_addr(ext_frame_RAM0_addr),
    .ext_frame_RAM0_data(ext_frame_RAM0_data),
    .ext_frame_RAM1_cs_n(ext_frame_RAM1_cs_n),
    .ext_frame_RAM1_wr(ext_frame_RAM1_wr),
    .ext_frame_RAM1_addr(ext_frame_RAM1_addr),
    .ext_frame_RAM1_data(ext_frame_RAM1_data),
    .dis_frame_RAM_din(dis_frame_RAM_din_0),
    .power_ack(power_ack_0),
    .power_control(power_control_0)
    );

//   DDR port 0

// Dummy register to create control signal
reg [7:0] fml_sel_ddr0;
always @ (posedge mclk_nova0 )
    begin
        if ( ext_frame_RAM0_cs_n == 1'b0 )
            if ( ext_frame_RAM0_wr ) 
                fml_sel_ddr0 <= dis_frame_RAM_din_0[7:0];
            else 
                fml_sel_ddr0 <= dis_frame_RAM_din_0[15:8];
    end
// Create to get a 2 bit pll_stat for DDR
wire sys_pll_lock;
reg sys_pll_lock_sync;
always @ (posedge pll_clk_o ) sys_pll_lock_sync <= sys_pll_lock;
    
// Dummy register to expand DDR bus to 64 bits
reg [31:0] nova0_data_extend;
wire [63:0]nova0_fml_di;
always @ (posedge mclk_nova0 ) nova0_data_extend <= dis_frame_RAM_din_0;
assign nova0_fml_di = { nova0_data_extend, dis_frame_RAM_din_0 };
assign ext_frame_RAM0_data = ext_frame_RAM0_addr[13] ? fml_do_ddr0 [63:32] : fml_do_ddr0 [31:0] ;

hpdmc #(
	.csr_addr(4'h0),
        .sdram_depth(14),
        .sdram_columndepth(9)
) nova0_ddr0 (
	.sys_clk(mclk_nova0),
	.sys_clk_n(!mclk_nova0),
	
	.dqs_clk(mclk_nova0),
	.dqs_clk_n(!mclk_nova0),
	
	.sys_rst(!reset_n_i),

	/* Control interface */
 	.csr_a(per_addr),
	.csr_we(per_we[0]),
	.csr_di(per_din),
	.csr_do(per_dout_ddr0),
	
	/* Simple FML 4x64 interface to the memory contents */
	.fml_adr(ext_frame_RAM0_addr),
	.fml_stb(ext_frame_RAM0_cs_n),
	.fml_we(ext_frame_RAM0_wr),
	.fml_ack(),
	.fml_sel(fml_sel_ddr0),
	.fml_di(nova0_fml_di),
	.fml_do(fml_do_ddr0),
	
	/* SDRAM interface.
	 * The SDRAM clock should be driven synchronously to the system clock.
	 * It is not generated inside this core so you can take advantage of
	 * architecture-dependent clocking resources to generate a clean
	 * differential clock.
	 */
	.sdram_cke(ddr0_cke_i),
	.sdram_cs_n(ddr0_cs_n_i),
	.sdram_we_n(ddr0_we_n_i),
	.sdram_cas_n(ddr0_cas_n_i),
	.sdram_ras_n(ddr0_ras_n_i),
	.sdram_adr(ddr0_adr_i),
	.sdram_ba(ddr0_ba_i),
	
	 
        .sdram_dm(ddr0_dm_i),
        .sdram_dq(ddr0_dq),
	.sdram_dqs(ddr0_dqs),
	
	/* Interface to the DCM generating DQS */
	.dqs_psen(),
	.dqs_psincdec(),
	.dqs_psdone(1'b0),

	.pll_stat({sys_pll_lock,sys_pll_lock_sync})
);

//   DDR port 1

// Dummy register to create control signal
reg [7:0] fml_sel_ddr1;
always @ (posedge mclk_nova0 )
    begin
        if ( ext_frame_RAM1_cs_n == 1'b0 )
            if ( ext_frame_RAM1_wr ) 
                fml_sel_ddr1 <= dis_frame_RAM_din_0[23:16];
            else 
                fml_sel_ddr1 <= dis_frame_RAM_din_0[31:24];
    end
assign ext_frame_RAM1_data = ext_frame_RAM1_addr[13] ? fml_do_ddr1 [63:32] : fml_do_ddr1 [31:0] ;

hpdmc #(
	.csr_addr(4'h1),
        .sdram_depth(14),
        .sdram_columndepth(9)
) nova0_ddr1 (
	.sys_clk(mclk_nova0),
	.sys_clk_n(!mclk_nova0),
	
	.dqs_clk(mclk_nova0),
	.dqs_clk_n(!mclk_nova0),
	
	.sys_rst(!reset_n_i),

	/* Control interface */
 	.csr_a(per_addr),
	.csr_we(per_we[0]),
	.csr_di(per_din),
	.csr_do(per_dout_ddr1),
	
	/* Simple FML 4x64 interface to the memory contents */
	.fml_adr(ext_frame_RAM1_addr),
	.fml_stb(ext_frame_RAM1_cs_n),
	.fml_we(ext_frame_RAM1_wr),
	.fml_ack(),
	.fml_sel(fml_sel_ddr1),
	.fml_di(nova0_fml_di),
	.fml_do(fml_do_ddr1),
	
	/* SDRAM interface.
	 * The SDRAM clock should be driven synchronously to the system clock.
	 * It is not generated inside this core so you can take advantage of
	 * architecture-dependent clocking resources to generate a clean
	 * differential clock.
	 */
	.sdram_cke(ddr1_cke_i),
	.sdram_cs_n(ddr1_cs_n_i),
	.sdram_we_n(ddr1_we_n_i),
	.sdram_cas_n(ddr1_cas_n_i),
	.sdram_ras_n(ddr1_ras_n_i),
	.sdram_adr(ddr1_adr_i),
	.sdram_ba(ddr1_ba_i),
	
	 
        .sdram_dm(ddr1_dm_i),
        .sdram_dq(ddr1_dq),
	.sdram_dqs(ddr1_dqs),
	
	/* Interface to the DCM generating DQS */
	.dqs_psen(),
	.dqs_psincdec(),
	.dqs_psdone(1'b0),

	.pll_stat({sys_pll_lock,sys_pll_lock_sync})
);

// NOVA 1 clock gate
always @(negedge mclk_i ) enable_nova1 <= power_iso[1];
AND2_X1_HVT i_nova1_cg (.A1(mclk_i), .A2(enable_nova1), .ZN(mclk_nova1) );



    nova_wrapper nova1 (
    .clk(mclk_nova1),
    .clk_reg(smclk),
    .reset_n(reset_n_i),
    .per_dout(per_dout_nova1),
    .per_addr(per_addr),
    .per_din(per_din[15:0]),
    .per_en(per_en),
    .per_we(per_we),
    .BitStream_buffer_input(BitStream_buffer_input_1_i),
    .BitStream_ram_ren(BitStream_ram_ren_1_i),
    .BitStream_ram_addr(BitStream_ram_addr_1_i),
    .ext_frame_RAM0_cs_n(ext_frame_RAM2_cs_n),
    .ext_frame_RAM0_wr(ext_frame_RAM2_wr),
    .ext_frame_RAM0_addr(ext_frame_RAM2_addr),
    .ext_frame_RAM0_data(ext_frame_RAM2_data),
    .ext_frame_RAM1_cs_n(ext_frame_RAM3_cs_n),
    .ext_frame_RAM1_wr(ext_frame_RAM3_wr),
    .ext_frame_RAM1_addr(ext_frame_RAM3_addr),
    .ext_frame_RAM1_data(ext_frame_RAM3_data),
    .dis_frame_RAM_din(dis_frame_RAM_din_1),
    .power_ack(power_ack[1]),
    .power_control(power_control[1])
    );

//   DDR port 2

// Dummy register to create control signal
reg [7:0] fml_sel_ddr2;
always @ (posedge mclk_nova1 )
    begin
        if ( ext_frame_RAM2_cs_n == 1'b0 )
            if ( ext_frame_RAM0_wr ) 
                fml_sel_ddr2 <= dis_frame_RAM_din_1[7:0];
            else 
                fml_sel_ddr2 <= dis_frame_RAM_din_1[15:8];
    end
// Dummy register to expand DDR bus to 64 bits
reg [31:0] nova1_data_extend;
wire [63:0]nova1_fml_di;
always @ (posedge mclk_nova1 ) nova1_data_extend <= dis_frame_RAM_din_1;
assign nova1_fml_di = { nova1_data_extend, dis_frame_RAM_din_1 };
assign ext_frame_RAM2_data = ext_frame_RAM2_addr[13] ? fml_do_ddr2 [63:32] : fml_do_ddr2 [31:0] ;

hpdmc #(
	.csr_addr(4'h2),
        .sdram_depth(14),
        .sdram_columndepth(9)
) nova0_ddr2 (
	.sys_clk(mclk_nova1),
	.sys_clk_n(!mclk_nova1),
	
	.dqs_clk(mclk_nova1),
	.dqs_clk_n(!mclk_nova1),
	
	.sys_rst(!reset_n_i),

	/* Control interface */
 	.csr_a(per_addr),
	.csr_we(per_we[0]),
	.csr_di(per_din),
	.csr_do(per_dout_ddr2),
	
	/* Simple FML 4x64 interface to the memory contents */
	.fml_adr(ext_frame_RAM2_addr),
	.fml_stb(ext_frame_RAM2_cs_n),
	.fml_we(ext_frame_RAM2_wr),
	.fml_ack(),
	.fml_sel(fml_sel_ddr2),
	.fml_di(nova1_fml_di),
	.fml_do(fml_do_ddr2),
	
	/* SDRAM interface.
	 * The SDRAM clock should be driven synchronously to the system clock.
	 * It is not generated inside this core so you can take advantage of
	 * architecture-dependent clocking resources to generate a clean
	 * differential clock.
	 */
	.sdram_cke(ddr2_cke_i),
	.sdram_cs_n(ddr2_cs_n_i),
	.sdram_we_n(ddr2_we_n_i),
	.sdram_cas_n(ddr2_cas_n_i),
	.sdram_ras_n(ddr2_ras_n_i),
	.sdram_adr(ddr2_adr_i),
	.sdram_ba(ddr2_ba_i),
	
	 
        .sdram_dm(ddr2_dm_i),
        .sdram_dq(ddr2_dq),
	.sdram_dqs(ddr2_dqs),
	
	/* Interface to the DCM generating DQS */
	.dqs_psen(),
	.dqs_psincdec(),
	.dqs_psdone(1'b0),

	.pll_stat({sys_pll_lock,sys_pll_lock_sync})
);

//   DDR port 3

// Dummy register to create control signal
reg [7:0] fml_sel_ddr3;
always @ (posedge mclk_nova1 )
    begin
        if ( ext_frame_RAM3_cs_n == 1'b0 )
            if ( ext_frame_RAM0_wr ) 
                fml_sel_ddr3 <= dis_frame_RAM_din_1[23:16];
            else 
                fml_sel_ddr3 <= dis_frame_RAM_din_1[31:24];
    end
assign ext_frame_RAM3_data = ext_frame_RAM3_addr[13] ? fml_do_ddr3 [63:32] : fml_do_ddr3 [31:0] ;

hpdmc #(
	.csr_addr(4'h1),
        .sdram_depth(14),
        .sdram_columndepth(9)
) nova0_ddr3 (
	.sys_clk(mclk_nova1),
	.sys_clk_n(!mclk_nova1),
	
	.dqs_clk(mclk_nova1),
	.dqs_clk_n(!mclk_nova1),
	
	.sys_rst(!reset_n_i),

	/* Control interface */
 	.csr_a(per_addr),
	.csr_we(per_we[0]),
	.csr_di(per_din),
	.csr_do(per_dout_ddr3),
	
	/* Simple FML 4x64 interface to the memory contents */
	.fml_adr(ext_frame_RAM3_addr),
	.fml_stb(ext_frame_RAM3_cs_n),
	.fml_we(ext_frame_RAM3_wr),
	.fml_ack(),
	.fml_sel(fml_sel_ddr3),
	.fml_di(nova1_fml_di),
	.fml_do(fml_do_ddr3),
	
	/* SDRAM interface.
	 * The SDRAM clock should be driven synchronously to the system clock.
	 * It is not generated inside this core so you can take advantage of
	 * architecture-dependent clocking resources to generate a clean
	 * differential clock.
	 */
	.sdram_cke(ddr3_cke_i),
	.sdram_cs_n(ddr3_cs_n_i),
	.sdram_we_n(ddr3_we_n_i),
	.sdram_cas_n(ddr3_cas_n_i),
	.sdram_ras_n(ddr3_ras_n_i),
	.sdram_adr(ddr3_adr_i),
	.sdram_ba(ddr3_ba_i),
	
	 
        .sdram_dm(ddr3_dm_i),
        .sdram_dq(ddr3_dq),
	.sdram_dqs(ddr3_dqs),
	
	/* Interface to the DCM generating DQS */
	.dqs_psen(),
	.dqs_psincdec(),
	.dqs_psdone(1'b0),

	.pll_stat({sys_pll_lock,sys_pll_lock_sync})
);

usb_sys i_usbf (
                // WISHBONE Interface
// QSG                .power_ack(power_ack_2),
// QSG                .power_control(power_control_2),
                .clk_i(mclk_i),
                .rst_i(reset_n_i),
                .wb_addr_i(dmem_addr[17:0]), 
                .wb_data_i(per_din), 
                .wb_data_o(per_dout_usb),
                .wb_we_i(per_we[0]), 
                .wb_stb_i(per_en), 
                .inta_o(usb_intb), 
                .intb_o(usb_inta),

		// UTMI Interface
		.phy_clk_pad_i(usb_clk), 
                .phy_rst_pad_o(phy_rst_pad),
		.DataOut_pad_o(usb_DataOut), 
                .TxValid_pad_o(usb_TxValid), 
                .TxReady_pad_i(usb_TxReady),

		.RxValid_pad_i      (usb_RxValid), 
                .RxActive_pad_i     (usb_RxActive), 
                .RxError_pad_i      (usb_RxError),
		.DataIn_pad_i       (usb_DataIn), 
                .LineState_pad_i    (usb_LineState)
		);


usb_phy i_usb_phy(
                .clk(usb_clk), 
                .rst(phy_rst_pad), 
                .phy_tx_mode(1'b0), 
                .usb_rst(),	
		// UTMI Interface
		.DataOut_i      (usb_DataOut), 
                .TxValid_i      (usb_TxValid), 
                .TxReady_o      (usb_TxReady), 
                .RxValid_o      (usb_RxValid),
		.RxActive_o     (usb_RxActive), 
                .RxError_o      (usb_RxError), 
                .DataIn_o       (usb_DataIn), 
                .LineState_o    (usb_LineState),
	
		.txdp(usb_txdp), 
                .txdn(usb_txdn),
                .txoe(usb_txoe),	
		.rxd(usb_rxd), 
                .rxdp(usb_rxdp), 
                .rxdn(usb_rxdn)
		);

    //  --------------------
    //   Main  PLL 
    //   DIVR = 1, DIVF = 80. DIVQ = 2
    //   Overall Multiply by 40
    //  --------------------
    PLL i_MAIN_PLL (
        .REF(lfxt_clk_i),     // Reference clock
        .FB(dco_clk),       // Feedback clock
        .FSE(1'b1),         // Selects source of feedback input
        .BYPASS(1'b0),
        .RESET(!reset_n_i),
        .DIVF7(1'b0),   .DIVF6(1'b1),   .DIVF5(1'b0),   .DIVF4(1'b0),   .DIVF3(1'b1),   .DIVF2(1'b1),   .DIVF1(1'b1),   .DIVF0(1'b1),
        .DIVQ2(1'b0),   .DIVQ1(1'b0),   .DIVQ0(1'b1),
        .DIVR5(1'b0),   .DIVR4(1'b0),   .DIVR3(1'b0),   .DIVR2(1'b0),   .DIVR1(1'b0),   .DIVR0(1'b0),
        .RANGE2(1'b0),  .RANGE1(1'b0),  .RANGE0(1'b1),

        .LOCK(sys_pll_lock), 
        .PLLOUT(pll_clk_o)
    );

    //assign pll_clk = scan_mode_i ? sysclk_byp_i : pll_clk_o;
    MUX2_X2_HVT i_sys_clk_mux ( .A(pll_clk_o), .B(sysclk_byp_i), .S(scan_mode_i), .Z(pll_clk) );

    //  --------------------
    //   USB  PLL 
    //   DIVR = 1, DIVF = 96. DIVQ = 16
    //   Overall Multiply by 6
    //  --------------------
    PLL i_USB_PLL (
        .REF(lfxt_clk_i),     // Reference clock
        .FB(1'b0),       // Feedback clock
        .FSE(1'b1),         // Selects source of feedback input
        .BYPASS(1'b0),
        .RESET(!reset_n_i),
        .DIVF7(1'b0),   .DIVF6(1'b1),   .DIVF5(1'b0),   .DIVF4(1'b1),   .DIVF3(1'b1),   .DIVF2(1'b1),   .DIVF1(1'b1),   .DIVF0(1'b1),
        .DIVQ2(1'b1),   .DIVQ1(1'b0),   .DIVQ0(1'b0),
        .DIVR5(1'b0),   .DIVR4(1'b0),   .DIVR3(1'b0),   .DIVR2(1'b0),   .DIVR1(1'b0),   .DIVR0(1'b0),
        .RANGE2(1'b0),  .RANGE1(1'b0),  .RANGE0(1'b1),

        .LOCK(),            // ??? Will it be used?
        .PLLOUT(usb_clk_o)
    );

    //assign usb_clk = scan_mode_i ? usbclk_byp_i : usb_clk_o;
    MUX2_X2_HVT i_usb_clk_mux ( .A(usb_clk_o), .B(usbclk_byp_i), .S(scan_mode_i), .Z(usb_clk) );

endmodule

