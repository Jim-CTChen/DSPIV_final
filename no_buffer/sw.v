`include "PE_array.v"
`include "max.v"

module sw(
    clk,
    reset,
    valid,
    data_s,
    data_t,
    finish,
    max
);

input  clk;
input  reset;
input  valid;
input  [1:0] data_t, data_s;
output finish;
output [11:0] max;

parameter INPUT_LENGTH = 256;
parameter PE_LENGTH = 128;
parameter MATCH_SCORE = 8;
parameter MISMATCH_SCORE = -5;
parameter OPEN_SCORE = -7;
parameter EXTENSION_SCORE = -3;

// STATE
parameter IDLE = 3'd0;
parameter PROC = 3'd1;
parameter WAIT = 3'd2;
parameter END  = 3'd3;

//------------------------------------------------------------------
// reg & wire

reg  [1:0]  s_in, next_s_in;
reg  [1:0]  t_in, next_t_in;
reg         valid_in, next_valid_in;

reg  [ 2:0] state, next_state;
reg  [11:0] max, next_max, final_max, next_final_max;

wire [11:0] max_final_out;

wire        valid_pe_out, valid_sr_out;
wire [ 1:0] s_pe_out, t_pe_out, s_sr_out, t_sr_out;
wire [11:0] max_pe_out, v_pe_out, f_pe_out, max_sr_out, v_sr_out, f_sr_out;

reg  [15:0] counter, next_counter;

assign finish = (state == END);

PE_array pe_array(
    .clk(clk),
    .rst(reset),
    .valid_in(valid_in),
    .s_in(s_in),
    .t_in(t_in),
    .f_in(OPEN_SCORE),
    .max_in(0),
    .v_in(0),
    .t_out(t_pe_out),
    .max_out(max_pe_out),
    .v_out(v_pe_out),
    .f_out(f_pe_out),
    .valid_out(valid_pe_out)
);

unsigned_max max_final(
    .in0(v_pe_out),
    .in1(max_pe_out),
    .out(max_final_out)
);


//------------------------------------------------------------------
// combinational part
always @(*) begin
    next_s_in = data_s;
    next_t_in = data_t;
    next_valid_in = valid;
end

// counter
always @(*) begin
    if (state == PROC || (state == IDLE && valid)) begin
        next_counter = counter + 1;
    end
    else begin
        next_counter = counter;
    end
end

always@(*) begin
    next_final_max = max_final_out;
    next_max = max_final_out;
    case (state)
        IDLE: begin
            if (valid) begin // start input
                next_state = PROC;
            end
            else next_state = IDLE;
        end
        PROC: begin // PE.source = input
            if (counter == 256) begin // input 128 cycles + proc 128 cycles
                next_state = END;
            end
            else next_state = PROC;
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
    counter <= 0;
    final_max <= 12'd0;
    max <= 12'd0;
    s_in <= 0;
    t_in <= next_t_in;
    valid_in <= next_valid_in;
  end
  else begin
    state <= next_state;
    counter <= next_counter;
    final_max <= next_final_max;
    max <= next_max;
    s_in <= next_s_in;
    t_in <= next_t_in;
    valid_in <= next_valid_in;
  end
end
    
endmodule


