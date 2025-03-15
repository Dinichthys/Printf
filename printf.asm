section .data

WRITE_FUNC      equ 0x1
PRINT_NUMBER    equ 0x1
STDOUT          equ 0x1

BUFFER_LEN equ 0xFF

END_SYMBOL      equ 0x0
ARG_SYMBOL      equ '%'
JUMP_TABLE_FIRST_SYM equ 'b'
%define JUMP_TABLE_LEN_FROM_D_TO_N  'n'-'d' - 1
%define JUMP_TABLE_LEN_FROM_N_TO_O  'o'-'n' - 1
%define JUMP_TABLE_LEN_FROM_O_TO_S  's'-'o' - 1
%define JUMP_TABLE_LEN_FROM_S_TO_X  'x'-'s' - 1

DONE_RESULT      equ 0x0
INVALID_ARGUMENT equ 0x1

ADDRESS_LEN_POW_2 equ 0x3
STACK_ELEM_SIZE   equ 0x8
QWORD_LEN         equ 0x3

SIGN_MASK equ 0xA000000000000000                            ; First bit is 1, other are 0
MINUS     equ '-'

REGISTER_SIZE equ 64

%define CURRENT_ARGUMENT        qword [r8]
%define INCREASE_ARGUMENT_INDEX add r8, STACK_ELEM_SIZE
%define ARGUMENT_INDEX          r8

%define START_COUNTING_ARGUMENTS xor r9, r9
%define INCREASE_ARGUMENT_NUMBER inc r9
%define ARGUMENT_NUMBER          r9

FLAG_START_NUMBER equ 0x1
FLAG_END_NUMBER   equ 0x0

FIRST_DEGREE  equ 0x1
THIRD_DEGREE  equ 0x3
FOURTH_DEGREE equ 0x4

Alphabet:
    db '0123456789ABCDEF'

Buffer:
    db BUFFER_LEN dup (0)

;--------------------------------------------


;--------------------------------------------

section .text

global MyPrintf

;--------------------------------------------
; Function pushes all parameters to stack
; and save pointer on string in rdi
;
; Entry: RDI, RSI, RDX, RCX, R8, R9, STACK
; Exit:  Stdout
; Dest:  RAX
;--------------------------------------------

MyPrintf:

    pop rax                         ; Save returning value

    push r9                         ; Push parameters
    push r8
    push rcx
    push rdx
    push rsi
    push rdi

    push rax

    push rbp
    mov rbp, rsp                    ; Make the stack frame

    mov r8, rbp
    add r8, STACK_ELEM_SIZE * 2     ; R8 - pointer of the argument
    mov rsi, qword [r8]             ; Move pointer of string to RSI -
    add r8, STACK_ELEM_SIZE

    jmp MyPrintfReal                ; Start real Printf

ExitFunction:
    mov rsp, rbp

    pop rbp
    pop rdi

    add rsp, STACK_ELEM_SIZE * 6
    push rdi

    ret

;--------------------------------------------

;--------------------------------------------
; Function print the string with parameters
; pointed by R8
;
; Entry: RSI, R8
; Exit:  Stdout, RAX
; Dest:  RCX, RDX, RSI, RDI, R8, R9, R11
;--------------------------------------------

MyPrintfReal:
    xor rcx, rcx
    START_COUNTING_ARGUMENTS                    ; Start counting arguments

;---------------------------------

.Conditional:
    cmp byte [rsi], END_SYMBOL
    je .Done                                    ; Check if there is the end of the string

.While:
    cmp byte [rsi], ARG_SYMBOL
    je .PrintArgument                           ; Check if an argument is needed

.PrintChar:
    cmp rcx, BUFFER_LEN
    je .BufferEnd

.Continue:
    mov al, byte [rsi]
    mov byte [Buffer + rcx], al
    inc rcx

    inc rsi                                     ; RSI is the pointer of the next symbol of the string
    jmp .Conditional

;---------------------------------

.Done:
    cmp rcx, 0x0
    jne .LastPrintBuffer

.MovDoneResult:
    mov rax, DONE_RESULT

.StopPrint:
    jmp ExitFunction

