`timescale 1ns / 1ps

module top_tb;
reg clk;
reg boot;
wire [6:0] seg;
wire [7:0] an;

reg [15:0] cycle;

top_module TOP(clk, boot, seg, an);
    
initial
begin
    clk=0;
    cycle=0;
    forever #0.01
    begin
    clk=~clk;
    cycle=cycle+clk;
    end
end
    
initial
begin
boot=0;
#0.035 boot=1;
end

endmodule