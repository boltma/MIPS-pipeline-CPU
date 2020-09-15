module LED(reset, clk, Write_data, MemWrite, leds);
	input reset, clk;
	input [7:0] Write_data;
	input MemWrite;
	output reg [7:0] leds;

	always @(posedge reset or posedge clk)
		if (reset) begin
			leds <= 8'h00;
		end else if (MemWrite) begin
			leds <= Write_data;
		end
			
endmodule
