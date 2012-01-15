/* i2d_id.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 *
 * i2d instruction decode module
 */

`include "i2d_core_defines.v"

module i2d_id(
	clk, rst,
	//input
	if_ins, if_pc, sr, id_dis,
	//output
	id_ins, id_pc, imm, rfa_addr, rfb_addr, rfa_r, rfb_r, alu_op, id_err,
	swi, branch, oprand_mux_a, oprand_mux_b
);

input		clk;
input		rst;
input	[31:0]	if_ins;
input	[31:0]	if_pc;
input	[31:0]	sr;
input		id_dis;

output	[31:0]	id_ins;
output	[31:0]	id_pc;
output	[31:0]	imm;
output	[5:0]	rfa_addr;
output	[5:0]	rfb_addr;
output		rfa_r;
output		rfb_r;
output	[3:0]	alu_op;
output		id_err;
output		swi;
output		branch;
output	[1:0]	oprand_mux_a;
output	[1:0]	oprand_mux_b;

reg	[31:0]	id_ins;
reg	[31:0]	id_pc;
reg	[31:0]	imm;
reg	[3:0]	rfa_addr;
reg	[3:0]	rfb_addr;
reg		rfa_r;
reg		rfb_r;
reg	[3:0]	alu_op;
//reg		id_err;
reg		swi;
reg		branch;
reg	[1:0]	oprand_mux_a;
reg	[1:0]	oprand_mux_b;

//internal
reg		sel_imm_16;	//16 bit imm
reg		sel_imm_22;	//22 bit imm
reg		imm_ext;	//imm sign extend
reg		oprand_ra_pc;	//oprand mux
reg		oprand_rb_pc;	//
reg		sel_rf_ra;
reg		sel_rf_rb;

//reg		sel_rf_swi;
//reg		sel_rf_ret;
//reg		sel_rf_rfe;

always @(posedge clk)
begin
	if (rst == 0)
	begin
		id_ins <= 0;
		id_pc <= 0;
	end
	else
	begin
		id_ins <= if_ins;
		id_pc <= if_pc;
	end
end


always @(imm_ext or sel_imm_16 or sel_imm_22)
begin
	if (~rst)
		imm <= 0;
	else
	begin
		if (~id_dis)
		begin
			if (imm_ext)
			begin
				if (sel_imm_16)
					imm <= {{17{id_ins[15]}}, id_ins[14:0]};
				else if (sel_imm_22)
					imm <= {{11{id_ins[21]}}, id_ins[20:0]};
				else
					imm <= 0;
			end
			else
			begin
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
end

//decode imm
always @(id_ins)
begin
	case (id_ins[31:26])
		//ALU
		`I2D_INS_ADDI,
		`I2D_INS_ADDCI,
		`I2D_INS_SUBI,
		`I2D_INS_SUBCI,
		`I2D_INS_MULI,
		`I2D_INS_DIVI,
		`I2D_INS_ANDI,
		`I2D_INS_ORI,
		`I2D_INS_MOVI,
		`I2D_INS_LD,
		`I2D_INS_ST:
		begin
			sel_imm_16 <= 1;
			sel_imm_22 <= 0;
			imm_ext <= 1;
		end
		//usigned
		`I2D_INS_MULUI,
		`I2D_INS_DIVUI,
		`I2D_INS_RSLI,
		`I2D_INS_RSRI,
		`I2D_INS_ASLI,
		`I2D_INS_ASRI:
		begin
			sel_imm_16 <= 1;
			sel_imm_22 <= 0;
			imm_ext <= 0;
		end
		//branch
		`I2D_INS_BI,
		//OTHER
		`I2D_INS_CALLI:
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

//decode rf
always @(sel_rf_ra or sel_rf_rb)
begin
	if (sel_rf_ra)
		if (if_ins[21:18] == `I2D_RF_PC)
		begin
			oprand_ra_pc <= 1;
			rfa_addr <= 0;
			rfa_r <= 0;
		end
		else
		begin
			oprand_ra_pc <= 0;
			rfa_addr <= if_ins[21:18];
			rfa_r <= 1;
		end
	else
	begin
		oprand_ra_pc <= 0;
		rfa_addr <= 0;
		rfa_r <= 0;
	end

	if (sel_rf_rb)
		if (if_ins[17:14] == `I2D_RF_PC)
		begin
			oprand_rb_pc <= 1;
			rfb_addr <= 0;
			rfb_r <= 0;
		end
		else
		begin
			oprand_rb_pc <= 0;
			rfb_addr <= if_ins[17:14];
			rfb_r <= 1;
		end
	else
	begin
		oprand_rb_pc <= 0;
		rfb_addr <= 0;
		rfb_r <= 0;
	end
end

