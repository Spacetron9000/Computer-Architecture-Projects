//Kyle M. Medeiros and Jacob Stevens
//7/13/2017
//EEL 4768C - Computer Architecture and Organization
//Program Counter Test Bench
//Adapted from lec9ex4.v by Dr. David Foster

//This file will verify the inputs of a Program Counter by comparing its inputs with a 
//test vector file. 
//If Reset = 0, PC = NextPC. 
//If Reset = 1, PC = 0x00400000. 
//The test vector file will verify that the PC accomplishes these two things via a number of use cases. 
module pc_tb;  	
reg [31:0] wNextPC;
reg wClk,wReset;
wire [31:0] wPC;

     			
reg [64:0] testvectors[0:50];
reg [7:0] errors;			// counts how many rows were incorrect
reg [7:0] vectornum;		// loop counter
reg [31:0] rightPC;		

// Connect UUT to test bench signals
pc #(32,32'h00400000) uut(
.NextPC	(wNextPC),
.PC 	(wPC),
.Clk	(wClk),
.Reset	(wReset)
);


initial  begin
    $dumpfile ("pc_tb.vcd"); 
	$dumpvars; 
end 

initial begin
	$readmemh("testvec_pc.txt", testvectors); 
	vectornum = 0;
	errors = 0;
end

// self-checking test bench needs a loop structure that will process lines from a text file
always begin
	{wReset, wNextPC, rightPC} = testvectors[vectornum];
	
	if (testvectors[vectornum][0] === 1'bX) begin    // X is the "End of File" indicator
		$display("%1d tests completed with %1d errors.", vectornum, errors);
		$finish;
		wReset = 1;
	end
	
	wClk = 1; //Start off with a positive clock edge so that the first PC output isn't 'xxxxxxxx'
			  //continue to manually generate a positive clock edge
	
	
	#1  // must allow state machine time to run its behavioral code
	if (rightPC !== wPC) begin 
		errors = errors+1;	// found another incorrect output
		$display("NextPC=%h Reset=%b incorrectly outputs PC=%h.",wNextPC, wReset, wPC);
	end
	wClk = 0;	// manually generate negative edge to clock the state machine
	
	
	vectornum = vectornum+1; // increments loop counter
end

endmodule

