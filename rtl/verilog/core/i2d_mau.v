/* filename
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 * This code publish under GNU GPL License
 *
 * i2d mau module
 */

`include "i2d_core_defines.v"

module i2d_mau(
		rst, clk,
		//internal interface
		mau_dis, mau_flush, mau_op, mau_addr,
		datain, data_out, busy,
		//wishbone interface
		adr_o, dat_i, dat_o, ack_i, cyc_o, err_i, try_i, sel_o,
		we_o
);

input		rst;
input		clk;
input		mau_dis;
input		mau_flush;
input	[1:0]	mau_op;

endmodule
