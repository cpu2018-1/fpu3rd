module ftoi(
    input wire [31:0] x,
    output reg [31:0] y,
    input wire clk);

    wire sx;
    wire [7:0] ex;
    wire [22:0] mx;
    assign sx = x[31:31];
    assign ex = x[30:23];
    assign mx = x[22:0];

    wire [31:0] mya;
    assign mya = {1'b1,mx,8'b0};

    wire [7:0] se;
    assign se = 8'd157 - ex;

    wire [31:0] myb;
    assign myb = (mya >> se) + 1;
  
    wire [30:0] myc;
    assign myc = myb[31:1];

    wire sy;
    wire [30:0] my;
    assign sy = sx;
    assign my = (sy) ? (~myc) + 1: myc;

    wire [31:0] y_wire;
    assign y_wire = (my == 0) ? 0: {sy,my};

    always @(posedge clk) begin
        y <= y_wire;
    end

endmodule
