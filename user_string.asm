;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  file name   : user_string.asm                          ;
;  author      : 
;  description : read characters from the keyboard,       ;
;	             then echo them back to the ASCII display ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The following CODE will go into USER's Program Memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.DATA                 ; lines below are DATA memory
.ADDR x4000           ; where to start in DATA memory

global_array          ; label address x4000: global_array
.FILL x49             ; load address x4000 with the ASCII code for I 
.FILL x20             ; load address x4001 with the ASCII code for space  
.FILL x6C             ; load address x4002 with the ASCII code for l 
.FILL x6F             ; load address x4003 with the ASCII code for o  
.FILL x76             ; load address x4004 with the ASCII code for v  
.FILL x65             ; load address x4005 with the ASCII code for e
.FILL x20             ; load address x4006 with the ASCII code for space  
.FILL x43             ; load address x4007 with the ASCII code for C  
.FILL x49             ; load address x4008 with the ASCII code for I  
.FILL x53             ; load address x4009 with the ASCII code for S  
.FILL x00             ; load address x400A with the ASCII code for NULL  

.CODE
.ADDR x0000

LEA R0, global_array  ; load starting address of DATA to R0
TRAP x03              ; this calls "TRAP_PUTS" in os.asm

END