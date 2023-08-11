`timescale 1 ns/ 1 ns
module CLA4_clk
(
input clk,
input rst_n,
input start,
input [3:0] A,
input [3:0] B,
output [3:0] Sum,
output Cout
);
wire Cin;
assign Cin = 1'b0;
reg start_d1;
reg start_d2;
wire start_TG;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
    start_d1 <= 1'b0;
    start_d2 <= 1'b0;
    end
    else
    begin
    start_d1 <= start;
    start_d2 <= start_d1;
    end
end
assign start_TG = start_d1 && !start_d2;
reg busy_r;
wire fin_TG;
always@(posedge clk or negedge rst_n or posedge fin_TG)
begin
    if(!rst_n || fin_TG)
    begin
    busy_r <= 1'b0;
    end
    else
    begin
        if(start_TG)
        begin
        busy_r <= 1'b1;
        end
        else
        begin
        busy_r <= busy_r;
        end
    end
end

reg [2:0] cnt;
always@(posedge clk or negedge rst_n or posedge start_TG)
begin
    if(!rst_n || start_TG)
    begin
    cnt <= 3'd0;
    end
    else
    begin
        if(busy_r && (cnt <= 3'd4))
        begin
        cnt <= cnt + 3'd1;
        end
        else
        begin
        cnt <= cnt;
        end
    end
end

reg fin_r;
always@(posedge clk or negedge rst_n or posedge start_TG)
begin
    if(!rst_n || start_TG)
    begin
    fin_r <= 1'b0;
    end
    else
    begin
        if(cnt == 3'd4)
        begin
        fin_r <= 1'b1;
        end
        else
        begin
        fin_r <= fin_r;
        end
    end
end
reg fin_d1;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
    fin_d1 <= 1'b0;
    end
    else
    begin
    fin_d1 <= fin_r;
    end
end
assign fin_TG = fin_r && !fin_d1;

reg [3:0] p_r;
reg [3:0] g_r;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
    p_r <= 4'd0;
    end
    else
    begin
        if(busy_r)
        begin
        p_r <= A^B;
        end
        else
        begin
        p_r <= p_r;
        end
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
    g_r <= 4'd0;
    end
    else
    begin
        if(busy_r)
        begin
        g_r <= A&B;
        end
        else
        begin
        g_r <= g_r;
        end
    end
end

reg [4:0] c_r;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
    c_r <= 4'd0;
    end
    else
    begin
        if(busy_r)
        begin
        c_r[0] <= Cin;
        c_r[1] <= g_r[0] | ( p_r[0] & c_r[0]);  
        c_r[2] <= g_r[1]|(p_r[1]&(g_r[0]|(p_r[0]&c_r[0])));
        c_r[3] <= g_r[2]|(p_r[2]&(g_r[1]|(p_r[1]&(g_r[0]|(p_r[0]&c_r[0])))));
        c_r[4] <= g_r[3]|(p_r[3]&(g_r[2]|(p_r[2]&(g_r[1]|(p_r[1]&(g_r[0]|(p_r[0]&c_r[0])))))));
        end
        else
        begin
        c_r <= c_r;
        end
    end
end

reg [3:0] sum_r;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
    sum_r <= 4'd0;
    end
    else
    begin
        if(busy_r)
        begin
        sum_r <= p_r[3:0] ^ c_r[3:0];
        end
        else
        begin
        sum_r <= sum_r;
        end
    end
end

reg [3:0] sum_r2;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
    sum_r2 <= 4'd0;
    end
    else
    begin
        if(fin_r)
        begin
        sum_r2 <= sum_r;
        end
        else
        begin
        sum_r2 <= sum_r2;
        end
    end
end
assign Sum = sum_r2;

reg Cout_r;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
    Cout_r <= 1'b0;
    end
    else
    begin
        if(fin_r)
        begin
        Cout_r <= c_r[4];
        end
        else
        begin
        Cout_r <= Cout_r;
        end
    end
end

assign Cout = Cout_r;

endmodule