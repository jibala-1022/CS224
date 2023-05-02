`timescale 1ns / 1ps

module top_module(
    input clk,
    input boot, // start of program
    output [6:0] seg,
    output [7:0] an
);

reg load; // program running
wire [63:0] bus; // 64-bit bus
wire mem_ready;
wire pro_ready;
wire [1:0] mem_line;
wire [1:0] pro_line;
wire terminate; // stop program
wire [8:0] hits;
wire [8:0] misses;

reg [4:0] counter;
reg clk1; // slowed clk

initial
begin
    load=0;
    counter=0;
    clk1=0;
end

processor PROCESSOR(clk1, load, pro_line, bus, pro_ready, terminate);
dram MEMORY(clk1, bus, mem_line, mem_ready, hits, misses);
bus_controller BUS_CONTROLLER(clk1, mem_ready, pro_ready, mem_line, pro_line);

driver DRIVER_7_SEG(clk1, hits, misses, seg, an);

always@(posedge clk)
begin
   counter=counter+1;
   clk1=~clk1;
end

always@(posedge counter[4])
begin
    if(terminate) // stop the program once done
    begin
        load=0;
    end
    else if(boot) 
    begin
        load=1;
    end
end

endmodule