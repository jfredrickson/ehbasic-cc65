
; minimal monitor for EhBASIC and 6502 simulator V1.05

; To run EhBASIC on the simulator load and assemble [F7] this file, start the simulator
; running [F6] then start the code with the RESET [CTRL][SHIFT]R. Just selecting RUN
; will do nothing, you'll still have to do a reset to run the code.

	.include "basic.asm"

; put the IRQ and MNI code in RAM so that it can be changed

IRQ_vec	= VEC_SV+2		; IRQ code vector
NMI_vec	= IRQ_vec+$0A	; NMI code vector

; setup for the 6502 simulator environment

; IO_AREA	= $F000		; set I/O area for this monitor

; ACIAsimwr	= IO_AREA+$01	; simulated ACIA write port
; ACIAsimrd	= IO_AREA+$04	; simulated ACIA read port

; now the code. all this does is set up the vectors and interrupt code
; and wait for the user to select [C]old or [W]arm start. nothing else
; fits in less than 128 bytes

.segment "CODE"

; reset vector points here

RES_vec
	CLD				; clear decimal mode
	LDX	#$FF			; empty stack
	TXS				; set the stack

init_acia:
  lda #$00
  sta ACIA_STATUS     ; reset the ACIA by setting status to 0
  lda #ACIA_CMD_FLAGS ; configure ACIA command flags
  sta ACIA_CMD	    	; set ACIA command register
  lda #ACIA_CTL_FLAGS	; configure ACIA control flags
  sta ACIA_CTL    		; set ACIA control options

; set up vectors and interrupt code, copy them to page 2

	LDY	#END_CODE-LAB_vec	; set index/count
LAB_stlp
	LDA	LAB_vec-1,Y		; get byte from interrupt code
	STA	VEC_IN-1,Y		; save to RAM
	DEY				; decrement index/count
	BNE	LAB_stlp		; loop if more to do

; now do the signon message, Y = $00 here

LAB_signon
	LDA	LAB_mess,Y		; get byte from sign on message
	BEQ	LAB_nokey		; exit loop if done

	JSR	V_OUTP		; output character
	INY				; increment index
	BNE	LAB_signon		; loop, branch always

LAB_nokey
	JSR	V_INPT		; call scan input device
	BCC	LAB_nokey		; loop if no key

	AND	#$DF			; mask xx0x xxxx, ensure upper case
	CMP	#'W'			; compare with [W]arm start
	BEQ	LAB_dowarm		; branch if [W]arm start

	CMP	#'C'			; compare with [C]old start
	BNE	RES_vec		; loop if not [C]old start

	JMP	LAB_COLD		; do EhBASIC cold start

LAB_dowarm
	JMP	LAB_WARM		; do EhBASIC warm start

; byte out to simulated ACIA

ACIAout
	pha									; push the character onto the stack to preserve it
wait_txd_empty:
  lda ACIA_STATUS     ; read the ACIA status register
  and #%00010000      ; check the transmit data register empty flag
  beq wait_txd_empty  ; if the transmit data register isn't empty yet, wait
	pla									; pull the character back into the accumulator from the stack
  sta ACIA_DATA       ; send the character to the ACIA TX/RX data register
	rts

; byte in from simulated ACIA

ACIAin
  lda ACIA_STATUS     ; read the ACIA status register
  and #%00001000      ; check the receive data available flag
  beq LAB_nobyw   		; if no data available, branch
  lda ACIA_DATA       ; read the received character from the ACIA data register
	sec									; flag character received
	rts

LAB_nobyw
	CLC				; flag no byte received
no_load				; empty load vector for EhBASIC
no_save				; empty save vector for EhBASIC
	RTS

; vector tables

LAB_vec
	.word	ACIAin		; byte in from simulated ACIA
	.word	ACIAout		; byte out to simulated ACIA
	.word	no_load		; null load vector for EhBASIC
	.word	no_save		; null save vector for EhBASIC

; EhBASIC IRQ support

IRQ_CODE
	PHA				; save A
	LDA	IrqBase		; get the IRQ flag byte
	LSR				; shift the set b7 to b6, and on down ...
	ORA	IrqBase		; OR the original back in
	STA	IrqBase		; save the new IRQ flag byte
	PLA				; restore A
	RTI

; EhBASIC NMI support

NMI_CODE
	PHA				; save A
	LDA	NmiBase		; get the NMI flag byte
	LSR				; shift the set b7 to b6, and on down ...
	ORA	NmiBase		; OR the original back in
	STA	NmiBase		; save the new NMI flag byte
	PLA				; restore A
	RTI

END_CODE

LAB_mess
	.byte	$0D,$0A,"6502 EhBASIC [C]old/[W]arm ?",$00
					; sign on string

; system vectors

.segment "VECTORS"

	.word	NMI_vec		; NMI vector
	.word	RES_vec		; RESET vector
	.word	IRQ_vec		; IRQ vector

