
module sr(
  clk, rst,
  s_in, t_in, max_in, v_in, f_in, valid_in,
  s_out, t_out, max_out, v_out, f_out, valid_out
);

input         clk, rst, valid_in;
input  [ 1:0] s_in, t_in;
input  [11:0] max_in, v_in, f_in;
output        valid_out;
output [ 1:0] s_out, t_out;
output [11:0] max_out, v_out, f_out;

parameter BUFFER_LENGTH = 129;

// STATE
parameter IDLE = 2'b00;
parameter BUSY = 2'b01;
parameter END = 2'b10;

reg  [ 1:0] state, next_state;
reg         valid_buffer [0:BUFFER_LENGTH-1];
reg  [ 1:0] s_buffer     [0:BUFFER_LENGTH-1];
reg  [ 1:0] t_buffer     [0:BUFFER_LENGTH-1];
reg  [11:0] max_buffer   [0:BUFFER_LENGTH-1];
reg  [11:0] f_buffer     [0:BUFFER_LENGTH-1];
reg  [11:0] v_buffer     [0:BUFFER_LENGTH-1];

integer i;
initial begin
  state = IDLE;
end

assign valid_out = valid_buffer[BUFFER_LENGTH-1];
assign s_out = s_buffer[BUFFER_LENGTH-1];
assign t_out = t_buffer[BUFFER_LENGTH-1];
assign max_out = max_buffer[BUFFER_LENGTH-1];
assign f_out = f_buffer[BUFFER_LENGTH-1];
assign v_out = v_buffer[BUFFER_LENGTH-1];

always@ (*) 
begin
  case(state)
    IDLE: begin
      if (valid_in)
        next_state = BUSY;
      else 
        next_state = IDLE;
    end
    BUSY: begin
      if (!valid_in) // stop shifting after register is full (128 data were received)
        next_state = END;
      else
        next_state = BUSY;
    end
    default:
      next_state = IDLE;
  endcase
end

integer idx;
always@ (posedge clk or posedge rst)
begin
  if (rst) begin
    state <= IDLE;
    for (idx = 0; idx < BUFFER_LENGTH; idx = idx + 1) begin
      valid_buffer[idx] <= 0;
      s_buffer[idx] <= 0;
      t_buffer[idx] <= 0;
      max_buffer[idx] <= 0;
      f_buffer[idx] <= 0;
      v_buffer[idx] <= 0;
    end
  end
  else begin
    state <= next_state;
    if (next_state == END) begin 
      valid_buffer[0] <= 0;
      s_buffer[0] <= 0;
      t_buffer[0] <= 0;
      max_buffer[0] <= 0;
      f_buffer[0] <= 0;
      v_buffer[0] <= 0;
    end
    else begin
      valid_buffer[0] <= valid_in;
      s_buffer[0] <= s_in;
      t_buffer[0] <= t_in;
      max_buffer[0] <= max_in;
      f_buffer[0] <= f_in;
      v_buffer[0] <= v_in;
    end

    for (idx = 1; idx < BUFFER_LENGTH; idx = idx + 1) begin
      valid_buffer[idx] <= valid_buffer[idx-1];
      s_buffer[idx] <= s_buffer[idx-1];
      t_buffer[idx] <= t_buffer[idx-1];
      max_buffer[idx] <= max_buffer[idx-1];
      f_buffer[idx] <= f_buffer[idx-1];
      v_buffer[idx] <= v_buffer[idx-1];
    end
  end
end

endmodule