/* core_id.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 *
 * i2d instruction decode module
 *
 * TODO: swi
 */

`include "i2d_core_defines.v"

module core_id(
	clk, rst,
	//input
	if_ins, if_pc, sr, id_halt, id_flush, wb_addr,
	//output
	id_ins, id_pc, imm, rfa_addr, rfb_addr, alu_op, id_err,
	swi, branch, operand_mux_a, operand_mux_b, mau_op, mau_sel
);

input		clk;
input		rst;
input	[31:0]	if_ins;
input	[31:0]	if_pc;
input	[31:0]	sr;
input		id_halt;
input		id_flush;
input	[4:0]	wb_addr;

output	[31:0]	id_ins;
output	[31:0]	id_pc;
output	[31:0]	imm;
output	[5:0]	rfa_addr;
output	[5:0]	rfb_addr;
output	[3:0]	alu_op;
output		id_err;
output		swi;
output		branch;
output	[1:0]	operand_mux_a;
output	[1:0]	operand_mux_b;
output	[1:0]	mau_op;
output	[1:0]	mau_sel;

reg	[31:0]	id_ins;
reg	[31:0]	id_pc;
reg	[31:0]	imm;
reg	[3:0]	alu_op;
reg		swi;
reg		branch;
reg	[1:0]	operand_mux_a;
reg	[1:0]	operand_mux_b;
reg	[1:0]	mau_op;
reg	[1:0]	mau_sel;

//internal
reg		sel_imm_16;	//16 bit imm
reg		sel_imm_22;	//22 bit imm
reg		imm_ext;	//imm sign extend
reg		operand_ra_pc;	//operand mux
reg		operand_rb_pc;	//
reg		sel_rf_ra;
reg		sel_rf_rb;
reg		opcode_err;
reg		branch_code_err;
wire	[3:0]	branch_code;
wire		ra_wb_clash;
wire		rb_wb_clash;

assign		rfa_addr = id_ins[`CORE_INS_RA_MSB:`CORE_INS_RA_MSB-3];
assign		rfb_addr = id_ins[`CORE_INS_RB_MSB:`CORE_INS_RB_MSB-3];
assign		id_err = opcode_err | branch_code_err;
assign		branch_code = id_ins[31-`CORE_OPCODE_WIDTH:31-`CORE_OPCODE_WIDTH-3];
assign		ra_wb_clash = rfa_addr == wb_addr;
assign		rb_wb_clash = rfb_addr == wb_addr;

always @(posedge clk)
begin
	if (rst == 0) begin
		id_ins <= 0;
		id_pc <= 0;
	end
	else
		if (!id_halt) begin
			id_ins <= if_ins;
			id_pc <= if_pc;
		end
		else begin
			id_ins <= id_ins;
			id_pc <= id_pc;
		end
end


always @(imm_ext or sel_imm_16 or sel_imm_22)
begin
	if (~id_dis) begin
		if (imm_ext) begin
			if (sel_imm_16)
				imm <= {{17{id_ins[15]}}, id_ins[14:0]};
			else if (sel_imm_22)
				imm <= {{11{id_ins[21]}}, id_ins[20:0]};
			else
				imm <= 0;
		end
		else begin
			if (sel_imm_16)
				imm <= id_ins[15:0];
			else if (sel_imm_22)
				imm <= id_ins[21:0];
			else
				imm <= 0;
		end
	end
	else
		imm <= 0;
end

//decode imm
always @(id_ins)
begin
	case (id_ins[31:26])
		//ALU
		`CORE_OPCODE_ADDI,
		`CORE_OPCODE_ADDCI,
		`CORE_OPCODE_SUBI,
		`CORE_OPCODE_SUBCI,
		`CORE_OPCODE_MULI,
		`CORE_OPCODE_DIVI,
		`CORE_OPCODE_ANDI,
		`CORE_OPCODE_ORI,
		`CORE_OPCODE_MOVI,
		`CORE_OPCODE_LD,
		`CORE_OPCODE_ST:
		begin
			sel_imm_16 <= 1;
			sel_imm_22 <= 0;
			imm_ext <= 1;
		end
		//usigned
		`CORE_OPCODE_MULUI,
		`CORE_OPCODE_DIVUI,
		`CORE_OPCODE_RSLI,
		`CORE_OPCODE_RSRI,
		`CORE_OPCODE_ASLI,
		`CORE_OPCODE_ASRI:
		begin
			sel_imm_16 <= 1;
			sel_imm_22 <= 0;
			imm_ext <= 0;
		end
		//branch
		`CORE_OPCODE_BI,
		//OTHER
		`CORE_OPCODE_CALLI:
		begin
			sel_imm_16 <= 0;
			sel_imm_22 <= 1;
			imm_ext <= 1;
		end
		default:
			begin
			sel_imm_16 <= 0;
			sel_imm_22 <= 0;
			imm_ext <= 0;
			end
	endcase
