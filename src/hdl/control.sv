//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Given Code - Incomplete ISDU for SLC-3
// Module Name:    Control - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//    Revised 07-25-2023
//    Xilinx Vivado
//	  Revised 12-29-2023
// 	  Spring 2024 Distribution
// 	  Revised 6-22-2024
//	  Summer 2024 Distribution
//	  Revised 9-27-2024
//	  Fall 2024 Distribution
//------------------------------------------------------------------------------

    module control (
	input logic			clk, 
	input logic			reset,

	input logic  [15:0]	ir,
	input logic			ben,

	input logic 		continue_i,
	input logic 		run_i,

	output logic		ld_mar,
	output logic		ld_mdr,
	output logic		ld_ir,
	output logic		ld_pc,
	output logic        ld_led,
	output logic        ld_reg,
	output logic        ld_ben,
	output logic        ld_cc,
	output logic        SR1_MUX_select,
	output logic        SR2_MUX_select,
	output logic        ADDR1_MUX_select,
	output logic        [1:0] ADDR2_MUX_select,
	output logic        DR_MUX_select,
	output logic        [1:0] ALUK,
	output logic        mio_en,
	output logic       [1:0] PCMUX_select,
						
	output logic		gate_pc,
	output logic		gate_mdr,
	output logic        gate_marmux,
	output logic        gate_alu,
	
	//You should add additional control signals according to the SLC-3 datapath design

	output logic		mem_mem_ena, // Mem Operation Enable
	output logic		mem_wr_ena  // Mem Write Enable
);

	enum logic [5:0] {
		halted, 
		pause_ir1,
		pause_ir2, 
		s_18, 
		s_33_1,
		s_33_2,
		s_33_3,
		s_35,
		s_32,
		s_1_add,
		s_5_and,
		s_9_not,
		s_6_ldr,
		s_25_1,
		s_25_2,
		s_25_3,
		s_27,
		s_7_str,
		s_23,
		s_16_1,
		s_16_2,
		s_16_3,
		s_0_br,
		s_22,
		s_12_jmp,
		s_4_jsr,
		s_21
	} state, state_nxt;   // Internal state logic


	always_ff @ (posedge clk)
	begin
		if (reset) 
			state <= halted;
		else 
			state <= state_nxt;
	end
   
	always_comb
	begin 
		
		// Default controls signal values so we don't have to set each signal
		// in each state case below (If we don't set all signals in each state,
		// we can create an inferred latch)
		ld_mar = 1'b0;
		ld_mdr = 1'b0;
		ld_ir = 1'b0;
		ld_pc = 1'b0;
		ld_led = 1'b0;
		ld_reg = 1'b0;
		ld_ben = 1'b0;
		ld_cc = 1'b0;
		
		gate_pc = 1'b0;
		gate_mdr = 1'b0;
		gate_marmux = 1'b0;
		gate_alu = 1'b0;
		
		SR1_MUX_select = 1'b0;
		SR2_MUX_select = 1'b0;
		ADDR1_MUX_select = 1'b0;
		ADDR2_MUX_select = 2'b0;
		ALUK = 2'b0;
		PCMUX_select = 2'b0;
		mio_en = 1'b1;
		DR_MUX_select = 1'b0;
		
		mem_mem_ena = 1'b0;
		mem_wr_ena = 1'b0;
		
		
	
		// Assign relevant control signals based on current state
		case (state)
			halted: ; 
			s_18 : 
				begin 
					gate_pc = 1'b1;
					ld_mar = 1'b1;
					PCMUX_select = 2'b00;
					ld_pc = 1'b1;
				end
			s_33_1, s_33_2, s_33_3 : //you may have to think about this as well to adapt to ram with wait-states
				begin
					mem_mem_ena = 1'b1;
					ld_mdr = 1'b1;
				end
			s_35 : 
				begin 
					gate_mdr = 1'b1;
					ld_ir = 1'b1;
				end
			pause_ir1: ld_led = 1'b1; 
			pause_ir2: ld_led = 1'b1; 
			// you need to finish the rest of state output logic..... 
			
			s_32 :
			  begin
			     ld_ben = 1'b1;
			  end
			  
			s_7_str :
			  begin
			     SR1_MUX_select = 1'b1;
			     ADDR1_MUX_select = 1'b1;
			     ADDR2_MUX_select = 2'b01;
			     gate_marmux = 1'b1;
			     ld_mar = 1'b1;
			  end
			  
			s_23:
			 begin
			     SR1_MUX_select = 1'b0;
			     gate_alu = 1'b1;
		         mio_en = 1'b0;
			     ALUK = 2'b11;
			     ld_mdr = 1'b1;
			  end   
			
			s_16_1 , s_16_2,  s_16_3:
			 begin
			     mem_wr_ena = 1'b1;
			     mem_mem_ena = 1'b1;	     
			 end
			 
		   s_1_add :
		      begin 
		          ld_reg = 1'b1;
		          ld_cc = 1'b1;
		          gate_alu = 1'b1;
		          DR_MUX_select = 1'b0;
		          SR1_MUX_select = 1'b1;
		          ALUK = 2'b00;
		          SR2_MUX_select = ir[5];
		      end
		      
		   s_5_and :
		      begin 
		          ld_reg = 1'b1;
		          ld_cc = 1'b1;
		          gate_alu = 1'b1;
		          DR_MUX_select = 1'b0;
		          SR1_MUX_select = 1'b1;
		          ALUK = 2'b01;
		          SR2_MUX_select = ir[5];
		      end
		   
		   s_9_not :
		      begin 
		          ld_reg = 1'b1;
		          ld_cc = 1'b1;
		          gate_alu = 1'b1;
		          DR_MUX_select = 1'b0;
		          SR1_MUX_select = 1'b1;
		          ALUK = 2'b10;
		      end
		      
		   s_0_br:
		      begin
		      end
		      
		  s_22: 
		      begin
		      ADDR1_MUX_select = 1'b0;
		      ADDR2_MUX_select = 2'b10;
		      PCMUX_select = 2'b01;
		      ld_pc = 1'b1;
		      end
		      
		  s_6_ldr:
		      begin
		         SR1_MUX_select = 1'b1;
			     ADDR1_MUX_select = 1'b1;
			     ADDR2_MUX_select = 2'b01;
			     gate_marmux = 1'b1;
			     ld_mar = 1'b1;
			 end
			 
		  s_25_1 , s_25_2:
		      begin
		          mem_mem_ena = 1'b1;
		      end
		      
		 s_25_3:
		      begin
		          mem_mem_ena = 1'b1;
		          ld_mdr = 1'b1;
		      end
		  
		  s_27:
		      begin
		      
		      ld_cc = 1'b1;
		      gate_mdr = 1'b1;
		      ld_reg = 1'b1;
		      
		      end
		 
		   s_12_jmp:
		      begin
		      SR1_MUX_select = 1'b1;
		      gate_alu = 1'b1;
		      ALUK = 2'b11;
		      PCMUX_select = 2'b10;;
		      ld_pc = 1'b1; 
		      end  
		  
		   s_4_jsr:
		      begin
		      ld_reg = 1'b1;
		      gate_pc = 1'b1;
		      DR_MUX_select = 1'b1;
		      end
		   
		   s_21:
		      begin
		      ADDR1_MUX_select = 1'b0;
		      ADDR2_MUX_select = 2'b11;
		      PCMUX_select = 2'b01;
		      ld_pc = 1'b1;
		      end
		          

			default : ;
		endcase
	end 


	always_comb
	begin
		// default next state is staying at current state
		state_nxt = state;

		unique case (state)
			halted : 
				if (run_i) 
					state_nxt = s_18;
			s_18 : 
				state_nxt = s_33_1; //notice that we usually have 'r' here, but you will need to add extra states instead 
			s_33_1 :                 //e.g. s_33_2, etc. how many? as a hint, note that the bram is synchronous, in addition, 
				state_nxt = s_33_2;   //it has an additional output register. 
			s_33_2 :
				state_nxt = s_33_3;
			s_33_3 : 
				state_nxt = s_35;
			s_35 : 
				state_nxt = s_32;
			// pause_ir1 and pause_ir2 are only for week 1 such that TAs can see 
			// the values in ir.
			pause_ir1 : 
				if (continue_i) 
					state_nxt = pause_ir2;
			pause_ir2 : 
				if (~continue_i)
					state_nxt = s_18;
			// you need to finish the rest of state transition logic.....
			
			s_32:
			    if (ir[15:12] == 4'b0001)
			    begin 
			     state_nxt = s_1_add;
			    end
			    
			    else if (ir[15:12] == 4'b0101)
			    begin
			     state_nxt = s_5_and;
			    end
			    
			    else if (ir[15:12] == 4'b1001)
			    begin
			     state_nxt = s_9_not;
			    end
			    
			    else if (ir[15:12] == 4'b0110)
			    begin
			     state_nxt = s_6_ldr;
			    end
			    
			    else if (ir[15:12] == 4'b0111)
			    begin
			     state_nxt = s_7_str;
			    end
			    
			    else if (ir[15:12] == 4'b0100)
			    begin
			     state_nxt = s_4_jsr;
			    end
			    
			    else if (ir[15:12] == 4'b1100)
			    begin
			     state_nxt = s_12_jmp;
			    end
			    
			    else if (ir[15:12] == 4'b0000)
			    begin
			     state_nxt = s_0_br;
			    end
			    
			    else if (ir[15:12] == 4'b1101)
			    begin
			     state_nxt = pause_ir1;
			    end
			    
			    else
			    begin
			     state_nxt = s_32;
			    end
			    
			s_1_add:
			     state_nxt = s_18;
			s_5_and:
			     state_nxt = s_18;
			s_9_not:              
			     state_nxt = s_18;
		    s_6_ldr:
		         state_nxt = s_25_1;
		    s_25_1:
		         state_nxt = s_25_2;
		    s_25_2:
		         state_nxt = s_25_3;
		    s_25_3:
		         state_nxt = s_27;
		    s_27:
		         state_nxt = s_18;
		    s_7_str:
		         state_nxt = s_23;
		    s_23:
		         state_nxt = s_16_1;
		   s_16_1:
		         state_nxt = s_16_2;
		   s_16_2:
		         state_nxt = s_16_3;
		    s_16_3:
		         state_nxt = s_18;
		    s_0_br:
		         if (ben)
		         begin
		           state_nxt = s_22;
		         end 
		         else 
		         begin
		           state_nxt = s_18;
		         end
		    s_22:
		         state_nxt = s_18;
		    s_12_jmp:
		         state_nxt = s_18;
		    s_4_jsr:
		         state_nxt = s_21;
		    s_21:
		         state_nxt = s_18;
			default :;
		endcase
	end
	
endmodule
