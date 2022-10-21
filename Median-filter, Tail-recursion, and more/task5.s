.global _start
//Input Image: 
// **each word contains 1 byte dedicated to each channel**
//Note that if the window size (n by m) is even, the median is the average of the middle two numbers.

input_image: 
.word 1057442138, 2410420899, 519339369, 2908788659, 1532551093, 4249151175, 4148718620, 788746931, 3777110853, 2023451652
.word 3000595192,   1424215634, 3130581119, 3415585405, 2359913843, 1600975764, 1368061213, 2330908780, 3460755284, 464067332
.word 2358850436,   1191202723, 2461113486, 3373356749, 3070515869, 4219460496, 1464115644, 3200205016, 1316921258, 143509283
.word 3846979011,   2393794600, 618297079,  2016233561, 3509496510, 1966263545, 568123240,  4091698540, 2472059715, 2420085477
.word 395970857,    2217766702, 44993357,   694287440,  2233438483, 1231031852, 2612978931, 1464238350, 3373257252, 2418760426
.word 4005861356,   288491815, 3533591053,  754133199,  3745088714, 2711399263, 2291899825, 2117953337, 1710526325, 1989628126
.word 465096977,    3100163617, 195551247,  3884399959, 422483884,  2154571543, 3380017320, 380355875,  4161422042, 654077379
.word 2168260534,   3266157063, 3870711524, 2809320128, 3980588369, 2342816349, 1283915395, 122534782,  4270863000, 2232709752
.word 1946888581,   1956399250, 3892336886, 1456853217, 3602595147, 1756931089, 858680934,  2326906362, 2258756188, 1125912976
.word 1883735002,   1851212965, 3925218056, 2270198189, 3481512846, 1685364533, 1411965810, 3850049461, 3023321890, 2815055881

//row: .word 1
//column: .word 1

//Filter must be applied to each channel
//red: 	.word 1
//green: 	.word 1
//blue: 	.word 1
//alpha: 	.word 1

red_window: 	.space 25
blue_window: 	.space 25
green_window: 	.space 25
alpha_window: 	.space 25

output_image: .space 144 //36*4

_start:

/*
Go through each column in each row (nested for loops)
Track row and column (2 pointers)
While row and column are less than the length of each 
	- (while loop, length is 5 for both)
Take the values around that value
Add them to an array
Use insertion sort subroutine
Add the middle value from the result to a new matrix
*/

LDR A1, =input_image //A1 is input image
LDR A2, =output_image //A2is the output image
PUSH {A1, A2, LR}
BL traverseArr
BL insertionSort_alpha
BL insertionSort_blue
BL insertionSort_green
BL insertionSort_red
//BL window_median
POP {A1, A2, LR}
B end

traverseArr: 
	PUSH {V1-V8}
	MOV V1, #0//Column Counter
	MOV V2, #0//Counter
	LDR V3, =alpha_window //Space in mem for alpha
	LDR V4, =blue_window //Space in mem for blue
	LDR V5, =green_window //Space in mem for green
	LDR V6, =red_window //Space in mem for red
	MOV V7, #0 //Array Counter
	
column_loop:
	CMP V2, #4//if column>number of columns, end
	BGT end1
	
