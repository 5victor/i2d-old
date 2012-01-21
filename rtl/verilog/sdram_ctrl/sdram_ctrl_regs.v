/* sdram_ctrl_regs.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 * This code publish under GNU GPL License
 *
 * i2d soc sdram controller regs module
 */

`include "i2d_soc_defines.v"

module sdram_ctrl_regs(
	clk, rst,
	//wishbone slave interface
	adr_i, dat_i, sel_i, we_i, cyc_i, stb_i, dat_o, ack_o, err_o, rty_o,
	//regs
	ref_count, mem_size, ctrl_en, cl, t_rcd, t_rp, t_ref
);
input			clk;
input			rst;
input	[`WBS_ADR_WIDTH-1:0]	adr_i;
input	[`WB_DATA_WIDTH-1:0]	dat_i;
input	[`WB_SEL_WIDTH-1:0]	sel_i;
input			we_i;
input			cyc_i;
input			stb_i;
output	[`WB_DATA_WIDTH-1:0]	dat_o;
output			ack_o;
output			err_o;
output			rty_o;
output	[15:0]		ref_count;
output	[2:0]		mem_size;
output			ctrl_en;
output	[2:0]		t_rcd;
output	[2:0]		cl;
output	[2:0]		t_rp;
output	[2:0]		t_ref;
reg	[`WB_DATA_WIDTH-1:0]	dat_o;
reg			ack_o;
reg			err_o;
reg			rty_o;
reg	[12:0]		ref_count;
reg			ctrl_en;
reg	[2:0]		cl;
reg	[2:0]		t_rcd;
reg	[2:0]		t_rp;
reg	[2:0]		t_ref;

localparam REG_CTRL = 0;
localparam REG_REF = 4;


always @(posedge clk)
begin
	if (rst == 0) begin
		dat_o = 0;
		ack_o = 0;
		err_o = 0;
		rty_o = 0;
		ref_count = 0;
		ctrl_en = 0;
		cl = 0;
		t_rcd = 0;
		t_rp = 0;
		t_ref = 0;
	end
	else if (cyc_i & stb_i & ~ack_o) begin
		ack_o = 1;
		err_o = 0;
		rty_o = 0;
		case (adr_i)
			REG_CTRL: begin
				if (we_i) begin
					ctrl_en = dat_i[12];
					cl = dat_i[11:9];
					t_rcd = dat_i[8:6];
					t_rp = dat_i[5:3];
					t_ref = dat_i[2:0];
				end
				else begin
					dat_o[12] = ctrl_en;
					dat_o[11:9] = cl;
					dat_o[8:6] = t_rcd;
					dat_o[5:3] = t_rp;
					dat_o[2:0] = t_ref;			
				end
			end
			REG_REF: begin
				if (we_i) begin
					ref_count = dat_i[12:0];
					mem_size = dat_i[15:13];
				end
				else begin
					dat_o[12:0] = ref_count;
					dat_o[15:13] = mem_size;
			end
		endcase
	end
	else if (cyc_i & stb_i & ack_o)
		ack_o = 0;
end

endmodule
