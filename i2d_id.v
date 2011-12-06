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
	if_ins, if_pc, sr, if_dis,
	//output
	id_ins, id_pc, imm, rf_ra, rf_rb, rf_r, alu_op, id_err, swi, branch
);

input		clk;
input		rst;
input	[31:0]	if_ins;
input	[31:0]	if_pc;
input	[31:0]	sr;
input		if_dis;

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
reg		sel_imm;

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
	if (sel_imm)
		imm <= {7{id_ins[25]},id_ins[24:0]};
end

always @(id_ins)
begin
	case (id_ins[31:26])
		
		default: sel_imm <= 0;
	endcase
end

endmodule



