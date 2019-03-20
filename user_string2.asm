;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  file name   : user_string2.asm                            ;
;  author      : 
;  description : read characters from the keyboard,       ;
;	             then echo them back to the ASCII display ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The following CODE will go into USER's Program Memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 .CODE
 .ADDR x0000

 CONST R0, x20
 HICONST R0, x20       ; R0 = x2020; data memory addr
 CONST R1, #0          ; R1 = 0; R1 = length of string 
 TRAP x02              ; this calls "TRAP_GETS" in os.asm
 ADD R4, R1, #0        ; R4 = R1; store R1 in R4 b/c other TRAPS modify R1

 CONST R0, x4C	       ; ASCII code for L
 TRAP x01	           ; this calls "TRAP_PUTC" in os.asm

 CONST R0, x65	       ; ASCII code for e
 TRAP x01	           ; this calls "TRAP_PUTC" in os.asm

 CONST R0, x6E	       ; ASCII code for n
 TRAP x01	           ; this calls "TRAP_PUTC" in os.asm
 
 CONST R0, x67	       ; ASCII code for g
 TRAP x01	           ; this calls "TRAP_PUTC" in os.asm
 
 CONST R0, x74	       ; ASCII code for t
 TRAP x01	           ; this calls "TRAP_PUTC" in os.asm
 
 CONST R0, x68	       ; ASCII code for h
 TRAP x01	           ; this calls "TRAP_PUTC" in os.asm
 
 CONST R0, x20	       ; ASCII code for space
 TRAP x01	           ; this calls "TRAP_PUTC" in os.asm

 CONST R0, x3D	       ; ASCII code for =
 TRAP x01	           ; this calls "TRAP_PUTC" in os.asm

 CONST R0, x20	       ; ASCII code for space
 TRAP x01	           ; this calls "TRAP_PUTC" in os.asm
 
 ADD R0, R4, #15        
 ADD R0, R0, #15        
 ADD R0, R0, #15        
 ADD R0, R0, #3        ; R1 = length of string; we must add 48 to transform from binary to ASCII char
 TRAP x01	           ; this calls "TRAP_PUTC" in os.asm

 CONST R0, x20	       ; ASCII code for space
 TRAP x01	           ; this calls "TRAP_PUTC" in os.asm

 CONST R0, x20
 HICONST R0, x20       ; R0 = x2020; data memory addr
 TRAP x03              ; this calls "TRAP_PUTS" in os.asm


 END