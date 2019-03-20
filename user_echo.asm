;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  file name   : user_echo.asm                            ;
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

;;;  Students - run this code and see how it works before modifying!
;;;  once you load it into PennSim, press "continue" instead of step to run
;;;  type a character by clicking on the white box in left hand corner of PennSim


;;;  The following code will output "Type Here>" on the ASCII display
;;;  then it will then read one character from the keyboard
;;;  and output it back to the display
;;;  HINT: you could simplify this with a directive called ".STRINGZ" - see your textbook!

	CONST R0, x54	; ASCII code for T
	TRAP x01	    ; this calls "TRAP_PUTC" in os.asm	

	CONST R0, x79   ; ASCII code for y
	TRAP x01

	CONST R0, x70   ; ASCII code for p
	TRAP x01

	CONST R0, x65   ; ASCII code for e
	TRAP x01

	CONST R0, x20   ; ASCII code for space
	TRAP x01

	CONST R0, x48	; ASCII code for H
	TRAP x01

	CONST R0, x65	; ASCII code for e
	TRAP x01

	CONST R0, x72	; ASCII code for r
	TRAP x01

	CONST R0, x65	; ASCII code for e
	TRAP x01

	CONST R0, x3E	; ASCII code for >
	TRAP x01
	
	 
	;; Add code to "loop" reading characters from keyboard and outputting them to display
	;; until the "enter" key is pressed

	;; pseudocode of algorithm you must implement for problem #1
	;;
	;; loop until (R0 == enter)
	;;    read character from keyboard into R0 using TRAP_GETC
	;;    write character from R0 to ASCII display using TRAP_PUTC
	;;    repeat loop...
	;; loop_end 

    WHILE_LOOP 
        TRAP x00       ; this calls "TRAP_GETC" in os.asm; output is R0
        CMPI R0, x0A   ; sets  NZP (R0 - x0A)
        BRz END        ; tests NZP (was R0 - x0A zero?, if yes, go to END); 
                       ; if R0 was <enter> then the loop would END    
                       
        TRAP x01       ; this calls "TRAP_PUTC" in os.asm; input is R0 	
        JMP WHILE_LOOP

END


