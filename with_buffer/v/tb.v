`timescale 1ns/10ps
`define CLK_period 6.5               // Modify CLK period.

`define END_CYCLE 50000 // Modify your terminate cycle here

module tb;
reg CLK;
reg reset;
reg [1:0] pats_mem [0:255];
reg [1:0] patt_mem [0:255];
reg [11:0] exp_mem [0:1];
reg valid;
reg [1:0] data_s;
reg [1:0] data_t;
integer i;


wire finish;
wire [11:0] max;

reg flag; 

initial begin
   `ifdef tb1
     `define PATS "./dat/s1.dat"
     `define PATT "./dat/t1.dat"
     `define EXP "./dat/golden1.dat"
   `endif
   `ifdef tb2
     `define PATS "./dat/s2.dat"
     `define PATT "./dat/t2.dat"
     `define EXP "./dat/golden2.dat"
   `endif
   `ifdef SDFSYN
     $sdf_annotate("sw_syn.sdf", u_sw);
   `endif
   `ifdef SDFAPR
     $sdf_annotate("sw_APR.sdf", u_sw);
   `endif	 	 
   `ifdef FSDB
     $fsdbDumpfile("sw.fsdb");
	 $fsdbDumpvars();
	 //if you want to dump register array ex. reg [0:15] reg_arr [0:7] use $fsdbDumpvars(0, u_sw, "+mda") instead.
     //$fsdbDumpvars(0, u_sw, "+mda");
   `endif
   `ifdef VCD
     $dumpfile("sw.vcd");
	 $dumpvars();
   `endif
end

sw u_sw(.clk(CLK), .reset(reset), .valid(valid), .data_s(data_s), .data_t(data_t),
    .finish(finish), .max(max) ); 


initial $readmemh(`PATS, pats_mem);
initial $readmemh(`PATT, patt_mem);
initial $readmemh(`EXP, exp_mem);
initial $display("%s, %s and %s were used for this simulation.", `PATS, `PATT,  `EXP);   //

initial CLK = 1'b0;

always begin #(`CLK_period/2) CLK = ~CLK; end

initial begin
  #0 reset = 1'b0;
  #`CLK_period reset = 1'b1;
  #(`CLK_period*2) reset = 1'b0;
end

initial begin
  #0 valid = 1'b0;
     i = 0;
  #(`CLK_period*5);
  @(negedge CLK) valid = 1'b1;
  data_s = pats_mem[i];
  data_t = patt_mem[i];
  for (i=1;i<256;i=i+1) begin
    @(negedge CLK) begin 
    	data_s = pats_mem[i];
    	data_t = patt_mem[i];
    end
    //@(negedge CLK) data_t = patt_mem[i];
  end
  @(negedge CLK) valid = 1'b0;
       data_s = 2'b0;
       data_t = 2'b0;
end


always@(negedge CLK) begin
  if (reset) begin
    flag <= 1'b0;
  end 
  else begin

    if(finish == 1'b1) begin
      if (exp_mem[0] == max) begin    
        flag <= 1'b1;
        $display("=======================The test result is ..... PASS=========================");
        $display("\n");
        $display("        *************************************************              ");
        $display("        **                                             **      /|__/|");
        $display("        **             Congratulations !!              **     / O,O  \\");
        $display("        **                                             **    /_____   \\");
        $display("        **  All data have been generated successfully! **   /^ ^ ^ \\  |");
        $display("        **                                             **  |^ ^ ^ ^ |w|");
        $display("        *************************************************   \\m___m__|_|");
        $display("\n");
        $display("============================================================================");
        $finish;
      end else begin
      	$display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
        $display("---------- The test result is ..... FAIL -------------------\n");
        $display("            Simulation stop here.");
        $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
        $finish;
      end
    end
  end
end

initial begin 
	#(`CLK_period*`END_CYCLE);
	$display("================================================================================================================");
	$display("(/`n`)/ ~#  There is something wrong with your code!!"); 
	$display("Time out!! The simulation didn't finish after %d cycles!!, Please check it!!!", `END_CYCLE); 
	$display("================================================================================================================");
	$finish;
end

endmodule

