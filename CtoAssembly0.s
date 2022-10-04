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
	BLE ELSE
	MOV R1, #7
	B END
ELSE:
	MOV R1, #13
END:
	STR R1, B