module fneg(
    input wire [31:0] x1,
    output wire [31:0] y);

    assign y = {~x1[31:31],x1[30:0]};

endmodule
