Title EnigmaV2
Include Irvine32.inc

; Created by Samuel Marshall
; Created on November 2nd, 2011, 18:45

;Copyright (c) 2010-2011, Sam Marshall
;All rights reserved.

;Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
;1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
;2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
;3. All advertising materials mentioning features or use of this software must display the following acknowledgement:
; This product includes software developed by the Sam Marshall.
;4. Neither the name of the Sam Marshall nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
;
;THIS SOFTWARE IS PROVIDED BY Sam Marshall ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
; IN NO EVENT SHALL Sam Marshall BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


.data
input byte 255 dup(?),0
input_prompt byte "Enter a message: ",0
output byte 255 dup(?),0
output_prompt byte "Encrypted message: ",0

stringlen byte 0

arotor byte "EKMFLGDQVZNTOWYHXUSPAIBRCJ"
arevrs byte 26 dup(" ")

brotor byte "AJDKSIRUXBLHWTMCQGZNPYFVOE"
brevrs byte 26 dup(" ")

crotor byte "BDFHJLCPRTXVZNYEIWGAKMUSQO"
crevrs byte 26 dup(" ")

reflct byte "YRUHQSLDPXNGOKMIEBFZCWVJAT"

astep byte 0
bstep byte 0
cstep byte 0

ashft byte 1
bshft byte 1
cshft byte 1

E byte "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

plug byte "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

rotor_positions byte "<A> <A> <A>",0

.code

PassThroughRotor proc uses esi edi ecx,
	r_offset:PTR BYTE,
	step_count:BYTE
	mov ecx, 26
	mov edi, ecx
	mov esi, r_offset
	movzx edx, step_count
	sub ebx, 65
	add esi, edx
	add edx, ebx
	sub ecx, edx
	sub edi, ecx
	add esi, edi
	mov bl, [esi]
	ret
PassThroughRotor endp

GenerateReverse proc uses edi esi ecx eax ebx, 
	reverse_rotor:PTR BYTE,
	rotor:PTR BYTE
	mov esi, rotor
	mov ecx, 26
	FillReverse:
	mov al, [esi]
	sub al, 65
	mov edi, reverse_rotor
	add edi, eax
	mov bl, 91
	sub bl, cl
	mov [edi], bl
	inc esi
	loop FillReverse
	ret
GenerateReverse endp

SetXY proc,
	X:BYTE,
	Y:BYTE
	mov dl, X
	mov dh, Y
	call gotoxy
	ret
SetXY endp

UpdateRotorPositions proc uses eax ecx edx edi
	invoke SetXY, 34, 5
	mov edi, offset astep
	mov cl, 3
	updatepositions:
	mov al, [edi]
	add al, 65
	call writechar
	add dl, 4
	invoke SetXY, dl, dh
	inc edi
	loop updatepositions
	invoke SetXY, 0, 11
	ret
UpdateRotorPositions endp

main proc
	call Setup
	invoke GenerateReverse, addr crevrs, addr crotor
	invoke GenerateReverse, addr brevrs, addr brotor
	invoke GenerateReverse, addr arevrs, addr arotor
	call GetInputString
	mov esi, offset input
	mov edi, offset output
	movzx ecx, stringlen
	Encrypt:
	cmp ecx, 0
	je PrintOutput
	mov ebx, 0
	mov bl, [esi]
	call Verify
	cmp eax, 0
	jne NextCharacter
	
	movzx eax, cshft
	add cstep, al
	cmp cstep, 26
	jl encode
	sub cstep, 26
	movzx eax, bshft
	add bstep, al
	cmp bstep, 26
	jl encode
	sub bstep, 26
	movzx eax, ashft
	add astep, al
	cmp astep, 26
	jl encode
	sub astep, 26

	encode:
	invoke UpdateRotorPositions
	
	invoke PassThroughRotor, offset plug, 0
	invoke PassThroughRotor, offset crotor, cstep
	invoke PassThroughRotor, offset brotor, bstep
	invoke PassThroughRotor, offset arotor, astep
	invoke PassThroughRotor, offset reflct, 0
	invoke PassThroughRotor, offset arevrs, astep
	invoke PassThroughRotor, offset brevrs, bstep
	invoke PassThroughRotor, offset crevrs, cstep
	invoke PassThroughRotor, offset plug, 0
	
	NextCharacter:
	mov [edi], bl
	inc esi
	inc edi
	dec ecx
	jmp Encrypt
	PrintOutput:
	mov edx, offset output
	call writestring
	call crlf
	exit
main endp

GetInputForRotor proc uses eax ebx ecx edx edi
	mov ebx, 0
	mov edi, offset astep
	mov dl, 34
	mov dh, 5
	NextInput:
	mov cl, [edi]
	inputkey:
		invoke SetXY, dl, dh
		call readchar
		cmp eax, 7181
		je finishrotors
		cmp eax, 18432
		je increasestep
		cmp eax, 20480
		je decreasestep
		cmp eax, 19200
		je leftrotor
		cmp eax, 19712
		je rightrotor
		jne inputkey
	increasestep:
		inc cl
		cmp cl, 25
		jle WriteNewPosition
		mov cl, 0
		jmp WriteNewPosition
	decreasestep:
		cmp cl, 0
		jne backposition
		mov cl, 26
		backposition:
		dec cl
	WriteNewPosition:
		mov [edi], cl
		add cl, 65
		movzx eax, cl
		call writechar
		jmp NextInput
	leftrotor:
		cmp ebx, 0
		je NextInput
		sub dl, 4
		dec edi
		dec ebx
		jmp NextInput
	rightrotor:
		cmp ebx, 2
		je NextInput
		add dl, 4
		inc edi
		inc ebx
		jmp NextInput
	finishrotors:
	ret
GetInputForRotor endp

Setup proc
	call clrscr
	invoke SetXY, 33, 5
	mov edx, offset rotor_positions
	call writestring
	invoke GetInputForRotor
	call crlf
	ret
Setup endp

GetInputString proc
	mov edx, offset input_prompt
	call writestring
	mov edx, offset input
	mov ecx, lengthof input
	call readstring
	mov stringlen, al
	invoke str_ucase, addr input
	ret
GetInputString endp

Verify proc
	mov eax, 0
	cmp ebx, 65
	jl invalid
	cmp ebx, 90
	jle GotoEnd
	invalid:
	mov eax, 1
	GotoEnd:
	ret
Verify endp

end main