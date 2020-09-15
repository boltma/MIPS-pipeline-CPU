module Timer(reset, clk, Address, Write_data, MemWrite, Read_data, MemRead, IRQ);
	input reset, clk;
	input [1:0] Address;
	input [31:0] Write_data;
	input MemRead, MemWrite;
	output [31:0] Read_data;
	output IRQ;

	reg [31:0] TH, TL;
	reg [2:0] TCon;

	assign Read_data = MemRead?
						((Address == 2'b00)? TH:
						 (Address == 2'b01)? TL:
						 (Address == 2'b10)? {29'h00000000, TCon}:
						 32'h00000000):
						32'h00000000;
	
	assign IRQ = TCon[2];

	always @(posedge reset or posedge clk)
		if (reset) begin
			TH <= 32'h00000000;
			TL <= 32'h00000000;
			TCon <= 3'b000;
		end else if (MemWrite) begin
			if (Address == 2'b00) begin
				TH <= Write_data;
			end else if (Address == 2'b01) begin
				TL <= Write_data;
			end else if (Address == 2'b10) begin
				TCon <= Write_data[2:0];
			end
		end	else if (TCon[0]) begin
			if (&TL) begin
				TL <= TH;
				if (TCon[1])
					TCon[2] <= 1'b1;
			end else begin
				TL <= TL + 1;
			end
		end

endmodule