always @(if_ins)
begin
	if (rst)
	begin
		sel_rf_ra <= 0;
		sel_rf_rb <= 0;
	end
	else
	case (if_ins[31:26])
		`I2D_INS_ADD,
		`I2D_INS_ADDC,
		`I2D_INS_SUB,
		`I2D_INS_SUBC,
		`I2D_INS_MUL,
		`I2D_INS_MULU,
		`I2D_INS_DIV,
		`I2D_INS_DIVU,
		`I2D_INS_AND,
		`I2D_INS_OR,
		`I2D_INS_RSL,
		`I2D_INS_ASL,
		`I2D_INS_ASR:
		//`I2D_INS_RETE:
		begin
			sel_rf_ra <= 1;
			sel_rf_rb <= 1;
		end
		`I2D_INS_NOT,
		`I2D_INS_B,
		`I2D_INS_CALL,
		`I2D_INS_MOV,
		`I2D_INS_ST,
		//
		`I2D_INS_RET,
		`I2D_INS_MRS:
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


//oprand mux

always @(sel_rf_ra or sel_rf_rb or sel_imm_16 or sel_imm_22 or oprand_ra_pc or oprand_rb_pc)
begin
	if (sel_rf_ra)
		oprand_mux_a <= `I2D_OPMUX_A_RA;
	else if (oprand_ra_pc)
		oprand_mux_a <= `I2D_OPMUX_A_ID_PC;
	else
		oprand_mux_a <= `I2D_OPMUX_A_NONE;

	if (sel_rf_rb)
		oprand_mux_b <= `I2D_OPMUX_B_RB;
	else if (oprand_rb_pc)
		oprand_mux_b <= `I2D_OPMUX_B_ID_PC;
	else if (sel_imm_16 | sel_imm_22)
		oprand_mux_b <= `I2D_OPMUX_B_IMM;
	else
		oprand_mux_b <= `I2D_OPMUX_B_NONE;

end

//decode aluop & id_err(illgel instruction)

assign id_err = alu_op == `I2D_ALUOP_ERR ? 1 : 0;

always @(id_ins)
begin
	if (~rst)
		alu_op <= `I2D_ALUOP_NONE;
	else
		case (id_ins[31:26])
			`I2D_INS_ADD,
			`I2D_INS_ADDI,
			`I2D_INS_LD,
			`I2D_INS_ST,
			`I2D_INS_B,
			`I2D_INS_BI,
			`I2D_INS_CALL,
			`I2D_INS_CALLI:
				alu_op <= `I2D_ALUOP_ADD;
			`I2D_INS_ADDC,
			`I2D_INS_ADDCI:
				alu_op <= `I2D_ALUOP_ADDC;
			`I2D_INS_SUB,
			`I2D_INS_SUBI:
				alu_op <= `I2D_ALUOP_SUB;
			`I2D_INS_SUBC,
			`I2D_INS_SUBCI:
				alu_op <= `I2D_ALUOP_SUBC;
			`I2D_INS_MUL,
			`I2D_INS_MULI:
				alu_op <= `I2D_ALUOP_MUL;
			`I2D_INS_MULU,
			`I2D_INS_MULUI:
				alu_op <= `I2D_ALUOP_MULU;
			`I2D_INS_DIV,
			`I2D_INS_DIVI:
				alu_op <= `I2D_ALUOP_DIV;
			`I2D_INS_DIVU,
			`I2D_INS_DIVUI:
				alu_op <= `I2D_ALUOP_DIVU;
			`I2D_INS_AND,
			`I2D_INS_ANDI:
				alu_op <= `I2D_ALUOP_AND;
			`I2D_INS_OR,
			`I2D_INS_ORI:
				alu_op <= `I2D_ALUOP_OR;
			`I2D_INS_NOT:
				alu_op <= `I2D_ALUOP_NOT;
			`I2D_INS_RSL,
			`I2D_INS_RSLI:
				alu_op <= `I2D_ALUOP_RSL;
			`I2D_INS_RSR,
			`I2D_INS_RSRI:
				alu_op <= `I2D_ALUOP_RSR;
			`I2D_INS_ASL,
			`I2D_INS_ASLI:
				alu_op <= `I2D_ALUOP_ASL;
			`I2D_INS_ASR,
			`I2D_INS_ASRI:
				alu_op <= `I2D_ALUOP_ASR;
			`I2D_INS_NOP,
			`I2D_INS_MOV,
			`I2D_INS_MOVI,
			`I2D_INS_SWI,
			`I2D_INS_RET,
			`I2D_INS_RFE,
			`I2D_INS_MSR,
			`I2D_INS_MRS:
				alu_op <= `I2D_ALUOP_NONE;
			default:
				alu_op <= `I2D_ALUOP_ERR;
		endcase
end

endmodule

