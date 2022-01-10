module max(in0, in1, out);
  input  signed [11:0] in0, in1;
  output reg signed [11:0] out;

  always@ (*) begin
    out = (in0 >= in1) ? in0 : in1;
  end
endmodule

module unsigned_max(in0, in1, out);
  input  [11:0] in0, in1;
  output reg [11:0] out;

  always@ (*) begin
    out = (in0 >= in1) ? in0 : in1;
  end
endmodule