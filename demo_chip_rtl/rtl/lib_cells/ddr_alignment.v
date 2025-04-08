
module IDDR2 #(
    parameter DDR_ALIGNMENT = "NONE",    
    parameter INIT_Q0 = 1'b0,
    parameter INIT_Q1 = 1'b0,
    parameter SRTYPE = "SYNC"
)
(Q0, Q1, C0, C1, CE, D, R, S);

    output reg Q0;
    output reg Q1;
    input C0;
    input C1;
    input CE;
    input D;
    input R;
    input S;


    always @(posedge C0 or posedge R ) begin
        if (R)
            Q0 <= 1'b0;
        else
            if (CE)
                Q0 <= D;
    end

    always @(posedge C1 or posedge R ) begin
        if (R)
            Q1 <= 1'b0;
        else
            if (CE)
                Q1 <= D;
    end


endmodule // IDDR2

module ODDR2 #(
    parameter DDR_ALIGNMENT = "NONE",  
    parameter INIT = 1'b0,
    parameter SRTYPE = "SYNC"
)(Q, C0, C1, CE, D0, D1, R, S);

    output Q;
    input C0;
    input C1;
    input CE;
    input D0;
    input D1;
    input R;
    input S;

    wire data_0, data_1;
            
    assign data_0 = ( C0 && CE ) ? D0 : 1'b0;  
    assign data_1 = ( C1 && CE ) ? D1 : 1'b0;
    assign Q = data_0 || data_1;
      
endmodule // ODDR2
