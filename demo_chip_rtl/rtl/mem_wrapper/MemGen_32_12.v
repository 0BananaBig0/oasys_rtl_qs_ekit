module MemGen_32_12 (
    chip_en,
    clock,
    addr,

    rd_en,
    rd_data,
   
    wr_en,
    wr_data
);

    parameter data_width	=	32;
    parameter addr_width	=	12;
    parameter mem_depth	 	=	4096;

    input                               chip_en;
    input                               clock;
    input	[addr_width-1:0]	addr;

    output	[data_width-1:0]	rd_data;
    input                               rd_en;
      
    input                               wr_en;
    input	[data_width-1:0]	wr_data;
   
    reg		[data_width-1:0]	rd_data;

reg [3:0] mem_sel ;
wire [31:0] mem_data_out [3:0];

always @(*)
    begin
        if ( chip_en == 1'b1 )
            case (addr[11:10])
                2'h0 : begin mem_sel = 4'b0001; rd_data = mem_data_out[0]; end
                2'h1 : begin mem_sel = 4'b0010; rd_data = mem_data_out[1]; end
                2'h2 : begin mem_sel = 4'b0100; rd_data = mem_data_out[2]; end
                2'h3 : begin mem_sel = 4'b1000; rd_data = mem_data_out[3]; end
            endcase
        else
            begin
                mem_sel =  4'b0000; 
                rd_data = 32'h00000000;   
            end
    end


genvar i;

generate
    for (i = 0; i < 4; i = i + 1) begin
        MemGen_16_10 U_lo (.chip_en(mem_sel[i]), .clock(clock), .addr(addr[9:0]), .rd_en(rd_en), .rd_data(mem_data_out[i][15:0]),  .wr_en(wr_en), .wr_data(wr_data[15:0]) );
        MemGen_16_10 U_hi (.chip_en(mem_sel[i]), .clock(clock), .addr(addr[9:0]), .rd_en(rd_en), .rd_data(mem_data_out[i][31:16]), .wr_en(wr_en), .wr_data(wr_data[31:16]) );
    end
endgenerate

endmodule
