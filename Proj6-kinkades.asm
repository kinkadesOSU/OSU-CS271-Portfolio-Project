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
MAX_LENGTH = 12 ; 10 digits + a sign + null terminator

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
error_message1				BYTE	"ERROR: You did not enter a signed number, or your number was too big."
error_message2				BYTE	"Please try again: "

result_prompt				BYTE	"You entered the following numbers:"
sum_prompt					BYTE	"The sum of these numbers is: "
avg_prompt					BYTE	"The rounded average is: "

input_accumulator			BYTE	MAX_LENGTH DUP(?)

CONVERTED_DIGIT				DWORD	?	; make a local variable for final

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
;PUSH	offset	input_accumulator		; array to hold the converted number
;PUSH	offset	enter_instruction
;CALL	ReadVal

;------------------TEST ReadVal BEFORE CREATING PROCEDURE-----------------------------------
	;ACCUMULATOR			EQU		[EBP + 12]
	;ENTER_INSTRUCTION	EQU		[EBP + 8]

	;LOCAL CONVERTED_DIGIT	DWORD

	;PUSH	EBP						; store stack frame reference
	;MOV		EBP, ESP

	; give the user some instructions
	MOV		EDX, OFFSET ENTER_INSTRUCTION
	CALL	WriteString

	MOV		EDX, input_accumulator
	CALL	ReadString				; gets the user's number as a string (need to convert to an int)
	MOV		ECX, EAX				; EAX has the length of the string in bytes, so we can move that to ECX for the loop counter

	; convert string to int
_conversionLoop:
	LODSB							; puts a byte in AL
	
	; check if byte is a sign
	CMP		al, '-'
	JNE		_checkPositive
	JMP		_nextNumber					; move to the end of the structure to start the loop over with the next character	
		
		
	_checkPositive:
		CMP		al, "+"
		JNE		_noSignIndicated			; assume the number is positive if the user didn't specify
		JMP		_nextNumber					; move to the end of the structure to start the loop over with the next character

	_noSignIndicated:
		CMP		al, '0'
		JB		_errorMessage
		CMP		al, '9'
		JA		_errorMessage

		_doConversion:
			; passes all checks, so we can convert the character to a digit
			MOV		EAX, 0
			MOV		EBX, 10						; divisor for later step

			MOV		CONVERTED_DIGIT, EDX		; EDX has the offset to the accumulator array
			IMUL	EBX							; multiplies EDX by 10
			MOV		EDX, CONVERTED_DIGIT		;1006
			JO		_errorMessage				; if the number overflows
			ADD		EAX, EDX
			JO		_errorMessage				; check overflow again
			JMP		_nextNumber

	_errorMessage:
		;ERROR MESSAGE
	; if it is, indicate that somehow
			; move to the next character
		; it it's not
			; if the character is a digit (compare to characters '0' and '9'. No digit = return 0)
				; MOV EAX, 0 ; clear accumulator
				; MOV EBX, 10
				; MOV the character into DL
				; AND EDX, 0Fh			; converts to binary
				; MOV CONVERTED_DIGIT, EDX ; 0s out CONVERTED_DIGIT
				; IMUL EBX
				; MOV EDX, CONVERTED_DIGIT
				; if there is an overflow (overflow flag comparison)
					;print error message and try again
				; else:
					; add EAX, EDX ; EAX should hold the integer when the loop is done
					; check overflow
					; inc ESI
					; LOOP _conversionLoop
	_nextNumber:
		INC		ESI							; look at the next character
		LOOP _conversionLoop

	call WriteInt ; test to see if the read procedure works















;write the user's value


;say goodbye
PUSH	offset	goodbye
CALL	say_goodbye

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

ReadVal PROC
	ACCUMULATOR			EQU		[EBP + 12]
	ENTER_INSTRUCTION	EQU		[EBP + 8]

	LOCAL CONVERTED_DIGIT	DWORD

	PUSH	EBP						; store stack frame reference
	MOV		EBP, ESP

	; give the user some instructions
	MOV		EDX, ENTER_INSTRUCTION
	CALL	WriteString

	MOV		EDX, ACCUMULATOR
	CALL	ReadString				; gets the user's number as a string (need to convert to an int)
	MOV		ECX, EAX				; EAX has the length of the string in bytes, so we can move that to ECX for the loop counter

	; convert string to int
_conversionLoop:
	LODSB							; puts a byte in AL
	
	; check if byte is a sign
	CMP		al, '-'
	JNE		_checkPositive
	JMP		_nextNumber					; move to the end of the structure to start the loop over with the next character	
		
		
	_checkPositive:
		CMP		al, "+"
		JNE		_noSignIndicated			; assume the number is positive if the user didn't specify
		JMP		_nextNumber					; move to the end of the structure to start the loop over with the next character

	_noSignIndicated:
		CMP		al, '0'
		JB		_errorMessage
		CMP		al, '9'
		JA		_errorMessage

		_doConversion:
			; passes all checks, so we can convert the character to a digit
			MOV		EAX, 0
			MOV		EBX, 10						; divisor for later step

			MOV		CONVERTED_DIGIT, EDX		; EDX has the offset to the accumulator array
			IMUL	EBX							; multiplies EDX by 10
			MOV		EDX, CONVERTED_DIGIT		;1006
			JO		_errorMessage				; if the number overflows
			ADD		EAX, EDX
			JO		_errorMessage				; check overflow again
			JMP		_nextNumber

	_errorMessage:
		;ERROR MESSAGE
	; if it is, indicate that somehow
			; move to the next character
		; it it's not
			; if the character is a digit (compare to characters '0' and '9'. No digit = return 0)
				; MOV EAX, 0 ; clear accumulator
				; MOV EBX, 10
				; MOV the character into DL
				; AND EDX, 0Fh			; converts to binary
				; MOV CONVERTED_DIGIT, EDX ; 0s out CONVERTED_DIGIT
				; IMUL EBX
				; MOV EDX, CONVERTED_DIGIT
				; if there is an overflow (overflow flag comparison)
					;print error message and try again
				; else:
					; add EAX, EDX ; EAX should hold the integer when the loop is done
					; check overflow
					; inc ESI
					; LOOP _conversionLoop
	_nextNumber:
		INC		ESI							; look at the next character
		LOOP _conversionLoop

	call WriteInt ; test to see if the read procedure works

	; clean up stack
	mov		ESP, EBP
	pop		EBP
	ret		4

ReadVal ENDP



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
