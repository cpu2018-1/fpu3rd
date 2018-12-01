module decord(
    input wire [3:0] ctrl,
    output wire [5:0] y
);

    function [5:0] Y (
        input [3:0] CTRL
    );
    begin
        casex(CTRL)
        4'd1: Y = 6'b000010;
        4'd2: Y = 6'b000010;
        4'd4: Y = 6'b000100;
        4'd5: Y = 6'b000100;
        default: Y = 6'b000001;
        endcase
    end
    endfunction

    assign y = Y(ctrl);

endmodule
