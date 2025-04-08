
// 
//   Wrapper for CPU + memory


module cpu_sys (


    input  clock,
    input  reset,
    input  [4:0] Interrupts,            // 5 general-purpose hardware interrupts
    input  NMI,                         // Non-maskable interrupt
    // Data Memory Interface
    input  [31:0] per_dout,             //
    output DataMem_Read, 
    output [3:0]  DataMem_Write,        // 4-bit Write, one for each byte in word.
    output [29:0] DataMem_Address,      // Addresses are words, not bytes.
    output [31:0] DataMem_Out

    );

// Instruction Memory Interface
wire  [31:0] pmem_dout;
wire  [29:0] pmem_addr;      // Addresses are words, not bytes.
wire pmem_cen;

wire  dmem_cen;
wire [31:0] dmem_dout;          // Data Memory data output
wire [31:0] DataMem_In;

//  ---------------------------------
//    MIPS processor
//  ---------------------------------

Processor MIPS_CPU (
    .clock(clock),
    .reset(reset),
    .Interrupts(Interrupts),                  // 5 general-purpose hardware interrupts
    .NMI(NMI),                         // Non-maskable interrupt
    // Data Memory Interface
    .DataMem_In(DataMem_In),
    .DataMem_Ready(1'b1),
    .DataMem_Read(), 
    .DataMem_Write(DataMem_Write),                 // 4-bit Write, one for each byte in word.
    .DataMem_Address(DataMem_Address),                 // Addresses are words, not bytes.
    .DataMem_Out(DataMem_Out),
    // Instruction Memory Interface
    .InstMem_In(pmem_dout),
    .InstMem_Address(pmem_addr),                 // Addresses are words, not bytes.
    .InstMem_Ready(1'b1),
    .InstMem_Read(pmem_cen),
    .IP()                               // Pending interrupts (diagnostic)
);

//  ---------------------------------
//    Program Memory RAM //
//  ---------------------------------
MemGen_32_12 program_memory (
   .chip_en(pmem_cen),
   .clock(clock),  
   .addr(pmem_addr[11:0]), 
   .rd_data(pmem_dout),
   .rd_en(pmem_cen),
   .wr_data(32'h00000000),
   .wr_en(1'b0)
	);
    
//  ---------------------------------
//    Program Memory RAM //
//  ---------------------------------

assign DataMem_In   = DataMem_Address[29] ? per_dout : dmem_dout;
assign dmem_cen     = !DataMem_Address[29];

MemGen_32_12 data_memory (
   .chip_en(dmem_cen),
   .clock(clock),  
   .addr(DataMem_Address[11:0]), 
   .rd_data(dmem_dout),
   .rd_en(DataMem_Read),  
   .wr_data(DataMem_Out),
   .wr_en(DataMem_Write[0])
	);
	
endmodule
