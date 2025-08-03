module muxbus (input logic [15:0] Din0,
                    input logic [15:0] Din1,
                    input logic [15:0] Din2,
                    input logic [15:0] Din3,
            input logic [1:0] sel,
            output logic [15:0] Dout);
            always_comb
            begin
              if (sel == 2'b00)
                   Dout = Din0;
              else if(sel == 2'b01)
                   Dout = Din1;
              else if(sel == 2'b10)
                   Dout = Din2;
              else if (sel == 2'b11)
                    Dout = Din3;
              else
                   Dout = 16'b0000000000000000;
            end
endmodule