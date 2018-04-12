//Kyle M. Medeiros and Jacob Stevens
//7/13/2017
//EEL 4768C - Computer Architecture and Organization
//4 to 1 MUX Test Bench
//Adapted from lec9ex1.v by Dr. David Foster
//This file will verify the inputs of a 4 to 1 MUX by comparing its inputs with a 
//test vector file. 
//The test vector file will verify that the select line S is selecting the proper input
//and that it is the output as well. 

module mux41_tb;  
reg [4:0] wD0;
reg [4:0] wD1;
reg [4:0] wD2;
reg [4:0] wD3;
reg [1:0] wS;     //Select Line
wire [4:0] wY;			

reg [27:0] testvectors[0:20];
reg [7:0] errors;			// counts how many rows were incorrect - 8-bit integer
reg [7:0] tests;			// counts how many tests were run - 8-bit integer
reg [7:0] vectornum;		// loop counter
reg [4:0] rightY;			// holds the expected answer from the input file

// Connect UUT to test bench signals
mux41 #(5) uut(
.D0	(wD0),
.D1	(wD1),
.D2 (wD2),
.D3 (wD3),
.S	(wS),
.Y	(wY)
);

initial begin
	$readmemb("testvec_mux41.txt", testvectors); 
	vectornum = 0;
	errors = 0;
	tests = 0;
end

// self-checking test bench needs a loop structure that will process lines from a text file
always begin
	if (testvectors[vectornum] === 1'bX) begin    // X is the "End of File" indicator
		$display("%1d tests completed with %1d errors.", tests, errors);
		$finish;
	end
	{wD0, wD1, wD2, wD3, wS, rightY} = testvectors[vectornum];	
	#1; // need a delay in the loop if you will dump variables for looking at them graphically
	if (rightY !== wY) begin
		errors = errors+1;	// found another incorrect output
		$display("Input {D0,D1,D2,D3,S} = {%b_%b_%b_%b_%b} incorrectly outputs Y=%b instead of %b.", wD0, wD1, wD2, wD3, wS, wY, rightY);
	end
	tests = tests+1;
	
	vectornum = vectornum+1; // increments loop counter
end
endmodule