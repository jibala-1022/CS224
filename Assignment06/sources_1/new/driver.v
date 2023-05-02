`timescale 1ns / 1ps

module driver(
    input clk,
    input [8:0] hits,
    input [8:0] misses,
    output reg [6:0] seg,
    output reg [7:0] an
);

wire [6:0] seg1, seg2, seg3, seg4, seg5, seg6;
reg [12:0] segclk;
reg [2:0] state;
reg [3:0] h1,h2,h3, m1,m2,m3;
reg [8:0] h,m;

initial
begin
    h=0;
    m=0;
    h1=0;
    h2=0;
    h3=0;
    m1=0;
    m2=0;
    m3=0;
    segclk=0;
    state=0;
end

always@(posedge clk)
begin
    segclk <= segclk + 1;
end

always@(posedge segclk[12])
case(state)
0:
    begin
    seg <= 7'b0000001;
    an <= 8'b01111111;
    state <= 1;
    end
1:
    begin
    seg <= seg1;
    an <= 8'b10111111;
    state <= 2;
    end
2:
    begin
    seg <= seg2;
    an <= 8'b11011111;
    state <= 3;
    end
3:
    begin
    seg <= seg3;
    an <= 8'b11101111;
    state <= 4;
    end
4:
    begin
    seg <= 7'b0000001;
    an <= 8'b11110111;
    state <= 5;
    end
5:
    begin
    seg <= seg4;
    an <= 8'b11111011;
    state <= 6;
    end
6:
    begin
    seg <= seg5;
    an <= 8'b11111101;
    state <= 7;
    end
7:
    begin
    seg <= seg6;
    an <= 8'b11111110;
    state <= 0;
    end
endcase


always@(hits)
begin
    h=hits;
    h3=h%10;
    h=h/10;
    h2=h%10;
    h1=h/10;
end

always@(misses)
begin
    m=misses;
    m3=m%10;
    m=m/10;
    m2=m%10;
    m1=m/10;
end


decoder HITS_1(h1, seg1);
decoder HITS_2(h2, seg2);
decoder HITS_3(h3, seg3);
decoder MISSES_1(m1, seg4);
decoder MISSES_2(m2, seg5);
decoder MISSES_3(m3, seg6);

endmodule