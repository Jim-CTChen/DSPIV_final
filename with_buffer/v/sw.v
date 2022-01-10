`include "PE_array.v"
`include "shift_rg.v"
`include "max.v"
module sw(clk, reset, valid, data_s, data_t, finish, max);

input clk;
input reset;
input valid;
input [1:0] data_t, data_s;
output finish;
output [11:0] max;

parameter INPUT_LENGTH = 256;
parameter PE_LENGTH = 128;
parameter MATCH_SCORE = 8;
parameter MISMATCH_SCORE = -5;
parameter OPEN_SCORE = -7;
parameter EXTENSION_SCORE = -3;

// STATE
parameter IDLE = 3'b000;
parameter FIRST = 3'b001;
parameter SECOND = 3'b010;
parameter THIRD = 3'b011;
parameter FOURTH = 3'b100;
parameter END = 3'b101;

//------------------------------------------------------------------
// reg & wire

reg  [ 1:0] s_in_buffer;

reg         valid_pe_in;
reg  [ 1:0] s_pe_in, t_pe_in;
reg  [11:0] max_pe_in = 12'd0;
reg  signed [11:0] f_pe_in = 12'b0;
reg  [11:0] v_pe_in = 12'd0;

reg  [ 2:0] state, next_state;
reg  [11:0] max, next_max, final_max, next_final_max;
reg         finish;
wire [11:0] max_final_out;

wire        valid_pe_out, valid_sr_out;
wire [ 1:0] s_pe_out, t_pe_out, s_sr_out, t_sr_out;
wire [11:0] max_pe_out, v_pe_out, f_pe_out, max_sr_out, v_sr_out, f_sr_out;

initial begin
  state = IDLE;
end

PE_array pe_array(
.clk(clk),
.rst(reset),
.valid_in(valid_pe_in),
.s_in(s_pe_in),
.t_in(t_pe_in),
.f_in(f_pe_in),
.max_in(max_pe_in),
.v_in(v_pe_in),
.t_out(t_pe_out),
.max_out(max_pe_out),
.v_out(v_pe_out),
.f_out(f_pe_out),
.valid_out(valid_pe_out)
);

sr shift_reg(
.clk(clk),
.rst(reset),
.s_in(s_in_buffer),
.t_in(t_pe_out),
.f_in(f_pe_out),
.max_in(max_pe_out),
.v_in(v_pe_out),
.valid_in(valid_pe_out),
.s_out(s_sr_out),
.t_out(t_sr_out),
.max_out(max_sr_out),
.v_out(v_sr_out),
.f_out(f_sr_out),
.valid_out(valid_sr_out)
);

unsigned_max max_final(
.in0(v_pe_out),
.in1(max_pe_out),
.out(max_final_out)
);


//------------------------------------------------------------------
// combinational part
always@(*) begin
  next_final_max = max_final_out;
  next_max = final_max;
	case (state)
    IDLE: begin
      if (valid) begin
        next_state = FIRST;
      end
      else next_state = IDLE;
    end
    FIRST: begin // PE.source = input
      if (!valid) begin // input end, 256th clk
        next_state = SECOND;
      end
      else next_state = FIRST;
    end
    SECOND: begin // PE.source = shift register
      if (!valid_pe_out)
        next_state = THIRD; // 256 + 128th clk,
      else next_state = SECOND;
    end
    THIRD: begin // PE.source = shift register
      if (valid_pe_out) // PE.reset
        next_state = FOURTH; // 256 + 129th clk
      else next_state = THIRD;
    end
    FOURTH: begin // PE.source = shift register
      if (!valid_pe_out)
        next_state = END; // 256 + 129 + 256th clk
      else next_state = FOURTH;
    end
    END: begin
      next_max = max;
      next_state = END;
    end
    default: begin
      next_state = IDLE;
    end
  endcase
end

//------------------------------------------------------------------
// sequential part
always@( posedge clk or posedge reset) begin
  if (reset) begin
    state <= IDLE;
    final_max <= 12'd0;
    max <= 12'd0;
    s_in_buffer <= 2'd0;

    valid_pe_in <= 0;
    s_pe_in <= 0;
    t_pe_in <= 0;
    f_pe_in <= 0;
    max_pe_in <= 0;
    v_pe_in <= 0;
  end
  else begin
    state <= next_state;
    final_max <= next_final_max;
    max <= next_max;
    s_in_buffer <= data_s;

    if (state == END) begin
      finish <= 1'b1;
    end
    else begin
      finish <= 1'b0;
    end
    if (state == IDLE || state == FIRST) begin
      valid_pe_in <= valid;
      s_pe_in <= data_s;
      t_pe_in <= data_t;
      f_pe_in <= OPEN_SCORE;
      max_pe_in <= 12'd0;
      v_pe_in <= 12'd0;
    end
    else if (state == SECOND || state == THIRD || state == FOURTH) begin
      valid_pe_in <= valid_sr_out;
      s_pe_in <= s_sr_out;
      t_pe_in <= t_sr_out;
      f_pe_in <= f_sr_out;
      max_pe_in <= max_sr_out;
      v_pe_in <= v_sr_out;
    end
    else begin
      valid_pe_in <= 0;
      s_pe_in <= 0;
      t_pe_in <= 0;
      f_pe_in <= 0;
      max_pe_in <= 0;
      v_pe_in <= 0;
    end
  end
end
    
endmodule


