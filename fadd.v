module fadd(
    input wire [31:0] x1,
    input wire [31:0] x2,
    output wire [31:0] y,
    input wire clk,
    input wire rstn);

    reg sy_reg,e2a_zero_reg;
    reg [7:0] e1a_reg,eya_reg;
    reg [22:0] m1a_reg;
    reg [25:0] mya_reg;

    // stage 1
    wire a;
    wire [31:0] x1a,x2a;
    assign a = (x1[30:0] < x2[30:0]);
    assign x1a = (a) ? x2: x1;
    assign x2a = (a) ? x1: x2;

    wire s1a,s2a;
    wire [7:0] e1a,e2a,ey;
    wire [22:0] m1a,m2a,my;
    assign s1a = x1a[31:31];
    assign e1a = x1a[30:23];
    assign m1a = x1a[22:0];
    assign s2a = x2a[31:31];
    assign e2a = x2a[30:23];
    assign m2a = x2a[22:0];

    wire [7:0] sm;
    assign sm = e1a - e2a;

    wire [23:0] m1b;
    assign m1b = {1'b1,m1a};

    wire [23:0] m2b;
    assign m2b = {1'b1,m2a} >> sm;

    wire e2a_zero;
    assign e2a_zero = (e2a == 0);

    wire [24:0] mya;
    assign mya = (s1a == s2a) ? m1b + m2b: m1b - m2b;

    // stage 2
    function [7:0] SE (
	input [24:0] MYA
    );
    begin
	casex(MYA)
        25'b1xxxxxxxxxxxxxxxxxxxxxxxx: SE = 8'd0;
        25'b01xxxxxxxxxxxxxxxxxxxxxxx: SE = 8'd1;
	25'b001xxxxxxxxxxxxxxxxxxxxxx: SE = 8'd2;
	25'b0001xxxxxxxxxxxxxxxxxxxxx: SE = 8'd3;
	25'b00001xxxxxxxxxxxxxxxxxxxx: SE = 8'd4;
        25'b000001xxxxxxxxxxxxxxxxxxx: SE = 8'd5;
	25'b0000001xxxxxxxxxxxxxxxxxx: SE = 8'd6;
	25'b00000001xxxxxxxxxxxxxxxxx: SE = 8'd7;
	25'b000000001xxxxxxxxxxxxxxxx: SE = 8'd8;
	25'b0000000001xxxxxxxxxxxxxxx: SE = 8'd9;
	25'b00000000001xxxxxxxxxxxxxx: SE = 8'd10;
	25'b000000000001xxxxxxxxxxxxx: SE = 8'd11;
	25'b0000000000001xxxxxxxxxxxx: SE = 8'd12;
	25'b00000000000001xxxxxxxxxxx: SE = 8'd13;
	25'b000000000000001xxxxxxxxxx: SE = 8'd14;
	25'b0000000000000001xxxxxxxxx: SE = 8'd15;
	25'b00000000000000001xxxxxxxx: SE = 8'd16;
	25'b000000000000000001xxxxxxx: SE = 8'd17;
	25'b0000000000000000001xxxxxx: SE = 8'd18;
	25'b00000000000000000001xxxxx: SE = 8'd19;
	25'b000000000000000000001xxxx: SE = 8'd20;
	25'b0000000000000000000001xxx: SE = 8'd21;
	25'b00000000000000000000001xx: SE = 8'd22;
	25'b000000000000000000000001x: SE = 8'd23;
	25'b0000000000000000000000001: SE = 8'd24;
        default : SE = 8'd255;
	endcase
    end
    endfunction

    wire [7:0] sea;
    assign sea = SE(mya_reg);

    wire [7:0] eyb;
    assign eyb = (eya_reg > sea) ? eya_reg - sea: 0;
    assign ey = (e2a_zero_reg) ? e1a_reg: eyb;

    wire [4:0] seb;
    assign seb = (sea == 8'd255) ? 5'd25: sea;

    wire [24:0] myb;
    assign myb = mya_reg << seb;
    assign my = (e2a_zero_reg) ? m1a_reg: myb[23:1];

    assign y = {sy_reg,ey,my};

    always @(posedge clk) begin
        // stage 1
        sy_reg <= s1a;
        e1a_reg <= e1a;
        e2a_zero_reg <= e2a_zero;
        eya_reg <= e1a + 1;
        m1a_reg <= m1a;
        mya_reg <= mya;
    end

    always @(negedge ~rstn) begin
        sy_reg <= 0;
        e2a_zero_reg <= 0;
        e1a_reg <= 0;
        eya_reg <= 0;
        m1a_reg <= 0;
        mya_reg <= 0;
    end

endmodule
