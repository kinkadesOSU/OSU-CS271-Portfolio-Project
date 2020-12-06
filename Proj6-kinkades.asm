TITLE Designing low-level I/O procedures      (Proj6-kinkades.asm)

; Author: Sam Kinkade
; Last Modified: December 3rd, 2020
; OSU email address: kinkades@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                 Due Date: December 6th, 2020
; Description: This file takes 10 inputs from the user, validates them for size / number / sign, prints out the numbers, and returns the sum and average of them. 
; This is accomplished via macros and without the aid of ReadInt, ReadDec, WriteInt, or WriteDec

INCLUDE Irvine32.inc

; (insert macro definitions here)

; (insert constant definitions here)
MAX_LENGTH = 10 ; 10 digits + a sign + null terminator

.data

; (insert variable definitions here)
intro1						BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",0								; opening statement to user
intro2						BYTE	"Written byte: Sam Kinkade",0

instruction1				BYTE	"Please provide 10 signed decimal integers.",0
instruction2				BYTE	"Each number needs to be small enough to fit inside a 32 bit register. After",0
instruction3				BYTE	"you have finished inputting the raw numbers I will display a list of the integers,",0
instruction4				BYTE	"their sum, and their average value.",0
goodbye						BYTE	"Thanks for playing!",0

enter_instruction			BYTE	"Please enter a signed number: ",0
error_message1				BYTE	"ERROR: You did not enter a signed number, or your number was too big.",0
error_message2				BYTE	"Please try again: ",0

result_prompt				BYTE	"You entered the following numbers: ",0
sum_prompt					BYTE	"The sum of these numbers is: ",0
avg_prompt					BYTE	"The rounded average is: ",0

user_input_array			BYTE	10 DUP(?),0

;-----------------CONVERT STRING TO INT-----------------
input_accumulator			BYTE	MAX_LENGTH DUP(?)
BUFFER						BYTE	21 DUP(0)
byteCount					DWORD	?
;result						DWORD	0	; make a local variable for final number to be saved
LOCAL_ERROR1				EQU DWORD PTR [EBP - 4]
LOCAL_ERROR2				EQU DWORD PTR [EBP - 8]
;-----------------CONVERT INT TO STRING-----------------
int_string					BYTE	MAX_LENGTH DUP(?),0
char_list					BYTE	"0123456789ABCDEF"
sign_indicator				DWORD	0						; need a boolean to tell us which sign the number is. Can't use the sign flag since it's controlled by the system. Assume it's a positive number to start (makes life easier)


.code
main PROC

; (insert executable instructions here)
; introduce the program to the user
PUSH	offset	intro1
PUSH	offset	intro2
PUSH	offset	instruction1
PUSH	offset	instruction2
PUSH	offset	instruction3
PUSH	offset	instruction4
CALL	introduction


; read in the user's value
;PUSH	OFFSET	user_input_array
PUSH	OFFSET	error_message1
PUSH	OFFSET	error_message2
PUSH	OFFSET	enter_instruction
PUSH	OFFSET	BUFFER
PUSH	SIZEOF	BUFFER
CALL	convert_string_to_int	

;------------DELETE AT FINAL----------------------------------------
Call	CrLf
Call	WriteInt ; test that the string is being converted properly
Call	CrLf
Call	CrLf


MOV		ECX, 0
MOV		EDI, offset int_string
ADD		EDI, (MAX_LENGTH-1)
MOV		EBX, 10
		
CMP		EAX, 0
JG		_divideLoop
NEG		EAX						; make the negative number positive
MOV		sign_indicator, 1


 _divideLoop:
 	MOV		EDX, 0
 	DIV		EBX

 	XCHG	EAX, EDX						; swap the quotient and the remainder
 	PUSH	EBX
 	MOV		EBX, offset char_list
 	XLAT									; looks up the ASCII value from the char_list in EAX
 	POP		EBX

 	MOV		[EDI], al									; saves the ascii digit
 	;DEC		EDI
 	DEC		EDI
 	XCHG	EAX, EDX						; swap the quotient and the remainder

 	INC		ECX
 	CMP		EAX, 0					
 	JNZ		_divideLoop						; if the quotient isn't 0, we need to divide again


	; add negative sign if needed
	CMP		sign_indicator, 1				; 1 means the sign is negative
	JNE		_printString
	INC		ECX								; increment ECX to tell WriteString that there is 1 more character to print
	MOV		BYTE PTR[EDI], "-"
	DEC		EDI

 	; print the string
 	_printString:
	MOV		EDX, OFFSET result_prompt
	CALL	WriteString
	
	INC		EDI								; skip the sign bit (should be empty for a positive number)
 	MOV		EDX, EDI						; move pointer for the string to EDX for WriteString
 	CALL	WriteString
	CALL	CrLf
 ; calculate results







