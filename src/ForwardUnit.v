module ForwardUnit(RegisterRs, RegisterRt,
				   ID_EX_RegWrite, ID_EX_RegisterRd,
				   ID_EX_RegisterRs, ID_EX_RegisterRt,
				   EX_MEM_RegWrite, EX_MEM_RegisterRd,
				   MEM_WB_RegWrite, MEM_WB_RegisterRd,
				   ForwardA_ID, ForwardB_ID, ForwardA_EX, ForwardB_EX);
	input [4:0] RegisterRs;
	input [4:0] RegisterRt;
	input ID_EX_RegWrite;
	input [4:0] ID_EX_RegisterRd;
	input [4:0] ID_EX_RegisterRs;
	input [4:0] ID_EX_RegisterRt;
	input EX_MEM_RegWrite;
	input [4:0] EX_MEM_RegisterRd;
	input MEM_WB_RegWrite;
	input [4:0] MEM_WB_RegisterRd;
	output [1:0] ForwardA_ID;
	output ForwardB_ID;
	output [1:0] ForwardA_EX;
	output [1:0] ForwardB_EX;

	// ForwardA_ID:
	// 2'b00 No forward
	// 2'b01 EX_MEM_ALU_out
	// 2'b10 MEM_WB_Write_data
	assign ForwardA_ID = (
				EX_MEM_RegWrite
				&& EX_MEM_RegisterRd != 0
				&& EX_MEM_RegisterRd == RegisterRs
			 )? 2'b01: (
				MEM_WB_RegWrite
	 			&& MEM_WB_RegisterRd != 0
				&& MEM_WB_RegisterRd == RegisterRs
	 		 )? 2'b10: 2'b00;
	
	// ForwardB_ID:
	// 1'b0 No forward
	// 1'b1 MEM_WB_Write_data
	assign ForwardB_ID = (
				MEM_WB_RegWrite
	 			&& MEM_WB_RegisterRd != 0
				&& MEM_WB_RegisterRd == RegisterRt
	 		 )? 1'b1: 1'b0;
	
	// ForwardA_EX:
	// 2'b00 No forward
	// 2'b01 EX_MEM_ALU_out
	// 2'b10 MEM_WB_Write_data
	assign ForwardA_EX = (
				ID_EX_RegWrite
				&& ID_EX_RegisterRd != 0
				&& ID_EX_RegisterRd == RegisterRs
			 )? 2'b01: (
				EX_MEM_RegWrite
	 			&& EX_MEM_RegisterRd != 0
				&& EX_MEM_RegisterRd == RegisterRs
	 		 )? 2'b10: 2'b00;
	
	// ForwardB_EX:
	// 2'b00 No forward
	// 2'b01 EX_MEM_ALU_out
	// 2'b10 MEM_WB_Write_data
	assign ForwardB_EX = (
				ID_EX_RegWrite
				&& ID_EX_RegisterRd != 0
				&& ID_EX_RegisterRd == RegisterRt
			 )? 2'b01: (
				EX_MEM_RegWrite
	 			&& EX_MEM_RegisterRd != 0
				&& EX_MEM_RegisterRd == RegisterRt
	 		 )? 2'b10: 2'b00;
	
endmodule
