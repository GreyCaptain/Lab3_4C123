;/*****************************************************************************/
; OSasm.s: low-level OS commands, written in assembly                       */
; Runs on LM4F120/TM4C123/MSP432
; Lab 3 starter file
; March 2, 2016




        AREA |.text|, CODE, READONLY, ALIGN=2
        THUMB
        REQUIRE8
        PRESERVE8

        EXTERN  RunPt            ; currently running thread
        EXPORT  StartOS
        EXPORT  SysTick_Handler
        IMPORT  Scheduler


SysTick_Handler                ; 1) Saves R0-R3,R12,LR,PC,PSR
    CPSID   I                  ; 2) Prevent interrupt during switch
	PUSH    {R4-R11}		   ; 3) Saves the remaining regs R4-R11
	LDR     R0, =RunPt         ; 4) R0 = pointer to RunPt, OLD THREAD!
	LDR     R1, [R0]           ;    R1 = RunPt
	STR     SP, [R1]           ; 5) Save SP into TCB
	;LDR     R1, [R1, #4]       ; 6) R1 = RunPt->Next
	;STR     R1, [R0]           ;    RunPt = R1
	PUSH    {R0,LR}
    BL      Scheduler
    POP     {R0,LR}
	LDR     R1, [R0]           ; 6) R1 = RunPt, new thread
	LDR     SP, [R1]           ; 7) New Thread. SP = Runpt->sp
	POP     {R4-R11}           ; 8) Restore regs R4-R11
    CPSIE   I                  ; 9) tasks run with interrupts enabled
    BX      LR                 ; 10) restore R0-R3,R12,LR,PC,PSR
	

StartOS
	LDR     R0, =RunPt         ; R0 = pointer to RunPt, currently running thread
	LDR     R1, [R0]           ; R1 = value of RunPt
	LDR     SP, [R1]           ; New thread. SP = Runpt->sp
    POP     {R4-R11}          ; Restore regs R4-R11
	POP     {R0-R3}            ; Restore regs R0-R3
	POP     {R12}              ; Restore reg R12
	ADD     SP, SP, #4         ; Discard LR from from initial stack
	POP     {LR}               ; Start location of the new thread is inserted to LR from PC. 
	ADD     SP, SP, #4         ; Discard PSR 
    CPSIE   I                  ; Enable interrupts at processor level
    BX      LR                 ; start first thread

    ALIGN
    END
