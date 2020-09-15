module SysTick(reset, clk, count);
	input reset, clk;
	output reg [31:0] count;

	always @(posedge reset or posedge clk)
		if (reset) begin
			count <= 32'h00000000;
		end else begin
			count <= count + 1;
		end
			
endmodule
