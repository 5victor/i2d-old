/* core_alu.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 * This code publish under GNU GPL License
 *
 * i2d core alu module
 *
 * TODO: 1.mul 2.add of = of_i case after instruction flag not change
 */

`include "i2d_core_defines.v"

module core_alu(
	a, b, alu_op, cf_i, result, cf, of, zf
);
input	[31:0]	a;
input	[31:0]	b;
input	[3:0]	alu_op;
input		cf_i;
output	[31:0]	result;
output	cf;
output	of;
output	zf;
reg	[31:0]	result;
reg	cf;
reg	of;
reg	zf;

always @(*)
begin
	result = 0;
	cf = 0;
	of = 0;
	case(alu_op)
		`CORE_ALUOP_NONE: begin
			result = 0;
			cf = 0;
			of = 0;
		end
		`CORE_ALUOP_ADD: begin
			{cf,result} = a + b;
			of = ~((a[31]==b[31]) & (a[31] == result[31]));
		end
		`CORE_ALUOP_ADDC: begin
			{cf, result} = a + b + cf_i;
			of = ~((a[31]==b[31]) & (a[31] == result[31]));
		end
		`CORE_ALUOP_SUB: begin
			cf = 1;
			result = {cf,a} - b;
			cf = ~cf;
			of = ~((a[31]==!b[31]) & (a[31] == result[31]));
		end
		`CORE_ALUOP_SUBC: begin
			cf = 1;
			result = {cf,a} - b - cf_i;
			cf = ~cf;
			of = ~((a[31]==!b[31]) & (a[31] == result[31]));
		end
		`CORE_ALUOP_MUL: begin

		end
		`CORE_ALUOP_MULU: begin
		end
		`CORE_ALUOP_DIV: begin
		end
		`CORE_ALUOP_DIVU: begin
		end
		`CORE_ALUOP_AND: begin
			result = a & b;
		end
		`CORE_ALUOP_OR:
			result = a | b;
		`CORE_ALUOP_NOT:
			result = ~a;
		`CORE_ALUOP_LSL:
			result = a << b;
		`CORE_ALUOP_LSR:
			result = a >> b;
		`CORE_ALUOP_ASL:
			result = a <<< b;
		`CORE_ALUOP_ASR:
			result = a >>> b;
		default: begin
			result = 0;
		end
	endcase
	zf = ~(|result);
end
