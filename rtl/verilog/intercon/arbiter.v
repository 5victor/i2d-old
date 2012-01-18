/* arbiter.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 * This code publish under GNU GPL License
 *
 * i2d soc intercon arbiter module
 */

`include "i2d_soc_defines.v"

module arbiter(
	rst, clk, request, grant
);
localparam WIDTH = `INTERCON_MASTER_NUM;

input			rst;
input			clk;
input	[WIDTH-1:0]	request;
output	[WIDTH-1:0]	grant;

//internal wires
reg	[WIDTH-1:0]	masked_req;
wire	[2*WIDTH-1:0]	double_req;
wire	[2*WIDTH-1:0]	pre_grant;
reg			last;
reg			base;

always @(posedge clk)
begin
	if (rst == 0)
		last = 0;
	else
	begin
		if (request & grant == 0)
			last = grant;
	end
	
end

always @*
begin
if (last == 0) begin
	masked_req = request;
	base = 1;
end
else begin
	masked_req = request & ~last;
	base = last;
end
end

assign	double_req = {masked_req,masked_req};
assign	pre_grant = double_req & ~(double_req-base);
assign	grant = pre_grant[WIDTH-1:0] | pre_grant[2*WIDTH-1:WIDTH];

endmodule

