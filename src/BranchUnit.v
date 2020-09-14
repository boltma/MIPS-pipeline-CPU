module BranchUnit(in1, in2, Branch, BranchOp, out);
	input [31:0] in1, in2;
	input Branch;
	input [2:0] BranchOp;
	output out;
	
	reg Branch_out;
	assign out = Branch_out && Branch;
	
	always @(*)
		case (BranchOp)
			3'b001: Branch_out <= in1 == in2;
			3'b010: Branch_out <= in1 != in2;
			3'b011: Branch_out <= in1[31] || ~|in1;
			3'b100: Branch_out <= ~(in1[31] || ~|in1);
			3'b101: Branch_out <= in1[31];
			default: Branch_out <= 0;
		endcase

endmodule
