module fir_filter (
    input clk,
    input signed [7:0] noisy_in,
    output reg signed [7:0] clean_out
);
    // Create an array of 8 registers (the "taps")
    reg signed [7:0] shift_reg [0:7];
    integer i;
    
    // Sum needs to be wider (12 bits) to prevent overflow when adding eight 8-bit numbers
    reg signed [11:0] sum; 

    // Shift data through the registers on every clock cycle
    always @(posedge clk) begin
        shift_reg[0] <= noisy_in;
        for (i = 1; i < 8; i = i + 1) begin
            shift_reg[i] <= shift_reg[i-1];
        end
    end

    // Combinational logic to calculate the sum of all 8 taps
    always @(*) begin
        sum = 0;
        for (i = 0; i < 8; i = i + 1) begin
            sum = sum + shift_reg[i];
        end
    end

    // Divide by 8 (using arithmetic bit shift right by 3) to get the average
    always @(posedge clk) begin
        clean_out <= sum >>> 3; 
    end
endmodule
