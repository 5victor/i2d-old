/* sdram_ctrl_ramif.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 * This code publish under GNU GPL License
 *
 * i2d soc sdram controller ram interface module
 */

`include "i2d_soc_defines.v"

/* brust lenth = 2 in task modereg
 * change busy finish in always @*
 */

module sdram_ctrl_ramif(
	clk, rst,
	//input
	ref, acc, we, ba, row_addr, col_addr, data, mask,
	//regs
	ref_count, cl, t_rcd, t_rp, t_ref,
	//output
	finish, busy, refreshing
	//sdram interface output
	cs_sdr, ras_sdr, cas_sdr, we_sdr, dqm_sdr, addr_sdr, ba_sdr, dq_sdr
);
input		clk;
input		rst;
input		ref;
input		continue;
input		acc; //access
input		we;
input	[1:0]	ba;
input	[12:0]	row_addr;
input	[8:0]	col_addr;
input	[15:0]	data;
input	[3:0]	mask;
input	[15:0]	ref_count;
input	[2:0]	cl;
input	[2:0]	t_rcd;
input	[2:0]	t_rp;
input	[2:0]	t_ref;

output		finish;
output		busy;
output		refreshing;
output		cs_sdr;
output		ras_sdr;
output		cas_sdr;
output		we_sdr;
output	[1:0]	dqm_sdr;
output	[12:0]	addr_sdr;
output	[1:0]	ba_sdr;
output	[15:0]	dq_sdr;

reg		finish;
reg		busy;
reg		cs_sdr;
reg		ras_sdr;
reg		cas_sdr;
reg		we_sdr;
reg	[1:0]	dqm_sdr;
reg	[12:0]	addr_sdr;
reg	[1:0]	ba_sdr;
reg	[15:0]	dq_sdr;

localparam state_init_delay		= 20'b00000000000000000001;
localparam state_init_precharge		= 20'b00000000000000000010;
localparam state_init_precharge_delay	= 20'b00000000000000000100;
localparam state_init_refresh1		= 20'b00000000000000001000;
localparam state_init_refresh1_delay	= 20'b00000000000000010000;
localparam state_init_refresh2		= 20'b00000000000000100000;
localparam state_init_refresh2_delay	= 20'b00000000000001000000;
localparam state_init_modereg		= 20'b00000000000010000000;
localparam state_init_modereg_delay	= 20'b00000000000100000000;
localparam state_idle			= 20'b00000000001000000000;
localparam state_refresh		= 20'b00000000010000000000;
localparam state_refresh_delay		= 20'b00000000100000000000;
localparam state_active			= 20'b00000001000000000000;
localparam state_active_delay		= 20'b00000010000000000000;
localparam state_read			= 20'b00000100000000000000;
localparam state_read_delay		= 20'b00001000000000000000;
localparam state_read_data1		= 20'b00010000000000000000;
localparam state_wirte			= 20'b00100000000000000000; //write data1
localparam state_precharge		= 20'b01000000000000000000; //read data2 write data2
localparam state_precharge_delay	= 20'b10000000000000000000;

//internal
reg	[7:0]	count;
reg		rst_count;
reg	[11:0]	state;
reg	[11:0]	next_state;
reg		ctrl_en_save;
wire		ctrl_init;

always @(posedge clk)
	ctrl_en_save = ctrl_en;

assign ctrl_init = ~ctrl_en_save & ctrl_en;

always @(posedge clk or negedge rst)
begin
	if (!rst)
		state <= state_init_delay;
	else if (ctrl_init) begin
		state <= state_init_precharge;
	end
	else
		state <= next_state;
	if (!rst) begin
		rst_count = 0;
		count = 0;
	end
	else
		if (rst_count) begin
			rst_count = 0;
			count = 0;
		end
		else
			count = count + 1;

end

always @(*)
begin
	case (state)
		state_init_delay: begin
			nop;
			if (count == ref_count / 640) begin
				next_state = state_init_prechare;
				busy = 1;
				finish = 0;
				//rst_count = 1;
			end
		end
		state_init_prechare: begin
			precharge;
			next_state = state_init_precharge_delay;
			rst_count = 1;
			busy = 1;
			finish = 0;
		end
		state_init_precharge_delay: begin
			nop;
			if (count == t_rp) begin
				next_state = state_init_refresh1;
				//rst_count = 1;
			end
		end
		state_init_refresh1: begin
			refresh;
			next_state = state_init_refresh1_delay;
			rst_count = 1;
		end
		state_init_refresh1_delay: begin
			nop;
			if (count == t_ref) begin
				next_state = state_init_refresh2;
				//rst_count = 1;
			end
		end
		state_init_refresh2: begin
			refresh;
			next_state = state_init_refresh_delay;
			rst_count = 1;
		end
		state_init_refresh2_delay: begin
			nop;
			if (count == t_ref) begin
				next_state = state_init_modereg;
				//rst_count = 1;
			end
		end
		state_init_modereg: begin
			modereg;
			next_state = state_init_modereg_delay;
			rst_count = 1;
		end
		state_init_modereg_delay: begin
			nop;
			if (count == 3) begin //chage it for the correct
				next_state = state_idle;
			end
		end
		state_idle: begin
			nop;
			busy = 0;
			finish = 0;
			refreshing = 0;
			if (ref) begin
				next_state = state_refresh;
				busy = 1;
			end
			else if (acc & (ref == 0)) begin
				next_state = state_active;
				busy = 1;
			end
		end
		state_refresh: begin
			refresh;
			refreshing = 1;
			next_state = state_refresh_delay;
			rst_count = 1;
		end
		state_refresh_delay: begin
			nop;
			if (count == t_ref) begin
				next_state = state_idle;
			end
		end
		state_active: begin
			active;
			next_state = state_active_delay;
			rst_count = 1;
		end
		state_active_delay: begin
			nop;
			if (count == t_rcd)
				if (we)
					next_state = state_write;
				else begin
					next_state = state_read;
					rst_count = 1;
				end
		end
		state_read: begin //count = 0, rst_count = 1 above
			read;
			next_state = state_read_delay;
			//rst_count = 1;
		end
		state_read_delay: begin //count = 1
			nop;
			if (count == cl) begin
				data[15:0] = dq_sdr;
				dqm_sdr = mask[1:0];
				next_state = state_precharge;
			end
		end
		state_write: begin
			write;
			dq_sdr = data[15:0];
			dqm_sdr = mask[1:0];
			next_state = state_precharge;
		end
		state_precharge: begin
			precharge;
			if (we) begin
				dq_sdr = data[31:16];
				dqm_sdr = mask[3:2];
			end
			else begin
				data[31:16] = dq_sdr;
				dqm_sdr = mask[3:2];
			end
			next_state = state_precharge_delay;
			rst_count = 1;
			finish = 1;
		end
		state_precharge_delay:begin
			nop;
			if (count == t_rp)
				next_state = state_idle;
		end
		default:
			next_state = state_idle;
	endcase
end

task modereg;
begin
	cs_sdr = 0;
	ras_sdr = 0;
	cas_sdr = 0;
	we_sdr = 0;
	dqm_sdr = 0;
	addr_sdr = 10'b0000000001;
	adr_sdr[6:4] = cl;
	ba_sdr	= 0; 
end
endtask

task nop;
begin
	cs_sdr = 1;
	ras_sdr = 0;
	cas_sdr = 0;
	we_sdr = 0;
	dqm_sdr = 0;
	addr_sdr = 0;
	ba_sdr	= 0;
end
endtask

task active;
begin
	cs_sdr = 0;
	ras_sdr = 0;
	cas_sdr = 1;
	we_sdr = 1;
	dqm_sdr = 0;
	addr_sdr = row_addr;
	ba_sdr	= ba;
end
endtask

task read;
begin
	cs_sdr = 0;
	ras_sdr = 1;
	cas_sdr = 0;
	we_sdr = 1;
	dqm_sdr = mask;
	addr_sdr = col_addr;
	ba_sdr	= ba;
end
endtask

task write;
begin
	cs_sdr = 0;
	ras_sdr = 1;
	cas_sdr = 0;
	we_sdr = 0;
	dqm_sdr = mask;
	addr_sdr = col_addr;
	ba_sdr	= ba;
end
endtask

task precharge;
begin
	cs_sdr = 0;
	ras_sdr = 0;
	cas_sdr = 1;
	we_sdr = 0;
	dqm_sdr = mask;
	addr_sdr = 0;
	addr_sdr[10] = 1;
	ba_sdr	= 0;
end
endtask

task refresh;
begin
	cs_sdr = 0;
	ras_sdr = 0;
	cas_sdr = 0;
	we_sdr = 1;
	dqm_sdr = 0;
	addr_sdr = 0;
	ba_sdr	= 0;
end
endtask

endmodule

