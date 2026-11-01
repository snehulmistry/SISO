
`timescale 1ns/1ps

module shift_register_tb;

    reg clk;
    reg rst;
    reg serial_in;
    wire [3:0] q;

    shift_register uut (
        .clk(clk),
        .rst(rst),
        .serial_in(serial_in),
        .q(q)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        serial_in = 0;

	$dumpfile("sim/shift_register.vcd");
	$dumpvars(0, shift_register_tb);	

        // Reset check
        @(posedge clk);
        #1;
        if (q !== 4'b0000)
            $fatal(1, "Reset FAILED");

        rst = 0;

        // Shift in 1
        @(negedge clk); serial_in = 1;
        @(posedge clk); #1;
        if (q !== 4'b0001)
            $fatal(1, "Test 1 FAILED");

        // Shift in 0
        @(negedge clk); serial_in = 0;
        @(posedge clk); #1;
        if (q !== 4'b0010)
            $fatal(1, "Test 2 FAILED");

        // Shift in 1
        @(negedge clk); serial_in = 1;
        @(posedge clk); #1;
        if (q !== 4'b0101)
            $fatal(1, "Test 3 FAILED");

        // Shift in 1
        @(negedge clk); serial_in = 1;
        @(posedge clk); #1;
        if (q !== 4'b1011)
            $fatal(1, "Test 4 FAILED");

        $display("ALL TESTS PASSED!");
        $finish;
    end

endmodule

