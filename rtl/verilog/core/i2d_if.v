/* i2d_if.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 *
 * i2d instruction fetch module
 */

`include "i2d_core_defines.v"


module i2d_if(
	clk, rst,
	//wishbone bus
	adr_o, dat_i, ack_i, rty_i, err_i,

	//
	if_dis, set_pc, new_pc, if_ins, if_pc, if_busy, if_err
);

input	clk;
input	rst;
input	[31:0]	dat_i;
input	ack_i;
input	rty_i;
input	err_i;

input	if_dis;
input	set_pc;
input	[31:0]	new_pc;

output	[31:0]	adr_o;
output	[31:0]	if_ins;
output	[31:0]	if_pc;
output	if_busy;
output	if_err;

reg	[31:0]	adr_o;
reg	[31:0]	if_pc;

reg	[31:0]	pc;

assign if_busy = rty_i;
assign if_err = err_i | (~rty_i & ~err_i & ~ack_i);
assign if_ins = if_dis ? dat_i : {`I2D_INS_NOP, 26'b0};

always @(posedge clk)
begin
	if (~rst)
		pc <= 0;
	else if (~if_dis && ~rty_i)
	begin
		if (set_pc)
			pc <= new_pc;
		else
			pc <= pc + 4;
	end
end

always @(pc)
begin
	adr_o <= pc;
	if_pc <= pc;
end

endmodule

