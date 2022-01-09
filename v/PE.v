// `include "max.v"
module PE(
    clk, rst, 
    s_in, t_in, max_in, v_in, f_in, valid_in,
    t_out, max_out, v_out, f_out, valid_out
);
input         clk, rst, valid_in;
input  [ 1:0] s_in, t_in;
input  [11:0] max_in, v_in, f_in;
output        valid_out;
output [ 1:0] t_out;
output [11:0] max_out, v_out, f_out;

parameter IDLE = 1'b0;
parameter BUSY = 1'b1;
parameter INVALID = 1'b0;
parameter VALID = 1'b1;
parameter MATCH_SCORE = 12'd8;     // pos
parameter MISMATCH_SCORE = 12'd5;  // neg
parameter OPEN_SCORE = -12'd7;      // neg
parameter EXTENSION_SCORE = -12'd3; // neg
parameter NINF = 12'b111000000000;

//------------------------------------------------------------------
// reg & wire
reg         next_valid_out;
reg         state, next_state;
reg  [ 1:0] t_out, s_value, next_s_value;
reg  [11:0] v_diag, next_v_diag;
reg  [11:0] v_out, next_v_out;
reg  signed [11:0] f_out, next_f_out;
reg  signed [11:0] e_out, next_e_out;
reg  [11:0] max_out, next_max_out;
wire [11:0] candidate_0;
wire signed [11:0] result_00, result_01, result_10, result_11;

wire [ 1:0] s_LUT_in;
wire [11:0] max_out_0, max_out_1, max_out_2, max_out_3, max_out_4, max_out_5;
wire valid_out;

assign valid_out = next_valid_out;

assign s_LUT_in = (valid_in == VALID && state == IDLE) ? s_in : s_value;
assign result_00 = e_out + EXTENSION_SCORE;
assign result_01 = v_out + OPEN_SCORE;
assign result_10 = f_in + EXTENSION_SCORE;
assign result_11 = v_in + OPEN_SCORE;

initial begin
    v_diag = 12'b0;
end
//------------------------------------------------------------------
// combinational part

LUT lut(
    .s(s_LUT_in),
    .t(t_in),
    .v_diag(v_diag),
    .out(candidate_0)
);

max max00(
    .in0 (max_in),
    .in1 (v_out),
    .out (max_out_0)
);

max max01(
    .in0 (max_out_0),
    .in1 (max_out),
    .out (max_out_1)
);

max max02(
    .in0 (result_00),
    .in1 (result_01),
    .out (max_out_2)
);

max max03(
    .in0 (result_10),
    .in1 (result_11),
    .out (max_out_3)
);

max max_04(
    .in0 (next_e_out),
    .in1 (next_f_out),
    .out (max_out_4)
);

max max_05(
    .in0 (candidate_0),
    .in1 (max_out_4),
    .out (max_out_5)
);

always@ (*) begin
    next_state = valid_in;
    next_v_diag = valid_in ? v_in : 12'd0;
    next_v_out = valid_in ? max_out_5 : 12'd0;
    next_f_out = valid_in ? max_out_3 : 12'd0;
    next_e_out = valid_in ? max_out_2 : 12'd0;
    next_max_out = valid_in ? max_out_1 : 12'd0;
    next_s_value = s_value;

    if (valid_in & !state) begin
        next_s_value = s_in;
        next_e_out = NINF; // for E[*, 0] = -inf
    end
end

//------------------------------------------------------------------
// sequential part

always@ ( posedge clk or posedge rst ) begin
    if (rst) begin
        next_valid_out <= INVALID;
        state <= IDLE;
        t_out <= 2'd0;
        s_value <= 2'd0;
        v_diag <= 12'd0;
        v_out  <= 12'd0;
        f_out <= 12'd0;
        e_out <= 12'd0;
        max_out <= 12'd0;
    end
    else begin
        next_valid_out <= valid_in;
        state <= next_state;
        t_out <= t_in;
        s_value <= next_s_value;
        v_diag <= next_v_diag;
        v_out <= next_v_out;
        f_out <= next_f_out;
        e_out <= next_e_out;
        max_out <= next_max_out;
    end
end
endmodule

module LUT (
    s, t, v_diag, out
);
input      [ 1:0] s, t;
input      [11:0] v_diag;
output reg [11:0] out;
parameter MATCH_SCORE = 12'd8;     // pos
parameter MISMATCH_SCORE = 12'd5;  // neg

always@ (*) begin
    if (s == t) begin
        out = v_diag + MATCH_SCORE;
    end
    else begin
        if (v_diag < MISMATCH_SCORE) out = 12'd0;
        else out = v_diag - MISMATCH_SCORE;
    end
end

endmodule