title enigma
include Irvine32.inc

; Created by Samuel Marshall
; Created on November 01, 2011, 12:32 PM

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

menu_title byte "Select an option: ",0
menu_select byte "Select a menu item: ",0

setup_rotor_title byte "Setup Rotors:",0

rotor_str1 byte "Current Rotors:",0

rtr_a byte "1. A: ",0
rtr_b byte "2. B: ",0
rtr_c byte "3. C: ",0
rtr_r byte "4. R: ",0

rtr_1_menu byte "	1. Edit a Rotor"
		   byte 0dh,0ah,"	2. Use these Rotors",0
		
rtrprompt byte "Enter the Rotor you want to edit (1-4): ",0

rtr_1_title byte "Rotor Properties:",0
rtr_1_prop1 byte "	   Rotor: ",0
rtr_1_prop2 byte "	 Reverse: ",0
rtr_1_prop3 byte "	Position: ",0
rtr_1_prop4 byte "	    Step: ",0

rtr_1_menu_item1 byte "		1. Select a Rotor",0
rtr_1_menu_item2 byte "		2. Create a Rotor",0
rtr_1_menu_item3 byte "		3. Set a position",0
rtr_1_menu_item4 byte "		4. Set step increment",0
rtr_1_menu_item5 byte "		5. Back",0
rtr_1_menu_item6 byte "		3. Back",0

rtr_2_menu byte "Select a Rotor: "
		   byte 0dh,0ah,"		1. Service - I"
		   byte 0dh,0ah,"		2. Service - II"
		   byte 0dh,0ah,"		3. Service - III"
		   byte 0dh,0ah,"		4. Service - IV"
		   byte 0dh,0ah,"		5. Service - V"
		   byte 0dh,0ah,"		6. Service - VI"
		   byte 0dh,0ah,"		7. Service - VII"
		   byte 0dh,0ah,"		8. Service - VIII"
		   byte 0dh,0ah,"		9. Service - UKW A"
		   byte 0dh,0ah,"	       10. Service - UKW B"
		   byte 0dh,0ah,"	       11. Service - UKW C",0

rtr_input_prompt byte "Enter a rotor sequence: ",0

rtr_input byte 26 dup(" ")
rtr_term byte 0

rtr_pos_prompt byte "Enter the starting position for this rotor: ",0

rtr_step_prompt byte "Enter the step increment for this rotor: ",0

setup_plugboard_title byte "Setup Plugboard:",0

pb_str1 byte "Current Plugboard: ",0

pb_menu byte "	1. Add a connection"
		byte 0dh,0ah,"	2. Reset Plugboard"
		byte 0dh,0ah,"	3. Use this Plugboard",0

pb_str2 byte "Enter Plugboard Key: ",0

pkey1 byte "0",0
pkey2 byte "0",0

p1index byte 0
p2index byte 0

inputprompt byte "Enter text to encode: ",0

input byte 255 dup(?),0
inputlen byte 0

output byte 255 dup(?),0

s1 byte "EKMFLGDQVZNTOWYHXUSPAIBRCJ"
s2 byte "AJDKSIRUXBLHWTMCQGZNPYFVOE"
s3 byte "BDFHJLCPRTXVZNYEIWGAKMUSQO"
s4 byte "ESOVPZJAYQUIRHXLNFTGKDCMWB"
s5 byte "VZBRGITYUPSDNHLXAWMJQOFECK"
s6 byte "JPGVOUMFYQBENHZRDKASXLICTW"
s7 byte "NZJHGRCXMYSWBOUFAIVLPEKQDT"
s8 byte "FKQHTLXOCBJSPDZRAMEWNIUYGV"
s9 byte "EJMZALYXVBWFCRQUONTSPIKHGD"
s10 byte "YRUHQSLDPXNGOKMIEBFZCWVJAT"
s11 byte "FVPJIAOYEDRZXWGCTKUQSBNMHL"

E byte "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

A_ byte 26 dup(" ")
   byte 0
A_R byte 26 dup(" ")
	byte 0
	
astep byte 0
ashift byte 1

