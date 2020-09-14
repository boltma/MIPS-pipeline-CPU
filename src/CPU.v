module CPU(control, reset, clk, register);
	input reset, clk;
	input [1:0] control;
	output [7:0] register;
	
	// Control Signals
	wire [2:0] PCSrc;
	wire Branch;
	wire [2:0] BranchOp;
	wire RegWrite;
	wire [1:0] RegDst;
	wire ExtOp;
	wire LuOp;
	wire ALUSrc1;
	wire ALUSrc2;
	wire [3:0] ALUOp;
	wire [1:0] MemtoReg;
	wire MemRead;
	wire MemWrite;
	
	// Flush Signals
	wire Stall;
	wire Branch_out;
	wire IF_ID_Flush;
	wire ID_EX_Flush;
	
	// IF/ID Registers
    reg [31:0] IF_ID_PC_plus_4;
	reg [31:0] IF_ID_Instruction;
	
	// ID/EX Registers
	reg [31:0] ID_EX_PC_plus_4;
	reg ID_EX_Branch;
	reg [2:0] ID_EX_BranchOp;
	reg ID_EX_RegWrite;
	reg [4:0] ID_EX_RegisterRs;
	reg [4:0] ID_EX_RegisterRt;
	reg [4:0] ID_EX_RegisterRd;
	reg [31:0] ID_EX_Rs_data, ID_EX_Rt_data;
	reg [31:0] ID_EX_Imm;
	reg [4:0] ID_EX_Shamt;
	reg [5:0] ID_EX_Funct;
	reg ID_EX_ALUSrc1, ID_EX_ALUSrc2;
	reg [3:0] ID_EX_ALUOp;
	reg [1:0] ID_EX_MemtoReg;
	reg ID_EX_MemRead, ID_EX_MemWrite;
	
	// EX/MEM Registers
	reg [31:0] EX_MEM_PC_plus_4;
	reg EX_MEM_RegWrite;
	reg [4:0] EX_MEM_RegisterRd;
	reg [1:0] EX_MEM_MemtoReg;
	reg [31:0] EX_MEM_Rt_data;
	reg [31:0] EX_MEM_ALU_out;
	reg EX_MEM_MemRead, EX_MEM_MemWrite;
	
	// MEM/WB Registers
	reg MEM_WB_RegWrite;
	reg [4:0] MEM_WB_RegisterRd;
	reg [31:0] MEM_WB_Write_data;
	
	// IF Stage
	reg [31:0] PC;
	wire [31:0] PC_next;
	wire [31:0] PC_jump, PC_branch, PC_jr, PC_plus_4;
	assign PC_plus_4 = PC + 32'd4;
	// TODO: Remove Branch Signal, add interrupt
	assign PCSrc[2] = 0;
	assign PC_next = Branch_out? PC_branch:
					 (PCSrc == 3'b000)? PC_plus_4:
					 (PCSrc == 3'b001)? PC_jump:
					 (PCSrc == 3'b010)? PC_jr:
					 (PCSrc == 3'b100)? 32'h80000004:
					 32'h80000008;
	always @(posedge reset or posedge clk)
		if (reset)
			PC <= 32'h00000000;
		else if (~Stall)
			PC <= PC_next;

	// Fetch instruction
	wire [31:0] Instruction;
	InstructionMemory instruction_memory1(.Address(PC), .Instruction(Instruction));

	// IF/ID Registers update
	assign IF_ID_Flush = Branch_out || PCSrc == 3'b001 || PCSrc == 3'b010;
	always @(posedge reset or posedge clk)
		if (reset || IF_ID_Flush) begin
			IF_ID_Instruction <= 32'h00000000;
			IF_ID_PC_plus_4 <= 32'h00000000;
		end else if (~Stall) begin
			IF_ID_Instruction <= Instruction;
			IF_ID_PC_plus_4 <= PC_plus_4;
		end
	
	// ID Stage
	wire [31:0] ID_Databus1, ID_Databus2;
	RegisterFile register_file1(.control(control), .reset(reset), .clk(clk), .RegWrite(MEM_WB_RegWrite), 
	 	.Read_register1(IF_ID_Instruction[25:21]), .Read_register2(IF_ID_Instruction[20:16]), .Write_register(MEM_WB_RegisterRd),
	 	.Write_data(MEM_WB_Write_data), .Read_data1(ID_Databus1), .Read_data2(ID_Databus2), .register(register));
	
	Control control1(
		.OpCode(IF_ID_Instruction[31:26]), .Funct(IF_ID_Instruction[5:0]),
		.PCSrc(PCSrc[1:0]), .Branch(Branch), .RegWrite(RegWrite), .RegDst(RegDst), 
		.MemRead(MemRead),	.MemWrite(MemWrite), .MemtoReg(MemtoReg),
		.ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .ExtOp(ExtOp), .LuOp(LuOp), .ALUOp(ALUOp), .BranchOp(BranchOp));

	HazardUnit hazard_unit1(.ID_EX_MemRead(ID_EX_MemRead), .EX_MEM_MemRead(EX_MEM_MemRead),
		.RegisterRs(IF_ID_Instruction[25:21]), .RegisterRt(IF_ID_Instruction[20:16]),
		.ID_EX_RegisterRd(ID_EX_RegisterRd), .EX_MEM_RegisterRd(EX_MEM_RegisterRd), .PCSrc(PCSrc), .Stall(Stall));
	
	// ID Stage Forwarding
	// TODO: Forwarding, whether RtSrc is needed
	wire [1:0] ID_RsSrc;
	wire ID_RtSrc;
	wire [1:0] EX_RsSrc;
	wire [1:0] EX_RtSrc;
	ForwardUnit forward_unit1(.RegisterRs(IF_ID_Instruction[25:21]), .RegisterRt(IF_ID_Instruction[20:16]),
		.ID_EX_RegisterRs(ID_EX_RegisterRs), .ID_EX_RegisterRt(ID_EX_RegisterRt), .ID_EX_RegWrite(ID_EX_RegWrite),
		.EX_MEM_RegWrite(EX_MEM_RegWrite), .EX_MEM_RegisterRd(EX_MEM_RegisterRd),
		.MEM_WB_RegWrite(MEM_WB_RegWrite), .MEM_WB_RegisterRd(MEM_WB_RegisterRd),
		.ForwardA_ID(ID_RsSrc), .ForwardB_ID(ID_RtSrc), .ForwardA_EX(EX_RsSrc), .ForwardB_EX(EX_RtSrc));
	
	wire [31:0] ID_Rs_data, ID_Rt_data;
	assign ID_Rs_data = (ID_RsSrc == 2'b00)? ID_Databus1:
                        (ID_RsSrc == 2'b01)? EX_MEM_ALU_out:
                        MEM_WB_Write_data;
	assign ID_Rt_data = (ID_RtSrc == 1'b0)? ID_Databus2: MEM_WB_Write_data;
	
	wire [31:0] Ext_out;
	assign Ext_out = {ExtOp? {16{IF_ID_Instruction[15]}}: 16'h0000, IF_ID_Instruction[15:0]};
	wire [31:0] Imm_out;
	assign Imm_out = LuOp? {IF_ID_Instruction[15:0], 16'h0000}: Ext_out;
	
	// TODO: PC[31] instead of IF_ID_PC...[31]
	assign PC_jump = {IF_ID_PC_plus_4[31:28], IF_ID_Instruction[25:0], 2'b00};
	assign PC_jr = ID_Rs_data;
	
	wire [4:0] Write_register;
	assign Write_register = (RegDst == 2'b00)? IF_ID_Instruction[20:16]:
	 						(RegDst == 2'b01)? IF_ID_Instruction[15:11]:
							(RegDst == 2'b10)? 5'd31:
	 						5'd26;
	
	// ID/EX Registers Update
	assign ID_EX_Flush = Stall || Branch_out;
	always @(posedge reset or posedge clk)
		if (reset || ID_EX_Flush) begin
			ID_EX_PC_plus_4 <= 32'h00000000;
			ID_EX_Branch <= 1'b0;
			ID_EX_BranchOp <= 3'b000;
			ID_EX_RegWrite <= 1'b0;
			ID_EX_RegisterRs <= 5'b00000;
			ID_EX_RegisterRt <= 5'b00000;
			ID_EX_RegisterRd <= 5'b00000;
			ID_EX_Rs_data <= 32'h00000000;
			ID_EX_Rt_data <= 32'h00000000;
			ID_EX_Imm <= 32'h00000000;
			ID_EX_Shamt <= 5'b00000;
			ID_EX_Funct <= 6'b000000;
			ID_EX_ALUSrc1 <= 1'b0;
			ID_EX_ALUSrc2 <= 1'b0;
			ID_EX_ALUOp <= 4'b0000;
			ID_EX_MemtoReg <= 2'b00;
			ID_EX_MemRead <= 1'b0;
			ID_EX_MemWrite <= 1'b0;
		end else begin
			ID_EX_PC_plus_4 <= IF_ID_PC_plus_4;
			ID_EX_Branch <= Branch;
			ID_EX_BranchOp <= BranchOp;
			ID_EX_RegWrite <= RegWrite;
			ID_EX_RegisterRs <= IF_ID_Instruction[25:21];
			ID_EX_RegisterRt <= IF_ID_Instruction[20:16];
			ID_EX_RegisterRd <= Write_register;
			ID_EX_Rs_data <= ID_Rs_data;
			ID_EX_Rt_data <= ID_Rt_data;
			ID_EX_Imm <= Imm_out;
			ID_EX_Shamt <= IF_ID_Instruction[10:6];
			ID_EX_Funct <= IF_ID_Instruction[5:0];
			ID_EX_ALUSrc1 <= ALUSrc1;
			ID_EX_ALUSrc2 <= ALUSrc2;
			ID_EX_ALUOp <= ALUOp;
			ID_EX_MemtoReg <= MemtoReg;
			ID_EX_MemRead <= MemRead;
			ID_EX_MemWrite <= MemWrite;
		end
	
	// EX Stage
	// EX Stage Forwarding
	wire [31:0] EX_Rs_data, EX_Rt_data;
	assign EX_Rs_data = (EX_RsSrc == 2'b00)? ID_EX_Rs_data:
                        (EX_RsSrc == 2'b01)? EX_MEM_ALU_out:
                        MEM_WB_Write_data;
	assign EX_Rt_data = (EX_RtSrc == 2'b00)? ID_EX_Rt_data:
                        (EX_RtSrc == 2'b01)? EX_MEM_ALU_out:
                        MEM_WB_Write_data;
	
	// ALU
	wire [4:0] ALUCtl;
	wire Sign;
	ALUControl alu_control1(.ALUOp(ID_EX_ALUOp), .Funct(ID_EX_Funct), .ALUCtl(ALUCtl), .Sign(Sign));
	
	wire [31:0] ALU_in1, ALU_in2, ALU_out;
	assign ALU_in1 = ID_EX_ALUSrc1? {27'h0000000, ID_EX_Shamt}: EX_Rs_data;
	assign ALU_in2 = ID_EX_ALUSrc2? ID_EX_Imm: EX_Rt_data;
	ALU alu1(.in1(ALU_in1), .in2(ALU_in2), .ALUCtl(ALUCtl), .Sign(Sign), .out(ALU_out));
	
	// Branch
	BranchUnit branch_unit1(.in1(ALU_in1), .in2(ALU_in2), .Branch(ID_EX_Branch), .BranchOp(ID_EX_BranchOp), .out(Branch_out));
	
	// TODO: PC[31] instead of ID_EX_PC...[31]
	assign PC_branch = ID_EX_PC_plus_4 + {ID_EX_Imm[29:0], 2'b00};
	
	// EX/MEM Registers Update
	always @(posedge reset or posedge clk)
		if (reset) begin
			EX_MEM_PC_plus_4 <= 32'h00000000;
			EX_MEM_RegWrite <= 1'b0;
			EX_MEM_RegisterRd <= 5'b00000;
			EX_MEM_MemtoReg <= 2'b00;
			EX_MEM_MemRead <= 1'b0;
			EX_MEM_MemWrite <= 1'b0;
			EX_MEM_Rt_data <= 32'h00000000;
			EX_MEM_ALU_out <= 32'h00000000;
		end else begin
			EX_MEM_PC_plus_4 <= ID_EX_PC_plus_4;
			EX_MEM_RegWrite <= ID_EX_RegWrite;
			EX_MEM_RegisterRd <= ID_EX_RegisterRd;
			EX_MEM_MemtoReg <= ID_EX_MemtoReg;
			EX_MEM_MemRead <= ID_EX_MemRead;
			EX_MEM_MemWrite <= ID_EX_MemWrite;
			EX_MEM_Rt_data <= EX_Rt_data;
			EX_MEM_ALU_out <= ALU_out;
		end
	
	// MEM Stage
	wire [31:0] Read_data;
	DataMemory data_memory1(.reset(reset), .clk(clk), .Address(EX_MEM_ALU_out),
		.Write_data(EX_MEM_Rt_data), .Read_data(Read_data), .MemRead(EX_MEM_MemRead), .MemWrite(EX_MEM_MemWrite));
	
	wire [31:0] Write_data;
	assign Write_data = (EX_MEM_MemtoReg == 2'b00)? EX_MEM_ALU_out:
						(EX_MEM_MemtoReg == 2'b01)? Read_data:
						EX_MEM_PC_plus_4;
	
	// MEM/WB Registers Update
	always @(posedge reset or posedge clk)
		if (reset) begin
			MEM_WB_RegWrite <= 1'b0;
			MEM_WB_RegisterRd <= 5'b00000;
			MEM_WB_Write_data <= 32'h00000000;
		end else begin
			MEM_WB_RegWrite <= EX_MEM_RegWrite;
			MEM_WB_RegisterRd <= EX_MEM_RegisterRd;
			MEM_WB_Write_data <= Write_data;
		end
	
	// WB Stage: Nothing to be done

endmodule
	