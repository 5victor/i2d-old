/* i2d_core_defines.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 *
 * i2d core defines
 */

`include i2d_soc_defines.v

// instruction opcode
`define CORE_OPCODE_WIDTH	6
//ALU instruction
`define CORE_OPCODE_ADD		6'd1
`define CORE_OPCODE_ADDI	6'd2
`define CORE_OPCODE_ADDC	6'd3
`define CORE_OPCODE_ADDCI	6'd4
`define CORE_OPCODE_SUB		6'd5
`define CORE_OPCODE_SUBI	6'd6
`define CORE_OPCODE_SUBC	6'd7
`define CORE_OPCODE_SUBCI	6'd8
`define CORE_OPCODE_MUL		6'd9
`define CORE_OPCODE_MULI	6'd10
`define	CORE_OPCODE_MULU	6'd11
`define CORE_OPCODE_MULUI	6'd12
`define CORE_OPCODE_DIV		6'd13
`define CORE_OPCODE_DIVI	6'd14
`define CORE_OPCODE_DIVU	6'd15
`define CORE_OPCODE_DIVUI	6'd16
`define CORE_OPCODE_AND		6'd17
`define CORE_OPCODE_ANDI	6'd18
`define CORE_OPCODE_OR		6'd19
`define CORE_OPCODE_ORI		6'd20
`define CORE_OPCODE_NOT		6'd21
`define CORE_OPCODE_RSL		6'd22
`define CORE_OPCODE_RSLI	6'd23
`define CORE_OPCODE_RSR		6'd24
`define CORE_OPCODE_RSRI	6'd25
`define	CORE_OPCODE_ASL		6'd26
`define CORE_OPCODE_ASLI	6'd27
`define CORE_OPCODE_ASR		6'd28
`define CORE_OPCODE_ASRI	6'd29

//MEM instruction
`define CORE_OPCODE_LD		6'd30
`define CORE_OPCODE_LDB		6'd42
`define CORE_OPCODE_LDW		6'd43
`define CORE_OPCODE_ST		6'd31
`define CORE_OPCODE_STB		6'd44
`define CORE_OPCODE_STW		6'd45

//branch instruction may have 2 opcodes(imm, reg), while the condition in ins[26:0]
`define CORE_OPCODE_B	6'd31
`define CORE_OPCODE_BI	6'd32

/*
`define CORE_OPCODE_BE	6'd011000
`define CORE_OPCODE_BER	6'd011001
`define CORE_OPCODE_BNE	6'd011010
`define CORE_OPCODE_BNER	6'd011011
`define CORE_OPCODE_BG	6'd011100
`define CORE_OPCODE_BGR	6'd011101
`define CORE_OPCODE_BL	6'd011110
`define CORE_OPCODE_BLR	6'd011111
`define CORE_OPCODE_BA	6'd100000
`define CORE_OPCODE_BAR	6'd100001
`define CORE_OPCODE_BB	6'd100010
`define CORE_OPCODE_BBR	6'd100011
*/

//other instruction
`define CORE_OPCODE_NOP		6'd33
`define CORE_OPCODE_MOV		6'd34
`define CORE_OPCODE_MOVI	6'd35
`define CORE_OPCODE_SWI		6'd36
`define CORE_OPCODE_CALL	6'd37
`define	CORE_OPCODE_CALLI	6'd38
`define CORE_OPCODE_RET		6'd39
`define CORE_OPCODE_RFE		6'd40
`define CORE_OPCODE_MSR		6'd41
`define CORE_OPCODE_MRS		6'd42

`define CORE_INS_RA_MSB		21//31-6-4
`define CORE_INS_RB_MSB		17

//i2d regfile
`define CORE_GPR_WIDTH	4

`define CORE_RF_R0	4'b0000

//mode depend gpr
`define CORE_RF_LR	4'b1101
`define CORE_RF_SP	4'b1110
`define CORE_RF_PC	4'b1111

//mode depend spr
`define CORE_RF_EPC	5'b10000
`define CORE_RF_ESR	5'b10001

//oprand mux
`define CORE_OPMUX_A_NONE	0
`define CORE_OPMUX_A_RA		1
`define CORE_OPMUX_A_PC		2
`define CORE_OPMUX_A_WB		3
`define CORE_OPMUX_B_NONE	0
`define CORE_OPMUX_B_RB		1
`define CORE_OPMUX_B_ID_PC	2
`define CORE_OPMUX_B_IMM	3
`define CORE_OPMUX_B_WB		4

//alu op
`define CORE_ALUOP_NONE		0
`define CORE_ALUOP_ADD		1
`define CORE_ALUOP_ADDC		2
`define CORE_ALUOP_SUB		3
`define CORE_ALUOP_SUBC		4
`define CORE_ALUOP_MUL		5
`define CORE_ALUOP_MULU		6
`define CORE_ALUOP_DIV		7
`define CORE_ALUOP_DIVU		8
`define CORE_ALUOP_AND		9
`define CORE_ALUOP_OR		8
`define CORE_ALUOP_NOT		9
`define CORE_ALUOP_LSL		10
`define CORE_ALUOP_LSR		11
`define CORE_ALUOP_ASL		12
`define CORE_ALUOP_ASR		13
`define CORE_ALUOP_ERR		14

//status register bit
`define CORE_SR_CF			0
`define CORE_SR_OF			1
`define CORE_SR_ZF			2

`define CORE_SR_MODE_M		3	//MSB
`define CORE_SR_MODE_L		5	//LSB

//branch instrution
`define CORE_BRANCH_B		1	//always
`define CORE_BRANCH_BNE		2
`define CORE_BRANCH_BE		3

//mau op
`define CORE_MAUOP_NONE		0
`define CORE_MAUOP_R		1
`define CORE_MAUOP_W		2

//mau sel
`define CORE_MAUSEL_NONE	0
`define CORE_MAUSEL_B		1
`define CORE_MAUSEL_W		2
`define CORE_MAUSEL_D		3
