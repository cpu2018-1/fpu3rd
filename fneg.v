module fneg(
    input wire [31:0] x1,
    output reg [31:0] y,
    input wire clk);

    wire s1;
    assign s1 = x1[31:31];

    wire [31:0] y_wire;
    assign y_wire = {~x1[31:31],x1[30:0]};

    always @(posedge clk) begin
        y <= y_wire;
    end

endmodule
