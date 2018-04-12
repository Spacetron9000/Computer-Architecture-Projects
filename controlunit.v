/* Author: David Foster
	Modified by Kyle M. Medeiros and Jacob Stevens
   Last Modified: 7/31/2017
   Module Name: controlunit
   Version: 1.1
   Module Desc: control unit for single-cycle 32-bit RISC system
   Inputs: 	opcode - 6-bit MIPS opcode, see MIPS instruction set for listing 
  			funct - 6-bit extension for some opcodes, see inst. set for listing
			rt0 - used to distinguish some instructions
			reset - external reset signal to reload PC with initial value
   Outputs: regDestMUXS - // 00 for reg t, 01 for reg d, 10 for $ra, 11 - N/A 
			regWriteEN - 1- update register file			
			aluSrcAMUXS - Source for inA: 0 reg rs, 1 shamt 
			aluSrcAMUXS - Source for inB: 0 reg rt, 1 immediate 
			aluOp - select operation from the ALU
			dataWriteEN - 1: enables storing to data memory
			dataWriteByte - 1: store just one byte to data memory
			dataWriteHalf - 1:store just a half word to data memory	
			immExtSign - tells immExtender to sign extend if 1 (math) or 0 extend (Bool)
			dataExtSign - when loading a byte or half word from memory, control unsigned (0) or signed (1) extension
			dataExtByte - when loading a byte or half word from memory, control byte (1) or half word (0)
			memMUXS - 2-bit select line for memMUX, 0 for direct DATA, 1 for extended version, 2 for ALU result
			branchMUXS - 0 to move sequentially, 1 to branch or jump
			jumpMUXS - 00 to move serially or branch, 01 jump to target, 10 jump to reg, 11 reset vector
			
   Internal parameters:
		alu_ops.txt provides alphanumeric names for 4-bit operations
*/

