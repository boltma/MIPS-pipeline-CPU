module BCD7(reset, clk, Write_data, MemWrite, digits);
	input reset, clk;
	input [11:0] Write_data;
	input MemWrite;
	output reg [11:0] digits;

	always @(posedge reset or posedge clk)
		if (reset) begin
			digits <= 12'h000;
		end else if (MemWrite) begin
			digits <= Write_data;
		end
			
endmodule