;------------DELETE AT FINAL----------------------------------------







;PUSH	sign_indicator
;PUSH	OFFSET result_prompt
;PUSH	EAX							; has number to convert
;CALL	convert_int_to_string

; calculate results


;say goodbye
PUSH	offset	goodbye
CALL	say_goodbye
CALL	CrLf
	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)
introduction PROC
	INTRO_1				EQU		[EBP + 28]
	INTRO_2				EQU		[EBP + 24]
	INSTRUCTION_1		EQU		[EBP + 20]
	INSTRUCTION_2		EQU		[EBP + 16]
	INSTRUCTION_3		EQU		[EBP + 12]
	INSTRUCTION_4		EQU		[EBP + 8]

	PUSH	EBP						; store stack frame reference
	MOV		EBP, ESP		
	MOV		EDX, INTRO_1
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, INTRO_2
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf
	MOV		EDX, INSTRUCTION_1
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, INSTRUCTION_2
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, INSTRUCTION_3
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, INSTRUCTION_4
	CALL	WriteString
	CALL	CrLf

	; clean up stack
	mov		ESP, EBP
	pop		EBP
	ret		24

introduction ENDP

convert_string_to_int PROC

	;LIST_OF_NUMBERS				EQU [EBP + 28]
	ERROR1						EQU [EBP + 24]
	ERROR2						EQU	[EBP + 20]
	USER_INSTRUCTION			EQU [EBP + 16]
	STRING_BUFFER				EQU [EBP + 12]
	SIZEOF_STRING_BUFFER		EQU [EBP + 8]

	PUSH	EBP						; store stack frame reference
	MOV		EBP, ESP
	SUB		ESP, 8					; reserve space for locals
	
	MOV		EAX, ERROR1
	MOV		LOCAL_ERROR1, EAX
	MOV		EAX, ERROR2
	MOV		LOCAL_ERROR2, EAX
	PUSH	EBP						; save stack pointer because EBP is going to be used later

	MOV		EAX, ERROR1
	MOV		LOCAL_ERROR1, EAX

	MOV		EAX, ERROR2
	MOV		LOCAL_ERROR2, EAX

	; give the user some instructions
	MOV		EDX, USER_INSTRUCTION
	CALL	WriteString

	_enterValue:
		MOV		EDX, STRING_BUFFER
		MOV		ECX, SIZEOF_STRING_BUFFER
		CALL	ReadString					; gets the user's number as a string (need to convert to an int)
		MOV		ECX, EAX					; moves number of bytes into ECX for the conversion steps
		MOV		ESI, STRING_BUFFER			; moves the string to ESI so LODSB can iterate through it

		; convert string to int
		LODSB								; puts a byte in AL
		MOV		dl, al						; preserve the character so we can use EAX later
		MOV		EBP, 1						; assume the number is positive to begin with. Logic get's complicated to have the default later on	
		
		_checkNegative:
			CMP		dl, '-'
			JNE		_checkPositive
			MOV		EBP, -1

			LODSB							; load the next digit
			MOV		dl, al					; preserve the character so we can use EAX later
			DEC		ECX						; ECX would've had the length of the digit plus 1 for the sign. We need to ignore that
		
		_checkPositive:
			CMP		dl, "+"
			JNE		_noSignIndicated		; assume the number is positive if the user didn't specify
			MOV		EBP, 1				
			
			LODSB							; load the next digit
			MOV		dl, al					; preserve the character so we can use EAX later
			DEC		ECX						; ECX would've had the length of the digit plus 1 for the sign. We need to ignore that
		
		_noSignIndicated:
			CMP		dl, '0'
			JB		_errorMessage
			CMP		dl, '9'
			JA		_errorMessage

			POP		EAX						; get the stack pointer off the stack
			PUSH	EBP						; +/- 1
			MOV		EBP, EAX

			PUSH	EBP						; has our stack pointer, but is also being used for the calculation
			MOV		EBP, 0					; use EBP for calc because EAX is locked up
			MOV		EAX, 0
			MOV		EBX, 10

		_conversionLoop:
			; passes all checks, so we can convert the character to a digit
			AND		EDX, 0Fh
			PUSH	EDX							; save EDX because IMUL messes with it
			MOV		EAX, EBP
			IMUL	EBX							; EAX = EAX * EBX
			POP		EDX							; bring EDX back
		
			JO		_errorMessage
			MOV		EBP, EAX
			add		EBP, EDX
			JO		_errorMessage
			LODSB								; load character to al
			MOV		dl, al						; LODSB puts the byte in al, but the loop uses EDX, so the byte needs to be in dl
			LOOP		_conversionLoop

		;MOV		EDI, LIST_OF_NUMBERS				; offset to address of array that will hold the ten
		MOV		EAX, EBP							; EBP has been holding the result, but EAX will need it for WriteInt
		;STOSB										; stores the byte. USES EDI!!!!!!!!!
		
		POP		EBP									; EBP has the old stack pointer value	
		MOV		EDI, EBP							; preserve it because EDI is going to be used
		POP		EBP									; EBP should have the +/- 1
		IMUL	EBP									; EAX * EBP ( +/- 1)
		MOV		EBP, EDI							; restore stack pointer to EBP
		JMP		_endProcedure

	_errorMessage:
	; print error message
		POP		EAX
		MOV		EBP, EAX
		MOV		EDX, LOCAL_ERROR1
		CALL	WriteString
		CALL	CrLf
		MOV		EDX, LOCAL_ERROR2
		CALL	WriteString
		JMP		_enterValue
		PUSH	EBP

	_endProcedure:
	mov		ESP, EBP
	pop		EBP
	ret		20

