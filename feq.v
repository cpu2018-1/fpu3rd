module feq(
    input wire [31:0] x1,
    input wire [31:0] x2,
    output reg [31:0] y,
    input wire clk);

    wire [7:0] e1,e2;
    assign e1 = x1[30:23];
    assign e2 = x2[30:23];

    wire [31:0] y_wire;
    assign y_wire = (x1 == x2 || ((e1 == 0) && (e2 == 0))) ? 32'b1: 0;

    always @(posedge clk) begin
        y <= y_wire;
    end

endmodule