createArr:
	//B column_loop
	LDR V8, [A1, V1, LSL #2] //Get 32-bit value at the first place
	STRB V8, [V4, V1] //Store Alpha into the Alpha window
	
	ROR V8, V8, #8 //Rotate by 8 bits to get the next window
	STRB V8, [V5, V1] //Store Blue into the Blue window
	
	ROR V8, V8, #8 //Rotate by 8 bits to get the next window
	STRB V8, [V5, V1] //Store Green into the Green window
	
	ROR V8, V8, #8 //Rotate by 8 bits to get the next window
	STRB V8, [V5, V1] //Red Blue into the Red window
	
	ROR V8, V8, #8
	
	ADD V7, V7, #1
	ADD V1, V1, #1
	ADD V2, V2, #1
	
if: //Array is full, end
	CMP V7, #25
	BGE end2
	
	B column_loop	

//column_loop:
//	CMP V2, #5//if column>number of columns, end
//	BGT end1

end1: //ending row loop
	ADD V1, V1, #5 //Get to next row
	MOV V2, #0 // Array counter set back to 0
	B column_loop
	
end2:
	POP {V1-V8}
	BX LR

//TO DO:
//Carry out insertion sort on the constructed arrays
//Get median of each array
//Construct new 6x6 matrix
	
insertionSort_alpha:
    MOV A1, V4 //Passing the pointer to the array
	MOV A2, #25 //Passing the length of the array
	
	//Using more than 4 arguments, so stack is used
	
	PUSH {A1, A2, LR} //Save params and LR on stack, A1 is TOS
	BL forinit_alpha
	POP {A1, A2, LR}
	B end
	
forinit_alpha:
	PUSH {V1-V6} //Callee-save, V1 is TOS
	MOV V1, #1 //V1 is 'i'
	LDR V2, [SP, #20] //Load the first array value from the stack

forcond_alpha:
	CMP V1, A2 //Updated CPSR with V1-A2 (i-n)
	BLT forexe_alpha //If valid, execute for loop
	POP {V1-V6}
	BX LR
	
forexe_alpha:
	LDR V6, [V2, V1, LSL #2]
	MOV V3, V1 //Copy i into j, V3 is 'j'
	
whilecond_alpha:
	CMP V3, #0
	BLE endwhile_alpha
	SUB V4, V3, #1 //V4 <- V3 - 1 for the condition, V4 is j-1
	LDR V5, [V2, V4, LSL #2] //Multiply the value by 4 (word size) and add to SP
	CMP V5, V6 //arr[j-1]-arr[i], if less than 0, end while loop
	BLE endwhile_alpha
	STR V5, [V2, V3, LSL #2] //V5 -> [V2+(V3<<2)]
	SUB V3, V3, #1
	B whilecond_alpha //Branch back to while loop
	
endwhile_alpha:
	STR V6, [V2, V3, LSL #2]
	
	ADD V1, V1, #1 //Increment 'i' (for loop)
	B forcond_alpha

insertionSort_blue:
	MOV A1, V5 //Passing the pointer to the array
	MOV A2, #25 //Passing the length of the array
	
	//Using more than 4 arguments, so stack is used
	
	PUSH {A1, A2, LR} //Save params and LR on stack, A1 is TOS
	BL forinit_alpha
	POP {A1, A2, LR}
	B end
	
forinit_blue:
	PUSH {V1-V6} //Callee-save, V1 is TOS
	MOV V1, #1 //V1 is 'i'
	LDR V2, [SP, #20] //Load the first array value from the stack

forcond_blue:
	CMP V1, A2 //Updated CPSR with V1-A2 (i-n)
	BLT forexe_blue //If valid, execute for loop
	POP {V1-V6}
	BX LR
	
forexe_blue:
	LDR V6, [V2, V1, LSL #2]
	MOV V3, V1 //Copy i into j, V3 is 'j'
	
whilecond_blue:
	CMP V3, #0
	BLE endwhile_blue
	SUB V4, V3, #1 //V4 <- V3 - 1 for the condition, V4 is j-1
	LDR V5, [V2, V4, LSL #2] //Multiply the value by 4 (word size) and add to SP
	CMP V5, V6 //arr[j-1]-arr[i], if less than 0, end while loop
	BLE endwhile_blue
	STR V5, [V2, V3, LSL #2] //V5 -> [V2+(V3<<2)]
	SUB V3, V3, #1
	B whilecond_blue //Branch back to while loop
	
endwhile_blue:
	STR V6, [V2, V3, LSL #2]
	
	ADD V1, V1, #1 //Increment 'i' (for loop)
	B forcond_blue

insertionSort_green:
	MOV A1, V6 //Passing the pointer to the array
	MOV A2, #25 //Passing the length of the array
	
	//Using more than 4 arguments, so stack is used
	
	PUSH {A1, A2, LR} //Save params and LR on stack, A1 is TOS
	BL forinit_green
	POP {A1, A2, LR}
	B end
	
forinit_green:
	PUSH {V1-V6} //Callee-save, V1 is TOS
	MOV V1, #1 //V1 is 'i'
	LDR V2, [SP, #20] //Load the first array value from the stack

forcond_green:
	CMP V1, A2 //Updated CPSR with V1-A2 (i-n)
	BLT forexe_green //If valid, execute for loop
	POP {V1-V6}
	BX LR
	
forexe_green:
	LDR V6, [V2, V1, LSL #2]
	MOV V3, V1 //Copy i into j, V3 is 'j'
	
whilecond_green:
	CMP V3, #0
	BLE endwhile_green
	SUB V4, V3, #1 //V4 <- V3 - 1 for the condition, V4 is j-1
	LDR V5, [V2, V4, LSL #2] //Multiply the value by 4 (word size) and add to SP
	CMP V5, V6 //arr[j-1]-arr[i], if less than 0, end while loop
	BLE endwhile_green
	STR V5, [V2, V3, LSL #2] //V5 -> [V2+(V3<<2)]
	SUB V3, V3, #1
	B whilecond_green //Branch back to while loop
	
endwhile_green:
	STR V6, [V2, V3, LSL #2]
	
	ADD V1, V1, #1 //Increment 'i' (for loop)
	B forcond_green

insertionSort_red:
	MOV A1, V7 //Passing the pointer to the array
	MOV A2, #25 //Passing the length of the array
	
	//Using more than 4 arguments, so stack is used
	
	PUSH {A1, A2, LR} //Save params and LR on stack, A1 is TOS
	BL forinit_red
	POP {A1, A2, LR}
	B end
	
forinit_red:
	PUSH {V1-V6} //Callee-save, V1 is TOS
	MOV V1, #1 //V1 is 'i'
	LDR V2, [SP, #20] //Load the first array value from the stack

forcond_red:
	CMP V1, A2 //Updated CPSR with V1-A2 (i-n)
	BLT forexe_red //If valid, execute for loop
	POP {V1-V6}
	BX LR
	
forexe_red:
	LDR V6, [V2, V1, LSL #2]
	MOV V3, V1 //Copy i into j, V3 is 'j'
	
whilecond_red:
	CMP V3, #0
	BLE endwhile_red
	SUB V4, V3, #1 //V4 <- V3 - 1 for the condition, V4 is j-1
	LDR V5, [V2, V4, LSL #2] //Multiply the value by 4 (word size) and add to SP
	CMP V5, V6 //arr[j-1]-arr[i], if less than 0, end while loop
	BLE endwhile_red
	STR V5, [V2, V3, LSL #2] //V5 -> [V2+(V3<<2)]
	SUB V3, V3, #1
	B whilecond_red //Branch back to while loop
	
endwhile_red:
	STR V6, [V2, V3, LSL #2]
	
	ADD V1, V1, #1 //Increment 'i' (for loop)
	B forcond_red

//TO DO:
//Get median of each array
//Construct new 6x6 matrix

//window_median:

end:
	B end
	

