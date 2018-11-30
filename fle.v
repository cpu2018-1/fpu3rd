module fle(
    input wire [31:0] x1,
    input wire [31:0] x2,
    output reg [31:0] y,
    input wire clk,
    input wire rstn);

    wire s1,s2;
    wire [7:0] e1,e2;
    wire [22:0] m1,m2;
    assign s1 = x1[31:31];
    assign e1 = x1[30:23];
    assign m1 = x1[22:0];
    assign s2 = x2[31:31];
    assign e2 = x2[30:23];
    assign m2 = x2[22:0];

    wire s1a,s2a;
    wire [7:0] e1a,e2a;
    wire [22:0] m1a,m2a,m1b,m2b;
    assign s1a = (e1 == 0) ? 1: ~s1;
    assign e1a = (s1a) ? e1: ~e1;
    assign m1a = (e1 == 0) ? 0: m1;
    assign m1b = (s1a) ? m1a: ~m1a;
    assign s2a = (e2 == 0) ? 1: ~s2;
    assign e2a = (s2a) ? e2: ~e2;
    assign m2a = (e2 == 0) ? 0: m2;
    assign m2b = (s2a) ? m2a: ~m2a;

    always @(posedge clk) begin
        y <= ({s1a,e1a,m1b} <= {s2a,e2a,m2b});
    end

    always @(negedge rstn) begin
        y <= 0;
    end

endmodule
