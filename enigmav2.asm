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
ashft byte 1

bstep byte 0
bshft byte 2

cstep byte 0
cshft byte 1

E byte "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

plug byte "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

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

main proc
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