B_ byte 26 dup(" ")
   byte 0
B_R byte 26 dup(" ")
	byte 0
	
bstep byte 0
bshift byte 1

C_ byte 26 dup(" ")
   byte 0
C_R byte 26 dup(" ")
	byte 0
	
cstep byte 0
cshift byte 1

R byte 26 dup(" ")
  byte 0

plug byte "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
 	 byte 0

.code

main proc
	;setup rotors
	call ClearRegisters
	call SetupRotors
	
	;setup plugboard
	call SetupPlugBoard	
	
	;get input string
	call GetInputString
	call ClearRegisters
	mov cl, inputlen
	mov esi, offset input
	mov edi, offset output
	Encrypt:
	;check character
	mov eax, [esi]
	cmp al, 65
	jl isfalse
	cmp al, 90
	jg isfalse
	;we are working with a letter

	mov bl, ashift
	add astep, bl
	cmp astep, 26
	jge incb
	jmp startencoding
	incb:
		sub astep, 26
		mov ebx, 0
		mov bl, bshift
		add bstep, bl
		cmp bstep, 26
		jge incc
		jmp startencoding
	incc:
		sub bstep, 26
		mov ebx, 0
		mov bl, cshift
		add cstep, bl
		cmp cstep, 26
		jge resetc
		jmp startencoding
	resetc:
		sub cstep, 26
	startencoding:

	push esi
	push ecx

	;send to plugboard
	mov esi, offset plug
	mov edx, 0
	mov ecx, lengthof plug
	call PassThroughRotor
	
	;send to E
	
	;send to A
	mov esi, offset A_
	mov edx, 0
	mov dl, astep
	mov ecx, lengthof A_
	call PassThroughRotor
	
	;send to B
	mov esi, offset B_
	movzx edx, bstep
	mov ecx, lengthof B_
	call PassThroughRotor
	
	;send to C
	mov esi, offset C_
	movzx edx, cstep
	mov ecx, lengthof C_
	call PassThroughRotor
	
	;send to R
	mov esi, offset R
	mov edx, 0
	mov ecx, lengthof R
	call PassThroughRotor
	
	;send to CR
	mov esi, offset C_R
	movzx edx, cstep
	mov ecx, lengthof C_R
	call PassThroughRotor
	
	;send to B_R
	mov esi, offset B_R
	movzx edx, bstep
	mov ecx, lengthof B_R
	call PassThroughRotor
	
	;send to A_R
	mov esi, offset A_R
	movzx edx, astep
	mov ecx, lengthof A_R
	call PassThroughRotor
	
	;send to E
	
	;send to plugboard
	mov esi, offset plug
	mov edx, 0
	mov ecx, lengthof plug
	call PassThroughRotor
	
	;add character to output
	isfalse:
	pop ecx
	pop esi
	mov [edi], al
	;next character
	inc esi
	inc edi
	dec ecx
	cmp ecx, 0
	jne Encrypt
	
	call crlf
	call crlf
	mov edx, offset output
	call writeline
	
	exit
main endp

ClearRegisters proc
	mov eax, 0
	mov ebx, 0
	mov ecx, 0
	mov edx, 0
	mov esi, 0
	mov edi, 0
	ret
ClearRegisters endp

GetInputString proc
	mov edx, offset inputprompt
	call writestring
	mov edx, offset input
	mov ecx, lengthof input
	mov eax, 0
	call readstring
	mov inputlen, al
	invoke str_ucase, addr input
	ret
GetInputString endp

GetIndexInEntry proc uses ebx ecx esi
	mov ecx, lengthof E
	mov esi, offset E
	ScanEntry:
	cmp al, [esi]
	je FoundIndex
	inc esi
	loop ScanEntry
	jmp gotoEnd
	FoundIndex:
	mov ebx, lengthof E
	sub ebx, ecx
	mov eax, ebx
	gotoEnd:
	ret
GetIndexInEntry endp

