module fir_filter (
    input clk,
    input signed [7:0] noisy_in,
    output reg signed [7:0] clean_out
);
    // Buffer for the 8-tap delay line; stores the most recent 8 samples
    reg signed [7:0] shift_reg [0:7];
    integer i;
    
    // Internal accumulator: defined as 12-bit to safely handle the worst-case 
    // summation of eight 8-bit signed values without clipping or overflow.
    reg signed [11:0] sum; 

    // Data pipeline: Shifting samples through the register array on each clock edge
    always @(posedge clk) begin
        shift_reg[0] <= noisy_in;
        for (i = 1; i < 8; i = i + 1) begin
            shift_reg[i] <= shift_reg[i-1];
        end
    end

    // Real-time summation: Aggregating all current taps to calculate the window total
    always @(*) begin
        sum = 0;
        for (i = 0; i < 8; i = i + 1) begin
            sum = sum + shift_reg[i];
        end
    end

    // Normalization: Dividing the total by 8 via a 3-bit arithmetic right shift.
    // This provides a resource-efficient average for the final output.
    always @(posedge clk) begin
        clean_out <= sum >>> 3; 
    end
endmodule
