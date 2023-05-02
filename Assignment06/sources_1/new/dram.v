`timescale 1ns / 1ps


module dram(
    input clk,
    input [63:0] bus,
    input [1:0] mem_line,
    output mem_ready,
    output reg [8:0] hits,
    output reg [8:0] misses
);

reg [7:0] row_buf [0:1][0:7][0:15];
reg rshr [0:1][0:7][0:15]; // row status handling register 00->ready, 01->requesting 10->free

reg [25:0] in_buf [0:1023];
reg [9:0] in_front;
reg [9:0] in_back;

reg [25:0] req_queue [0:9];
reg [1:0] req_status [0:9];
reg [7:0] req_counter [0:9];
reg [3:0] req_front;
reg mshr [0:9];
reg [2:0] basr [0:1];

reg channel;
reg [2:0] rank;
reg [3:0] bank;
reg [7:0] row;
reg [9:0] column;

reg [25:0] out_buf [0:1023];
reg [9:0] out_front;
reg [9:0] out_back;

integer i=0;
integer j=0;
integer k=0;

initial
begin
    in_front=0;
    in_back=0;
    out_front=0;
    out_back=0;
    req_front=0;
    hits=0;
    misses=0;
    channel=0;
    rank=0;
    bank=0;
    row=0;
    column=0;
    basr[0]=0;
    basr[1]=0;
    for(i=0;i<10;i=i+1)
    begin
        req_status[i]=2'b10;
        req_counter[i]=0;
        mshr[i]=0;
    end
    for(i=0;i<2;i=i+1)
    begin
        for (j=0;j<8;j=j+1)
        begin
            for(k=0;k<16;k=k+1)
            begin
                rshr[i][j][k]=0;
                row_buf[i][j][k]=255;
            end
        end
    end
end


always@(posedge clk)
begin
    
    if(req_status[req_front]==2'b10 && in_front!=in_back)
    begin
        req_queue[req_front]=in_buf[in_back];
        in_back=in_back+1;
        req_status[req_front]=2'b00;
        req_front=(req_front+1)%10;
    end

    for(i=0;i<10;i=i+1)
    begin
        channel=req_queue[i][25];
        rank=req_queue[i][24:22];
        bank=req_queue[i][21:18];
        row=req_queue[i][17:10];
        column=req_queue[i][9:0];

        if(req_status[i]==2'b01)
        begin
            req_counter[i]=req_counter[i]+1;
            if(mshr[i] && req_counter[i]==128)
            begin
                mshr[i]=0;
                req_counter[i]=0;
                row_buf[channel][rank][bank]=row;
            end
            else if(~mshr[i] && req_counter[i]==32)
            begin
                req_status[i]=2'b10;
                req_counter[i]=0;
                basr[channel]=basr[channel]-1;
                rshr[channel][rank][bank]=0;
                out_buf[out_front]={channel,rank,bank,row,column};
                out_front=out_front+1;
            end
        end
        else if(req_status[i]==2'b00 && ~rshr[channel][rank][bank] && basr[channel]<8)///
        begin
            req_status[i]=2'b01;
            rshr[channel][rank][bank]=1;
            basr[channel]=basr[channel]+1;
            if(row_buf[channel][rank][bank]==row)
            begin
                hits=hits+1;
            end
            else
            begin
                misses=misses+1;
                mshr[i]=1;
            end
        end
    end
end


always@(posedge clk)
begin
    if(mem_line==2'b01)
    begin
        in_buf[in_front]=bus[25:0];
        in_front=in_front+1;
    end
    else if(mem_line==2'b10)
    begin
        out_back=out_back+1;
    end

end

assign mem_ready=(out_front!=out_back);


endmodule