PassThroughRotor proc uses ebx ecx edx edi esi
	; eax input letter
	push esi
	push ecx
	call GetIndexInEntry
	pop ecx
	pop esi
	; eax is positon
	; esi offset of rotor array
	; edx steps for rotor
	; ecx lengthof rotor array
	mov edi, ecx
	add esi, edx
	mov ebx, 0
	mov bl, dl
	add bl, al
	;bl = distance from (offset + steps) (0 - 25)
	sub edi, ebx
	;ecx = distance from (offset + steps) to position 26
	sub ecx, edi
	add esi, ecx
	mov ecx, [esi]
	mov eax, ecx
	ret
PassThroughRotor endp

SetupPlugBoard proc uses edx eax esi edi
	Setupkey:
	call clrscr
	mov edx, offset setup_plugboard_title
	call writestring
	call crlf
	
	mov edx, offset pb_str1
	call writestring
	mov edx, offset plug
	call writestring
	call crlf
	
	mov edx, offset menu_title
	call writeline
	mov edx, offset pb_menu
	call writeline
	call crlf
	mov edx, offset menu_select
	call writestring
	mov eax, 0
	call readint
	cmp al, 1
	jl invalid
	jmp valid1
	valid1:
		cmp al, 3
		jg invalid
		jmp valid2
	valid2:
		cmp al, 2
		jl one
		je two
		jg three
	
	one:
		call crlf
		mov edx, offset pb_str2
		call writestring
		mov edx, offset pkey1
		mov ecx, lengthof pkey1
		call readstring
		mov edx, offset pb_str2
		call writestring
		mov edx, offset pkey2
		mov ecx, lengthof pkey2
		call readstring
		
		call ClearRegisters
		
		mov esi, offset pkey1
		mov al, [esi]
		call GetIndexInEntry
		mov p1index, al
		
		call ClearRegisters
		
		mov esi, offset pkey2
		mov al, [esi]
		call GetIndexInEntry
		mov p2index, al
		
		mov eax, offset E
		mov ebx, offset plug
		add al, p1index
		add bl, p1index
		mov ecx, [eax]
		mov edx, [ebx]
		cmp ecx, edx
		jne usedplug		
		plug1ok:
			call ClearRegisters
			mov eax, offset E
			mov ebx, offset plug
			add al, p2index
			add bl, p2index
			mov ecx, [eax]
			mov edx, [ebx]
			cmp ecx, edx
			jne usedplug
			plug2ok:
				call ClearRegisters
				mov eax, offset plug
				mov ebx, offset plug
				mov cl, p1index
				mov dl, p2index
				add al, cl
				add bl, dl
				mov ecx, 0
				mov edx, 0
				mov cl, [eax]
				mov dl, [ebx]
				xchg ecx, edx
				mov [eax], cl
				mov [ebx], dl
		usedplug:		
		jmp Setupkey
	two:
		mov esi, offset E
		mov edi, offset plug
		mov ecx, lengthof E
		resetPlug:
			mov eax, [esi]
			mov [edi], al
			inc esi
			inc edi
		loop resetPlug
	invalid:
	jmp Setupkey
	
	three:
		call clrscr
		
	ret
SetupPlugBoard endp