end

//decode rf_addr = pc
always @(*)
begin
	if (rfa_addr == `CORE_RF_PC)
		operand_ra_pc = 1;
	else
		operand_ra_pc = 0;
	if (rfb_addr == `CORE_RF_PC)
		operand_rb_pc = 1;
	else
		operand_rb_pc = 0;
end

always @(id_ins)
begin
	case (id_ins[31:26])
		`CORE_OPCODE_ADD,
		`CORE_OPCODE_ADDC,
		`CORE_OPCODE_SUB,
		`CORE_OPCODE_SUBC,
		`CORE_OPCODE_MUL,
		`CORE_OPCODE_MULU,
		`CORE_OPCODE_DIV,
		`CORE_OPCODE_DIVU,
		`CORE_OPCODE_AND,
		`CORE_OPCODE_OR,
		`CORE_OPCODE_RSL,
		`CORE_OPCODE_ASL,
		`CORE_OPCODE_ASR:
		//`CORE_OPCODE_RETE:
		begin
			sel_rf_ra <= 1;
			sel_rf_rb <= 1;
		end
		`CORE_OPCODE_NOT,
		`CORE_OPCODE_B,
		`CORE_OPCODE_CALL,
		`CORE_OPCODE_MOV,
		`CORE_OPCODE_ST,
		//
		`CORE_OPCODE_RET,
		`CORE_OPCODE_MRS:
		begin
			sel_rf_ra <= 1;
			sel_rf_rb <= 0;
		end
		default:
		begin
			sel_rf_ra <= 0;
			sel_rf_rb <= 0;
		end
	endcase
end


//operand mux
always @(*)
begin
	if (sel_rf_ra)
		operand_mux_a = `CORE_OPMUX_A_RA;
	else if (operand_ra_pc)
		operand_mux_a = `CORE_OPMUX_A_PC;
	else if (ra_wb_clash)
		operand_mux_a = `CORE_OPMUX_A_WB;
	else
		operand_mux_a = `CORE_OPMUX_A_NONE;

	if (sel_rf_rb)
		operand_mux_b = `CORE_OPMUX_B_RB;
	else if (operand_rb_pc)
		operand_mux_b = `CORE_OPMUX_B_PC;
	else if (sel_imm_16 | sel_imm_22)
		operand_mux_b = `CORE_OPMUX_B_IMM;
	else if (rb_wb_clash)
		operand_mux_b = `CORE_OPMUX_B_WB;
	else
		operand_mux_b <= `CORE_OPMUX_B_NONE;
end

//decode aluop & opcode_err

