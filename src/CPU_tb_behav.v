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
    $readmemh("instruction.txt", cpu1.instruction_memory1.RAM_data);
    $display("Instructions loaded");
    #100 reset = 0;
    $readmemh("data.txt", cpu1.bus1.data_memory1.RAM_data);
    $display("Data loaded");
end

always @(posedge leds[0]) begin
    $writememh("data_sorted.txt", cpu1.bus1.data_memory1.RAM_data);
    #5000 $finish;
end

always #(`PERIOD/2) clk = ~clk;

endmodule
