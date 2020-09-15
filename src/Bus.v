module Bus(reset, clk, Address, Write_data, Read_data, MemRead, MemWrite, leds, digits, IRQ);
	input reset, clk;
	input [31:0] Address, Write_data;
	input MemRead, MemWrite;
	output [31:0] Read_data;
	output [7:0] leds;
	output [11:0] digits;
	output IRQ;
	
	// Enable signals
	wire EN_DataMemory;
	wire EN_Timer;
	wire EN_LED;
	wire EN_BCD7;
	wire EN_SysTick;
	
	assign EN_DataMemory = Address <= 32'h000007ff;
	assign EN_Timer = Address >= 32'h40000000 && Address <= 32'h40000008;
	assign EN_LED = Address == 32'h4000000c;
	assign EN_BCD7 = Address == 32'h40000010;
	assign EN_SysTick = Address == 32'h40000014;
	
	wire [31:0] Read_data_DataMemory, Read_data_Timer, Read_data_SysTick;

	DataMemory data_memory1(.reset(reset), .clk(clk), .Address(Address),
		.Write_data(Write_data), .Read_data(Read_data_DataMemory), .MemRead(MemRead && EN_DataMemory), .MemWrite(MemWrite && EN_DataMemory));
	
	Timer timer1(.reset(reset), .clk(clk), .Address(Address[3:2]), .Read_data(Read_data_Timer), .MemRead(MemRead && EN_Timer),
		.Write_data(Write_data), .MemWrite(MemWrite && EN_Timer), .IRQ(IRQ));
	
	LED led1(.reset(reset), .clk(clk), .Write_data(Write_data[7:0]), .MemWrite(MemWrite && EN_LED), .leds(leds));
	
	BCD7 bcd7(.reset(reset), .clk(clk), .Write_data(Write_data[11:0]), .MemWrite(MemWrite && EN_BCD7), .digits(digits));
	
	SysTick sys_tick1(.reset(reset), .clk(clk), .count(Read_data_SysTick));
	
	assign Read_data = MemRead?
						(EN_DataMemory? Read_data_DataMemory:
					     EN_Timer? Read_data_Timer:
						 EN_LED? {24'h000000, leds}:
						 EN_BCD7? {20'h00000, digits}:
					     EN_SysTick? Read_data_SysTick:
						 32'h00000000):
					    32'h00000000;

endmodule