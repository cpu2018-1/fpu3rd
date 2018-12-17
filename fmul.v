module fmul(
    input wire [31:0] x1,
    input wire [31:0] x2,
    output wire [31:0] y);

    wire s1,s2,sy;
    wire [7:0] e1,e2,ey;
    wire [22:0] m1,m2,my;
    assign s1 = x1[31:31];
    assign e1 = x1[30:23];
    assign m1 = x1[22:0];
    assign s2 = x2[31:31];
    assign e2 = x2[30:23];
    assign m2 = x2[22:0];

    assign sy = s1 ^ s2;

    wire [47:0] mya;
    assign mya = {1'b1,m1} * {1'b1,m2};

    wire [22:0] myb;
    assign myb = (mya[47:47]) ? mya[46:24]: mya[45:23];

    wire [8:0] eya0;
    assign eya0 = (x1[30:0] == 31'b0 | x2[30:0] == 31'b0) ? 9'b0: e1 + e2;
    
    wire [9:0] ey0,ey1;
    assign ey0 = eya0 - 10'd127;
    assign ey1 = eya0 - 10'd126;

    wire [9:0] eya;
    assign eya = (mya[47:47]) ? ey1: ey0;
    assign ey = (eya[9]) ? 8'b0: eya[7:0];
    assign my = (eya[9]) ? 23'b0: myb;

    assign y = {sy,ey,my};

endmodule
