module register_unit (
    input logic reset,
    input logic clk,
    input logic [15:0] data_in,
    input logic [2:0] DR_reg,
    input logic [2:0] SR1_reg,
    input logic [2:0] SR2_reg,
    input logic ld_reg,
    
    output logic [15:0] SR1_OUT_reg,
    output logic [15:0] SR2_OUT_reg
);



    logic [15:0] reg_file[8];
    
    always_comb
    begin 
    
    SR1_OUT_reg = reg_file[SR1_reg];
    SR2_OUT_reg = reg_file[SR2_reg];
    
    end
    
    
    always_ff @(posedge clk) begin
    
    if (reset) begin
            // Reset all registers to 0
            for (int i = 0; i < 8; i++) begin
                reg_file[i] <= 16'b0;
            end
        end else if (ld_reg) 
        begin
            // Write data to the destination register
            reg_file[DR_reg] <= data_in;
        end
    end
    
endmodule 