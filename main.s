ACIA_DATA       = $7F70   ; ACIA TX/RX data register
ACIA_STATUS     = $7F71   ; ACIA status register
ACIA_CMD        = $7F72   ; ACIA command register
ACIA_CTL        = $7F73   ; ACIA control register

; no parity, no echo, no transmit interrupt, no receive interrupt, DTR active low
ACIA_CMD_FLAGS  = %00001011

; 1 stop bit, 8-bit word length, 19200 baud
ACIA_CTL_FLAGS  = %00011111

RAM_BASE        = $0300   ; first page of available user RAM
RAM_TOP         = $7E00   ; last page of available user RAM

.include "min_mon.asm"