convert_string_to_int ENDP


convert_int_to_string PROC
	;INT_SIGN			EQU		[EBP + 16]
	USER_MESSAGE		EQU		[EBP + 12]
	NUMBER_TO_CONVERT	EQU		[EBP + 8]
	
	LOCAL INT_SIGN_LOCAL:DWORD

	PUSH	EBP						; store stack frame reference
	MOV		EBP, ESP	

	;MOV		EAX, INT_SIGN
	;MOV		INT_SIGN_LOCAL, EAX

	MOV		EAX, 0					; clear EAX to test that it's being passed properly

	; set up various registers
	MOV		ECX, 0
	MOV		EDI, offset int_string
	ADD		EDI, (MAX_LENGTH - 1)
	MOV		EBX, 10
	MOV		EAX, NUMBER_TO_CONVERT				


	OR		EAX, EAX
	JNS		_divideLoop
	NEG		EAX						; make the negative number positive
	MOV		INT_SIGN_LOCAL, 1



	_divideLoop:
		MOV		EDX, 0
		DIV		EBX

		XCHG	EAX, EDX						; swap the quotient and the remainder
		PUSH	EBX
		MOV		EBX, offset char_list
		XLAT									; looks up the ASCII value from the char_list in EAX
		POP		EBX

		STOSB									; saves the ascii digit
		DEC		EDI								; decrement EDI because STOSB automatically increments it
		DEC		EDI								; decrement again to point to the correct memory address
		XCHG	EAX, EDX						; swap the quotient and the remainder

		INC		ECX
		OR		EAX, EAX					
		JNZ		_divideLoop						; if the quotient isn't 0, we need to divide again

	; print user message
	MOV		EDX, USER_MESSAGE
	CALL	WriteString

	; print the string
	INC		EDI
	MOV		EDX, EDI
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

	; clean up stack
	mov		ESP, EBP
	pop		EBP
	ret		8

convert_int_to_string ENDP

say_goodbye PROC
	GOOD_BYE		EQU		[EBP + 8]
	
	PUSH	EBP						; store stack frame reference
	MOV		EBP, ESP	
	MOV		EDX, GOOD_BYE
	CALL	WriteString
	CALL	CrLF

	; clean up stack
	mov		ESP, EBP
	pop		EBP
	ret		4

say_goodbye ENDP


END main