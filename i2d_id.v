/* i2d_id.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 *
 * i2d instruction decode module
 */

`include "i2d_defines.v"

module i2d_id(
	clk, rst,
	//input
	if_ins, if_pc, sr, id_dis,
	//output
	id_ins, id_pc, imm, rf_ra, rf_rb, rf_r, alu_op, id_err, swi, branch
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
output	[5:0]	rf_ra;
output	[5:0]	rf_rb;
output		rf_r;
output	[3:0]	alu_op;
output		id_err;
output		swi;
output		branch;

reg	[31:0]	id_ins;
reg	[31:0]	id_pc;
reg	[31:0]	imm;
reg	[5:0]	rf_ra;
reg	[5:0]	rf_rb;
reg		rf_r;
reg	[3:0]	alu_op;
reg		id_err;
reg		swi;
reg		branch;

//internal
reg		sel_imm_r;	//instruction have a register operand
reg		sel_imm_nr;	//instruction does not have a register operand
reg		sel_rf_ra;
reg		sel_rf_rb;

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


always @(posedge clk)
begin
	if (~id_dis)
		if (sel_imm_nr)
			imm <= {7{id_ins[25]}, id_ins[24:0]};
		if (sel_imm_r)
			imm <= {12{id_ins[20], id_ins[19:0]};
	else
		imm <= 0;
end

//decode imm
always @(id_ins)
begin
	case (id_ins[31:26])
		//ALU
		`I2D_INS_ADDI:
		`I2D_INS_ADDCI:
		`I2D_INS_SUBI:
		`I2D_INS_SUBCI:
		`I2D_INS_MULI:
		`I2D_INS_MULUI:
		`I2D_INS_DIVI:
		`I2D_INS_DIVUI:
		`I2D_INS_ANDI:
		`I2D_INS_ORI:
		`I2D_INS_RSLI:
		`I2D_INS_RSRI:
		`I2D_INS_ASLI:
		`I2D_INS_ASRI:
		//other
		`I2D_INS_MOVI:	sel_imm_r <= 1;
		//branch
		`I2D_INS_B:
		//OTHER
		`I2D_INS_CALL:	sel_imm_nr <= 1;		
		default:	sel_imm <= 0;
	endcase
end

//decode rf


	

endmodule

