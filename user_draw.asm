;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  file name   : user_draw.asm                            ;
;  author      : 
;  description : read characters from the keyboard,       ;
;	             then echo them back to the ASCII display ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The following CODE will go into USER's Program Memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CONST R0, x32      ; x-coordinate of rectangle
HICONST R0, x00    ; x-coordinate of rectangle

CONST R1, x05      ; y-coordinate of rectangle
HICONST R1, x00    ; y-coordinate of rectangle

CONST R2, x0A      ; length of rectangle
HICONST R2, x00  ; length of rectangle

CONST R3, x05     ; width of rectangle
HICONST R3, x00    ; width of rectangle

CONST R4, x00     ; color of rectangle
HICONST R4, x7C   ; color of rectangle


TRAP x09

END