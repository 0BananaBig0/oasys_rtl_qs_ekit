
//  --------------------------------------------------
//    Simple CPU writable register
//    Outputs can be used to control power down signals
//  --------------------------------------------------


module powerdown_control (
    input clk,
    input reset_n,

    //---register access---
    input   [13:0] per_addr,
    input   [31:0] per_din,
    input          per_en,
    input          per_we,
    input          per_rd,
    input   [31:0] power_ack,
    output  reg [31:0] per_dout,
    output  reg [31:0] power_control,
    output  reg [31:0] power_iso
);
  
parameter       [13:0] BASE_ADDR   = 14'h400;




always @(posedge clk or negedge reset_n)
    begin
        if ( reset_n == 1'b0 ) 
            begin
                power_control   = 32'h00000000;
                power_iso       = 32'h00000000;
            end
        else
            begin
                // Write reg
                if ( per_en == 1'b1 && per_we == 1'b0 && per_addr[13:4] == BASE_ADDR[13:4]) 
                    begin
                        case (per_addr[3:0])
                            4'h0 : power_control    = per_din;
                            4'h1 : power_iso        = per_din;
                        endcase
                    end
                        
            end
    end

// read_reg
always @(*)
    begin
        if ( per_en == 1'b1 && per_rd == 1'b1 && per_addr[13:4] == BASE_ADDR[13:4])
            begin
                case (per_addr[3:0])
                    4'h0 : per_dout    = power_control;
                    4'h1 : per_dout    = power_iso;
                    4'h2 : per_dout    = power_ack;
                    default : per_dout = 32'h00000000;
                endcase
            end
        else
            per_dout = 32'h00000000;
    end
            
    
endmodule                
