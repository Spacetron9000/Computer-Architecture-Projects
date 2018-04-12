//Kyle M. Medeiros and Jacob Stevens
//7/13/2017
//EEL 4768C - Computer Architecture and Organization
//Extender Test Bench
//Adapted from lec9ex1.v by Dr. David Foster
//This file will take the 16 bit value and turn it to a 32 bit value.
//If the sign value is true, it will take the value and extend it as Signed.
//If the Byte value is true, it will only consider the bottom 8 bits 
//The test vector will verify that the extender will A: properly extend a 16 bit value
//B: Extend it as signed or unsigned depending on the sign input, and C: if Byte is true,
//that the extender only takes the bottom 8 bits when extending. 

module extender_tb;  
reg [15:0]wD; 		//16 bit input
reg wSign,wByte;       
wire [31:0] wY;		//32 bit output

reg [50:0] testvectors[0:20];
								
reg [7:0] errors;			// counts how many rows were incorrect - 8-bit integer
reg [7:0] tests;			// counts how many tests were run - 8-bit integer
reg [7:0] vectornum;		// loop counter
reg [31:0]rightY;					

// Connect UUT to test bench signals
extender uut(
.D  	(wD),
.Sign	(wSign),
.Byte	(wByte),
.Y		(wY)
);

initial begin
	$readmemh("testvec_extender.txt", testvectors); 
	vectornum = 0;
	errors = 0;
	tests = 0;
end

// self-checking test bench needs a loop structure that will process lines from a text file
always begin
	if (testvectors[vectornum][0] === 1'bX) begin    // X is the "End of File" indicator
		$display("%1d tests completed with %1d errors.", tests, errors);
		$finish;
	end
	{wSign, wByte, wD, rightY} = testvectors[vectornum];	
	#1; // need a delay in the loop if you will dump variables for looking at them graphically
	if (rightY !== wY) begin
		errors = errors+1;	// found another incorrect output
		$display("Input {D,Sign,Byte} = {%h,%b,%b} incorrectly outputs Y=%h instead of %h.", wD, wSign, wByte, wY, rightY);
	end
	tests = tests+1;
	
	vectornum = vectornum+1; // increments loop counter
end
endmodule