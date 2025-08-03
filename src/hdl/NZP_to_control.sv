module NZP ( 
    input logic clk,
    input logic reset, 
    input logic [15:0] data_in,
    input logic ld_cc,
    output logic N , Z , P
);

logic N_in , P_in , Z_in;
always_comb
begin

    if (data_in[15])
    begin 
        N_in=1;
        Z_in=0;
        P_in=0;
    end

    else if (data_in == 16'b0)
    begin

        N_in=0;
        Z_in=1;
        P_in=0;
    
    end

    else if (data_in[15] == 0)
    begin 

        N_in = 0;
        Z_in = 0;
        P_in = 1;

    end
    
    else 
    begin
    
    N_in = 0;
    Z_in = 0;
    P_in = 0;
    
    end
    

end

always_ff @(posedge clk or posedge reset)begin
            
            if (ld_cc == 1) begin
                N <= N_in;
                Z <= Z_in;
                P <= P_in;
            end
            
            else if (reset) 
            begin
            
            N <= 0;
            Z <= 0;
            P <= 0;
            
            end
            else begin 
                N <= N;
                Z <= Z;
                P <= P;
            end
            
            
            end
endmodule



