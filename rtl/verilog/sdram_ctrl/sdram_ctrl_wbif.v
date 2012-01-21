/* sdram_ctrl_wbif.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 * This code publish under GNU GPL License
 *
 * i2d soc sdram controller wishbone interface module
 */

`include "i2d_soc_defines.v"

module sdram_ctrl_wbif(
	clk, rst,
	//wishbone
	adr_i, dat_i, sel_i, we_i, cyc_i, stb_i, dat_o, ack_o, err_o, rty_o,
	//output
	acc, we, ba, row_addr, col_addr, data, mask,
	//input
	finish, busy, ref, mem_size
);
input		clk;
input		rst;
input	[`SDRAM_ADR_WIDTH]	adr_i;
input	[`WB_DATA_WIDTH]	dat_i;
input	[`WB_SEL_WIDTH]		sel_i;
input		we_i;
input		cyc_i;
input		stb_i;

input		finish;
input		busy;
input	[2:0]	mem_size;

output	[`WB_DATA_WIDTH]	dat_o;
output		ack_o;
output		err_o;
output		rty_o;

output		acc;
output		we;
output	[1:0]	ba;
output	[12:0]	row_addr;
output	[8:0]	col_addr;
output	[31:0]	data;
output	[3:0]	mask;

reg	[1:0]	ba;
reg	[12:0]	row_addr;
reg	[8:0]	col_addr;
reg	[31:0]	data;
reg	[3:0]	mask;
reg		ack_o;
reg		rty_o;
reg		err_o;

localparam state_idle		= 5'b00001;
localparam state_align		= 5'b00010;
localparam state_unalign1	= 5'b00100;
localparam state_unalign1_delay = 5'b01000;
localparam state_unalign2	= 5'b10000;

localparam size_2m	= 3'b000;
localparam size_4m	= 3'b001;
localparam size_8m	= 3'b010;
localparam size_16m	= 3'b011;
localparam size_32m	= 3'b100;
localparam size_64m	= 3'b101;
localparam size_128m	= 3'b110;

//internal
reg next_state;
reg state;
reg [3:0] unalign2_mask;
reg addr;

wire align = ~(|adr_i[1:0]);
assign we	= we_i;
assign acc	= cyc_i & stb_i;

always @(*)
begin
	col_addr = addr[10:2]; //[9:1] 16bit
	case(mem_size)
		size_2m: begin
			row_addr = addr[18:11];
			ba = addr[20:19];
		end
		size_4m: begin
			row_addr = addr[19:11];
			ba = addr[21:20];
		end
		size_8m: begin
			row_addr = addr[20:11];
			ba = addr[22:21];
		end
		size_16m: begin
			row_addr = addr[21:11];
			ba = addr[23:22];
		end
		size_32m: begin
			row_addr = addr[22:11];
			ba = addr[24:23];
		end
		size_64m: begin
			row_addr = addr[23:11];
			ba = addr[25:24];
		end
		size_128m: begin
			row_addr = addr[24:11];
			ba = addr[26:25];
		end
		default: begin
			row_addr = 0;
			ba = 0;
		end
	endcase
end

always @(posedge clk)
begin
	if (!rst)
		state = state_idle;
	else
		state = next_state;
end

always @(*)
begin
	case (state)
		state_idle: begin
			ack_o = 0;
			rty_o = 0;
			if (acc & !busy & !ref) //ref = 1 case busy, but ...
				if (align)
					next_state = state_align;
				else
					next_state = state_unalign1;
		end
		state_align: begin
			addr = adr_i;
			mask	= ~sel_i;
			if (we_i)
				data = dat_i;
			else
				dat_o = data; //when finish = 0, every pos clk
			if (finish) begin	//dat_o = data
				ack_o = 1;
				rty_o = 0;
				next_state = state_idle;
			end
			else
				rty_o = 1;
		end
		state_unalign1: begin
			addr = adr_i;
			mask = 4'b1111;
			unalign2_mask = 4'b1111;
			data = 0;
			case (adr_i[1:0])
				1: begin
					mask[3:1] = (~sel_i)[2:0];
					unalign2_mask = (~sel_i)[3];
					if (we_i)
						data[31:8] = dat_i[23:0];
					else
						dat_o[23:0] = data[31:8];	
				end
				2: begin
					mask[3:2] = (~sel_i)[1:0];
					unalign2_mask = (~sel_i)[3:2];
					if (we_i)
						data[31:16] = dat_i[15:0];
					else
						dat_o[15:0] = data[31:16];
				end
				3: begin
					mask[3] = (~sel_i)[0];
					unalign2_mask = (~sel_i)[3:1];
					if (we_i)
						data[31:24] = dat_i[7:0];
					else
						dat_o[7:0] = data[31:24];
				end
				default: begin
					mask = 4'b1111;
					unalign2_mask = 4'b1111;
					data = 0;
					dat_o = 0;
				end
			endcase
			if (finish)
				if (unalign2_mask == 4'b1111) begin
					next_state = state_idle;
					ack_o = 1;
					rty_o = 0;
				end
				else
					next_state = state_unalign1_delay;
			else
				rty_o = 1;				
		end
		state_unailgn1_delay: begin
			if (!busy & !ref)
			       next_state = state_unalign2;	
		end
		state_unalign2: begin
			addr = adr_i + 4;
			mask = unalign2_mask;
			data = 0;
			case (adr_i[1:0])
				1: begin
					if (we_i)
						data[7:0] = dat_i[31:24];
					else
						dat_o[31:24] = data[7:0];
				end
				2: begin
					if (we_i)
						data[15:0] = dat_i[31:16];
					else
						dat_o[31:16] = data[15:0];
				end
				3: begin
					if (we_i)
						data[23:0] = dat_i[31:8];
					else
						dat_o[31:8] = data[23:0];
				end
				default: begin
					data = 0;
					dat_o = 0;
				end
			endcase
			if (finish == 1) begin
				ack_o = 1;
				rty_o = 0;
				next_state = state_idle;
			end
			else
				rty_o = 1;	
		end
		default:
			next_state = state_idle;			
	endcase
end
