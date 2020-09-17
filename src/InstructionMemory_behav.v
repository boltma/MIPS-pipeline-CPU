module InstructionMemory(Address, Instruction);
	input [31:0] Address;
	output [31:0] Instruction;
	
	parameter RAM_SIZE = 256;
	parameter RAM_SIZE_BIT = 8;
	
	reg [31:0] RAM_data[RAM_SIZE - 1: 0];
	assign Instruction = RAM_data[Address[RAM_SIZE_BIT + 1:2]];
	
endmodule