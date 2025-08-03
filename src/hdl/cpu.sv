//------------------------------------------------------------------------------
// Company:              UIUC ECE Dept.
// Engineer:             Stephen Kempf
//
// Create Date:    
// Design Name:    ECE 385 Given Code - SLC-3 core
// Module Name:    SLC3
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 09-22-2015
//    Revised 06-09-2020
//      Revised 03-02-2021
//    Xilinx vivado
//    Revised 07-25-2023
//    Revised 12-29-2023
//    Revised 09-25-2024
//------------------------------------------------------------------------------

module cpu (
    input   logic        clk,
    input   logic        reset,

    input   logic        run_i,
    input   logic        continue_i,
    output  logic [15:0] hex_display_debug,
    output  logic [15:0] led_o,
   
    input   logic [15:0] mem_rdata,
    output  logic [15:0] mem_wdata,
    output  logic [15:0] mem_addr,
    output  logic        mem_mem_ena,
    output  logic        mem_wr_ena
);


// Internal connections, follow the datapath block diagram and add the additional needed signals
logic ld_mar;
logic ld_mdr;
logic ld_ir;
logic ld_pc;
logic ld_led;
logic ld_reg;
logic ld_cc;
logic ld_ben;

logic gate_pc;
logic gate_mdr;
logic gate_alu;
logic gate_marmux;

logic mio_en;

logic [1:0] pcmux;
logic [1:0] ALUK;

logic  SR1_MUX_select;
logic  SR2_MUX_select;
logic  DR_MUX_select;
logic [1:0] ADDR2_MUX_select;
logic ADDR1_MUX_select;
logic [1:0] PCMUX_select;

logic [15:0] mar;
logic [15:0] mdr;
logic [15:0] ir;
logic [15:0] pc;
logic ben;


logic [15:0] Mioen_out;
logic [15:0] Muxbus_out;
logic [15:0] PCmux_out;
logic [15:0] ALU_MUX_OUT;
logic [2:0] SR1_MUX_out;
logic [15:0] SR2_MUX_out;
logic [2:0] DR_MUX_out;
logic [15:0] ADDR2_MUX_OUT;
logic [15:0] A_ALU;
logic [15:0] B_ALU;
logic [15:0] ADDR1_MUX_OUT;

logic [1:0] mux_bux_select;


logic [15:0]SR2_Reg_In;

assign mem_addr = mar;
assign mem_wdata = mdr;


// REGISTER UNIT DECLARAtion below

logic [15:0] reg_in_bus;
assign reg_in_bus = Muxbus_out;

logic [2:0] DR_reg_unit;
assign DR_reg_unit =  DR_MUX_out;

logic [2:0] SR1_reg_unit;
assign SR1_reg_unit =  SR1_MUX_out;

logic [2:0] SR2_reg_unit;
assign SR2_reg_unit = ir[2:0] ;

logic [15:0] SR1_OUT_reg_unit;
assign A_ALU = SR1_OUT_reg_unit;

logic [15:0] SR2_OUT_reg_unit;
assign SR2_Reg_In = SR2_OUT_reg_unit;

// ADDR1 DECLARATION

logic [15:0] ADDR1_from_SR1;
assign ADDR1_from_SR1 = SR1_OUT_reg_unit;

// NZP Logic

logic [15:0] BUS_TO_NZP;
assign BUS_TO_NZP = Muxbus_out;

logic N_out, Z_out, P_out;
logic N_in,Z_in, P_in;
assign N_in = N_out;
assign Z_in = Z_out;
assign P_in = P_out;

// State machine, you need to fill in the code here as well
// .* auto-infers module input/output connections which have the same name
// This can help visually condense modules with large instantiations,
// but can also lead to confusing code if used too commonly
control cpu_control (
    .*
);


assign led_o = ir;
assign hex_display_debug = ir;

load_reg #(.DATA_WIDTH(16)) ir_reg (
    .clk    (clk),
    .reset  (reset),

    .load   (ld_ir),
    .data_i (mdr),

    .data_q (ir)
);

load_reg #(.DATA_WIDTH(16)) pc_reg (
    .clk(clk),
    .reset(reset),

    .load(ld_pc),
    .data_i(PCmux_out),

    .data_q(pc)
);

logic [15:0] mar_in;
assign mar_in = Muxbus_out;

