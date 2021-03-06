module Control(OpCode, Funct, IRQ, Kernel,
	PCSrc, Branch, RegWrite, RegDst,
	MemRead, MemWrite, MemtoReg,
	ALUSrc1, ALUSrc2, ExtOp, LuOp, ALUOp, BranchOp,
	Exception);
	input [5:0] OpCode;
	input [5:0] Funct;
	input IRQ;
	input Kernel;
	output [2:0] PCSrc;
	output Branch;
	output [2:0] BranchOp;
	output RegWrite;
	output [1:0] RegDst;
	output MemRead;
	output MemWrite;
	output [1:0] MemtoReg;
	output ALUSrc1;
	output ALUSrc2;
	output ExtOp;
	output LuOp;
	output [3:0] ALUOp;
	output Exception;
	
	wire Undefined;
	assign Undefined = ~((OpCode >= 6'h01 && OpCode <= 6'h0c) ||
        (OpCode == 6'h0f || OpCode == 6'h23 || OpCode == 6'h2b) ||
        (OpCode == 6'h00 &&
         	((Funct >= 6'h20 && Funct <= 6'h27) ||
			  Funct == 6'h00 ||
			  Funct == 6'h02 ||
			  Funct == 6'h03 ||
			  Funct == 6'h08 ||
			  Funct == 6'h09 ||
			  Funct == 6'h2a ||
			  Funct == 6'h2b
			)
        ));
	
	assign Exception =  (IRQ || Undefined) && ~Kernel;
	
	assign PCSrc =
		(~Kernel && IRQ)? 3'b100:
		(~Kernel && Undefined)? 3'b101:
		(OpCode == 6'h02 || OpCode == 6'h03)? 3'b001:
		(OpCode == 6'h00 && (Funct == 5'h08 || Funct == 5'h09))? 3'b010:
		3'b000;
	
	assign Branch = ~Exception && (OpCode == 6'h01 || (OpCode >= 6'h04 && OpCode <= 6'h07));
		
	assign BranchOp = 
		(OpCode == 6'h04)? 3'b001:
		(OpCode == 6'h05)? 3'b010:
		(OpCode == 6'h06)? 3'b011:
		(OpCode == 6'h07)? 3'b100:
		(OpCode == 6'h01)? 3'b101:
		3'b000;
	
	assign RegWrite = ~(~Exception &&(OpCode == 6'h2b || OpCode == 6'h02 || OpCode == 6'h01 ||
						(OpCode >= 6'h04 && OpCode <= 6'h07) || (OpCode == 6'h00 && Funct == 5'h08)));
	
	assign RegDst[1:0] =
		Exception? 2'b11:
		(OpCode == 6'h23 || OpCode == 6'h0f || OpCode == 6'h08 || OpCode == 6'h09 || OpCode == 6'h0c || OpCode == 6'h0a || OpCode == 6'h0b)? 2'b00:
		(OpCode == 6'h03)? 2'b10:
		2'b01;
	
	assign MemRead = OpCode == 6'h23 && ~Exception;
	
	assign MemWrite = OpCode == 6'h2b && ~Exception;
	
	assign MemtoReg[1:0] =
		(OpCode == 6'h23)? 2'b01:
		(Exception || OpCode == 6'h03 || (OpCode == 6'h00 && Funct == 5'h09))? 2'b10: 
		2'b00;
	
	assign ALUSrc1 = OpCode == 6'h00 && (Funct == 5'h00 || Funct == 5'h02 || Funct == 5'h03);
	
	assign ALUSrc2 = OpCode == 6'h23 || OpCode == 6'h2b || OpCode == 6'h0f || OpCode == 6'h08 || OpCode == 6'h09 || OpCode == 6'h0c || OpCode == 6'h0a || OpCode == 6'h0b;
	
	assign ExtOp = OpCode != 6'h0c;
	
	assign LuOp = OpCode == 6'h0f;
	
	assign ALUOp[2:0] = 
		(OpCode == 6'h00)? 3'b010: 
		(OpCode == 6'h04)? 3'b001: 
		(OpCode == 6'h0c)? 3'b100: 
		(OpCode == 6'h0a || OpCode == 6'h0b)? 3'b101: 
		3'b000;
		
	assign ALUOp[3] = OpCode[0];
	
endmodule