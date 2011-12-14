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
arevrs byte "UWYGADFPVZBECKMTHXSLRINQOJ"

brotor byte "AJDKSIRUXBLHWTMCQGZNPYFVOE"
brevrs byte "AJPCZWRLFBDKOTYUQGENHXMIVS"

crotor byte "BDFHJLCPRTXVZNYEIWGAKMUSQO"
crevrs byte "TAGBPCSDQEUFVNZHYIXJWLRKOM"

reflct byte "YRUHQSLDPXNGOKMIEBFZCWVJAT"

astep byte 0
bstep byte 0
cstep byte 0

ashft byte 1
bshft byte 1
cshft byte 1

E byte 		"ABCDEFGHIJKLMNOPQRSTUVWXYZ"

plug byte "ABCDEFGHIJKLMNOPQRSTUVWXYZ",0
plugpretty byte "||||||||||||||||||||||||||"
plugdone byte "[Done]",0

rotor_positions byte "<A> <A> <A>",0

.code

PassThroughRotor proc uses esi edi ecx eax,
	r_offset:PTR BYTE,
	step_count:BYTE
	mov esi, r_offset
	mov cl, step_count
	sub bl, 65
	add cl, bl
	cmp cl, 26
	jl loopback
	sub cl, 26
	loopback:
	add esi, ecx
	mov al, [esi]
	sub al, 65
	sub al, cl
	add bl, al
	cmp bl, 0
	jg skipcalc
	add bl, 26
	skipcalc:
	mov edi, offset E
	add edi, ebx
	mov bl, [edi]
	ret
PassThroughRotor endp

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

DisplayPlugboard proc uses eax esi ecx,
	str_offset:PTR BYTE
	mov esi, str_offset
	mov ecx, 26
	printplug:
		mov al, [esi]
		call writechar
		mov al, 32
		call writechar
		inc esi
	loop printplug
	ret
DisplayPlugboard endp

main proc
	call Setup
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
	cstate:
		movzx eax, cshft
		add cstep, al
		cmp cstep, 26
		jl bstate
		sub cstep, 26
	bstate:
		cmp cstep, 22
		jne testb
		movzx eax, bshft
		add bstep, al
	testb:
		cmp bstep, 26
		jl astate
		sub bstep, 26
	astate:
		cmp bstep, 5
		jne encode
		movzx eax, bshft
		add bstep, al
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

GetInputForRotor proc uses eax ecx edx edi
	mov edi, offset astep
	invoke SetXY, 34, 5
	NextInput:
		mov cl, [edi]
	inputkey:
		invoke SetXY, dl, dh
		call readchar
		cmp eax, 7181
		je finishrotors
		cmp eax, 20480
		je decreasestep
		cmp eax, 19200
		je leftrotor
		cmp eax, 19712
		je rightrotor
		cmp eax, 18432
		jne inputkey
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
			cmp dl, 34
			je NextInput
			sub dl, 4
			dec edi
			jmp NextInput
		rightrotor:
			cmp dl, 42
			je NextInput
			add dl, 4
			inc edi
			jmp NextInput
		finishrotors:
	ret
GetInputForRotor endp

GetInputForPlugboard proc uses eax ebx ecx edx esi edi
	invoke SetXY, 14, 7
	mov esi, offset plug
	clrenterinput:
		mov ebx, 0
		mov ecx, 0
		mov edi, 0
	enterinput:
		invoke SetXY, dl, dh
		call readchar
		cmp eax, 18432
		je gotoplugboard
		cmp eax, 20480
		je gotodone
		cmp eax, 19200
		je gotoleft
		cmp eax, 19712
		je gotoright
		cmp eax, 7181
		jne enterinput
			cmp dh, 7
			jne finishplugboard
			cmp bl, 0
			je firstswap
			mov cl, [esi]
			mov [esi], bl
			add edi, offset plug
			mov [edi], cl
			push edx
			invoke SetXY, 14, 7
			invoke DisplayPlugboard, offset plug
			pop edx
			jmp clrenterinput
		firstswap:
			mov bl, [esi]
			mov edi, esi
			sub edi, offset plug
			jmp enterinput
		gotoplugboard:
			cmp dh, 7
			je enterinput
			invoke SetXY, 14, 7
			jmp clrenterinput
		gotodone:
			invoke SetXY, 30, 15
			jmp clrenterinput
		gotoleft:
			cmp dl, 14
			je enterinput
			cmp dh, 15
			je enterinput
			sub dl, 2
			dec esi
			jmp enterinput
		gotoright:
			cmp dl, 64
			je enterinput
			cmp dh, 15
			je enterinput
			add dl, 2
			inc esi
			jmp enterinput
		finishplugboard:
	ret
GetInputForPlugboard endp

EditPlugboard proc uses esi ecx eax ebx edx
	invoke DisplayPlugboard, offset plug
	inc dh
	invoke SetXY, dl, dh
	invoke DisplayPlugboard, offset plugpretty
	inc dh
	invoke SetXY, dl, dh
	invoke DisplayPlugboard, offset E
	invoke SetXY, 29, 15
	mov edx, offset plugdone
	call writestring
	invoke GetInputForPlugboard
	ret
EditPlugboard endp

Setup proc
	call clrscr
	invoke SetXY, 14, 7
	invoke EditPlugboard
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