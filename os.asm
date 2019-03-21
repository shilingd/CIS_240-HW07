;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  file name   : os.asm                                 ;
;  author      : 
;  description : LC4 Assembly program to serve as an OS ;
;                TRAPS will be implemented in this file ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;   OS - TRAP VECTOR TABLE   ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.OS
.CODE
.ADDR x8000
  ; TRAP vector table
  JMP TRAP_GETC           ; x00
  JMP TRAP_PUTC           ; x01
  JMP TRAP_GETS           ; x02
  JMP TRAP_PUTS           ; x03
  JMP TRAP_TIMER          ; x04
  JMP TRAP_GETC_TIMER     ; x05
  JMP TRAP_RESET_VMEM	  ; x06
  JMP TRAP_BLT_VMEM	      ; x07
  JMP TRAP_DRAW_PIXEL     ; x08
  JMP TRAP_DRAW_RECT      ; x09
  JMP TRAP_DRAW_SPRITE    ; x0A

  ;
  ; TO DO - add additional vectors as described in homework 
  ;
  
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;   OS - MEMORY ADDRESSES & CONSTANTS   ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; these handy alias' will be used in the TRAPs that follow
  USER_CODE_ADDR .UCONST x0000	; start of USER code
  OS_CODE_ADDR 	 .UCONST x8000	; start of OS code

  OS_GLOBALS_ADDR .UCONST xA000	; start of OS global mem
  OS_STACK_ADDR   .UCONST xBFFF	; start of OS stack mem

  OS_KBSR_ADDR .UCONST xFE00  	; alias for keyboard status reg
  OS_KBDR_ADDR .UCONST xFE02  	; alias for keyboard data reg

  OS_ADSR_ADDR .UCONST xFE04  	; alias for display status register
  OS_ADDR_ADDR .UCONST xFE06  	; alias for display data register

  OS_TSR_ADDR .UCONST xFE08 	; alias for timer status register
  OS_TIR_ADDR .UCONST xFE0A 	; alias for timer interval register

  OS_VDCR_ADDR	.UCONST xFE0C	; video display control register
  OS_MCR_ADDR	.UCONST xFFEE	; machine control register
  OS_VIDEO_NUM_COLS .UCONST #128
  OS_VIDEO_NUM_ROWS .UCONST #124


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; OS DATA MEMORY RESERVATIONS ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.DATA
.ADDR xA000
OS_GLOBALS_MEM	.BLKW x1000

;;; Labels to be used in TRAP_DRAW_RECT

X_COORD_IN_OS_GLOBAL_MEM .UCONST xA000
Y_COORD_IN_OS_GLOBAL_MEM .UCONST xA001
LENGTH_IN_OS_GLOBAL_MEM .UCONST xA002
WIDTH_IN_OS_GLOBAL_MEM .UCONST xA003
COLOR_IN_OS_GLOBAL_MEM .UCONST xA004
OS_VIDEO_MEM_IN_OS_GLOBAL_MEM .UCONST xA005
OS_NUM_OF_ROWS_IN_OS_GLOBAL_MEM .UCONST xA006
OS_NUM_OF_COLS_IN_OS_GLOBAL_MEM .UCONST xA007
R7_IN_OS_GLOBAL_MEM .UCONST xA008


;;; LFSR value used by lfsr code
LFSR .FILL 0x0001

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; OS VIDEO MEMORY RESERVATION ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.DATA
.ADDR xC000
OS_VIDEO_MEM .BLKW x3E00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;   OS & TRAP IMPLEMENTATIONS BEGIN HERE   ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.CODE
.ADDR x8200
.FALIGN
  ;; first job of OS is to return PennSim to x0000 & downgrade privledge
  CONST R7, #0   ; R7 = 0
  RTI            ; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_GETC   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Get a single character from keyboard
;;; Inputs           - none
;;; Outputs          - R0 = ASCII character from ASCII keyboard

.CODE
TRAP_GETC
    LC R0, OS_KBSR_ADDR  ; R0 = address of keyboard status reg
    LDR R0, R0, #0       ; R0 = value of keyboard status reg
    BRzp TRAP_GETC       ; if R0[15]=1, data is waiting!
                             ; else, loop and check again...

    ; reaching here, means data is waiting in keyboard data reg

    LC R0, OS_KBDR_ADDR  ; R0 = address of keyboard data reg
    LDR R0, R0, #0       ; R0 = value of keyboard data reg
    RTI                  ; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_PUTC   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Put a single character out to ASCII display