SetupRotors proc uses eax edx ecx edx esi edi
	Setuprtr:
	call clrscr
	mov edx, offset setup_rotor_title
	call writeline
	call crlf
	
	mov edx, offset rtr_a
	call writestring
	mov edx, offset A_
	call writeline
	mov edx, offset rtr_b
	call writestring
	mov edx, offset B_
	call writeline
	mov edx, offset rtr_c
	call writestring
	mov edx, offset C_
	call writeline
	mov edx, offset rtr_r
	call writestring
	mov edx, offset R
	call writeline
	call crlf
	
	mov edx, offset menu_title
	call writeline
	mov edx, offset rtr_1_menu
	call writeline
	mov edx, offset menu_select
	call writestring
	mov eax, 0
	call readint
	
	cmp eax, 1
	je rtredit
	cmp eax, 2
	je rtruse
	jne Setuprtr
	
	rtredit:
		call crlf
		mov edx, offset rtrprompt
		call writestring
		mov eax, 0
		call readint
		
		cmp eax, 1
		je rtrone
		cmp eax, 2
		je rtrtwo
		cmp eax, 3
		je rtrthree
		cmp eax, 4
		je rtrfour
		cmp eax, 5
		je Setuprtr
		jne rtredit
		
		rtrone:
		call ClearRegisters
		mov bl, astep
		mov cl, ashift
		mov esi, offset A_
		mov edi, offset A_R
		call SetRotorProp
		mov astep, bl
		mov ashift, cl
		jmp Setuprtr
		
		rtrtwo:
		call ClearRegisters
		mov bl, bstep
		mov cl, bshift
		mov esi, offset B_
		mov edi, offset B_R
		call SetRotorProp
		mov bstep, bl
		mov bshift, cl
		jmp Setuprtr
		
		rtrthree:
		call ClearRegisters
		mov bl, cstep
		mov cl, cshift
		mov esi, offset C_
		mov edi, offset C_R
		call SetRotorProp
		mov cstep, bl
		mov cshift, cl
		jmp Setuprtr
		
		rtrfour:
		call ClearRegisters
		mov esi, offset R
		call SetReflectorProp
		jmp Setuprtr
		
	rtruse:
	ret
SetupRotors endp

;ebx = step
;ecx = start
;esi = rotor array
;edi = reverse rotor array

SetRotorProp proc uses edx eax
	setproperty:
	call clrscr
	mov edx, offset rtr_1_title
	call writeline
	call crlf
	
	mov edx, offset rtr_1_prop1
	call writestring
	mov edx, esi
	call writeline
	
	mov edx, offset rtr_1_prop2
	call writestring
	mov edx, edi
	call writeline
	
	mov edx, offset rtr_1_prop3
	call writestring
	mov eax, ebx
	call writeint
	call crlf
	
	mov edx, offset rtr_1_prop4
	call writestring
	mov eax, ecx
	call writeint
	call crlf
	
	call crlf
	mov edx, offset menu_title
	call writeline
	mov edx, offset rtr_1_menu_item1
	call writeline
	mov edx, offset rtr_1_menu_item2
	call writeline
	mov edx, offset rtr_1_menu_item3
	call writeline
	mov edx, offset rtr_1_menu_item4
	call writeline
	mov edx, offset rtr_1_menu_item5
	call writeline
	call crlf
	
	mov edx, offset menu_select
	call writestring
	mov eax, 0
	call readint
	
	cmp eax, 1
	je selectrtr
	cmp eax, 2
	je creatertr
	cmp eax, 3
	je setpos
	cmp eax, 4
	je setstep
	cmp eax, 5
	je gotoend
	jmp setproperty
	
	selectrtr:
	call clrscr
	push ebx
	
	call ExistingRotorSelect
	cmp eax, 0
	jle selectrtr
	cmp eax, 12
	jge selectrtr
	
	SetTheRotor:
	
	push ecx
	push edi
	mov edi, esi
	
	mov ecx, 26
	FillRotor:
	mov edx, [ebx]
	mov [edi], dl
	inc ebx
	inc edi
	loop FillRotor
	pop edi
	mov ebx, esi
	call GenerateReverse
	mov esi, ebx
	pop ecx
	pop ebx
	jmp setproperty
	
	creatertr:
	push ebx
	push ecx	
	call crlf
	mov edx, offset rtr_input_prompt
	call writestring
	mov edx, offset rtr_input
	mov ecx, 27
	mov eax, 0
	call readstring
	push esi
	mov esi, edx
	push eax
	call VerifyRotor
	pop eax
	pop esi
	cmp ebx, 0
	je creatertr
	call writeint
	cmp eax, 26
	jne creatertr
	pop ecx
	mov ebx, edx
	jmp SetTheRotor
	
	setpos:
	mov edx, offset rtr_pos_prompt
	call writestring
	mov eax, 0
	call readint
	mov ebx, 0
	mov ebx, eax
	jmp setproperty
	
	setstep:
	mov edx, offset rtr_step_prompt
	call writestring
	mov eax, 0
	call readint
	mov ecx, 0
	mov ecx, eax
	jmp setproperty
	
	gotoend:
	ret
