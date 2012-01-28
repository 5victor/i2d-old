/* sdram_ctrl.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 * This code publish under GNU GPL License
 *
 * i2d soc sdram controller module
 */

`include "i2d_soc_defines.v"

module sdram_ctrl(
	clk, rst,
	//sdram interface
	clk_sdr, cke_sdr, cs_sdr, ba_sdr, a_sdr, ras_sdr, cas_sdr, we_sdr,
	udqm_sdr, ldqm_sdr, dq_sdr,
	//sdram wishbone slave interface
	adr_i, dat_i, sel_i, we_i, cyc_i, stb_i, dat_o, ack_o, err_o, rty_o,
	//controller regs wishbone interface
	reg_adr_i, reg_dat_i, reg_sel_i, reg_we_i, reg_cyc_i, reg_stb_i,
	reg_dat_o, reg_ack_o, reg_err_o, reg_rty_o
);
input		clk;
input		rst;
input	[`SDRAM_ADR_WIDTH-1:0]	adr_i;
input	[`WB_DATA_WIDTH-1:0]	dat_i;
input	[`WB_SEL_WIDTH-1:0]	sel_i;
input				we_i;
input				cyc_i;
input				stb_i
input	[`WBS_ADR_WIDTH-1:0]	reg_adr_i;
input	[`WB_DATA_WIDTH-1:0]	reg_dat_i;
input	[`WB_SEL_WIDTH-1:0]	reg_sel_i;
input		reg_we_i;
input		reg_cyc_i;
input		reg_stb_i;

output	[`WB_DATA_WIDTH-1:0]	reg_dat_o;
output		reg_ack_o;
output		reg_err_o;
output		reg_rty_o;

output				clk_sdr;
output				cke_sdr;
output				cs_sdr;
output	[1:0]			ba_sdr;
output	[12:0]			a_sdr;
output				ras_sdr;
output				cas_sdr;
output				we_sdr;
output				udqm_sdr;
output				ldqm_sdr;
inout	[15:0]			dq_sdr;

output	[`WB_DATA_WIDTH-1:0]	dat_o;
output				ack_o;
output				err_o;
output				rty_o;

//internal
wire	acc;
wire	we;
wire [1:0] ba;
wire [12:0] row_addr;
wire [8:0] col_addr;
wire [31:0] data;
wire [3:0] mask;
wire	finish;
wire	busy;
wire	ref;
wire	[2:0]	mem_size;
wire	[12:0]	ref_count;
wire	ctrl_en;
wire	[2:0]	cl;
wire	[2:0]	t_rcd;
wire	[2:0]	t_rp;
wire	[2:0]	t_ref;
wire	refreshing;

assign clk_sdr = clk;
assign cke_sdr = ctrl_en;

sdram_ctrl_wbif wbif(clk, rst, adr_i, sel_i, we_i, cyc_i, stb_i, dat_o, ack_o,
	err_o, rty_o, acc, we, ba, row_addr, col_addr, data, mask, finish,
	busy, ref, mem_size);

sdram_ctrl_ramif ramif(clk, rst, ref, acc, we, ba, row_addr, col_addr, data,
	mask, ref_count, cl, t_rcd, t_rp, t_ref, finish, busy, refreshing,
	cs_sdr, ras_sdr, cas_sdr, we_sdr, we_sdr, dqm_sdr, addr_sdr, ba_sdr,
	dq_sdr);

sdram_ctrl_ref(clk, rst, ref_count, refreshing, ref);

sdram_ctrl_regs regs(clk, rst, reg_adr_i, reg_dat_i, reg_sel_i, reg_we_i,
	reg_cyc_i, reg_stb_i, reg_dat_o, reg_ack_o, reg_err_o, reg_rty_o,
	ref_count, mem_size, ctrl_en, cl, t_rcd, t_rp, t_ref);

endmodule

