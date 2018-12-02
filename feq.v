module feq(
    input wire [31:0] x1,
    input wire [31:0] x2,
    output wire [31:0] y);

    wire [7:0] e1,e2;
    assign e1 = x1[30:23];
    assign e2 = x2[30:23];

    assign y = (x1 == x2 || ((e1 == 0) && (e2 == 0))) ? 32'b1: 0;

endmodule
