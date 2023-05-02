`timescale 1ns / 1ps

module processor(
    input clk,
    input load,
    input [1:0] pro_line,
    output reg [63:0] bus,
    output pro_ready,
    output reg terminate
);

reg [63:0] pro_buf [0:1023];
reg [9:0] pro_front;
reg [9:0] pro_back;

reg [63:0] inp_buf [0:1023];
reg [9:0] inp_front;
reg [9:0] inp_back;

localparam REQUESTS=32;

initial
begin
    bus=0;
    pro_front=0;
    pro_back=0;
    terminate=0;
    inp_front=0;
    inp_back=REQUESTS;
    inp_buf[0]=1;
    inp_buf[1]=2;
    inp_buf[2]=3;
    inp_buf[3]=1;
    inp_buf[4]=2;
    inp_buf[5]=2000;
    inp_buf[6]=2;
    inp_buf[7]=262144;
    inp_buf[8]=262144;
    inp_buf[9]=2;
    inp_buf[10]=1;
    inp_buf[11]=2;
    inp_buf[12]=2;
    inp_buf[13]=1;
    inp_buf[14]=2;
    inp_buf[15]=2;
    inp_buf[16]=1;
    inp_buf[17]=2;
    inp_buf[18]=2;
    inp_buf[19]=1;
    inp_buf[20]=2;
    inp_buf[21]=2;
    inp_buf[22]=1;
    inp_buf[23]=2;
    inp_buf[24]=2;
    inp_buf[25]=1;
    inp_buf[26]=2;
    inp_buf[27]=2;
    inp_buf[28]=1;
    inp_buf[29]=2;
    inp_buf[30]=2;
    inp_buf[31]=1;
end

always@(posedge clk)
begin
    if(load) // loading requests
    begin
        inp_front=inp_front+1;
        if(inp_front==inp_back)
        begin
            terminate=1;
        end
    
        pro_buf[pro_front]=inp_buf[inp_front];
        pro_front=pro_front+1;
    end
    if(pro_line==2'b10 && pro_front!=pro_back) // send requests 
    begin
        bus=pro_buf[pro_back];
        pro_back=pro_back+1;
    end

end

assign pro_ready=(pro_front!=pro_back);

endmodule