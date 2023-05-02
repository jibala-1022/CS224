`timescale 1ns / 1ps


module bus_controller(
    input clk,
    input mem_ready, // memory feedback
    input pro_ready, // processor feedback
    output reg [1:0] mem_line, // control bits
    output reg [1:0] pro_line // control bits
);

reg [2:0] state;

initial
begin
    pro_line=2'b00;
    mem_line=2'b00;
    state=0;
end

always@(posedge clk)
begin
    if(state==0) 
    begin
        if(mem_ready)
        begin
            mem_line=2'b10;
            pro_line=2'b01;
            state=state+1;
        end
        else if(pro_ready)
        begin
            pro_line=2'b10;
            mem_line=2'b01;
            state=state+1;
        end
        else
        begin
            mem_line=2'b00;
            pro_line=2'b00;
        end
    end
    else
    begin
        state=state+1;
        mem_line=2'b00;
        pro_line=2'b00;
    end
end

endmodule