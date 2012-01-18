/* intercon.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 * This code publish under GNU GPL License
 *
 * i2d soc intercon module
 */

`include "i2d_soc_defines.v"

module intercon(
	clk, rst,
	//master 0
	wbm0_adr_o, wbm0_dat_o, wbm0_sel_o, wbm0_we_o, wbm0_cyc_o, wbm0_stb_o,
	wbm0_dat_i, wbm0_ack_i, wbm0_err_i, wbm0_rty_i,
	//master 1
	wbm1_adr_o, wbm1_dat_o, wbm1_sel_o, wbm1_we_o, wbm1_cyc_o, wbm1_stb_o,
	wbm1_dat_i, wbm1_ack_i, wbm1_err_i, wbm1_rty_i,
	//master ...
	//
	//slave 0
	wbs0_adr_i, wbs0_dat_i, wbs0_sel_i, wbs0_we_i, wbs0_cyc_i, wbs0_stb_i,
	wbs0_dat_o, wbs0_ack_o, wbs0_err_o, wbs0_rty_o
);
localparam	maxbit = `WB_BUS_WIDTH - 1;
localparam	selbit = `WB_BUS_WIDTH / 8;
localparam	master_num = `INTERCON_MASTER_NUM;

//slave address
parameter	slave0_addr = 8'b00000000;

input clk;
input rst;
//master 0
input	[maxbit:0]	wbm0_adr_o;
input	[maxbit:0]	wbm0_dat_o;
input	[selbit:0]	wbm0_sel_o;
input			wbm0_we_o;
input			wbm0_cyc_o;
input			wbm0_stb_o;
output	[maxbit:0]	wbm0_dat_i;
output			wbm0_ack_i;
output			wbm0_err_i;
output			wbm0_rty_i;
//master 1
input	[maxbit:0]	wbm1_adr_o;
input	[maxbit:0]	wbm1_dat_o;
input	[selbit:0]	wbm1_sel_o;
input			wbm1_we_o;
input			wbm1_cyc_o;
input			wbm1_stb_o;
output	[maxbit:0]	wbm1_dat_i;
output			wbm1_ack_i;
output			wbm1_err_i;
output			wbm1_rty_i;
//slave 0
output	[maxbit:0]	wbs0_adr_i;
output	[maxbit:0]	wbs0_dat_i;
output	[selbit:0]	wbs0_sel_i;
output			wbs0_we_i;
output			wbs0_cyc_i;
output			wbs0_stb_i;
input	[maxbit:0]	wbs0_dat_o;
input			wbs0_ack_o;
input			wbs0_err_o;
input			wbs0_rty_o;
// internal
wire	[`INTERCON_MASTER_NUM-1:0]	request;
wire	[`INTERCON_MASTER_NUM-1:0]	grant;
integer					i;

wire	[maxbit:0]	wbm_adr_o[`INTERCON_MASTER_NUM];
wire	[maxbit:0]	wbm_dat_o[`INTERCON_MASTER_NUM];
wire	[selbit:0]	wbm_sel_o[`INTERCON_MASTER_NUM];
wire			wbm_we_o[`INTERCON_MASTER_NUM];
wire			wbm_cyc_o[`INTERCON_MASTER_NUM];
wire			wbm_stb_o[`INTERCON_MASTER_NUM];
reg	[maxbit:0]	wbm_dat_i[`INTERCON_MASTER_NUM];
reg			wbm_ack_i[`INTERCON_MASTER_NUM];
reg			wbm_err_i[`INTERCON_MASTER_NUM];
reg			wbm_rty_i[`INTERCON_MASTER_NUM];

assign wbm_adr_o[0] = wbm0_adr_o;
assign wbm_dat_o[0] = wbm0_dat_o;
assign wbm_sel_o[0] = wbm0_sel_o;
assign wbm_we_o[0] = wbm0_we_o;
assign wbm_cyc_o[0] = wbm0_cyc_o;
assign wbm_stb_o[0] = wbm0_stb_o;
assign wbm0_dat_i = wbm_dat_i[0];
assign wbm0_ack_i = wbm_ack_i[0];
assign wbm0_err_i = wbm_err_i[0];
assign wbm0_rty_i = wbm_rty_i[0];

assign wbm_adr_o[1] = wbm1_adr_o;
assign wbm_dat_o[1] = wbm1_dat_o;
assign wbm_sel_o[1] = wbm1_sel_o;
assign wbm_we_o[1] = wbm1_we_o;
assign wbm_cyc_o[1] = wbm1_cyc_o;
assign wbm_stb_o[1] = wbm1_stb_o;
assign wbm1_dat_i = wbm_dat_i[1];
assign wbm1_ack_i = wbm_ack_i[1];
assign wbm1_err_i = wbm_err_i[1];
assign wbm1_rty_i = wbm_rty_i[1];

reg	[maxbit:0]	adr_o;
reg	[maxbit:0]	dat_o;
reg	[selbit:0]	sel_o;
reg			we_o;
reg			cyc_o;
reg			stb_o;
reg	[maxbit:0]	dat_i;
reg			ack_i;
reg			err_i;
reg			rty_i;



assign request[0] = wbm0_cyc_o;
assign request[1] = wbm1_cyc_o;

arbiter wb_arbiter(rst, clk, request, grant);

always @(grant)
for (i = 0; i < `INTERCON_MASTER_NUM; i++)
begin
	if (grant[i])
	begin
		adr_o = wbm_adr_o[i];
		dat_o = wbm_dat_o[i];
		sel_o = wbm_sel_o[i];
		we_o = wbm_we_o[i];
		cyc_o = wbm_cyc_o[i];
		stb_o = wbm_stb_o[i];
		wbm_dat_i[i] = dat_i;
		wbm_ack_i[i] = ack_i;
		wbm_err_i[i] = err_i;
		wbm_rty_i[i] = rty_i;
	end
end


wire [0:0] slave_sel;
assign slave_sel[0] = adr_o[maxbit:maxbit-8] == slave0_addr; 

assign wbs0_adr_i = adr_o;
assign wbs0_dat_i = dat_o;
assign wbs0_sel_i = sel_o;
assign wbs0_we_i = we_o;
assign wbs0_cyc_o = slave_sel[0] & cyc_o;
assign wbs0_stb_o = slave_sel[0] & stb_o;

always @(slave_sel)
	if (slave_sel[0]) begin
		dat_i = wbs0_dat_o;
		ack_i = wbs0_ack_o;
		err_i = wbs0_err_o;
		rty_i = wbs0_rty_o;
	end
	else begin
		dat_i = 0;
		ack_i = 0;
		err_i = 0;
		rty_i = 0;
	end
	
endmodule
