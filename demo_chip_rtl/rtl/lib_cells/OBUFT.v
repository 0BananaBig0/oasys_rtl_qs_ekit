
module OBUFT (
   input I, T,
   output O
  );


PAD U1 ( .IN_PORT(I), .SELECT(T), .INOUT_PORT(O), .OUT_PORT() );

endmodule
