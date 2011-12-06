/* i2d_defines.v
 *
 * Copyright: Victor Wen, vic7tor@gmail.com
 *
 * i2d defines
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

//branch instruction
//branch instruction may have 2 opcodes(imm, reg), while the condition in ins[26:0]
`define I2D_INS_B	6'b010110
`define I2D_INS_BR	6'b010111
`define I2D_INS_BE	6'b011000
`define I2D_INS_BER	6'b011001
`define I2D_INS_BNE	6'b011010
`define I2D_INS_BNER	6'b011011
`define I2D_INS_B	6'b011100
`define I2D_INS_BR	6'b011101
`define I2D_INS_B	6'b011110
`define I2D_INS_BR	6'b011111
`define I2D_INS_B	6'b100000
`define I2D_INS_BR	6'b100001
`define I2D_INS_B	6'b100010
`define I2D_INS_BR	6'b100011

//other instruction
`define I2D_INS_NOP	6'b100100
`define I2D_INS_MOV	6'b100101
`define I2D_INS_MOVI	6'b100110
`define I2D_INS_SWI	6'b100111
`define I2D_INS_CALL	6'b101000
`define	I2D_INS_CALLR	6'b110110
`define I2D_INS_RET	6'b101001
`define I2D_INS_RETE	6'b101010
`define I2D_INS_MSR	6'b101011
`define I2D_INS_MRS	6'b101100