;;; Inputs           - R0 = ASCII character to write to ASCII display
;;; Outputs          - none

.CODE
TRAP_PUTC
  LC R1, OS_ADSR_ADDR 	; R1 = address of display status reg
  LDR R1, R1, #0    	; R1 = value of display status reg
  BRzp TRAP_PUTC    	; if R1[15]=1, display is ready to write!
		    	    ; else, loop and check again...

  ; reaching here, means console is ready to display next char

  LC R1, OS_ADDR_ADDR 	; R1 = address of display data reg
  STR R0, R1, #0    	; R1 = value of keyboard data reg (R0)
  RTI			; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_GETS   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Get a string of characters from the ASCII keyboard
;;; Inputs           - R0 = Address to place characters from keyboard
;;; Outputs          - R1 = Length of the string without the NULL

.CODE
TRAP_GETS

  ; Check the keyboard status register to see if there is a new char 
  ; and if there is then grab the new char value from the data register 
  ; and store it in R4

  LC R4, OS_KBSR_ADDR  ; R4 = address of keyboard status reg
  LDR R4, R4, #0       ; R4 = value of keyboard status reg
  BRzp TRAP_GETS       ; if R4[15]=1, data is waiting!
                           ; else, loop and check again...

  ; reaching here, means data is waiting in keyboard data reg

  LC R4, OS_KBDR_ADDR  ; R4 = address of keyboard data reg
  LDR R4, R4, #0       ; R4 = value of keyboard data reg

  
  ; Put each new char value (R4) into the data memory addr (R0).  
  ; Before doing so, check to see if R0 is a valid data memory addr. 

  CONST R3, xFF
  HICONST R3, x7F
  CMP R0, R3           ; sets  NZP (R0 - R3)
  BRp RETURN_TO_CALLER_TRAP_GETS           ; tests NZP (was R0 - x7FFF positive?, if yes, go to RTI); 
                       ; if R0 was not a valid address in User Data Memory then return to caller
  
  CONST R3, x00
  HICONST R3, x20
  CMP R0, R3           ; sets  NZP (R0 - R3)
  BRnz RETURN_TO_CALLER_TRAP_GETS          ; tests NZP (was R0 - x2000 negative or zero?, if yes, go to RTI); 
                       ; if R0 was not a valid address in User Data Memory then return to caller
  
  ; reaching here, means R0 is a valid data memory addr.
    
  CMPI R4, x0A         ; sets  NZP (R4 - x0A)
  BRz END_OF_STR       ; tests NZP (was R4 - x0A zero?, if yes, go to END); 
                           ; if R4 was <enter> then reached end of str 
                               ; and must add NULL to data memory addr  
  
  STR R4, R0, #0       ; put the value in R4 into the data memory addr stored in R0 
  ADD R0, R0, #1       ; R0 = R0 + 1 (new data memory addr)
  ADD R1, R1, #1       ; R1 = R1 + 1; R1 = length of str
  JMP TRAP_GETS
  
  END_OF_STR
  CONST R5, x00        ; R5 = ASCII character for NUL
  STR R5, R0, #0       ; put NULL into the data memory addr stored in R0 
                           ; to represent the end of the str
 
  RETURN_TO_CALLER_TRAP_GETS
  RTI

;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_PUTS   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Put a string of characters out to ASCII display
;;; Inputs           - R0 = Address for first character
;;; Outputs          - none

.CODE
TRAP_PUTS
  
  CONST R3, xFF
  HICONST R3, x7F
  CMP R0, R3           ; sets  NZP (R0 - R3)
  BRp RETURN_TO_CALLER_TRAP_PUTS    ; tests NZP (was R0 - x7FFF positive?, if yes, go to RTI); 
                                        ; if R0 was not a valid address in User Data Memory then return to caller
  
  CONST R3, x00
  HICONST R3, x20
  CMP R0, R3           ; sets  NZP (R0 - R3)
  BRn RETURN_TO_CALLER_TRAP_PUTS   ; tests NZP (was R0 - x2000 negative?, if yes, go to RTI); 
                                       ; if R0 was not a valid address in User Data Memory then return to caller
  
  LDR R2, R0, #0       ; R2 = R0; load the ASCII character from the address held in R0
  
  WHILE_LOOP 
      CMPI R2, x00       ; sets  NZP (R2 - x00); 
      BRz RETURN_TO_CALLER_TRAP_PUTS  ; tests NZP (was R2 - x00 zero?, if yes, go to RTI); 
                                          ; check if ASCII character is NULL, if yes then return to caller 
 
      LC R1, OS_ADSR_ADDR 	; R1 = address of display status reg
      LDR R1, R1, #0    	; R1 = value of display status reg
      BRzp TRAP_PUTS    	; if R1[15]=1, display is ready to write! else, loop and check again...

      ; reaching here, means console is ready to display next char

      LC R1, OS_ADDR_ADDR 	; R1 = address of display data reg
      STR R2, R1, #0    	; R1 = value of ASCII character (R2)  
      
      ADD R0, R0, #1        ; R0 = R0 + 1; get the data memory addr of the next ASCII char   
      LDR R2, R0, #0        ; R1 = R0; load the ASCII character from the address held in R0   
      JMP WHILE_LOOP

  RETURN_TO_CALLER_TRAP_PUTS
  RTI