load_reg #(.DATA_WIDTH(16)) MAR_reg (
    .clk    (clk),
    .reset  (reset),

    .load   (ld_mar),
    .data_i (mar_in),

    .data_q (mar)
);

load_reg #(.DATA_WIDTH(16)) MDR_reg (
    .clk    (clk),
    .reset  (reset),

    .load   (ld_mdr),
    .data_i (Mioen_out),

    .data_q (mdr)
);

logic [15:0] mio_en_bus;
assign mio_en_bus = Muxbus_out;

mux2_1 MIOENmux(
     .sel  (mio_en),
     .Din0 (mio_en_bus),
     .Din1 (mem_rdata),
     .Dout (Mioen_out)
);

logic [15:0] PC_MUX_bus;
assign PC_MUX_bus = Muxbus_out;

mux4_1 PC_MUX(

    .sel (PCMUX_select),
    .Din0 (pc+1),
    .Din1 (ADDR2_MUX_OUT + ADDR1_MUX_OUT),
    .Din2 (PC_MUX_bus),
    .Din3 (16'b0),
    .Dout (PCmux_out)

);

always_comb
begin 
if(gate_marmux)
    begin
        Muxbus_out = ADDR2_MUX_OUT + ADDR1_MUX_OUT;
    end

else if(gate_pc)
    begin
        Muxbus_out = pc;
    end
else if(gate_alu)
    begin
        Muxbus_out = ALU_MUX_OUT;
    end
    
else if(gate_mdr)
    begin
        Muxbus_out = mdr;
    end
 
else 
    begin
        Muxbus_out = 16'b0;
    end

end

assign B_ALU = SR2_MUX_out;

mux4_1 ALU_MUX (

    .sel (ALUK),
    .Din0 (A_ALU + B_ALU),
    .Din1 (A_ALU & B_ALU),
    .Din2 (~A_ALU),
    .Din3 (A_ALU),
    .Dout (ALU_MUX_OUT)
);

SR1_DR_MUX SR1_Mux(

    .sel (SR1_MUX_select),
    .Din0 (ir[11:9]),
    .Din1 (ir[8:6]),
    .Dout (SR1_MUX_out)
);

SR1_DR_MUX DR_Mux(

    .sel (DR_MUX_select),
    .Din0 (ir[11:9]),
    .Din1 (3'b111),
    .Dout (DR_MUX_out)
);

//mux2_1 mar_mux (

//    .sel  (1'b1),
//    .Din0 ({8'b0 , ir[7:0]}),
//    .Din1 (mem_rdata),
//    .Dout (Mioen_out)
//);

mux4_1 ADDR2MUX(

    .sel  (ADDR2_MUX_select),
    .Din0 (16'b0),
    .Din1 ({{10{ir[5]}}, ir[5:0]}),   
    .Din2 ({{7{ir[8]}}, ir[8:0]}),
    .Din3 ({{6{ir[10]}}, ir[10:0]}),
    .Dout (ADDR2_MUX_OUT)
);


mux2_1 ADDR1MUX (
    .sel (ADDR1_MUX_select),
    .Din0 (pc),
    .Din1 (ADDR1_from_SR1), // ADD THE OUTPUT SR1 FROM THE REG FILE HERE. 
    .Dout (ADDR1_MUX_OUT)
);

mux2_1 SR2_MUX (
    .sel (SR2_MUX_select),
    .Din0 (SR2_Reg_In),
    .Din1 ({{12{ir[4]}}, ir[4:0]}),
    .Dout (SR2_MUX_out)
);



register_unit my_reg(
    
    .clk(clk),
    .reset (reset),
    .data_in (reg_in_bus),
    .DR_reg (DR_reg_unit),
    .SR1_reg(SR1_reg_unit),
    .SR2_reg(SR2_reg_unit),
    .ld_reg(ld_reg),
    .SR1_OUT_reg(SR1_OUT_reg_unit),
    .SR2_OUT_reg(SR2_OUT_reg_unit)
);

NZP nzp_control (

   .clk (clk),
   .reset (reset),
   .data_in (BUS_TO_NZP),
   .ld_cc (ld_cc),
   .N (N_out),
   .Z (Z_out) ,
   .P (P_out) 

);

BEN_to_control BEN_logic (

    
    .clk (clk),
    .ld_ben (ld_ben),
    .N (N_in),
    .Z (Z_in),
    .P (P_in),
    .ir_ben (ir[11:9]),
    .ben (ben)
);

endmodule