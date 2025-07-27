module cpu_tb;
  reg clk = 0;
  reg rst = 1;

  // Instantiate the CPU
  cpu uut(clk, rst);

  // Generate clock
  always #5 clk = ~clk;

  initial begin
    // Dump waveform
    $dumpfile("dump.vcd");
    $dumpvars(0, cpu_tb);

    // Reset the system
    #10 rst = 0;

    // Run simulation for some time
    #100 $finish;
  end
endmodule
