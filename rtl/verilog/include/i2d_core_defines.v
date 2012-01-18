/* i2d_core_defines.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 *
 * i2d core defines
 */


// instruction opcode

//ALU instruction
`define I2D_INS_ADD	6'b000001
`define I2D_INS_ADDI	6'b000010
`define I2D_INS_ADDC	6'b000011
`define I2D_INS_ADDCI	6'b000100
`define I2D_INS_SUB	6'b000101
`define I2D_INS_SUBI	6'b000110
`define I2D_INS_SUBC	6'b000111
`define I2D_INS_SUBCI	6'b001000
`define I2D_INS_MUL	6'b001001
`define I2D_INS_MULI	6'b101101
`define	I2D_INS_MULU	6'b001010
`define I2D_INS_MULUI	6'b101110
`define I2D_INS_DIV	6'b001011
`define I2D_INS_DIVI	6'b101111
`define I2D_INS_DIVU	6'b001100
`define I2D_INS_DIVUI	6'b110000
`define I2D_INS_AND	6'b001101
`define I2D_INS_ANDI	6'b110001
`define I2D_INS_OR	6'b001110
`define I2D_INS_ORI	6'b110010
`define I2D_INS_NOT	6'b001111
`define I2D_INS_RSL	6'b010000
`define I2D_INS_RSLI	6'b110011
`define I2D_INS_RSR	6'b010001
`define I2D_INS_RSRI	6'b110100
`define	I2D_INS_ASL	6'b010010
`define I2D_INS_ASLI	6'b110100
`define I2D_INS_ASR	6'b010011
`define I2D_INS_ASRI	6'b110101

//MEM instruction
`define I2D_INS_LD	6'b010100
`define I2D_INS_ST	6'b010101

//branch instruction may have 2 opcodes(imm, reg), while the condition in ins[26:0]
`define I2D_INS_B	6'b010110
`define I2D_INS_BI	6'b010111

/*
`define I2D_INS_BE	6'b011000
`define I2D_INS_BER	6'b011001
`define I2D_INS_BNE	6'b011010
`define I2D_INS_BNER	6'b011011
`define I2D_INS_BG	6'b011100
`define I2D_INS_BGR	6'b011101
`define I2D_INS_BL	6'b011110
`define I2D_INS_BLR	6'b011111
`define I2D_INS_BA	6'b100000
`define I2D_INS_BAR	6'b100001
`define I2D_INS_BB	6'b100010
`define I2D_INS_BBR	6'b100011
*/

//other instruction
`define I2D_INS_NOP	6'b100100
`define I2D_INS_MOV	6'b100101
`define I2D_INS_MOVI	6'b100110
`define I2D_INS_SWI	6'b100111
`define I2D_INS_CALL	6'b101000
`define	I2D_INS_CALLI	6'b110110
`define I2D_INS_RET	6'b101001
`define I2D_INS_RFE	6'b101010
`define I2D_INS_MSR	6'b101011
`define I2D_INS_MRS	6'b101100

//i2d regfile
`define I2D_GPR_WIDTH	4

`define I2D_RF_R0	4'b0000

//mode depend gpr
`define I2D_RF_LR	4'b1101
`define I2D_RF_SP	4'b1110
`define I2D_RF_PC	4'b1111

//mode depend spr
`define I2D_RF_EPC	5'b10000
`define I2D_RF_ESR	5'b10001

//oprand mux
`define I2D_OPMUX_A_NONE	0
`define I2D_OPMUX_A_RA		1
`define I2D_OPMUX_A_ID_PC	2
`define I2D_OPMUX_B_NONE	0
`define I2D_OPMUX_B_RB		1
`define I2D_OPMUX_B_ID_PC	2
`define I2D_OPMUX_B_IMM		3

//alu op
`define I2D_ALUOP_NONE		0
`define I2D_ALUOP_ADD		1
`define I2D_ALUOP_ADDC		2
`define I2D_ALUOP_SUB		3
`define I2D_ALUOP_SUBC		4
`define I2D_ALUOP_MUL		5
`define I2D_ALUOP_MULU		6
`define I2D_ALUOP_DIV		7
`define I2D_ALUOP_DIVU		8
`define I2D_ALUOP_AND		9
`define I2D_ALUOP_OR		8
`define I2D_ALUOP_NOT		9
`define I2D_ALUOP_RSL		10
`define I2D_ALUOP_RSR		11
`define I2D_ALUOP_ASL		12
`define I2D_ALUOP_ASR		13
`define I2D_ALUOP_ERR		14


//mau op
`define I2D_MAUOP_
