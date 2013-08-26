// Copyright (c) 2013 Owen McAree
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

.setcallreg	r30.w1
.origin 0
.entrypoint START
#include "../include/pru.hp"

START:
// Preamble to set up OCP and shared RAM
	LBCO	r0, CONST_PRUCFG, 4, 4		// Enable OCP master port
	CLR 	r0, r0, 4					// Clear SYSCFG[STANDBY_INIT] to enable OCP master port
	SBCO	r0, CONST_PRUCFG, 4, 4
	MOV		r0, SHARED_RAM+0x20						// Configure the programmable pointer register for PRU1 by setting c28_pointer[15:0]
	MOV		r1, PRU0_CTRL+CTPPR0					// field to 0x0120.  This will make C28 point to 0x00012000 (PRU shared RAM).
	SBBO	r0, r1, 0, 4
// End of preamble

	MOV		r0, 40000		// pulse length

// Send sync
SYNC:
	CALL	HI
	MOV		r3, 31
SYNC_LO:
	SUB		r3, r3, 1
	CALL	LO
	QBNE	SYNC_LO, r3, 0
	
	MOV		r3, 50*4 + 13*4		// Number of bits
	MOV		r4, 50*4			// Offset
SEND_BIT:
	LBCO	r5, CONST_PRUSHAREDRAM, r4, 4
	ADD		r4, r4, 4
	QBEQ	FINISH, r4, r3
	QBEQ	SEND_1, r5, 1
	QBEQ	SEND_0, r5, 0
	QBEQ	SEND_F, r5, 0xF
	QBA		FINISH
SEND_1:
	CALL	HI
	CALL	HI
	CALL	HI
	CALL	LO
	CALL	HI
	CALL	HI
	CALL	HI
	CALL	LO
	QBA		SEND_BIT
SEND_0:
	CALL	HI
	CALL	LO
	CALL	LO
	CALL	LO
	CALL	HI
	CALL	LO
	CALL	LO
	CALL	LO
	QBA		SEND_BIT
SEND_F:
	CALL	HI
	CALL	LO
	CALL	LO
	CALL	LO
	CALL	HI
	CALL	HI
	CALL	HI
	CALL	LO
	QBA		SEND_BIT
	
FINISH:
//	QBA		SYNC
	HALT
	
HI:
	SET		r30.t0
	MOV		r2, r0
STAY_HI:
	SUB		r2, r2, 1
	QBNE	STAY_HI, r2, 0
RET	

LO:
	CLR		r30.t0
	MOV		r2, r0
STAY_LO:
	SUB		r2, r2, 1
	QBNE	STAY_LO, r2, 0
RET	