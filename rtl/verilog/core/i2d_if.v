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
	adr_o, sel_o, we_o, cyc_o, stb_o, dat_i, ack_i, rty_i, err_i,
	//
	if_halt, set_pc, new_pc, if_ins, if_pc, if_busy, if_err
);

input	clk;
input	rst;
input	[31:0]	dat_i;
input	ack_i;
input	rty_i;
input	err_i;

input	if_halt;
input	set_pc;
input	[31:0]	new_pc;

output	[31:0]	adr_o;
output	[3:0]	sel_o;
output		we_o;
output		cyc_o;
output		stb_o;
output	[31:0]	if_ins;
output	[31:0]	if_pc;
output	if_busy;
output	if_err;

//internal
reg	[31:0]	pc;

assign if_busy = rty_i;
assign if_err = err_i;
assign if_ins = if_halt ? dat_i : {`CORE_OPCODE_NOP, 32-`CORE_OPCODE_WIDTH{0}};
assign sel_o = 4'b1111;
assign we_o = 0;
assign cyc_o = ~if_halt;
assign stb_o = cyc_o;
assign adr_o = pc;
assign if_pc = pc;

always @(posedge clk)
begin
	if (~rst)
		pc <= 0;
	else if (!if_halt & !if_busy)
	begin
		if (set_pc)
			pc <= new_pc;
		else
			pc <= pc + 4;
	end
	else
		pc <= pc;
end

endmodule

