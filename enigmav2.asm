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

arotor byte "EKMFLGDQVZNTOWYHXUSPAIBRCJ",0
arevrs byte "UWYGADFPVZBECKMTHXSLRINQOJ",0
brotor byte "AJDKSIRUXBLHWTMCQGZNPYFVOE",0
brevrs byte "AJPCZWRLFBDKOTYUQGENHXMIVS",0
crotor byte "BDFHJLCPRTXVZNYEIWGAKMUSQO",0
crevrs byte "TAGBPCSDQEUFVNZHYIXJWLRKOM",0
reflct byte "YRUHQSLDPXNGOKMIEBFZCWVJAT",0

astep byte 0
ashft byte 1

bstep byte 0
bshft byte 2

cstep byte 0
cshft byte 1

E byte "ABCDEFGHIJKLMNOPQRSTUVWXYZ",0

plug byte "ABCDEFGHIJKLMNOPQRSTUVWXYZ",0

.code

main proc
	call GetInputString
	mov esi, offset input
	mov edi, offset output
	movzx ecx, stringlen
	Encrypt:
	mov ebx, [esi]
	call Verify
	cmp ecx, 0
	je NextCharacter
	call Cypher
	NextCharacter:
	mov [edi], bl
	inc esi
	inc edi
	loop Encrypt
	mov edx, offset output
	call writestring
	call crlf
	exit
main endp

GetInputString proc uses eax ecx edx
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
	cmp ebx, 65
	jl invalid
	cmp ebx, 90
	jg invalid
	mov ecx, 0
	jmp GotoEnd
	invalid:
		mov ecx, 1
	GotoEnd:
	ret
Verify endp

Cypher proc uses esi edx ecx
	
	mov esi, offset plug
	push esi
	mov edx, 0
	push edx
	mov esi, offset arevrs
	push esi
	movzx edx, astep
	push edx
	mov esi, offset brevrs
	push esi
	movzx edx, bstep
	push edx
	mov esi, offset crevrs
	push esi
	movzx edx, cstep
	push edx
	mov esi, offset reflct
	push esi
	mov edx, 0
	push edx
	mov esi, offset crotor
	push esi
	movzx edx, cstep
	push edx
	mov esi, offset brotor
	push esi
	movzx edx, bstep
	push edx
	mov esi, offset arotor
	push esi
	movzx edx, astep
	push edx
	mov esi, offset plug
	push esi
	mov edx, 0
	push edx
	
	mov ecx, 9
	RunRotors:
	pop edx
	pop esi
	invoke str_length, esi
	call PassThroughRotor
	loop RunRotors
	
	ret
Cypher endp


PassThroughRotor proc 
	; ebx is the letter
	
	
	ret
PassThroughRotor endp

end main