module counter (
    input wire clk,       // Clock input
    input wire reset,     // Active high reset
    output reg [3:0] count // 4-bit counter output
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            count <= 4'b0000; // Reset counter to 0
        else
            count <= count + 1; // Increment counter
    end
endmodule

`ifndef SYNTHESIS
module testbench;
    reg clk;
    reg reset;
    wire [3:0] count;

    counter uut (
        .clk(clk),
        .reset(reset),
        .count(count)
    );

    // Clock generation
    always #10 clk = ~clk;

    // Initialize signals
    initial begin
        clk = 0;
        reset = 1;
        #20 reset = 0;
        #200; // Let the simulation run for 200 time units
        $finish; // End the simulation
    end

    // Monitor signals
    initial begin
        $monitor("Time = %0t | Reset = %b | Count = %b", $time, reset, count);
    end

    // Dump waveforms
    initial begin
        $dumpfile("sample.vcd"); // Specify the name of the waveform file
        $dumpvars(0, testbench); // Dump all variables in the testbench
    end
endmodule
`endif
