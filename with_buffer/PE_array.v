`include "PE.v"
module PE_array(
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

parameter PE_LENGTH = 128;

wire        valid_outs [PE_LENGTH:0];
wire [ 1:0] t_outs     [PE_LENGTH:0];
wire [11:0] max_outs   [PE_LENGTH:0];
wire [11:0] v_outs     [PE_LENGTH:0];
wire [11:0] f_outs     [PE_LENGTH:0];

assign valid_outs[0] = valid_in;
assign t_outs[0] = t_in;
assign max_outs[0] = max_in;
assign v_outs[0] = v_in;
assign f_outs[0] = f_in;

assign valid_out = valid_outs[PE_LENGTH];
assign t_out = t_outs[PE_LENGTH];
assign max_out = max_outs[PE_LENGTH];
assign v_out = v_outs[PE_LENGTH];
assign f_out = f_outs[PE_LENGTH];

genvar i;
generate
  for (i = 1; i <= PE_LENGTH; i = i + 1) begin:pe_array
    PE pe(
      .clk(clk),
      .rst(rst),
      .s_in(s_in),
      .t_in(t_outs[i-1]),
      .f_in(f_outs[i-1]),
      .max_in(max_outs[i-1]),
      .v_in(v_outs[i-1]),
      .valid_in(valid_outs[i-1]),
      .t_out(t_outs[i]),
      .max_out(max_outs[i]),
      .v_out(v_outs[i]),
      .f_out(f_outs[i]),
      .valid_out(valid_outs[i])
    );
  end
endgenerate

endmodule