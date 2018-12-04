module fpu(
    input wire [3:0] ctrl,
    input wire [31:0] ds_val,
    input wire [31:0] dt_val,
    input wire [5:0] dd,
    input wire [15:0] imm,
    output reg [5:0] reg_addr,
    output reg [31:0] dd_val,
    input wire clk,
    input wire rstn);
    
    function [31:0] TABLE (
        input [6:0] IMMR
    );
    begin
        casex(IMMR)
        7'd0:TABLE = 32'b00000000000000000000000000000000;
        7'd1:TABLE = 32'b00111111000000000000000000000000;
        7'd2:TABLE = 32'b00111111100000000000000000000000;
        7'd3:TABLE = 32'b01000000000000000000000000000000;
        7'd4:TABLE = 32'b01000000010010010000111111011100;
        7'd5:TABLE = 32'b01000000110010010000111111011010;
        7'd6:TABLE = 32'b00111110001010101010101011000001;
        7'd7:TABLE = 32'b00111100000010001000011100100011;
        7'd8:TABLE = 32'b00111001010011011000010101011001;
        7'd9:TABLE = 32'b00111101001010101010011111011111;
        7'd10:TABLE = 32'b00111010101100111001000110010010;
        7'd11:TABLE = 32'b10111111100000000000000000000000;
        7'd12:TABLE = 32'b00111111110010010000111111011000;
        7'd13:TABLE = 32'b00111111010010010000111111011000;
        7'd14:TABLE = 32'b01000000010010010000111111101101;
        7'd15:TABLE = 32'b00111111110010010000111111101001;
        7'd16:TABLE = 32'b00111111010010010000111111101001;
        7'd17:TABLE = 32'b00111110101010101010101010011111;
        7'd18:TABLE = 32'b00111110010011001100110011001101;
        7'd19:TABLE = 32'b00111110000100100100100100011011;
        7'd20:TABLE = 32'b00111101111000111000111000101010;
        7'd21:TABLE = 32'b00111101101101111101011000110000;
        7'd22:TABLE = 32'b00111101011101011110011101000011;
        7'd23:TABLE = 32'b01000000100011000000000000000000;
        7'd24:TABLE = 32'b01000000000111000000000000000000;
        7'd25:TABLE = 32'b00111100100011101111100110011000;
        7'd26:TABLE = 32'b01000011010010000000000000000000;
        7'd27:TABLE = 32'b11000011010010000000000000000000;
        7'd28:TABLE = 32'b10111110010011001100110011001101;
        7'd29:TABLE = 32'b00111100001000111101011100001010;
        7'd30:TABLE = 32'b10111101110011001100110011001101;
        7'd31:TABLE = 32'b01001110011011100110101100101000;
        7'd32:TABLE = 32'b01001100101111101011110000100000;
        7'd33:TABLE = 32'b00111000110100011011011100010111;
        7'd34:TABLE = 32'b01000001011100000000000000000000;
        7'd35:TABLE = 32'b01000001111100000000000000000000;
        7'd36:TABLE = 32'b00111110000110011001100110011010;
        7'd37:TABLE = 32'b01000011011111110000000000000000;
        7'd38:TABLE = 32'b00111110100110011001100110011010;
        7'd39:TABLE = 32'b01000001001000000000000000000000;
        7'd40:TABLE = 32'b00111110100000000000000000000000;
        7'd41:TABLE = 32'b00111101010011001100110011001101;
        7'd42:TABLE = 32'b01000001101000000000000000000000;
        7'd43:TABLE = 32'b00111011011111111111101111001110;
        7'd44:TABLE = 32'b11000000000000000000000000000000;
        7'd45:TABLE = 32'b00111101110011001100110011001101;
        7'd46:TABLE = 32'b11000011000101100000000000000000;
        7'd47:TABLE = 32'b01000011000101100000000000000000;
        7'd48:TABLE = 32'b00111111011001100110011001100110;
        7'd49:TABLE = 32'b01000011000000000000000000000000;
        default:TABLE = 32'b0;
        endcase
    end
    endfunction

    reg s_31,s_32,s_21,s1,s2;
    reg [3:0] ctrl_31,ctrl_32,ctrl_21;
    reg [5:0] reg_addr_31,reg_addr_32,reg_addr_21;
    reg [31:0] fadd_y,fmul_y,fdiv_y,fsqrt_y,feq_y,flt_y,fle_y,ftoi_y,itof_y,fneg_y;

    reg [5:0]  reg_addr1,reg_addr2;
    reg [31:0] dd_val1,dd_val2;
    
    fadd u1 (ds_val,{ctrl[1] ^ dt_val[31],dt_val[30:0]},fadd_y,clk,rstn);
    fmul u2 (ds_val,dt_val,fmul_y,clk,rstn);
    fdiv u3 (ds_val,dt_val,fdiv_y,clk,rstn);
    fsqrt u4 (ds_val,fsqrt_y,clk,rstn);
    feq u5 (ds_val,dt_val,feq_y,clk,rstn);
    flt u6 (ds_val,dt_val,flt_y,clk,rstn);
    fle u7 (ds_val,dt_val,fle_y,clk,rstn);
    ftoi u8 (ds_val,ftoi_y,clk,rstn);
    itof u9 (ds_val,itof_y,clk,rstn);
    fneg u10 (ds_val,fneg_y,clk,rstn);

    wire [6:0] immr;
    assign immr = imm[6:0];

    wire [31:0] flup_y;
    assign flup_y = TABLE(immr);

    always @(posedge clk) begin
        case(ctrl)
        // 2stageの命令
        // fadd
        4'd1: begin
            s_32 <= 0;
            ctrl_32 <= 0;
            reg_addr_32 <= 0;
            s_31 <= s_32;
            ctrl_31 <= ctrl_32;
            reg_addr_31 <= reg_addr_32;
            s_21 <= 1;
            ctrl_21 <= ctrl;
            reg_addr_21 <= dd;
            case({s_31,s_21,s1,s2})
            4'b0000: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            4'b0010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                s1 <= 0;
                reg_addr1 <= 0;
                dd_val1 <= 0;
            end
            4'b0011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                s2 <= 0;
                reg_addr2 <= 0;
                dd_val2 <= 0;
            end
            4'b0100: begin
                reg_addr <= reg_addr_21;
                dd_val <= fadd_y;
            end
            4'b0110: begin
                reg_addr <= reg_addr1;
                dd_val1 <= dd_val1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
            end
            4'b0111: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= reg_addr_21;
                dd_val2 <= fadd_y;
            end
            4'b1000: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl_31[0]) ? fsqrt_y: fdiv_y;
            end
            4'b1010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl_31[0]) ? fsqrt_y: fdiv_y; 
            end
            4'b1011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= reg_addr_31;
                dd_val2 <= (ctrl_31[0]) ? fsqrt_y: fdiv_y;
            end
            4'b1100: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl_31[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= reg_addr_21;
                dd_val <= fadd_y;
            end
            4'b1110: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl_31[0]) ? fsqrt_y: fdiv_y;
                s2 <= 1;
                reg_addr2 <= reg_addr_21;
                dd_val2 <= fadd_y;
            end
            default: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            endcase
        end
        // fsub
        4'd2: begin
            s_32 <= 0;
            ctrl_32 <= 0;
            reg_addr_32 <= 0;
            s_31 <= s_32;
            ctrl_31 <= ctrl_32;
            reg_addr_31 <= reg_addr_32;
            s_21 <= 1;
            ctrl_21 <= ctrl;
            reg_addr_21 <= dd;
            case({s_31,s_21,s1,s2})
            4'b0000: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            4'b0010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                s1 <= 0;
                reg_addr1 <= 0;
                dd_val1 <= 0;
            end
            4'b0011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                s2 <= 0;
                reg_addr2 <= 0;
                dd_val2 <= 0;
            end
            4'b0100: begin
                reg_addr <= reg_addr_21;
                dd_val <= fadd_y;
            end
            4'b0110: begin
                reg_addr <= reg_addr1;
                dd_val1 <= dd_val1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
            end
            4'b0111: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= reg_addr_21;
                dd_val2 <= fadd_y;
            end
            4'b1000: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl_31[0]) ? fsqrt_y: fdiv_y;
            end
            4'b1010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl_31[0]) ? fsqrt_y: fdiv_y; 
            end
            4'b1011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= reg_addr_31;
                dd_val2 <= (ctrl_31[0]) ? fsqrt_y: fdiv_y;
            end
            4'b1100: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl_31[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= reg_addr_21;
                dd_val <= fadd_y;
            end
            4'b1110: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl_31[0]) ? fsqrt_y: fdiv_y;
                s2 <= 1;
                reg_addr2 <= reg_addr_21;
                dd_val2 <= fadd_y;
            end
            default: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            endcase
        end


        // 3stage の命令
        // fdiv
        4'd4: begin
            s_32 <= 1;
            ctrl_32 <= ctrl;
            reg_addr_32 <= dd;
            s_31 <= s_32;
            ctrl_31 <= ctrl_32;
            reg_addr_31 <= reg_addr_32;
            s_21 <= 0;
            ctrl_21 <= 0;
            reg_addr_21 <= 0;
            case({s_31,s_21,s1,s2})
            4'b0000: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            4'b0010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                s1 <= 0;
                reg_addr1 <= 0;
                dd_val1 <= 0;
            end
            4'b0011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                s2 <= 0;
                reg_addr2 <= 0;
                dd_val2 <= 0;
            end
            4'b0100: begin
                reg_addr <= reg_addr_21;
                dd_val <= fadd_y;
            end
            4'b0110: begin
                reg_addr <= reg_addr1;
                dd_val1 <= dd_val1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
            end
            4'b0111: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= reg_addr_21;
                dd_val2 <= fadd_y;
            end
            4'b1000: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl_31[0]) ? fsqrt_y: fdiv_y;
            end
            4'b1010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl_31[0]) ? fsqrt_y: fdiv_y; 
            end
            4'b1011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= reg_addr_31;
                dd_val2 <= (ctrl_31[0]) ? fsqrt_y: fdiv_y;
            end
            4'b1100: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl_31[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= reg_addr_21;
                dd_val <= fadd_y;
            end
            4'b1110: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl_31[0]) ? fsqrt_y: fdiv_y;
                s2 <= 1;
                reg_addr2 <= reg_addr_21;
                dd_val2 <= fadd_y;
            end
            default: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            endcase
        end

        // fsqrt
        4'd5: begin
            s_32 <= 1;
            ctrl_32 <= ctrl;
            reg_addr_32 <= dd;
            s_31 <= s_32;
            ctrl_31 <= ctrl_32;
            reg_addr_31 <= reg_addr_32;
            s_21 <= 0;
            ctrl_21 <= 0;
            reg_addr_21 <= 0;
            case({s_31,s_21,s1,s2})
            4'b0000: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            4'b0010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                s1 <= 0;
                reg_addr1 <= 0;
                dd_val1 <= 0;
            end
            4'b0011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                s2 <= 0;
                reg_addr2 <= 0;
                dd_val2 <= 0;
            end
            4'b0100: begin
                reg_addr <= reg_addr_21;
                dd_val <= fadd_y;
            end
            4'b0110: begin
                reg_addr <= reg_addr1;
                dd_val1 <= dd_val1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
            end
            4'b0111: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= reg_addr_21;
                dd_val2 <= fadd_y;
            end
            4'b1000: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl_31[0]) ? fsqrt_y: fdiv_y;
            end
            4'b1010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl_31[0]) ? fsqrt_y: fdiv_y; 
            end
            4'b1011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= reg_addr_31;
                dd_val2 <= (ctrl_31[0]) ? fsqrt_y: fdiv_y;
            end
            4'b1100: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl_31[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= reg_addr_21;
                dd_val <= fadd_y;
            end
            4'b1110: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl_31[0]) ? fsqrt_y: fdiv_y;
                s2 <= 1;
                reg_addr2 <= reg_addr_21;
                dd_val2 <= fadd_y;
            end
            default: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            endcase
        end

        // 1stage の命令
        // fmul
        4'd3: begin
            s_32 <= 0;
            ctrl_32 <= 0;
            reg_addr_32 <= 0;
            s_31 <= s_32;
            ctrl_31 <= ctrl_32;
            reg_addr_31 <= reg_addr_32;
            s_21 <= 0;
            ctrl_21 <= 0;
            reg_addr_21 <= 0;
            case({s_31,s_21,s1,s2})
            4'b0000: begin
                reg_addr <= dd;
                dd_val <= fmul_y;
            end
            4'b0010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= dd;
                dd_val1 <= fmul_y;
            end
            4'b0011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= dd;
                dd_val2 <= fmul_y;
            end
            4'b0100: begin
                reg_addr <= reg_addr_21;
                dd_val <= fadd_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= fmul_y;
            end
            4'b0110: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= fmul_y;
            end
            4'b1000: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= fmul_y;
            end
            4'b1010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= fmul_y;
            end
            4'b1100: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= fmul_y;
            end
            default: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            endcase
        end
        // feq
        4'd6: begin
            s_32 <= 0;
            ctrl_32 <= 0;
            reg_addr_32 <= 0;
            s_31 <= s_32;
            ctrl_31 <= ctrl_32;
            reg_addr_31 <= reg_addr_32;
            s_21 <= 0;
            ctrl_21 <= 0;
            reg_addr_21 <= 0;
            case({s_31,s_21,s1,s2})
            4'b0000: begin
                reg_addr <= dd;
                dd_val <= feq_y;
            end
            4'b0010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= dd;
                dd_val1 <= feq_y;
            end
            4'b0011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= dd;
                dd_val2 <= feq_y;
            end
            4'b0100: begin
                reg_addr <= reg_addr_21;
                dd_val <= fadd_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= feq_y;
            end
            4'b0110: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= feq_y;
            end
            4'b1000: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= feq_y;
            end
            4'b1010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= feq_y;
            end
            4'b1100: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= feq_y;
            end
            default: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            endcase
        end
        // flt
        4'd7: begin
            s_32 <= 0;
            ctrl_32 <= 0;
            reg_addr_32 <= 0;
            s_31 <= s_32;
            ctrl_31 <= ctrl_32;
            reg_addr_31 <= reg_addr_32;
            s_21 <= 0;
            ctrl_21 <= 0;
            reg_addr_21 <= 0;
            case({s_31,s_21,s1,s2})
            4'b0000: begin
                reg_addr <= dd;
                dd_val <= flt_y;
            end
            4'b0010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= dd;
                dd_val1 <= flt_y;
            end
            4'b0011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= dd;
                dd_val2 <= flt_y;
            end
            4'b0100: begin
                reg_addr <= reg_addr_21;
                dd_val <= fadd_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= flt_y;
            end
            4'b0110: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= flt_y;
            end
            4'b1000: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= flt_y;
            end
            4'b1010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= flt_y;
            end
            4'b1100: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= flt_y;
            end
            default: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            endcase
        end
        // fle
        4'd8: begin
            s_32 <= 0;
            ctrl_32 <= 0;
            reg_addr_32 <= 0;
            s_31 <= s_32;
            ctrl_31 <= ctrl_32;
            reg_addr_31 <= reg_addr_32;
            s_21 <= 0;
            ctrl_21 <= 0;
            reg_addr_21 <= 0;
            case({s_31,s_21,s1,s2})
            4'b0000: begin
                reg_addr <= dd;
                dd_val <= fle_y;
            end
            4'b0010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= dd;
                dd_val1 <= fle_y;
            end
            4'b0011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= dd;
                dd_val2 <= fle_y;
            end
            4'b0100: begin
                reg_addr <= reg_addr_21;
                dd_val <= fadd_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= fle_y;
            end
            4'b0110: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= fle_y;
            end
            4'b1000: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= fle_y;
            end
            4'b1010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= fle_y;
            end
            4'b1100: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= fle_y;
            end
            default: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            endcase
        end
        // ftoi
        4'd9: begin
            s_32 <= 0;
            ctrl_32 <= 0;
            reg_addr_32 <= 0;
            s_31 <= s_32;
            ctrl_31 <= ctrl_32;
            reg_addr_31 <= reg_addr_32;
            s_21 <= 0;
            ctrl_21 <= 0;
            reg_addr_21 <= 0;
            case({s_31,s_21,s1,s2})
            4'b0000: begin
                reg_addr <= dd;
                dd_val <= ftoi_y;
            end
            4'b0010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= dd;
                dd_val1 <= ftoi_y;
            end
            4'b0011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= dd;
                dd_val2 <= ftoi_y;
            end
            4'b0100: begin
                reg_addr <= reg_addr_21;
                dd_val <= fadd_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= ftoi_y;
            end
            4'b0110: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= ftoi_y;
            end
            4'b1000: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= ftoi_y;
            end
            4'b1010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= ftoi_y;
            end
            4'b1100: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= ftoi_y;
            end
            default: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            endcase
        end
        // itof
        4'd10: begin
            s_32 <= 0;
            ctrl_32 <= 0;
            reg_addr_32 <= 0;
            s_31 <= s_32;
            ctrl_31 <= ctrl_32;
            reg_addr_31 <= reg_addr_32;
            s_21 <= 0;
            ctrl_21 <= 0;
            reg_addr_21 <= 0;
            case({s_31,s_21,s1,s2})
            4'b0000: begin
                reg_addr <= dd;
                dd_val <= itof_y;
            end
            4'b0010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= dd;
                dd_val1 <= itof_y;
            end
            4'b0011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= dd;
                dd_val2 <= itof_y;
            end
            4'b0100: begin
                reg_addr <= reg_addr_21;
                dd_val <= fadd_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= itof_y;
            end
            4'b0110: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= itof_y;
            end
            4'b1000: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= itof_y;
            end
            4'b1010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= itof_y;
            end
            4'b1100: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= itof_y;
            end
            default: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            endcase
        end
        // fneg
        4'd11: begin
            s_32 <= 0;
            ctrl_32 <= 0;
            reg_addr_32 <= 0;
            s_31 <= s_32;
            ctrl_31 <= ctrl_32;
            reg_addr_31 <= reg_addr_32;
            s_21 <= 0;
            ctrl_21 <= 0;
            reg_addr_21 <= 0;
            case({s_31,s_21,s1,s2})
            4'b0000: begin
                reg_addr <= dd;
                dd_val <= fneg_y;
            end
            4'b0010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= dd;
                dd_val1 <= fneg_y;
            end
            4'b0011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= dd;
                dd_val2 <= fneg_y;
            end
            4'b0100: begin
                reg_addr <= reg_addr_21;
                dd_val <= fadd_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= fneg_y;
            end
            4'b0110: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= fneg_y;
            end
            4'b1000: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= fneg_y;
            end
            4'b1010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= fneg_y;
            end
            4'b1100: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= fneg_y;
            end
            default: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            endcase
        end
        // fmvfr
        4'd12: begin
            s_32 <= 0;
            ctrl_32 <= 0;
            reg_addr_32 <= 0;
            s_31 <= s_32;
            ctrl_31 <= ctrl_32;
            reg_addr_31 <= reg_addr_32;
            s_21 <= 0;
            ctrl_21 <= 0;
            reg_addr_21 <= 0;
            case({s_31,s_21,s1,s2})
            4'b0000: begin
                reg_addr <= dd;
                dd_val <= ds_val;
            end
            4'b0010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= dd;
                dd_val1 <= ds_val;
            end
            4'b0011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= dd;
                dd_val2 <= ds_val;
            end
            4'b0100: begin
                reg_addr <= reg_addr_21;
                dd_val <= fadd_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= ds_val;
            end
            4'b0110: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= ds_val;
            end
            4'b1000: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= ds_val;
            end
            4'b1010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= ds_val;
            end
            4'b1100: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= ds_val;
            end
            default: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            endcase
        end
        // fmvtr
        4'd13: begin
            s_32 <= 0;
            ctrl_32 <= 0;
            reg_addr_32 <= 0;
            s_31 <= s_32;
            ctrl_31 <= ctrl_32;
            reg_addr_31 <= reg_addr_32;
            s_21 <= 0;
            ctrl_21 <= 0;
            reg_addr_21 <= 0;
            case({s_31,s_21,s1,s2})
            4'b0000: begin
                reg_addr <= dd;
                dd_val <= ds_val;
            end
            4'b0010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= dd;
                dd_val1 <= ds_val;
            end
            4'b0011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= dd;
                dd_val2 <= ds_val;
            end
            4'b0100: begin
                reg_addr <= reg_addr_21;
                dd_val <= fadd_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= ds_val;
            end
            4'b0110: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= ds_val;
            end
            4'b1000: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= ds_val;
            end
            4'b1010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= ds_val;
            end
            4'b1100: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= ds_val;
            end
            default: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            endcase
        end
         // fmvfr
        4'd14: begin
            s_32 <= 0;
            ctrl_32 <= 0;
            reg_addr_32 <= 0;
            s_31 <= s_32;
            ctrl_31 <= ctrl_32;
            reg_addr_31 <= reg_addr_32;
            s_21 <= 0;
            ctrl_21 <= 0;
            reg_addr_21 <= 0;
            case({s_31,s_21,s1,s2})
            4'b0000: begin
                reg_addr <= dd;
                dd_val <= flup_y;
            end
            4'b0010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= dd;
                dd_val1 <= flup_y;
            end
            4'b0011: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr2;
                dd_val1 <= dd_val2;
                reg_addr2 <= dd;
                dd_val2 <= flup_y;
            end
            4'b0100: begin
                reg_addr <= reg_addr_21;
                dd_val <= fadd_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= flup_y;
            end
            4'b0110: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= flup_y;
            end
            4'b1000: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= dd;
                dd_val1 <= flup_y;
            end
            4'b1010: begin
                reg_addr <= reg_addr1;
                dd_val <= dd_val1;
                reg_addr1 <= reg_addr_31;
                dd_val1 <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= flup_y;
            end
            4'b1100: begin
                reg_addr <= reg_addr_31;
                dd_val <= (ctrl[0]) ? fsqrt_y: fdiv_y;
                s1 <= 1;
                reg_addr1 <= reg_addr_21;
                dd_val1 <= fadd_y;
                s2 <= 1;
                reg_addr2 <= dd;
                dd_val2 <= flup_y;
            end
            default: begin
                reg_addr <= 0;
                dd_val <= 0;
            end
            endcase
        end
        endcase
    end

endmodule
