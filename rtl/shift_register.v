module shift_register (
    input wire clk,
    input wire rst,
    input wire serial_in,
    output reg [3:0] q
);

    always @(posedge clk) begin
        if (rst)
            q <= 4'b0000;
        else
            q <= {q[2:0], serial_in};
    end

endmodule