;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_TIMER   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function:
;;; Inputs           - R0 = time to wait in milliseconds
;;; Outputs          - none

.CODE
TRAP_TIMER
  LC R1, OS_TIR_ADDR 	; R1 = address of timer interval reg
  STR R0, R1, #0    	; Store R0 in timer interval register

COUNT
  LC R1, OS_TSR_ADDR  	; Save timer status register in R1
  LDR R1, R1, #0    	; Load the contents of TSR in R1
  BRzp COUNT    	; If R1[15]=1, timer has gone off!

  ; reaching this line means we've finished counting R0

  RTI       		; PC = R7 ; PSR[15]=0



;;;;;;;;;;;;;;;;;;;;;;;   TRAP_GETC_TIMER   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Get a single character from keyboard
;;; Inputs           - R0 = time to wait
;;; Outputs          - R0 = ASCII character from keyboard (or NULL)

.CODE
TRAP_GETC_TIMER

  LC R1, OS_TIR_ADDR 	; R1 = address of timer interval reg
  STR R0, R1, #0    	; Store R0 in timer interval register

  GETC_TIMER_COUNT
      LC R1, OS_TSR_ADDR  	; Save timer status register in R1
      LDR R1, R1, #0    	; Load the contents of TSR in R1     
      BRzp CHECK_KEY_STAT_REG    	    ; If R1[15]=1, timer has gone off!

  ; reaching this line means we've finished counting R0
  
  CONST R0, #0             ; R0 = 0 because user didn't type in char before timer ended
  BRz RETURN_TO_CALLER_GETC_TIMER     ; if R0 = 0, go to RETURN_TO_CALLER_GETC_TIMER

  CHECK_KEY_STAT_REG
      LC R0, OS_KBSR_ADDR  ; R0 = address of keyboard status reg
      LDR R0, R0, #0       ; R0 = value of keyboard status reg
      BRzp GETC_TIMER_COUNT           ; if R0[15]=1, data is waiting!
                                        ; else, loop and check again...

    ; reaching here, means data is waiting in keyboard data reg

      LC R0, OS_KBDR_ADDR  ; R0 = address of keyboard data reg
      LDR R0, R0, #0       ; R0 = value of keyboard data reg

  RETURN_TO_CALLER_GETC_TIMER
  RTI                  ; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRAP_RESET_VMEM ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; In double-buffered video mode, resets the video display
;;; DO NOT MODIFY this trap, it's for future HWs
;;; Inputs - none
;;; Outputs - none
.CODE	
TRAP_RESET_VMEM
  LC R4, OS_VDCR_ADDR
  CONST R5, #1
  STR R5, R4, #0
  RTI


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRAP_BLT_VMEM ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_BLT_VMEM - In double-buffered video mode, copies the contents
;;; of video memory to the video display.
;;; DO NOT MODIFY this trap, it's for future HWs
;;; Inputs - none
;;; Outputs - none
.CODE
TRAP_BLT_VMEM
  LC R4, OS_VDCR_ADDR
  CONST R5, #2
  STR R5, R4, #0
  RTI


;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_DRAW_PIXEL   ;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Draw point on video display
;;; Inputs           - R0 = row to draw on (y)
;;;                  - R1 = column to draw on (x)
;;;                  - R2 = color to draw with
;;; Outputs          - none

.CODE
TRAP_DRAW_PIXEL
  LEA R3, OS_VIDEO_MEM       ; R3=start address of video memory
  LC  R4, OS_VIDEO_NUM_COLS  ; R4=number of columns

  CMPIU R1, #0    	         ; Checks if x coord from input is > 0
  BRn END_PIXEL
  CMPIU R1, #127    	     ; Checks if x coord from input is < 127
  BRp END_PIXEL
  CMPIU R0, #0    	         ; Checks if y coord from input is > 0
  BRn END_PIXEL
  CMPIU R0, #123    	     ; Checks if y coord from input is < 123
  BRp END_PIXEL

  MUL R4, R0, R4      	     ; R4= (row * NUM_COLS)
  ADD R4, R4, R1      	     ; R4= (row * NUM_COLS) + col
  ADD R4, R4, R3      	     ; Add the offset to the start of video memory
  STR R2, R4, #0      	     ; Fill in the pixel with color from user (R2)