always @(id_ins)
begin
opcode_err = 0;
case (id_ins[31:26])
	`CORE_OPCODE_ADD,
	`CORE_OPCODE_ADDI,
	`CORE_OPCODE_LD,
	`CORE_OPCODE_ST,
	`CORE_OPCODE_B,
	`CORE_OPCODE_BI,
	`CORE_OPCODE_CALL,
	`CORE_OPCODE_CALLI:
		alu_op <= `CORE_ALUOP_ADD;
	`CORE_OPCODE_ADDC,
	`CORE_OPCODE_ADDCI:
		alu_op <= `CORE_ALUOP_ADDC;
	`CORE_OPCODE_SUB,
	`CORE_OPCODE_SUBI:
		alu_op <= `CORE_ALUOP_SUB;
	`CORE_OPCODE_SUBC,
	`CORE_OPCODE_SUBCI:
		alu_op <= `CORE_ALUOP_SUBC;
	`CORE_OPCODE_MUL,
	`CORE_OPCODE_MULI:
		alu_op <= `CORE_ALUOP_MUL;
	`CORE_OPCODE_MULU,
	`CORE_OPCODE_MULUI:
		alu_op <= `CORE_ALUOP_MULU;
	`CORE_OPCODE_DIV,
	`CORE_OPCODE_DIVI:
		alu_op <= `CORE_ALUOP_DIV;
	`CORE_OPCODE_DIVU,
	`CORE_OPCODE_DIVUI:
		alu_op <= `CORE_ALUOP_DIVU;
	`CORE_OPCODE_AND,
	`CORE_OPCODE_ANDI:
		alu_op <= `CORE_ALUOP_AND;
	`CORE_OPCODE_OR,
	`CORE_OPCODE_ORI:
		alu_op <= `CORE_ALUOP_OR;
	`CORE_OPCODE_NOT:
		alu_op <= `CORE_ALUOP_NOT;
	`CORE_OPCODE_RSL,
	`CORE_OPCODE_RSLI:
		alu_op <= `CORE_ALUOP_RSL;
	`CORE_OPCODE_RSR,
	`CORE_OPCODE_RSRI:
		alu_op <= `CORE_ALUOP_RSR;
	`CORE_OPCODE_ASL,
	`CORE_OPCODE_ASLI:
		alu_op <= `CORE_ALUOP_ASL;
	`CORE_OPCODE_ASR,
	`CORE_OPCODE_ASRI:
		alu_op <= `CORE_ALUOP_ASR;
	`CORE_OPCODE_NOP,
	`CORE_OPCODE_MOV,
	`CORE_OPCODE_MOVI,
	`CORE_OPCODE_SWI,
	`CORE_OPCODE_RET,
	`CORE_OPCODE_RFE,
	`CORE_OPCODE_MSR,
	`CORE_OPCODE_MRS:
		alu_op <= `CORE_ALUOP_NONE;
	default: begin
		alu_op <= `CORE_ALUOP_ERR;
		opcode_err = 1;
	endcase
end

always @(id_ins)
begin
	branch = 0;
	branch_code_err = 0;
	case(brach_code)
		`CORE_BRANCH_B:
			branch = 1;
		`CORE_BRANCH_BE:
			if (sr[`CORE_SR_ZF])
				branch = 1;
		`CORE_BRANCH_BNE:
			if(sr[`CORE_SR_ZF])
				branch = 1;
		default:
			branch_code_err = 1;
	endcase
end

always @(id_ins)
begin
	case(id_ins[31:26])
		`CORE_OPCODE_LD: begin
			mau_op = `CORE_MAUOP_R;
			mau_sel = `CORE_MAUSEL_D;
		end
		`CORE_OPCODE_LDB: begin
			mau_op = `CORE_MAUOP_R;
			mau_sel = `CORE_MAUSEL_B;
		end
		`CORE_OPCODE_LDW: begin
			mau_op = `CORE_MAUOP_R;
			mau_sel = `CORE_MAUSEL_W;
		end
		`CORE_OPCODE_ST: begin
			mau_op = `CORE_MAUOP_W;
			mau_sel = `CORE_MAUSEL_D;
		end
		`CORE_OPCODE_STB: begin
			mau_op = `CORE_MAUOP_W;
			mau_sel = `CORE_MAUSEL_B;
		end
		`CORE_OPCODE_STW: begin
			mau_op = `CORE_MAUOP_W;
			mau_sel = `CORE_MAUSEL_W;
		end
		default: begin
			mau_op = `CORE_MAUOP_NONE;
			mau_sel = `CORE_MAUSEL_NONE;
		end
	endcase
end

endmodule

