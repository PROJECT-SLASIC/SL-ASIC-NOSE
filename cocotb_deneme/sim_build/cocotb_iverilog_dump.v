module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/dff.fst");
    $dumpvars(0, dff);
end
endmodule