.LastPrintBuffer:
    call PrintBuffer
    jmp .MovDoneResult

;---------------------------------

.BufferEnd:
    call PrintBuffer
    jmp .Continue

;---------------------------------

.PrintArgument:
    inc rsi

    cmp byte [rsi], ARG_SYMBOL
    je .PrintChar
    xor rax, rax
    mov al, byte [rsi]
    inc rsi
    sub rax, JUMP_TABLE_FIRST_SYM               ; RAX is the number of string in JumpTable

    shl rax, QWORD_LEN

    add rax, .JumpTable
    mov rax, [rax]
    jmp rax

;---------------------------------

.InvalidArgument:

    mov rax, INVALID_ARGUMENT
    jmp .StopPrint

;-----------------

.ArgB:

    mov rax, CURRENT_ARGUMENT
    INCREASE_ARGUMENT_INDEX
    INCREASE_ARGUMENT_NUMBER
    push rsi
    mov rsi, FIRST_DEGREE                   ; RSI - the number of power of 2 in counting system
    call ValToStrPowTwo
    pop rsi
    jmp .Conditional

;-----------------

.ArgC:

    call PrintArgC
    jmp .Conditional

;-----------------

.ArgD:

;-----------------

.ArgN:

;-----------------

.ArgO:

    mov rax, CURRENT_ARGUMENT
    INCREASE_ARGUMENT_INDEX
    INCREASE_ARGUMENT_NUMBER
    call ValToStrOct
    jmp .Conditional

;-----------------

.ArgS:

    push rsi
    mov rsi, CURRENT_ARGUMENT
    INCREASE_ARGUMENT_INDEX
    INCREASE_ARGUMENT_NUMBER
    call PrintArgString
    pop rsi
    jmp .Conditional

;-----------------

.ArgX:

    mov rax, CURRENT_ARGUMENT
    INCREASE_ARGUMENT_INDEX
    INCREASE_ARGUMENT_NUMBER
    push rsi
    mov rsi, FOURTH_DEGREE                  ; RSI - the number of power of 2 in counting system
    call ValToStrPowTwo
    pop rsi
    jmp .Conditional

;---------------------------------

.JumpTable:
    dq .ArgB
    dq .ArgC
    dq .ArgD
    dq JUMP_TABLE_LEN_FROM_D_TO_N dup (.InvalidArgument)
    dq .ArgN
    dq JUMP_TABLE_LEN_FROM_N_TO_O dup (.InvalidArgument)
    dq .ArgO
    dq JUMP_TABLE_LEN_FROM_O_TO_S dup (.InvalidArgument)
    dq .ArgS
    dq JUMP_TABLE_LEN_FROM_S_TO_X dup (.InvalidArgument)
    dq .ArgX

;---------------------------------
; Prints buffer to stdout and
; mov null to rcx
;
; Entry:  Buffer, RCX
; Exit:   Stdout, RCX
; Destrs: RAX, RDI, RSI, RDX, R11
;---------------------------------

PrintBuffer:
    mov rax, WRITE_FUNC
    mov rdi, STDOUT         ; Make parameters of syscall
    mov rsi, Buffer
    mov rdx, rcx
    syscall
    xor rcx, rcx

    ret

;---------------------------------


;---------------------------------
; It moves argument char to buffer
;
; Entry:  RAX, RCX
; Exit:   Stdout, RCX, Buffer
; Destrs: RAX, RBX, RCX, RDX
;---------------------------------

PrintArgC:

    mov rax, CURRENT_ARGUMENT
    cmp rcx, BUFFER_LEN
    je .BufferEnd

.Continue:
    mov byte [Buffer + rcx], al
    inc rcx
    INCREASE_ARGUMENT_INDEX
    INCREASE_ARGUMENT_NUMBER
    ret

.BufferEnd:
    call PrintBuffer
    jmp .Continue

;---------------------------------


;---------------------------------
; It pushes sign to stack
;
; Entry:  RAX
; Exit:   STACK
; Destrs: RAX, RBX, RDX
;---------------------------------

