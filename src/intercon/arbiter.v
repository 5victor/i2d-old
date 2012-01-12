/* arbiter.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 * This code publish under GNU GPL License
 *
 * i2d soc intercon arbiter module
 */

`include "i2d_soc_defines.v"

module arbiter(
	request, last, grant, cyc_o
);
parameter WIDTH = `WBM_NUM;
input	[WIDTH-1:0]	request;
input	[WIDTH-1:0]	last; //last grant
output	[WIDTH-1:0]	grant;
output			cyc_o;

//internal wires
wire	[WIDTH-1:0]	masked_req;
wire	[2*WIDTH-1:0]	double_req;
wire	[2*WIDTH-1:0]	pre_grant;

assign	masked_req = last & ~current;
assign	double_req = {masked_req,masked_req};
assign	pre_grant = double_req & ~(double_req-last);
assign	grant = pre_grant[WIDTH-1:0] | pre_grant[2*WIDTH-1:WIDTH];
assign	cyc_o = |grant;

endmodule

