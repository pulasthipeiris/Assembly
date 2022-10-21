.global _start

divid: 	.word 5  //Dividend
divis: 	.word 3	 //Divisor
result: .space 4 //Uninitialized space for the result

_start:
	LDR A1, divid //Passing dividend
	LDR A2, divis //Passing divisor
	//LDR A3, =result //Passing address of the result 
	MOV V1, A1 //Copying dividend value into V1 (Remainder)
	MOV V2, #0 //Copying imm. value into V2 (Quotient)

cond:
	CMP V1, A2 //Update CPSR flags on A1-A2
	BGE division
	B store	
	
division:
	SUB V1, V1, A2
	ADD V2, V2, #1
	B cond
	
store:
	LSL V2, V2, #16
	ADD V2, V2, V1 
	//STR V1, [A3] //storing the result
	STR V1, result //this uses one less register than above
end:
	B end