module controlunit(
input  wire [5:0] opcode,   // opcode from instruction memory	
input  wire [5:0] funct,    // function field from instruction memory
input  wire rt0,
input  wire reset,
output reg [1:0] regDestMUXS, // 00 for reg t, 01 for reg d, 10 for $ra, 11 - N/A (signal A)
output reg regWriteEN,	    // update register file (signal B)
output reg aluSrcAMUXS,     // Source for inA: 0 reg rs, 1 shamt (signal C)
output reg aluSrcBMUXS,     // Source for inB: 0 reg rt, 1 immediate (signal D)
output reg [3:0] aluOp,	    // select operation from the ALU (signal E)
output reg dataWriteEN,	    // enables storing to data memory (signal F)
output reg dataWriteByte, 	// store just one byte to data memory (signal G)
output reg dataWriteHalf,	// store just a half word to data memory (signal H)
output reg immExtSign,      // extend immediate I-type 1:signed, 0 unsigned (signal J)
output reg dataExtSign,	    // when loading a byte or half word from memory, unsigned (0) or signed (1) extension (signal K)
output reg dataExtByte,	    // when loading a byte or half word from memory, byte (1) or half word (0) (signal L)
output reg [1:0] memMUXS,   // select line for memMUX, 00 for data word, 01 data half or byte, 10 for ALU result, 11 for pc (signal M)
output reg branchMUXS,	    // 0 to move sequentially, 1 to branch (signal N)
output reg [1:0] jumpMUXS  // 00 to move serially or branch, 01 jump to target, 10 jump to reg, 11 reset vector (signal P)
);
`include "alu_ops.txt"  // provides parameters for more readable operations

always @(opcode or funct or reset or rt0)
begin
	if (reset == 1) begin
		regDestMUXS = 2'bXX; // signal A
		regWriteEN = 0;	     // signal B    
		aluSrcAMUXS = 1'bX;  // signal C    
		aluSrcBMUXS = 1'bX;  // signal D    
		aluOp = OP_NOP1;	 // signal E
		dataWriteEN = 0;	 // signal F   
		dataWriteHalf = 1'bX;// signal G					
		dataWriteByte = 1'bX;// signal H
		immExtSign = 1'bX;   // signal J  
		dataExtSign = 1'bX;  // signal K   
		dataExtByte = 1'bX;	 // signal L  
		memMUXS = 2'bXX;     // signal M
		branchMUXS = 1'bX;   // signal N 
		jumpMUXS = 2'b11;    // signal P	
	end
	else begin
		case(opcode)
		6'b000000:begin
			case (funct)
				6'b100000: begin  // add rd, rs, rt
					regDestMUXS = 2'b01; // signal A
					regWriteEN = 1;	     // signal B    
					aluSrcAMUXS = 0;     // signal C    
					aluSrcBMUXS = 0;     // signal D    
					aluOp = OP_ADD;	     // signal E
					dataWriteEN = 0;	 // signal F   
					dataWriteHalf = 1'bX;// signal G					
					dataWriteByte = 1'bX;// signal H
					immExtSign = 1'bX;   // signal J  
					dataExtSign = 1'bX;	 // signal K   
					dataExtByte = 1'bX;	 // signal L  
					memMUXS = 2'b10;     // signal M
					branchMUXS = 0;	     // signal N 
					jumpMUXS = 2'b00;    // signal P
				end
				default: begin   // encode a NOP
					regDestMUXS = 2'bXX; // signal A
					regWriteEN = 0;	     // signal B    
					aluSrcAMUXS = 1'bX;  // signal C    
					aluSrcBMUXS = 1'bX;  // signal D    
					aluOp = OP_ADD;	     // signal E Any op, result not used
					dataWriteEN = 0;	 // signal F   
					dataWriteHalf = 1'bX;// signal G					
					dataWriteByte = 1'bX;// signal H
					immExtSign = 1'bX;   // signal J  
					dataExtSign = 1'bX;  // signal K   
					dataExtByte = 1'bX;	 // signal L  
					memMUXS = 2'bXX;     // signal M
					branchMUXS = 0;	     // signal N 
					jumpMUXS = 2'b00;    // signal P 
				end
			endcase
			end	
		6'b001101: begin // ORI
				regDestMUXS = 2'b00; // signal A
				regWriteEN = 1;	     // signal B    
				aluSrcAMUXS = 0;     // signal C    
				aluSrcBMUXS = 1;     // signal D    
				aluOp = OP_OR;	     // signal E
				dataWriteEN = 0;	 // signal F   
				dataWriteHalf = 1'bX;// signal G					
				dataWriteByte = 1'bX;// signal H
				immExtSign = 0;      // signal J  
				dataExtSign = 1'bX;	 // signal K   
				dataExtByte = 1'bX;	 // signal L  
				memMUXS = 2'b10;     // signal M
				branchMUXS = 0;	     // signal N 
				jumpMUXS = 2'b00;    // signal P  
			end
		6'b001001: begin //ADDIU !! Added during modification of files for lab
				regDestMUXS = 2'b00; // signal A
				regWriteEN = 1;	     // signal B    
				aluSrcAMUXS = 0;     // signal C    
				aluSrcBMUXS = 1;     // signal D    
				aluOp = OP_ADD;      // signal E
				dataWriteEN = 0;	 // signal F   
				dataWriteHalf = 1'bX;// signal G					
				dataWriteByte = 1'bX;// signal H
				immExtSign = 0;      // signal J  
				dataExtSign = 1'bX;	 // signal K   
				dataExtByte = 1'bX;	 // signal L  
				memMUXS = 2'b10;     // signal M
				branchMUXS = 0;	     // signal N 
				jumpMUXS = 2'b00;    // signal P
			end 
		6'b001000: begin //ADDI  !! Added during modification of files for lab
				regDestMUXS = 2'b00; // signal A
				regWriteEN = 1;	     // signal B    
				aluSrcAMUXS = 0;     // signal C    
				aluSrcBMUXS = 1;     // signal D    
				aluOp = OP_ADD;      // signal E
				dataWriteEN = 0;	 // signal F   
				dataWriteHalf = 1'bX;// signal G					
				dataWriteByte = 1'bX;// signal H
				immExtSign = 1;      // signal J  
				dataExtSign = 1'bX;	 // signal K   
				dataExtByte = 1'bX;	 // signal L  
				memMUXS = 2'b10;     // signal M
				branchMUXS = 0;	     // signal N 
				jumpMUXS = 2'b00;    // signal P
			end 
		6'b001111: begin // LUI
				regDestMUXS = 2'b00; // signal A
				regWriteEN = 1;	     // signal B    
				aluSrcAMUXS = 1'bX;  // signal C    
				aluSrcBMUXS = 1;     // signal D    
				aluOp = OP_LUI;	     // signal E
				dataWriteEN = 0;	 // signal F   
				dataWriteHalf = 1'bX;// signal G					
				dataWriteByte = 1'bX;// signal H
				immExtSign = 0;      // signal J  
				dataExtSign = 1'bX;	 // signal K   
				dataExtByte = 1'bX;	 // signal L  
				memMUXS = 2'b10;     // signal M
				branchMUXS = 0;	     // signal N 
				jumpMUXS = 2'b00;    // signal P 
			end
		6'b100000: begin // LB rt, offset(rs)
				regDestMUXS = 2'b00; // signal A
				regWriteEN = 1;	     // signal B    
				aluSrcAMUXS = 0;     // signal C    
				aluSrcBMUXS = 1;     // signal D    
				aluOp = OP_ADD;	     // signal E
				dataWriteEN = 0;	 // signal F   
				dataWriteHalf = 1'bX;// signal G					
				dataWriteByte = 1'bX;// signal H
				immExtSign = 1;      // signal J  
				dataExtSign = 1;	 // signal K   
				dataExtByte = 1;	 // signal L  
				memMUXS = 2'b01;     // signal M
				branchMUXS = 0;	     // signal N 
				jumpMUXS = 2'b00;    // signal P
			end		
		6'b100100: begin //LBU rt, offset (rs) !! Added during modification of files for lab
				regDestMUXS = 2'b00; // signal A
				regWriteEN = 1;	     // signal B    
				aluSrcAMUXS = 0;     // signal C    
				aluSrcBMUXS = 1;     // signal D    
				aluOp = OP_ADD;      // signal E
				dataWriteEN = 0;	 // signal F   
				dataWriteHalf = 1'bX;   // signal G					
				dataWriteByte = 1'bX;   // signal H
				immExtSign = 1;      // signal J  
				dataExtSign = 0;	 // signal K   
				dataExtByte = 1;	 // signal L  
				memMUXS = 2'b01;     // signal M
				branchMUXS = 0;	     // signal N 
				jumpMUXS = 2'b00;    // signal P
			end 
		6'b100011: begin // LW: load 32-bit word
				regDestMUXS = 2'b00; // signal A
				regWriteEN = 1;	     // signal B    
				aluSrcAMUXS = 0;     // signal C    
				aluSrcBMUXS = 1;     // signal D    
				aluOp = OP_ADD;	     // signal E
				dataWriteEN = 0;	 // signal F   
				dataWriteHalf = 1'bX;// signal G					
				dataWriteByte = 1'bX;// signal H
				immExtSign = 1;      // signal J  
				dataExtSign = 1'bX;  // signal K   
				dataExtByte = 1'bX;	 // signal L  
				memMUXS = 2'b00;     // signal M
				branchMUXS = 0;	     // signal N 
				jumpMUXS = 2'b00;    // signal P
			end
		6'b101011: begin // SW
				regDestMUXS = 2'bXX; // signal A
				regWriteEN = 0;	     // signal B    
				aluSrcAMUXS = 0;     // signal C    
				aluSrcBMUXS = 1;     // signal D    
				aluOp = OP_ADD;	     // signal E
				dataWriteEN = 1;	 // signal F   
				dataWriteHalf = 0;   // signal G					
				dataWriteByte = 0;   // signal H
				immExtSign = 1;      // signal J  
				dataExtSign = 1'bX;	 // signal K   
				dataExtByte = 1'bX;	 // signal L  
				memMUXS = 2'bXX;     // signal M
				branchMUXS = 0;	     // signal N 
				jumpMUXS = 2'b00;    // signal P
			end
		6'b000100: begin //BEQ rs, rt, imm !! Added during modification of files for lab
				regDestMUXS = 2'bXX; // signal A
				regWriteEN = 0;	     // signal B    
				aluSrcAMUXS = 0;     // signal C    
				aluSrcBMUXS = 0;     // signal D    
				aluOp = OP_NOP1;     // signal E
				dataWriteEN = 0;	 // signal F   
				dataWriteHalf = 1'bX;   // signal G					
				dataWriteByte = 1'bX;   // signal H
				immExtSign = 1;      // signal J  
				dataExtSign = 1'bX;	 // signal K   
				dataExtByte = 1'bX;	 // signal L  
				memMUXS = 2'bXX;     // signal M
				branchMUXS = 1;	     // signal N 
				jumpMUXS = 2'b00;    // signal P
			end 
		
		default: begin
				regDestMUXS = 2'bXX; // signal A
				regWriteEN = 0;	     // signal B    
				aluSrcAMUXS = 1'bX;  // signal C    
				aluSrcBMUXS = 1'bX;  // signal D    
				aluOp = OP_ADD;	     // signal E
				dataWriteEN = 0;	 // signal F   
				dataWriteHalf =1'bX; // signal G					
				dataWriteByte = 1'bX;// signal H
				immExtSign = 1'bX;   // signal J  
				dataExtSign = 1'bX;	 // signal K   
				dataExtByte = 1'bX;	 // signal L  
				memMUXS = 2'bXX;     // signal M
				branchMUXS = 0;	     // signal N 
				jumpMUXS = 0;        // signal P
			end
			

			/*template	
		6'bXXXXXX: begin
				regDestMUXS = 2'bXX; // signal A
				regWriteEN = X;	     // signal B    
				aluSrcAMUXS = X;     // signal C    
				aluSrcBMUXS = X;     // signal D    
				aluOp = OP_NOP1;     // signal E
				dataWriteEN = X;	 // signal F   
				dataWriteHalf = X;   // signal G					
				dataWriteByte = X;   // signal H
				immExtSign = X;      // signal J  
				dataExtSign = X;	 // signal K   
				dataExtByte = X;	 // signal L  
				memMUXS = 2'bXX;     // signal M
				branchMUXS = X;	     // signal N 
				jumpMUXS = 2'bXX;    // signal P
			end */
		endcase
	
	end
end
endmodule