CheckSign:

    shr rax, REGISTER_SIZE - 1
    cmp rax, 1
    je .Minus

.Done:
    ret

.Minus:
    cmp rcx, BUFFER_LEN
    je .BufferEnd

.Continue:
    mov byte [Buffer + rcx],  MINUS
    jmp .Done

.BufferEnd:
    call PrintBuffer
    jmp .Continue

;---------------------------------


;---------------------------------
; It translates RAX values
; to the string with value in a form of
; number system of 2 to the power RSI
;
; Entry:  RAX, RSI
; Exit:   STRING
; Destrs: RAX, RDI
;---------------------------------

ValToStrPowTwo:

    push rdi
    push rbx
    push rdx
    push rax

    xor rdx, rdx
    mov rbx, REGISTER_SIZE
    sub rbx, rsi
    mov rdi, FLAG_START_NUMBER

.Conditional:
    cmp rdx, REGISTER_SIZE
    jae .StopWhile

.While:
    push rcx
    mov rcx, rdx
    shl rax, cl
    mov rcx, rbx
    add rcx, rdx
    shr rax, cl
    pop rcx
    call DigitToStr
    pop rax
    push rax
    sub rbx, rsi
    add rdx, rsi
    jmp .Conditional

.StopWhile:

    pop rax
    pop rdx
    pop rbx
    pop rdi
    ret

;---------------------------------


;---------------------------------
; It translates RAX values
; to the string with value in a form of
; octal number system
;
; Entry:  RAX
; Exit:   STRING
; Destrs: RAX, RDI
;---------------------------------

ValToStrOct:

    push rdi
    push rbx
    push rdx
    push rax

    xor rdx, rdx
    mov rbx, REGISTER_SIZE
    sub rbx, 1                                  ; 64 mod 3 = 1, where 64 bit - size of register, 3 - power of 2
    mov rdi, FLAG_START_NUMBER

.Conditional:
    cmp rdx, REGISTER_SIZE
    jae .StopWhile

.While:
    push rcx
    mov rcx, rdx
    shl rax, cl
    mov rcx, rbx
    add rcx, rdx
    shr rax, cl
    pop rcx
    call DigitToStr
    pop rax
    push rax
    sub rbx, THIRD_DEGREE
    test rdx, rdx
    je .FirstDigit
    add rdx, THIRD_DEGREE
    jmp .Conditional

.StopWhile:
    pop rax
    pop rdx
    pop rbx
    pop rdi
    ret

.FirstDigit:
    add rdx, 1                                  ; 64 mod 3 = 1, where 64 bit - size of register, 3 - power of 2
    jmp .Conditional

;---------------------------------


;---------------------------------
; It translates number from AL to
; stack
;
; Entry:  RAX, RDI
; Exit:   Buffer
; Destrs: RAX, RDI
;---------------------------------

DigitToStr:

    cmp rcx, BUFFER_LEN
    je .BufferEnd

.Continue:
    cmp rdi, FLAG_START_NUMBER
    je .SkipZeroes

.DontSkip:
    mov al, byte [Alphabet + rax]
    mov byte [Buffer + rcx], al
    inc rcx

.Skip:
    ret

.SkipZeroes:
    test rax, rax
    je .Skip
    mov rdi, FLAG_END_NUMBER
    jmp .DontSkip

.BufferEnd:
    push rax
    push rbx
    push rdx
    call PrintBuffer
    pop rdx
    pop rbx
    pop rax
    jmp .Continue

;---------------------------------


;---------------------------------
; It prints string pointed by RSI
;
; Entry:  RSI
; Exit:   Stdout
; Destrs: RAX, RDX, RDI,
;---------------------------------

PrintArgString:

    push rcx

    xor rcx, rcx

.Conditional:
    cmp byte [rsi], END_SYMBOL
    je .ExitWhile

.While:
    inc rsi
    inc rcx
    jmp .Conditional

.ExitWhile:
    mov rax, WRITE_FUNC
    mov rdi, STDOUT         ; Make parameters of syscall
    sub rsi, rcx
    mov rdx, rcx
    syscall

    pop rcx
    ret

;---------------------------------

;--------------------------------------------

