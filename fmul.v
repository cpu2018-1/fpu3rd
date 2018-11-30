module fmul(
    input wire [31:0] x1,
    input wire [31:0] x2,
    output reg [31:0] y,
    input wire clk,
    input wire rstn);

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

    wire a;
    assign a = mya[47:47];
    assign my = (a) ? mya[46:24]: mya[45:23];

    wire [8:0] eya0;
    assign eya0 = (e1 == 0 | e2 == 0) ? 0: e1 + e2;
    
    wire [7:0] ey0,ey1;
    assign ey0 = (eya0 > 9'd127) ? eya0 - 9'd127: 0;
    assign ey1 = (eya0 > 9'd126) ? eya0 - 9'd126: 0;

    assign ey = (a) ? ey1: ey0;

    always @(posedge clk) begin
        y <= {sy,ey,my};
    end

    always @(negedge rstn) begin
        y <= 0;
    end

endmodule
