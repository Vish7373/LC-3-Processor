module BEN_to_control (
    input logic clk,
    input logic N , Z, P, ld_ben,
    input logic [2:0] ir_ben,
    output logic ben
);
    logic ben_in;
    always_comb
    begin
    
    ben_in = ((ir_ben[2] & N) | (ir_ben[1] & Z) | (ir_ben[0] & P));
    
    end

    always_ff @(posedge clk)
            begin
                  if (ld_ben == 1)begin
                  ben <= ben_in;
                  end
                  else begin
                  ben <= ben;
                  end
            end
endmodule


//module BEN_to_control (
//    input logic clk,           // Clock signal
//    input logic reset,         // Reset signal
//    input logic ld_ben,       // Load branch enable signal
//    input logic ld_cc,        // Load condition code signal
//    input logic [15:0] ir,    // Instruction register    // Data bus
//    output logic ben          // Branch enable output
//);

//    // Condition code registers
//    logic [2:0] nzp;          // Negative, zero, positive flags

//    // Sequential logic to load nzp based on ld_cc signal
//    always_ff @(posedge clk or posedge reset) begin
//        if (reset) begin
//            nzp <= 3'b000;      // Reset nzp to 0 (no flags set)
//        end else begin
//            nzp <= ir[11:9];    // Load bits IR[11:9] into nzp
//        end
//    end

//    // Combinational logic to determine the branch enable signal
//    always_comb begin
//        if (ld_ben) begin
//            // Output branch enable based on nzp flags
//            ben = (nzp != 3'b000); // Enable branch if nzp is not zero
//        end else begin
//            ben = 1'b0;            // Disable branch if ld_ben is low
//        end
//    end

//endmodule