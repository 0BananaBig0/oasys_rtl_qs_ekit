module MemGen_32_14 (
    chip_en,
    clock,
    addr,

    rd_en,
    rd_data,
   
    wr_en,
    wr_data
);

    parameter data_width	=	32;
    parameter addr_width	=	14;
    parameter mem_depth	 	=	16384;

    input						chip_en;
    input						clock;
    input	[addr_width-1:0]	addr;

    output	[data_width-1:0]	rd_data;
    input						rd_en;
      
    input						wr_en;
    input	[data_width-1:0]	wr_data;
   
    reg		[data_width-1:0]	rd_data;

reg  [15:0] mem_sel ;
wire [31:0] mem_data_out [15:0];

always @(*)
    begin
        if ( chip_en == 1'b1 )
            case (addr[13:10])
                4'h0 : begin mem_sel = 16'b0000000000000001; rd_data = mem_data_out[0];  end
                4'h1 : begin mem_sel = 16'b0000000000000010; rd_data = mem_data_out[1];  end
                4'h2 : begin mem_sel = 16'b0000000000000100; rd_data = mem_data_out[2];  end
                4'h3 : begin mem_sel = 16'b0000000000001000; rd_data = mem_data_out[3];  end
                4'h4 : begin mem_sel = 16'b0000000000010000; rd_data = mem_data_out[4];  end
                4'h5 : begin mem_sel = 16'b0000000000100000; rd_data = mem_data_out[5];  end
                4'h6 : begin mem_sel = 16'b0000000001000000; rd_data = mem_data_out[6];  end
                4'h7 : begin mem_sel = 16'b0000000010000000; rd_data = mem_data_out[7];  end
                4'h8 : begin mem_sel = 16'b0000000100000000; rd_data = mem_data_out[8];  end
                4'h9 : begin mem_sel = 16'b0000001000000000; rd_data = mem_data_out[9];  end
                4'hA : begin mem_sel = 16'b0000010000000000; rd_data = mem_data_out[10]; end
                4'hB : begin mem_sel = 16'b0000100000000000; rd_data = mem_data_out[11]; end
                4'hC : begin mem_sel = 16'b0001000000000000; rd_data = mem_data_out[12]; end
                4'hD : begin mem_sel = 16'b0010000000000000; rd_data = mem_data_out[13]; end
                4'hE : begin mem_sel = 16'b0100000000000000; rd_data = mem_data_out[14]; end
                4'hF : begin mem_sel = 16'b1000000000000000; rd_data = mem_data_out[15]; end
            endcase
        else
            begin
                mem_sel =  4'b0000; 
                rd_data = 32'h00000000;   
            end
    end

genvar i;


generate
    for (i = 0; i < 16; i = i + 1) begin
        MemGen_16_10 U_lo (.chip_en(mem_sel[i]), .clock(clock), .addr(addr[9:0]), .rd_en(rd_en), .rd_data(mem_data_out[i][15:0]),  .wr_en(wr_en), .wr_data(wr_data[15:0])  );
        MemGen_16_10 U_hi (.chip_en(mem_sel[i]), .clock(clock), .addr(addr[9:0]), .rd_en(rd_en), .rd_data(mem_data_out[i][31:16]), .wr_en(wr_en), .wr_data(wr_data[31:16]) );
    end
endgenerate

endmodule