SetRotorProp endp

GenerateReverse proc uses ebx ecx eax edx
	; edi reverse rotor
	; esi rotor
	; ebx E
	; eax value
	mov ebx, offset E
	mov ecx, 26
	FillReverse:
	mov eax, [esi]
	call GetIndexInEntry
	mov edx, [ebx]
	push esi
	mov esi, edi
	add edi, eax
	mov [edi], dl
	mov edi, esi
	pop esi
	inc esi
	inc ebx
	loop FillReverse
	
	ret
GenerateReverse endp

ExistingRotorSelect proc
	invalidrotor:
	call clrscr
	mov edx, offset rtr_2_menu
	call writeline
	call crlf
	mov edx, offset menu_select
	call writestring
	mov eax, 0
	call readint

	mov ebx, 0
	cmp eax, 0
	jle invalidrotor
	cmp eax, 12
	jge invalidrotor
	cmp eax, 1
	mov ebx, offset s1
	je fill_loop
	cmp eax, 2
	mov ebx, offset s2
	je fill_loop
	cmp eax, 3
	mov ebx, offset s3
	je fill_loop
	cmp eax, 4
	mov ebx, offset s4
	je fill_loop
	cmp eax, 5
	mov ebx, offset s5
	je fill_loop
	cmp eax, 6
	mov ebx, offset s6
	je fill_loop
	cmp eax, 7
	mov ebx, offset s7
	je fill_loop
	cmp eax, 8
	mov ebx, offset s8
	je fill_loop
	cmp eax, 9
	mov ebx, offset s9
	je fill_loop
	cmp eax, 10
	mov ebx, offset s10
	je fill_loop
	cmp eax, 11
	mov ebx, offset s11
	fill_loop:
	ret
ExistingRotorSelect endp

SetReflectorProp proc uses edx eax ebx edx ecx edi
	setreflect:
	call clrscr
	mov edx, offset rtr_1_title
	call writeline
	call crlf
	mov edx, offset rtr_1_prop1
	call writestring
	mov edx, esi
	call writeline
	call crlf
	
	mov edx, offset menu_title
	call writeline
	mov edx, offset rtr_1_menu_item1
	call writeline
	mov edx, offset rtr_1_menu_item2
	call writeline
	mov edx, offset rtr_1_menu_item6
	call writeline
	call crlf
	mov edx, offset menu_select
	call writestring
	mov eax, 0
	call readint
	
	cmp eax, 1
	je selectref
	cmp eax, 2
	je customref
	cmp eax, 3
	je GotoEndRef
	jmp setreflect
	
	selectref:
	call clrscr
	call ExistingRotorSelect
	cmp eax, 0
	jle setreflect
	cmp eax, 12
	jge setreflect
	
	chooseref:
	mov edi, esi
	mov ecx, 26
	FillReflector:
	mov edx, [ebx]
	mov [edi], dl
	inc ebx
	inc edi
	loop FillReflector
	jmp setreflect
	
	customref:
	push ecx	
	call crlf
	mov edx, offset rtr_input_prompt
	call writestring
	mov edx, offset rtr_input
	mov ecx, 27
	mov eax, 0
	call readstring
	push esi
	mov esi, edx
	push eax
	call VerifyRotor
	pop eax
	pop esi
	cmp ebx, 0
	je customref
	call writeint
	cmp eax, 26
	jne customref
	pop ecx
	mov ebx, edx
	jmp chooseref
	
	GotoEndRef:
	ret
SetReflectorProp endp

writeline proc
	call writestring
	call crlf
	ret
writeline endp

VerifyRotor proc uses ecx edx
	push edi
	mov edi, esi
	mov ebx, 1
	mov edx, 64
	Nextletter:
	inc edx
	mov ecx, 26
	mov esi, edi
	CheckLetters:
		mov eax, [esi]
		cmp eax, edx
		je Nextletter
		inc esi
	loop CheckLetters
	cmp edx, 90
	jge GotoEndVerify
	mov ebx, 0
	GotoEndVerify:
	mov esi, edi
	pop edi
	ret
VerifyRotor endp

end main