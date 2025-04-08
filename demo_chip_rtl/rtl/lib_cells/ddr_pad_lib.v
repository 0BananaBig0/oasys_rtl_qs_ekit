
module IOBUF (
   input I, T,
   inout IO,
   output O
  );


PADBID U1 ( .I(I), .OEN(T), .PAD(IO), .C(O) );

endmodule



module OBUFT (
   input I, T,
   output O
  );


PADBID U1 ( .I(I), .OEN(T), .PAD(IO), .C() );

endmodule
