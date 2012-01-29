/* sdram
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 * This code publish under GNU GPL License
 *
 * i2d soc sdram module
 */

`include "i2d_soc_defines.v"

module sdram(clk, cke, cs, ba0, ba1, a, ras, cas, we, udqm, ldqm, dq
);
input		clk;
input		cke;
input		cs;
input		ba0;
input		ba1;
input	[12:0]	a;
input		ras;
input		cas;
input		we;
input		udqm;
input		ldqm;
inout	[15:0]	dq;

