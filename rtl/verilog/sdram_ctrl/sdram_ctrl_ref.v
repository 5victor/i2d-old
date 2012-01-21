/* sdram_ctrl_ref.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 * This code publish under GNU GPL License
 *
 * i2d soc sdram controller refresh module
 */

`include "i2d_soc_defines.v"

module sdram_ctrl_ref(
	clk, rst,
	ref_count, //input
	refreshing;
	ref //output
);
input		clk;
input		rst;
input	[12:0]	ref_count;
input		refreshing;
output		ref;

reg		ref;

reg	[12:0]	count;
reg		rst_count;

always @(posedge clk)
begin
	if (!rst | rst_count)
		count = 0;
	else
		count = count + 1;
end

always @(*)
begin
	if (count == ref_count) begin
		rst_count = 1;
		ref = 1;
	end
	else if (refreshing) begin
		ref = 0;
		rst_count = 0;
	end
	else
		rst_count = 0;
end