END_PIXEL
  RTI       		         ; PC = R7 ; PSR[15]=0
  

;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_DRAW_RECT   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Draw a rectangle on the video display 
;;; Inputs    - R0 = “x coordinate” of upper-left corner of the rectangle.
;;;           - R1 = “y coordinate” of upper-left corner of the rectangle.
;;;           - R2 = length of the rectangle (in number of pixels).
;;;           - R3 = width of the side of the rectangle (in number of pixels).
;;;           - R4 = the color of the rectangle
;;; Outputs   A rectangle on the video display; 
;;;           If full length/ width arguments are invalid then no rectangle is drawn

.CODE
TRAP_DRAW_RECT

  ;; Check to see if the starting x-coordinate + length - 1 (full length of rect) is valid. 
  ;; Check to see if the starting y-coordinate + width - 1 (full width of rect) is valid. 

  ADD R5, R2, R0           ; R5 = R2 + R0; length = length + x-coordinate 
  ADD R5, R5, #-1          ; R5 = R5 - 1; full length = length + x-coordinate - 1 
  CMPIU R5, #0    	       ; Checks if full length from input is > 0
  BRnz END_PIXEL_FOR_DRAW_RECT
  CMPIU R5, #127    	   ; Checks if full length from input is =< 127
  BRp END_PIXEL_FOR_DRAW_RECT
  
  ADD R5, R3, R1           ; R5 = R3 + R0; width = width + y-coordinate 
  ADD R5, R5, #-1          ; R5 = R5 - 1; full width = width + y-coordinate - 1 
  CMPIU R5, #0    	       ; Checks if full width from input is > 0
  BRnz END_PIXEL_FOR_DRAW_RECT
  CMPIU R5, #123    	   ; Checks if full width from input is =< 123
  BRp END_PIXEL_FOR_DRAW_RECT

  ;; Store inputs (R0-R4) inside of the os global mem, starting at addr xA000.
  ;; Store OS_VIDEO_MEM, OS_VIDEO_NUM_ROWS, and OS_VIDEO_NUM_COLS inside of the os global mem.
  ;; Create a label for each addr in os global mem to be able to use later w/o iterating. 
  
  LEA R5, OS_GLOBALS_MEM   ; R5 = xA000; start address of os global mem
  STR R0, R5, #0           ; R5 = R0; store R0 (x-coordinate) into the os global mem addr stored in R5
  
  ADD R5, R5, #1           ; R5 = R5 + 1; increase the os global mem addr by 1 
  STR R1, R5, #0           ; R5 = R1; store R1 (y-coordinate) into the os global mem addr stored in R5 

  ADD R5, R5, #1           ; R5 = R5 + 1; increase the os global mem addr by 1 
  STR R2, R5, #0           ; R5 = R2; store R2 (length) into the os global mem addr stored in R5 

  ADD R5, R5, #1           ; R5 = R5 + 1; increase the os global mem addr by 1 
  STR R3, R5, #0           ; R5 = R3; store R3 (width) into the os global mem addr stored in R5 

  ADD R5, R5, #1           ; R5 = R5 + 1; increase the os global mem addr by 1 
  STR R4, R5, #0           ; R5 = R4; store R4 (color) into the os global mem addr stored in R5 

  ADD R5, R5, #1           ; R5 = R5 + 1; increase the os global mem addr by 1 
  LEA R0, OS_VIDEO_MEM     ; R0 =start address of video memory
  STR R0, R5, #0           ; R5 = R0; store R0 (os video mem) into the os global mem addr stored in R5 

  ADD R5, R5, #1           ; R5 = R5 + 1; increase the os global mem addr by 1 
  LC R0, OS_VIDEO_NUM_ROWS     ; R0 =number of rows (0-123)
  STR R0, R5, #0           ; R5 = R0; store R0 (num rows) into the os global mem addr stored in R5 

  ADD R5, R5, #1           ; R5 = R5 + 1; increase the os global mem addr by 1 
  LC R0, OS_VIDEO_NUM_COLS     ; R0 = number of columns (0-127)
  STR R0, R5, #0           ; R5 = R0; store R0 (num cols) into the os global mem addr stored in R5 

  ADD R5, R5, #1           ; R5 = R5 + 1; increase the os global mem addr by 1 
  STR R7, R5, #0           ; R7 = R0; store R7 (PC value) into the os global mem addr stored in R5 

  ;; Draw the rectangle by drawing each individual pixel, starting with the starting coordinate.
  ;; It is row major so first identify the row (y-coordinate) and then the column (x-coordinate). 
  
  ; Load arguments from os global mem     
  LC R0, Y_COORD_IN_OS_GLOBAL_MEM           ; R0 = y-coord in os global mem
  LDR R0, R0, #0            ; R0 = y-coord 
  LC R1, OS_NUM_OF_COLS_IN_OS_GLOBAL_MEM    ; R1 = num of cols in os global mem
  LDR R1, R1, #0            ; R1 = num of cols 
  LC R2, X_COORD_IN_OS_GLOBAL_MEM           ; R2 = x-coord in os global mem
  LDR R2, R2, #0            ; R1 = x-coord  
  LC R3, OS_VIDEO_MEM_IN_OS_GLOBAL_MEM      ; R3 = start of video mem in os global mem
  LDR R3, R3, #0            ; R3 = start of video mem
  LC R5, COLOR_IN_OS_GLOBAL_MEM      ; R5 = color in os global mem
  LDR R5, R5, #0            ; R5 = color
  
  ; Load the length from the os global mem
  LC R6, LENGTH_IN_OS_GLOBAL_MEM     ; R6 = length in os global mem
  LDR R6, R6, #0            ; R6 = length
  ADD R6, R6, R2            ; R6 = R6 + R2; length = length + x-coord
  ADD R6, R6, #-1           ; R6 = R6 - 1; full length = length + x-coord - 1
  
  ; Load the width from the os global mem 
  LC R7, WIDTH_IN_OS_GLOBAL_MEM       ; R7 = width in os global mem
  LDR R7, R7, #0            ; R7 = width
  ADD R7, R7, R0            ; R7 = R7 + R0; width = width + y-coord
  ADD R7, R7, #-1           ; R7 = R7 - 1; full width = width + y-coord - 1
      
  ; Fill in the pixel at the (x,y) coordinate 
  
  LOOP_TO_FILL_OUT_LENGTH
           
      ; Draw pixel
      MUL R4, R0, R1      	    ; R4= (row * NUM_COLS)
      ADD R4, R4, R2      	    ; R4= (row * NUM_COLS) + col
      ADD R4, R4, R3      	    ; Add the offset to the start of video memory
      STR R5, R4, #0      	    ; Fill in the pixel with color from user (R2)

      ;; Increase the x-coord by 1. 
      ;; If x-coord > full length, then row is filled out, so need to go to next row
      ADD R2, R2, #1            ; R2 = R2 + 1; add 1 to the x-coord 
      CMPU R6, R2               ; Check if R6 >= R2 
                                    ;(if x-coord is not greater than full length, then not done filling out row) 
      BRzp LOOP_TO_FILL_OUT_LENGTH    

  ;; If reach this point then the length has been filled out: one row is completed
  ;; Now, add 1 to the y-coord to increase the width: go to the next row
  
  LOOP_TO_INCREASE_WIDTH 
   
      ;; Increase the y-coord by 1. 
      ;; If y-coord > full width, then we have reached the full width so can return rectangle 
      
      ; Reset the x-coord to its original value
      LC R2, X_COORD_IN_OS_GLOBAL_MEM           ; R2 = x-coord in os global mem
      LDR R2, R2, #0            ; R1 = x-coord  
  
      ADD R0, R0, #1            ; R1 = R1 + 1; add 1 to the y-coord
      CMPU R7, R0               ; Check if R7 >= R0 
                                    ;(if y-coord is not greater than full width, then not done filling out rectangle) 
      BRzp LOOP_TO_FILL_OUT_LENGTH  
 
  END_PIXEL_FOR_DRAW_RECT
  LC R7, R7_IN_OS_GLOBAL_MEM    ; R7 = PC value stored in os global mem
  LDR R7, R7, #0                ; R7 = PC value
  RTI


;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_DRAW_SPRITE   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: EDIT ME!
;;; Inputs    EDIT ME!
;;; Outputs   EDIT ME!

.CODE
TRAP_DRAW_SPRITE

  ;;
  ;; TO DO: complete this trap
  ;;

  RTI


;; TO DO: Add TRAPs in HW