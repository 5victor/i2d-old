/* core_cpu.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 * This code publish under GNU GPL License
 *
 * i2d core module
 *
 * TODO: xxx
 */

`include "i2d_core_defines.v"

module core_cpu(
	clk, rst,
	//wishbone instruction interface
	wbi_adr_o, wbi_sel_o, wbi_we_o, wbi_cyc_o, wbi_stb_o,
	wbi_dat_i, wbi_ack_i, wbi_rty_i, wbi_err_i,
	//wishbone data interface
	wbd_adr_o, wbd_dat_o, wbd_sel_o, wbd_sel_o, wbd_we_o, wbd_cyc_o,
	wbd_stb_o, wbd_dat_i, wbd_ack_i, wbd_rty_i, wbd_err_i
);
input		clk;
input		rst;
input	[`WB_DAT_WIDTH-1:0]	wbi_dat_i;
input		wbi_ack_i;
input		wbi_rty_i;
input		wbi_err_i;
input	[`WB_DAT_WIDTH-1:0]	wbd_dat_i;
input		wbd_ack_i;
input		wbd_rty_i;
input		wbd_err_i;

output	[`WB_ADR_WIDTH-1:0]	wbi_adr_o;
output	[`WB_SEL_WIDTH-1:0]	wbi_sel_o;
output		wbi_we_o;
output		wbi_cyc_o;
output		wbi_stb_o;
output	[`WB_ADR_WIDTH-1:0]	wbd_adr_o;
output	[`WB_DAT_WIDTH-1:0]	wbd_dat_o;
output	[`WB_SEL_WIDTH-1:0]	wbd_sel_o;
output		wbd_we_o;
output		wbd_cyc_o;
output		wbd_stb_o;

//internal



