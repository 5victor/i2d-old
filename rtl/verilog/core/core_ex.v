/* core_ex.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 * This code publish under GNU GPL License
 *
 * i2d ex module
 */

`include "i2d_core_defines.v"

module core_ex(
	rst, clk,
	//input
	id_ins, id_pc, ex_halt,
	//ouput
	wb_addr
);
input		rst;
input		clk;
input	[31:0]	id_ins;
input	[31:0]	id_pc;
input		ex_halt;

endmodule

