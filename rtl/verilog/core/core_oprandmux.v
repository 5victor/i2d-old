/* core_oprandmux.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 * This code publish under GNU GPL License
 *
 * i2d xxx module
 */

`include "i2d_core_defines.v"

module core_oprandmux(
		rst, clk,
		//input
		ra, id_pc, rb, imm,
		//
		sel_a, sel_b,
		//output
		a, b
);
input		rst;
input		clk;
input	[31:0]	ra;
input	[31:0]	id_pc;
input	[31:0]	rb;
input	[31:0]	imm;
input	[1:0]	sel_a;
input	[1:0]	sel_b;

output	[31:0]	a;
output	[31:0]	b;

reg	[31:0]	a;
reg	[31:0]	b;

//internal reg
reg	[31:0]	toa;
reg	[31:0]	tob;

always @(posedge clk) begin
	if (~rst) begin
		a <= 0;
		b <= 0;
	end
	else begin
		a <= toa;
		b <= tob;
	end
end

always @(sel_a) begin
	case (sel_a)
	`I2D_OPMUX_A_RA:
		toa = ra;
	`I2D_OPMUX_A_ID_PC:
		toa = id_pc;
	default:
		toa = 0;
	endcase
end

always @(sel_b) begin
	case (sel_b)
	`I2D_OPMUX_B_RB:
		tob = rb;
	`I2D_OPMUX_B_ID_PC:
		tob = id_pc;
	`I2D_OPMUX_B_IMM:
		tob = imm;
	default:
		tob = 0;
	endcase
end

endmodule

