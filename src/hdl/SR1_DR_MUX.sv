module SR1_DR_MUX (input logic [2:0] Din0,
                    input logic [2:0] Din1,
            input logic sel,
            output logic [2:0] Dout);
            
            always_comb
            begin
              if (sel == 1'b0)
                   Dout = Din0;
              else
                   Dout = Din1;
            end
endmodule
