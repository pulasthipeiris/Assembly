//This program implements the insertion sort algorithm recursively in assembly

.global _start
arr:   .word 68, -22, -31, 75, -10, -61, 39, 92, 94, -55 // Test array
N:	   .word 10
I:     .word 1 // New function input argument - 'I'

_start:
	LDR A1, =arr //Passing the pointer to the array
	LDR A2, N //Passing the length of the array
	LDR A3, I //Passing I into A3
	
	//CMP A2, #1 //Base case: if N-1<=0, end
	//BLE end
	
	//PUSH {A1, A2, A3, LR}
	BL insertion_sort
	//POP {A1, A2, A3, LR}
	B end
	
insertion_sort:
	CMP A3, A2 //Update CPSR with A3-A2 -> I-N
	BGE poplr //If I-N<0 continue, ie. range is valid
	
	//PUSH {V1-V6} //Push variables onto the stack
	//LDR V1, [SP, #20] Load the array address from the stack
	MOV V2, A3 //Copy value of I into V2, V2 is 'j' 
	LDR V3, [A1, A3, LSL #2] //V3 is value
	
whilecond:
	CMP V2, #0 //Check if j>0, if true, continue
	BLE endwhile
	SUB V4, V2, #1 //V4 <- V2-1 for the condition, V4 is j-1
	LDR V5, [A1, V4, LSL #2] //Multiply the value by 4 (word size) and add to SP
	CMP V5, V3 //Check if arr[j-1]-value, if true, continue
	BLE endwhile
	STR V5, [A1, V2, LSL #2] //V5 -> [V1+(V2<<2)]
	SUB V2, V2, #1
	B whilecond //Branch back to while loop
	
endwhile:
	STR V3, [A1, V2, LSL #2]
	B if
	
if:
	ADD V6, A3, #1 //V6 is (I+1)
	CMP V6, A2 //If (I+1)-N > 0, then it's false. If false, end
	BGT end2
	ADD A3, A3, #1
	//POP {V1-V6}
	//PUSH {LR}
	BL insertion_sort //Recursively calling insertion_sort
	//POP {LR}
	
end:
	B end

end2:
	//POP {V1-V6}
	BX LR

poplr:
	BX LR
	