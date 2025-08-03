module testbench();

timeunit 1ns;
timeprecision 1ns;

 logic clk;
 logic reset;

 logic run_i;
 logic continue_i;
 logic [15:0] sw_i;

logic [15:0] led_o;
logic [7:0]  hex_seg_left;
logic [3:0]  hex_grid_left;
logic [7:0]  hex_seg_right;
logic [3:0]  hex_grid_right;

always begin: CLOCK_GENERATION
    #1 clk = ~clk;
end
   
initial begin: CLOCK_INITIALIZATION
    clk = 1;
end

processor_top processor_top(.*);

initial begin: TEST_VECTORS
        #10 reset <= 1;
        #10 reset <= 0; 
        sw_i <= 16'h0003;
        #50 run_i <= 1;
        #50 run_i <= 0;
        
//        sw_i <= 16'h0002;
        
        
//        #50 continue_i <=1;
//        #50 continue_i <=0;
        
//        #50 sw_i <= 16'h0004;
        
//        #50 continue_i <= 1;
//        #50 continue_i <= 0;
        
        
//        #50 continue_i <= 1;
//        #50 continue_i <= 0;
        
        
        #10 run_i <= 0;

//        #100 sw_i <= 16'h000a;
//        #100 sw_i <= 16'h000c;
//        #100 sw_i <= 16'h0006;
   
   
    $finish();
end

endmodule