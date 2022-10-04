// Implementing a dot product in assembly

.global _start //tells the assembler/linker where to start execution
n: .word 6
vectorA: .word 5, 3, −6, 19, 8, 12
vectorB: .word 2, 1 4, −3, 2, −5, 36
dotP: .space 4
_start:

	MOV R3, #0 // register R3 will accumulate the product
	LDR R0, =vectorA // R0 = vectorA base address (pseudo − instruction)
	LDR R1, =vectorB // R1 = vectorB base address (pseudo − instruction)
	LDR R2, n // R2 =6 ( R2 is our loop iteration variable i)
LOOP:
	LDR R4, [R0] , #4 // get vectorA [ i ]; post − index increments R0 after
	LDR R5, [R1] , #4 // get vectorB [ i ]; post − index increments R1 after
	MLA R3, R4, R5, R3 // R3 = ( R4*R5 ) + R3
	SUBS R2, R2 , # 1 // i −− and set condition flags
	BGT LOOP // we’re not done if i >0
	STR R3, dotP // save our result in memory
STOP:
	B STOP // infinite loop once we’re done