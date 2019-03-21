;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  file name   : user_getc_timer.asm                      ;
;  author      : 
;  description : read characters from the keyboard,       ;
;	             then echo them back to the ASCII display ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The following CODE will go into USER's Program Memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CONST R0, x70
HICONST R0, x17        ; R0 = time in milliseconds
TRAP x05               ; this calls "TRAP_GETC_TIMER" in os.asm

END