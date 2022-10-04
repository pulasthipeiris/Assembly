/*
Implementing the following C program in somewhat psuedocode:

if(a>3)
	b = 7
else
	b = 13

*/

.global _start
_start:
	LDR R0, A
	CMP R0, #3
	MOVGT R1, #7
	MOVLE R1, #13
	STR R1, B