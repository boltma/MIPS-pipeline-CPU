`timescale 1ns/1ps
`define PERIOD 100

module CPU_tb;
reg [1:0] control;
reg reset;
reg clk;
wire [7:0] register;

CPU cpu1(control, reset, clk, register);

initial begin
	control = 2'b00;
    reset = 1;
    clk = 1;
    #1000 reset = 0;
    #9000 reset = 1;
    control = 2'b01;
    #1000 reset = 0;
    #9000 reset = 1;
    control = 2'b10;
    #1000 reset = 0;
    #9000 reset = 1;
    control = 2'b11;
    #1000 reset = 0;
    #9000 $finish;
end

always #(`PERIOD/2) clk = ~clk;

endmodule
