# 110-1 DSP in VLSI Final Project

## Smith Waterman implementation

## File structure
DSPIV/
    with_buffer/: 128PE array with 129 buffer, run 256x256 tb
        max.v: max module
        PE_array.v: PE array
        PE.v: PE
        shift_rg.v: shift register
        sw.v: top module
        synthesis.tcl: for synthesis
        tb.v: testbench
    no_buffer/: 128PE array without buffer, run 128x128 tb
        (same as with_buffer/)
    problem/: problem description for 109-1 special project
    dat/: data for tb

## Simulations
RTL
> cd with_buffer or no_buffer
> ncverilog tb.v sw.v +define+tb1 +define+FSDB +access+r