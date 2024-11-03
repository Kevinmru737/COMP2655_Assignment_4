; Name:        Kevin Oh
; Email:       koh705@mtroyal.ca
; Course:      COMP2655-002
; Assignment:  Assignment #4
; Due Date:    November 16, 2023
; Filename:    ROMAN.S
; Instructor:  Paul Pospisil
; 
; Purpose: To translate a C program that converts user-input numbers
;	   in Improved Roman notation to Arabic notation.
; Program Details:
; 	Input: A string of characters representing Roman numeral
;
;	Output: The input Roman numeral number converted
;		into its corresponding value in Arabic notation
;
;	AL Quirks: Due to the subroutine provided for printing to the
;		   console, multiple repetitive loops are used when
;		   printing strings.
;
;		   When reading in input from the keyboard only the
;		   CR (carriage return) character is checked for
;		   when the user hits the enter key.
; 
;	Assumptions:
;		Valid input for this program is restricted to the range
;		of digits in Improved Roman Notation being:
;				I,V,X,L,C,D,M
;		as well as 'Q' which is used to terminate the program
;		and the enter key which is used to indicate the 
;		full roman number has been input
;  
; 	Limitations:
;		This calculator will only work within the range of 
;		values representing 1 to 3999
;
; Modification History:
;		Nov. 03, 2023:
;			-Basic I/O added
;			-Structure implementation
;
;		Nov. 06, 2023:
;			-Error switch case
;			-Error test 1
;
;		Nov. 13, 2023:
;			-Error2-5
;
;		Nov. 14, 2023:
;			-Fixing bugs (Subtraction/Incorrect Errors)
;
;		Nov. 15, 2023:
;			-Fixing error from C solution		
;
; Program Status:
;	What is completed/working:
;		All test cases returned the correct values.
;		All aspects of the program are assumed to be working.
;
;	Testing:
;		
;		Test Plan:
;			Because the given C code solution would be difficult
;			and time consuming to perform white box testing on
;			(as the C solution was provided to us), the following
;			test values are based on a black box testing scheme
;			ensuring the appropriate values are returned, based
;			on the values returned when the C program is run.
;
;		Error (1) Invalid Roman Digit:
;			Test cases - F, x, v, q, 0, 9, {, ?
;			Expected result - appropriate error message
;
;		Error (2) Digits out of order:
;			Test cases - IM, LC, LD, MVIM, VIC, IIV, XXD
;			Expected result - appropriate error message
;
;		Error (3) Digit already used as modifier:
;			Test cases - CMC, XCX, VIXI
;			Expected result - appropriate error message
;
;		Error (4) Illegal combination:
;			Test cases - XCL
;			Expected result - appropriate error message
;
;		Error (5) Exceeding Max Digit Occurrence:
;			Test cases - IIII, VV, XXXX, LL, CCCC, DD, MMMM
;			Expected result - appropriate error message
;
;		Non-error cases:
;			(Single digit dalues)
;			Test cases -      I, V,  X,  L,   C,   D,    M
;			Expected result - 1, 5, 10, 50, 100, 500, 1000
;
;			(Data size bounds(biggest byte/smallest word))
;			Test cases - CCLV, CCLVI
;			Expected result - 255,256
;		
;			(Different combinations of digits)
;			Test cases - MIV, CL, MDCLXVI, XVI, XCI, MCMXCIV
;			Expected result - 1004, 150, 1666, 16, 91, 1994
;	
;			(Has subtraction)
;			Test cases - IV, MLIX, DCXL, CIXL
;			Expected result - 4, 1059, 640, 139
;
;			(Bounds)
;			Test cases - I, MMMCMXCIX
;			Expected result - 1, 3999
;
;			(Largest Number of Digits Possible)
;			Test cases - MMMDCCCLXXXVIII
;			Expected result - 3888
;
;		Untested:
;			The specific comparisons and mathematical theory
;			behind how/why the conversion calculator works
;			are untested.			
;
;		Not Working:
;			Nothing found yet.
;	 
; Registers:
;			Data Registers
;
;	d0 - Handles I/O for the user
;	   - Input - Hold character read from the keyboard
;	   - Output - Holds character being written to the screen
;
;	d1 - Holds the status of the variable: error, 0   == no error
;	   - also checks for program quits 	    , 1-5 == error
;	   		
;	d2 - Used for comparisons of variables such as r_index
;	   - Calculations - Used to reference r_index for offsets
;
;	d3 - Used for index-like comparisons, displacements
;	   - Calculations - Used to reference r_last for offsets
;	
;	d4 - Used to compare the elements of roman_str
;	   - Calculations - Used to compare array elements
;
;	d5 - Used as a counter to clear all_roman elements 
;
;	d6 - Output - Used to convert the sum into each character
;		      for output
;	   - Calculations - holds/computes the value of sum
;
;	d7 - Used to hold index values to access and compare struct
;	     elements
;
;			Address Registers
;
;	a0 - Holds strings for I/O
;	   - Input - Hold addresses of string to be filled
;
;	a1 - Holds strings for I/O
;	   - Output - Hold addresses of string to be output
;
;	a2 - Used to fill/reference the array of type ROMAN_DIGIT
;	     called all_roman
;	
;	a3 - Used to reference the user input string roman_str
;
;	a4 - Used to store the character of the sum as separate
;	     characters for output
; 
	    
;subroutines
	xref	read_char
	xref	write_char
	xref	exit

;Constant Section
ASCII_INT	equ	'0'	;to convert ASCII to actual
				;integer value

CR		equ	13	;carriage return
LF		equ	10	;line feed
NULL		equ	0	;null

TRUE		equ	1
FALSE		equ	0

QUIT		equ	'Q'	;character for exiting program
MAX_ROMANS	equ	7	;all possible digits in Roman notation
MAX_STRING	equ	20	;maximum size of user input string
NO_ERROR	equ	0	
MAX_DIGIT_COUNT	equ	3	

ROMAN_DIGIT	equ	10	;struct ROMAN_DIGIT

DIGIT		equ	0	;Roman numeral character
ARAB_VALUE	equ	2	;corresponding Arabic notation value
SUBTRACT_INDEX	equ	4	;index used for subtraction
COUNT		equ	5	;times a digit has been used
MODIFIED	equ	6	;if a digit has had a modifier
MODIFIER	equ	7	;if a digit has been a modifier
MAX_TIMES	equ	8	;max number of times a digit can appear

start:
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7

fill_all_roman:				;initializing the array all_roman
	lea	all_roman,a2			;{'I',1,-1,0,F,F,3}
	move.b	#'I',DIGIT(a2,d2)
	move.w	#1,ARAB_VALUE(a2)
	move.b	#-1,SUBTRACT_INDEX(a2)
	move.b	#0,COUNT(a2)
	move.b	#FALSE,MODIFIED(a2)
	move.b	#FALSE,MODIFIER(a2)
	move.b	#MAX_DIGIT_COUNT,MAX_TIMES(a2)
	adda.l	#ROMAN_DIGIT,a2	

	move.b	#'V',DIGIT(a2)			;{'V',5,0,0,F,F,1}
	move.w	#5,ARAB_VALUE(a2)
	move.b	#0,SUBTRACT_INDEX(a2)
	move.b	#0,COUNT(a2)
	move.b	#FALSE,MODIFIED(a2)
	move.b	#FALSE,MODIFIER(a2)
	move.b	#1,MAX_TIMES(a2)
	adda.l	#ROMAN_DIGIT,a2	
	
	move.b	#'X',DIGIT(a2)			;{'X',10,0,0,F,F,3}
	move.w	#10,ARAB_VALUE(a2)
	move.b	#0,SUBTRACT_INDEX(a2)
	move.b	#0,COUNT(a2)
	move.b	#FALSE,MODIFIED(a2)
	move.b	#FALSE,MODIFIER(a2)
	move.b	#MAX_DIGIT_COUNT,MAX_TIMES(a2)
	adda.l	#ROMAN_DIGIT,a2	

	move.b	#'L',DIGIT(a2)			;{'L',50,2,0,F,F,1}
	move.w	#50,ARAB_VALUE(a2)
	move.b	#2,SUBTRACT_INDEX(a2)
	move.b	#0,COUNT(a2)
	move.b	#FALSE,MODIFIED(a2)
	move.b	#FALSE,MODIFIER(a2)
	move.b	#1,MAX_TIMES(a2)
	adda.l	#ROMAN_DIGIT,a2	
	
	move.b	#'C',DIGIT(a2)			;{'C',100,2,0,F,F,3}
	move.w	#100,ARAB_VALUE(a2)
	move.b	#2,SUBTRACT_INDEX(a2)
	move.b	#0,COUNT(a2)
	move.b	#FALSE,MODIFIED(a2)
	move.b	#FALSE,MODIFIER(a2)
	move.b	#MAX_DIGIT_COUNT,MAX_TIMES(a2)
	adda.l	#ROMAN_DIGIT,a2	
	
	move.b	#'D',DIGIT(a2)			;{'D',500,4,0,F,F,1}
	move.w	#500,ARAB_VALUE(a2)
	move.b	#4,SUBTRACT_INDEX(a2)
	move.b	#0,COUNT(a2)
	move.b	#FALSE,MODIFIED(a2)
	move.b	#FALSE,MODIFIER(a2)
	move.b	#1,MAX_TIMES(a2)
	adda.l	#ROMAN_DIGIT,a2
	
	move.b	#'M',DIGIT(a2)			;{'M',1000,4,0,F,F,3}
	move.w	#1000,ARAB_VALUE(a2)
	move.b	#4,SUBTRACT_INDEX(a2)
	move.b	#0,COUNT(a2)
	move.b	#FALSE,MODIFIED(a2)
	move.b	#FALSE,MODIFIER(a2)
	move.b	#MAX_DIGIT_COUNT,MAX_TIMES(a2)	
	lea	all_roman,a2

load_intro_str:
	lea	intro_str,a0

print_intro_str:	
	move.b	(a0)+,d0
	beq	load_prompt_str
	jsr	write_char
	bra	print_intro_str

load_prompt_str:
	lea	prompt_str,a0	

print_prompt_str:
	move.b	(a0)+,d0		;repeating prompt string
	beq	load_roman_str		;is displayed every program
	jsr	write_char		;iteration
	bra	print_prompt_str

load_roman_str:
	lea	roman_str,a1

read_roman:				;taking in the user input Roman
	jsr	read_char		;numeral to be converted
	cmp.b	#CR,d0			;into arabic notation
	beq	check_for_quit		;press the enter key to confirm
	move.b	d0,(a1)+		;input
	bra	read_roman

check_for_quit:
	move.b	#NULL,(a1)		;null-terminating roman_str

	move.b	roman_str,d1
	cmp.b	#QUIT,d1		;exit code is 'Q'
	beq	done_program
	
	move.b 	#CR,d0			;go to a new line
	jsr	write_char
	move.b	#LF,d0
	jsr	write_char

	move.w	#0,sum			;initialize/reset variables that
	move.b	#0,s_index		;are used for comparisons in the
	move.b	#NO_ERROR,error		;user input as well as providing 
	move.b	#MAX_ROMANS-1,r_last	;the final output

	lea	roman_str,a3

check_for_null:	
	clr.l	d3			;check every user input character	
	move.b	s_index,d3
	cmp.b	#NULL,(a3,d3.w)		;until NULL or an error is reached
	beq	null_or_error_found	;string[s_index] != NULL

check_for_error:	
	cmp.b	#NO_ERROR,error		;error == NO_ERROR
	bne	null_or_error_found

	clr.l	d4
	move.b	#MAX_ROMANS-1,r_index	;used to start from the 'back' of
					;all_roman and check each DIGIT
					;with each char in roman_str
check_digits:		
	move.b	r_index,d2		;implementing string[6]
	mulu.w	#ROMAN_DIGIT,d2		
			
	tst.w	d2			;check if r_index < 0
	bmi	set_error_1		
		
	move.b	(a3,d3.w),d4		;checking if each roman_str
	cmp.b	DIGIT(a2,d2.w),d4	;character corresponds to a
	beq	roman_digit_found	;existing Roman character
	
	sub.b	#1,r_index		;r_index--
	bra	check_digits

set_error_1:
	move.b	#1,error		;if r_index < 0, error = 1	
	bra	null_or_error_found
	
roman_digit_found:
	move.b	r_index,d3		;if r_index > r_last
	cmp.b	r_last,d3		;then it is possible to have
	bls	is_in_order		;an incorrect order of Roman
					;digits, this is checked using
	move.b	r_last,d2		;each digits SUBTRACT_INDEX
	mulu.w	#ROMAN_DIGIT,d3	

	cmp.b	SUBTRACT_INDEX(a2,d3.w),d2			
	bne	set_error_2

	clr.l	d7
	move.b	d2,d7
	mulu.w	#ROMAN_DIGIT,d7
	cmp.b	#1,COUNT(a2,d7.w)
	bls	correct_order

set_error_2:
	move.b	#2,error			;if Roman digits are out
	bra	null_or_error_not_found_yet	;of order, error 2 is set

correct_order:					;sum calculations
	mulu.w	#ROMAN_DIGIT,d2
	clr.l	d6				
	move.w	ARAB_VALUE(a2,d2.w),d6		;subtraction, if needed		
	lsl.l	d6				;is done using the index
	neg.w	d6				;and arab value of the
	add.w	ARAB_VALUE(a2,d3.w),d6		;previous roman digit
	add.w	d6,sum

	clr.l	d7	
	move.b	SUBTRACT_INDEX(a2,d3.w),d7
	mulu.w	#ROMAN_DIGIT,d7
	sub.b	#1,COUNT(a2,d7.w)

	add.b	#1,COUNT(a2,d3.w)
	move.b	#TRUE,MODIFIED(a2,d3.w)
	
	clr.l	d7
	move.b	SUBTRACT_INDEX(a2,d3.w),d7
	mulu.w	#ROMAN_DIGIT,d7
	move.b	#TRUE,MODIFIER(a2,d7.w)
	bra	null_or_error_not_found_yet

is_in_order:					;checking modifier status
	mulu.w	#ROMAN_DIGIT,d3
	move.b	#TRUE,d7
	cmp.b	MODIFIER(a2,d3.w),d7
	bne	modifier_unused

set_error_3:					;if modifier == true
	move.b	#3,error			;then error 3 is set
	bra	null_or_error_not_found_yet	

modifier_unused:
	clr.l	d4				;checking for illegal
	add.w	#ROMAN_DIGIT,d3			;combinations of digits
	move.b	SUBTRACT_INDEX(a2,d3.w),d4
	sub.w	#ROMAN_DIGIT,d3	
	cmp.b	SUBTRACT_INDEX(a2,d3.w),d4
	bne	legal_combination
	
	clr.l	d7
	move.b	SUBTRACT_INDEX(a2,d3.w),d7
	mulu.w	#ROMAN_DIGIT,d7
	move.b	MODIFIER(a2,d7.w),d4
	cmp.b	#TRUE,d4
	bne	legal_combination
	
set_error_4:					;illegal combination
	move.b	#4,error			;error case 4
	bra	null_or_error_not_found_yet

legal_combination:				;checking number of times
	add.b	#1,COUNT(a2,d3.w)		;a digit has been used
	move.b	COUNT(a2,d3.w),d4		;in relation to the
	cmp.b	MAX_TIMES(a2,d3.w),d4		;MAX_TIMES element of 
	bgt	exceeded_max_times		;each ROMAN_DIGIT
	
	clr.l	d6			
	move.w	ARAB_VALUE(a2,d3.w),d6
	add.w	d6,sum
	move.b	r_index,r_last
	bra	null_or_error_not_found_yet

exceeded_max_times:				;error case 5 (a digit has
	move.b	#5,error			;appeared more than allowed)
						;end of errorchecks
null_or_error_not_found_yet:
	cmp.b	#NO_ERROR,error
	bne	null_or_error_found
	add.b	#1,s_index
	move.b	r_index,r_last		;r_last = r_index
	bra	check_for_null

null_or_error_found:		
	cmp.b	#NO_ERROR,error
	beq	convert_sum
	
error_found:				;if error != 0
	lea	pre_error_message,a1
	
print_pre_error_message:		;printed for every error case
	move.b	(a1)+,d0
	beq	print_invalid_input
	jsr	write_char
	bra	print_pre_error_message

print_invalid_input:
	move.b	s_index,d0		;prints position followed by the
	add.b	#ASCII_INT,d0		;character causing errors
	jsr	write_char

	lea roman_str,a1
	move.b	#'(',d0
	jsr	write_char
	move.b	s_index,d7
	ext.w	d7
	move.b	(a1,d7.w),d0
	jsr	write_char
	move.b	#')',d0
	jsr	write_char

	move.b	#CR,d0			;newline
	jsr	write_char
	move.b	#LF,d0
	jsr	write_char

check_error_case:			
	cmp.b	#1,error
	beq	error_case_1
	cmp.b	#2,error
	beq	error_case_2
	cmp.b	#3,error
	beq	error_case_3
	cmp.b	#4,error
	beq	error_case_4
	cmp.b	#5,error
	beq	error_case_5
	bra	error_case_default

error_case_1:
	lea	error_case_1_message,a1

print_error_case_1_message:
	move.b	(a1)+,d0
	beq	done_with_errors
	jsr	write_char
	bra	print_error_case_1_message

error_case_2:
	lea	error_case_2_message,a1

print_error_case_2_message:
	move.b	(a1)+,d0
	beq	done_with_errors
	jsr	write_char
	bra	print_error_case_2_message

error_case_3:
	lea	error_case_3_message,a1

print_error_case_3_message:
	move.b	(a1)+,d0
	beq	done_with_errors
	jsr	write_char
	bra	print_error_case_3_message

error_case_4:
	lea	error_case_4_message,a1

print_error_case_4_message:
	move.b	(a1)+,d0
	beq	done_with_errors
	jsr	write_char
	bra	print_error_case_4_message

error_case_5:
	lea	error_case_5_message,a1

print_error_case_5_message:
	move.b	(a1)+,d0
	beq	done_with_errors
	jsr	write_char
	bra	print_error_case_5_message

error_case_default:				;should not be reached
	lea	error_default_message,a1	
						
print_error_default_message:
	move.b	(a1)+,d0
	beq	done_with_errors
	jsr	write_char
	bra	print_error_default_message
	
convert_sum:		
	lea	sum_array,a4
	move.w	sum,d6

convert_to_char:
	divu	#10,d6			;converts each digit of sum into
	swap	d6			;the corresponding ASCII char
	add.b	#'0',d6			;value and stores it in an array
	move.b	d6,(a4)+
	clr.w	d6
	swap	d6
	bne	convert_to_char

print_sum:
	cmpa.l	#sum_array,a4		;prints each sum digit
	beq	done_with_sum		;one by one
	move.b	-(a4),d0
	jsr	write_char
	bra	print_sum

done_with_sum:
	move.b	#CR,d0
	jsr	write_char
	move.b	#LF,d0
	jsr	write_char

done_with_errors:
	clr.l	d2			;index counter for all_roman
	clr.l	d5
	move.b	#MAX_ROMANS-1,d5	;for loop counter	
	
reset_all_roman:
	move.b	#0,COUNT(a2,d2.w)
	move.b	#FALSE,MODIFIED(a2,d2.w)
	move.b	#FALSE,MODIFIER(a2,d2.w)
	add.w	#ROMAN_DIGIT,d2
	dbra	d5,reset_all_roman

	bra	load_prompt_str		;while(string[0] != QUIT)

done_program:				;should only be reached if 'Q'
	jsr	exit			;is entered by the user

sum:				;for holding the sum of the conversion	
	ds.w	1
	
				;holds all the different characters used
all_roman:			;in Improved Roman notation and
				;corresponding values used in conversions	
	ds.b	ROMAN_DIGIT*MAX_ROMANS	

roman_str:
	ds.b	MAX_STRING+1	;holds the string of roman numerals
				;input by the user
intro_str:
	dc.b	"This program converts numbers in Improved "
	dc.b	"Roman notation to Arabic notation",CR,LF
	dc.b	"Input is limited to UPPER case Roman digits "
	dc.b	"only.",CR,LF
	dc.b	"To exit the program type only the Enter key."
	dc.b	CR,LF,NULL

prompt_str:
	dc.b	CR,LF,"Input a Roman number (Press 'Q' to exit): "
	dc.b	NULL

pre_error_message:
	dc.b	"Character at position ",NULL

error_case_1_message:
	dc.b	"	is not a valid Roman digit",CR,LF,NULL

error_case_2_message:
	dc.b	"	is out of order for a Improved Roman "
	dc.b	"number",CR,LF,NULL

error_case_3_message:
	dc.b	"	has been used as a modifier and can't be "
	dc.b	"used unmodified",CR,LF,NULL

error_case_4_message:
	dc.b	"	combination of the modified prior digit "
	dc.b	"and this digit is",CR,LF
	dc.b	"	an invalid Roman number",CR,LF,NULL

error_case_5_message:
	dc.b	"	has exceeded the maximum occurrences for "
	dc.b	"this digit",CR,LF,NULL

error_default_message:
	dc.b	"In error handling with an invalid error code"
	dc.b	CR,LF,NULL

s_index:		;current index of the user input string
	ds.b	1
r_last:			;index of the previous all_roman element
	ds.b	1
r_index:		;index the found all_roman element
	ds.b	1
error:			;set error flags (1-5), 0 == no errors
	ds.b	1
	
sum_array:
	ds.b	4	;max number of digits to output is 4
	dc.b	NULL

	even
	