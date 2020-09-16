module BCD7(reset, clk, Write_data, MemWrite, digits);
	input reset, clk;
	input [11:0] Write_data;
	input MemWrite;
	output reg [11:0] digits;

	always @(posedge reset or posedge clk)
		if (reset) begin
			digits <= 12'h000;
		end else if (MemWrite) begin
			case (Write_data[3:0])
				4'h0: digits[7:0] <= 8'b11000000;
				4'h1: digits[7:0] <= 8'b11111001;
				4'h2: digits[7:0] <= 8'b10100100;
				4'h3: digits[7:0] <= 8'b10110000;
				4'h4: digits[7:0] <= 8'b10011001;
				4'h5: digits[7:0] <= 8'b10010010;
				4'h6: digits[7:0] <= 8'b10000010;
				4'h7: digits[7:0] <= 8'b11111000;
				4'h8: digits[7:0] <= 8'b10000000;
				4'h9: digits[7:0] <= 8'b10010000;
				4'ha: digits[7:0] <= 8'b10001000;
				4'hb: digits[7:0] <= 8'b10000011;
				4'hc: digits[7:0] <= 8'b11000110;
				4'hd: digits[7:0] <= 8'b10100001;
				4'he: digits[7:0] <= 8'b10000110;
				4'hf: digits[7:0] <= 8'b10001110;
        		default: digits[7:0] <= 8'b11111111;
			endcase
			digits[11:8] <= Write_data[11:8];
		end
			
endmodule
