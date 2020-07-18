/**
 * Regular verilog testbench to be used by iverilog.
 * Compare results to verilator.
 */

`timescale 1ns/100ps

module pipelined_divider_tb();
    reg clock;

    reg input_valid;
    reg [5:0] input_tag;
    reg [divisor_width_tb - 1:0] divisor;
    reg signed [dividend_width_tb - 1:0] dividend;

    wire output_valid;
    wire [5:0] output_tag;
    wire [dividend_width_tb - 1:0] quotient;
    wire [dividend_width_tb - 1:0] remainder;

    parameter dividend_width_tb = 32, divisor_width_tb = 24;

    defparam divider.dividend_width = dividend_width_tb;
    defparam divider.divisor_width = divisor_width_tb;

    pipelined_divider divider(.clock(clock),

                              .input_valid(input_valid),
                              .input_tag(input_tag),
                              .divisor(divisor),
                              .dividend(dividend),

                              .output_valid(output_valid),
                              .output_tag(output_tag),
                              .quotient(quotient),
                              .remainder(remainder));

    always begin
        clock = 1'b0;
        #500;
        clock = 1'b1;
        #500;
    end

    wire err;
    assign err = (groundtruth_mem[output_tag] !== quotient) && output_valid;

    // store groundtruth results
    reg signed [dividend_width_tb - 1:0] groundtruth_mem [0:(2**6) - 1];
    wire signed [divisor_width_tb:0] divisor_sgx = {1'b0, divisor};
    always @(posedge clock) begin
        if (input_valid) begin
            groundtruth_mem[input_tag] <= dividend / divisor_sgx;
        end

        if (output_valid) begin
            if (err) begin
                $display("error dividing at time %t. expected %d got %d",
                         $time, groundtruth_mem[output_tag], quotient);
            end
        end
    end

    integer i;
    integer uniform_seed;
    localparam ntests = 100000;
    initial begin
        $dumpfile("pipelined_divider_tb.vcd");
        $dumpvars(0, pipelined_divider_tb);

        // zero out the divider's 'valid' tags.
        for (i = 0; i <= divider.stages; i = i + 1) begin
            divider.stage_valid[i] = 1'b0;
        end
        input_tag = 'h0;
        input_valid = 1'b0;

        @(posedge clock);
        @(posedge clock);
        for (i = 0; i < ntests; i = i + 1) begin
            @(posedge clock);

            input_tag = #1 input_tag + 'h1;
            input_valid = #1 1'b1;
            divisor = #1 $dist_uniform(uniform_seed, 1, (2**divisor_width_tb) - 1);
            dividend = #1 $urandom;
        end

        $finish;
    end
endmodule
