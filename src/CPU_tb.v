`timescale 1ns/1ps
`define PERIOD 10

module CPU_tb;
reg reset;
reg clk;
wire [7:0] leds;
wire [11:0] digits;

CPU cpu1(reset, clk, leds, digits);

initial begin
    reset = 1;
    clk = 1;
    #100 reset = 0;
end

always @(posedge leds[0]) begin
    #5000 $finish;
end

always #(`PERIOD/2) clk = ~clk;

endmodule
