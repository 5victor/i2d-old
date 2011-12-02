/* i2d_if.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 *
 * i2d instruction fetch module
 */

`include "i2d_defines.v"


module i2d_if(
	clk, rst,
	//wishbone bus
	adr_o, dat_i, ack_i, rty_i, err_i,

	//
	if_en, set_pc, new_pc, if_ins, if_pc, if_busy
);

input	clk;
input	rst;
input	[31:0]	dat_i;
input	ack_i;
input	rty_i;
input	err_i;

input	if_en;
input	set_pc;
input	[31:0]	new_pc;

output	[31:0]	adr_o;
output	[31:0]	if_ins;
output	[31:0]	if_pc;
output	if_busy;

reg	[31:0]	adr_o;
reg	[31:0]	if_pc;

reg	[31:0]	npc; //next pc
reg	pc;

assign if_busy = ~ack_i;
assign if_ins = if_en ? dat_i : {`I2D_INS_NOP, 26'b0};

always @(posedge clk)
begin
	if (~rst)
		pc <= 0;
	else if (if_en)
	begin
		if (set_pc)
			pc <= new_pc;
		else
			pc <= npc;
		
		npc <= pc + 4;
		adr_o <= pc;
		if_pc <= pc;
	end
end

endmodule

