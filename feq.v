module fle(
    input wire [31:0] x1,
    input wire [31:0] x2,
    output wire [31:0] y);

    wire s1,s2;
    wire [30:0] em1,em2;
    assign s1 = x1[31];
    assign em1 = x1[30:0];
    assign s2 = x2[31];
    assign em2 = x2[30:0];

    wire s1a,s2a,em1_zero,em2_zero;
    wire [30:0] em1a,em2a;
    assign em1_zero = (em1 == 31'b0);
    assign em2_zero = (em2 == 31'b0);
    assign s1a = (em1_zero) ? 1'b1: ~s1;
    assign em1a = (em1_zero) ? 31'b0: ((s1) ? ~em1: em1);
    assign s2a = (em2_zero) ? 1'b1: ~s2;
    assign em2a = (em2_zero) ? 1'b1: ((s2) ? ~em2: em2);

    wire [31:0] x1a,x2a;
    assign x1a = {s1a,em1a};
    assign x2a = {s2a,em2a};

    assign y = (x1a == x2a);

endmodule
