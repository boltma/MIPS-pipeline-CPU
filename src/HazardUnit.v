module HazardUnit(ID_EX_MemRead, EX_MEM_MemRead, RegisterRs, RegisterRt, ID_EX_RegisterRd, EX_MEM_RegisterRd, PCSrc, Stall);
	input ID_EX_MemRead;
	input EX_MEM_MemRead;
	input [4:0] RegisterRs;
	input [4:0] RegisterRt;
	input [4:0] ID_EX_RegisterRd;
	input [4:0] EX_MEM_RegisterRd;
	input [2:0] PCSrc;
	output Stall;
	
	wire EX_Stall, MEM_Stall; // EX_Stall for lw, and MEM_Stall for lw -> jr
	assign EX_Stall = ID_EX_MemRead && (ID_EX_RegisterRd != 0) && (ID_EX_RegisterRd == RegisterRs || ID_EX_RegisterRd == RegisterRt);
	assign MEM_Stall = EX_MEM_MemRead && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == RegisterRs);
	assign Stall =  EX_Stall || (PCSrc == 3'b010 && MEM_Stall);

endmodule
