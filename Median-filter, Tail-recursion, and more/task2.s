//This program implements the insertion sort algorithm in assembly

.global _start
arr:   .word 68, -22, -31, 75, -10, -61, 39, 92, 94, -55 // Test array
N:	   .word 10

_start:
	LDR A1, =arr //Passing the pointer to the array
	LDR A2, N //Passing the length of the array
	
	//Using more than 4 arguments, so stack is used
	
	PUSH {A1, A2, LR} //Save params and LR on stack, A1 is TOS
	BL forinit
	POP {A1, A2, LR}
	B end
	
forinit:
	PUSH {V1-V6} //Callee-save, V1 is TOS
	MOV V1, #1 //V1 is 'i'
	LDR V2, [SP, #20] //Load the first array value from the stack

forcond:
	CMP V1, A2 //Updated CPSR with V1-A2 (i-n)
	BLT forexe //If valid, execute for loop
	POP {V1-V6}
	BX LR
	
forexe:
	LDR V6, [V2, V1, LSL #2]
	MOV V3, V1 //Copy i into j, V3 is 'j'
	
whilecond:
	CMP V3, #0
	BLE endwhile
	SUB V4, V3, #1 //V4 <- V3 - 1 for the condition, V4 is j-1
	LDR V5, [V2, V4, LSL #2] //Multiply the value by 4 (word size) and add to SP
	CMP V5, V6 //arr[j-1]-arr[i], if less than 0, end while loop
	BLE endwhile
	STR V5, [V2, V3, LSL #2] //V5 -> [V2+(V3<<2)]
	SUB V3, V3, #1
	B whilecond //Branch back to while loop
	
endwhile:
	STR V6, [V2, V3, LSL #2]
	
	ADD V1, V1, #1 //Increment 'i' (for loop)
	B forcond
	
end:
	B end
	
	