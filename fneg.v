module fneg(
    input wire [31:0] x1,
    output reg [31:0] y,
    input wire clk,
    input wire rstn);

    always @(posedge clk) begin
        y <= {~x1[31:31],x1[30:0]};
    end

    always @(negedge rstn) begin
        y <= 0;
    end

endmodule
