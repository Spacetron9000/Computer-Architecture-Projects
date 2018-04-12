// Author: David Foster
// Modified by Kyle M. Medeiros and Jacob Stevens
// Last Modified: 7/31/2017
// Module name: mips_tb
// Module Desc: test bench for mips.v
// Internal parameters:
//		none
//	Test Vector Files:
//		table_copy.txt - contains test vectors
 
`include "mips.v"
module mips_tb();

 reg CLK, wReset;
 reg [15:0] tick = 0;
 reg [15:0] i;	
 reg [31:0] j; //An additional loop counter that's 32 bits
 reg [31:0] instructions[ 0:1023];
 reg [63:0] dataVec[0:1023]; //Additional Data Vector file 
 
 parameter INSTADDR = 32'h0040_0000;
 parameter INSTSIZE = 4096;
 
 parameter DATAADDR = 32'h1000_0000;
 parameter DATASIZE = 4096;
 
initial begin // set all registers and memory initially to 0xFF
	for (i=0; i<INSTSIZE;i=i+1)
	   uut.instMemory.memory[INSTADDR+i] = 8'hFF;
	for (i=0; i<DATASIZE;i=i+1)
	   uut.dataMemory.memory[DATAADDR+i] = 8'hFF;
	for (i=1; i<32;i=i+1)
	   uut.registerFile.registers[i] = 32'hFFFFFFFF;
	   //Here is where modifications were made.
	   //After initializing all data to 0xFF, this loop
	   //will set the required memory addresses to the required
	   //data. 
	$readmemh("datamem_mips_tb.txt", dataVec);
	i = 0;
	//Initialize data memory to specific values from the datamem_mips_tb.txt file
	while (dataVec[i][0] !==1'bX) begin
	uut.dataMemory.memory[dataVec[i][63:32]] = dataVec[i][7:0];
	uut.dataMemory.memory[dataVec[i][63:32]+1] = dataVec[i][15:8];
	uut.dataMemory.memory[dataVec[i][63:32]+2] = dataVec[i][23:16];
	uut.dataMemory.memory[dataVec[i][63:32]+3] = dataVec[i][31:24];
	i=i+1;
	end

end
 
initial begin // initialize instruction memory with assembly program
    $dumpfile ("mips.vcd"); 
	$dumpvars; 
	$readmemh("table_copy.txt", instructions); //Here, 'prog1.txt' was changed to 'table_copy.txt'
	i = 0;    // used to increment index into program and instruction memory
	while (instructions[i][0] !== 1'bX)
	begin
		uut.instMemory.memory[INSTADDR+i*4] = instructions[i][7:0];
//		$display("Addr: %h  Inst:%h", INSTADDR+i,instructions[i][7:0]);
		uut.instMemory.memory[INSTADDR+i*4+1] = instructions[i][15:8];
//		$display("Addr: %h  Inst:%h", INSTADDR+i+1,instructions[i][15:8]);
		uut.instMemory.memory[INSTADDR+i*4+2] = instructions[i][23:16];
//		$display("Addr: %h  Inst:%h", INSTADDR+i+2,instructions[i][23:16]);
		uut.instMemory.memory[INSTADDR+i*4+3] = instructions[i][31:24];
//		$display("   Addr: %h  Inst:%h", INSTADDR+i*4,instructions[i] );
		i = i+1;
	end
end 
 
// Operate the clock
always begin
	CLK = 0;
	#5
	CLK = 1;
	#5
	$display("Tick %0d PC:%h Inst:%h Next:%h", tick, uut.wPC, uut.wInstr, uut.wNextPC);
	//Display the data memory. 
	$display( "Address  | Value+0|  Value+4|  Value+8|  Value+c|");
	for (j=32'h10010000; j<32'h1001005F; j=j+32'h20) begin
	$display("%h: %h, %h, %h %h",j, {uut.dataMemory.memory[j+3], uut.dataMemory.memory[j+2], uut.dataMemory.memory[j+1], uut.dataMemory.memory[j]},{uut.dataMemory.memory[j+7],uut.dataMemory.memory[j+6],uut.dataMemory.memory[j+5],uut.dataMemory.memory[j+4]},{uut.dataMemory.memory[j+11],uut.dataMemory.memory[j+10],uut.dataMemory.memory[j+9],uut.dataMemory.memory[j+8]},{uut.dataMemory.memory[j+15],uut.dataMemory.memory[j+14],uut.dataMemory.memory[j+13],uut.dataMemory.memory[j+12]});
	
	end
//  display low registers
//		$display("    R 0:  0 %h", uut.registerFile.registers[0]);
//		$display("    R 1: at %h", uut.registerFile.registers[1]);
//		$display("    R 2: v0 %h", uut.registerFile.registers[2]);
//		$display("    R 3: v1 %h", uut.registerFile.registers[3]);
//		$display("    R 4: v2 %h", uut.registerFile.registers[4]);
//		$display("    R 5: v3 %h", uut.registerFile.registers[5]);
//		$display("    R 6: v4 %h", uut.registerFile.registers[6]);
//		$display("    R 7: v5 %h", uut.registerFile.registers[7]);	
	for (i=8;i<16;i=i+1) // t0-t7 registers
		begin
			$display("    R%2d: t%0d %h", i, i-8, uut.registerFile.registers[i]); //Switched on to show the $t0-$t7 registers
		end
	for (i=16;i<24;i=i+1) // s0-s7 registers
		begin
//			$display("    R%2d: s%0d %h", i, i-16, uut.registerFile.registers[i]);// Switched off
		end
//  display high registers
//		$display("    R24: t8 %h", uut.registerFile.registers[24]);
//		$display("    R25: t9 %h", uut.registerFile.registers[25]);
//		$display("    R26: k0 %h", uut.registerFile.registers[26]);
//		$display("    R27: k1 %h", uut.registerFile.registers[27]);
//		$display("    R28: gp %h", uut.registerFile.registers[28]);
//		$display("    R29: sp %h", uut.registerFile.registers[29]);
//		$display("    R30: fp %h", uut.registerFile.registers[30]);
//		$display("    R31: ra %h", uut.registerFile.registers[31]);
	tick = tick+1;
//  Add code to print a specific set of memory addresses from data memory.	
	
end

// Reset program counter and terminate after specified time
initial begin
	wReset = 1;
	#8
	wReset = 0;
	#420 //Modified to allow entire program to finish
	$finish;
end
	
mips uut(
.CLK (CLK),
.reset (wReset)
);

endmodule