section .data

WRITE_FUNC      equ 0x1
PRINT_NUMBER    equ 0x1
STDOUT          equ 0x1

BUFFER_LEN equ 0xFF

END_SYMBOL           equ 0x0
ARG_SYMBOL           equ '%'
JUMP_TABLE_FIRST_SYM equ 'b'
%define JUMP_TABLE_LEN_FROM_F_TO_N  'n'-'f' - 1
%define JUMP_TABLE_LEN_FROM_N_TO_O  'o'-'n' - 1
%define JUMP_TABLE_LEN_FROM_O_TO_S  's'-'o' - 1
%define JUMP_TABLE_LEN_FROM_S_TO_X  'x'-'s' - 1

DONE_RESULT      equ 0x0
INVALID_ARGUMENT equ 0x1

ADDRESS_LEN_POW_2 equ 0x3
STACK_ELEM_SIZE   equ 0x8
QWORD_LEN         equ 0x3

SIGN_MASK dq 0xA000000000000000                            ; First bit is 1, other are 0
MINUS     equ '-'

REGISTER_SIZE equ 64
INT_SIZE      equ 32
FLOAT_SIZE    equ 32
DOUBLE_SIZE   equ 64

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

TEN  equ 0xA
FIVE equ 0x5

EAX_PATTERN equ 0x00000000FFFFFFFF

MANTISSA_LEN equ 52
MANTISSA_ONE dq 0x0010000000000000

EXPONENT equ 0b10000000000

FLAG_NEG_RCX equ 1
FLAG_DEF_RCX equ 0

FLAG_PLUS  equ 0
FLAG_MINUS equ 1

%define LOC_VAR_NUM_PRINTED qword [rbp - STACK_ELEM_SIZE]

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

    sub rsp, STACK_ELEM_SIZE
    mov LOC_VAR_NUM_PRINTED, 0x0    ; Local variable with number of printed symbols

    mov r8, rbp
    add r8, STACK_ELEM_SIZE * 2     ; R8 - pointer of the argument
    mov rsi, qword [r8]             ; Move pointer of string to RSI -
    add r8, STACK_ELEM_SIZE

    jmp MyPrintfReal                ; Start real Printf

ExitFunction:
    add rsp, STACK_ELEM_SIZE
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

    mov rax, CURRENT_ARGUMENT
    INCREASE_ARGUMENT_INDEX
    INCREASE_ARGUMENT_NUMBER
    call PrintArgD
    jmp .Conditional

;-----------------

.ArgF:

    movq rax, xmm0
    ; cvtss2si eax, xmm0
    call PrintArgF
    jmp .Conditional

;-----------------

.ArgN:

    mov rax, CURRENT_ARGUMENT
    INCREASE_ARGUMENT_INDEX
    INCREASE_ARGUMENT_NUMBER
    mov rdx, LOC_VAR_NUM_PRINTED
    add rdx, rcx
    mov qword [rax], rdx
    jmp .Conditional

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
    dq .InvalidArgument                                     ; %e
    dq .ArgF
    dq JUMP_TABLE_LEN_FROM_F_TO_N dup (.InvalidArgument)
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
    add LOC_VAR_NUM_PRINTED, rcx
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
; It translates RAX values
; to the string
;
; Entry:  RAX
; Exit:   Buffer
; Destrs: RAX, RDX
;---------------------------------

PrintArgD:

    push rax
    push rbx
    push rdi
    push rsi

    push rcx
    mov rcx, REGISTER_SIZE
    shr rcx, 1                               ; CL = REGISTER_SIZE / 4
    shl rax, cl
    shr rax, cl                              ; Prepare DX and AX for dividing
    pop rcx

    mov rbx, INT_SIZE
    call CheckSign
    mov ebx, TEN

    xor rdx, rdx

    xor rsi, rsi                             ; RSI - Counter of digits in the number

    mov rdi, FLAG_START_NUMBER

.Conditional_1:
    test rax, rax
    je .StopWhile_1

.While_1:
    div ebx
    push rdx
    xor rdx, rdx
    inc rsi
    jmp .Conditional_1

.StopWhile_1:

.Conditional_2:
    test rsi, rsi
    je .StopWhile_2

.While_2:
    pop rax
    call DigitToStr
    dec rsi
    jmp .Conditional_2

.StopWhile_2:

    pop rsi
    pop rdi
    pop rbx
    pop rax

    ret

;---------------------------------


;---------------------------------
; It translates RAX values
; to the string
;
; Entry:  RAX
; Exit:   Buffer
; Destrs: RAX
;---------------------------------

PrintArgF:

    push rax
    push rbx
    push rdx

    mov rbx, DOUBLE_SIZE
    call CheckSign
    push rcx

    cmp rdx, FLAG_MINUS
    je .NegativeNum

    mov rdx, rax
    shr rdx, MANTISSA_LEN
    mov rbx, EXPONENT
    inc rdx
    sub rdx, rbx                             ; DX - Exponent

.ContinueNegativeNum:
    mov rbx, rax
    shl rbx, DOUBLE_SIZE - MANTISSA_LEN
    shr rbx, DOUBLE_SIZE - MANTISSA_LEN
    add rbx, qword [MANTISSA_ONE]                    ; RBX - Mantissa

    mov rcx, MANTISSA_LEN
    sub rcx, rdx


.ConditionalLeaveZeroes:
    push rbx
    and rbx, 0x1
    cmp rbx, 0x1
    pop rbx
    je .ExitWhileLiveZeroes

.WhileLiveZeroes:
    shr rbx, 0x1
    dec rcx
    jmp .ConditionalLeaveZeroes

.ExitWhileLiveZeroes:
                                                ; Printed number = RBX * 2 ^ (-RCX)
                                                ; Printed number = RBX * 5 ^ (RCX) * 10 ^ (-RCX)
    cmp rcx, [SIGN_MASK]
    ja .NegRCX
    je .ZeroRCX
    cmp rcx, 0x0
    je .ZeroRCX

    push rcx
.For:
    imul rbx, FIVE                          ; 5 = 10 / 2
    loop .For
    pop rcx

    mov rax, rbx
    mov rbx, rcx
    pop rcx
    call PrintNumber

.Done:
    pop rdx
    pop rbx
    pop rax

    ret

.NegRCX:
    neg rcx
    shl rbx, cl
    mov rax, rbx
    pop rcx
    call PrintArgD
    jmp .Done

.ZeroRCX:
    mov rax, rbx
    pop rcx
    call PrintArgD
    jmp .Done

.NegativeNum:
    neg rax
    shl rax, 1
    shr rax, 1
    ; push rax
    ; fst qword [rsp]
    ; push rax
    ; fld dword [rsp]
    ; fchs                                     ; Negate the value of the float number on the top of the stack
    ; fst qword [rsp]
    ; pop rax
    ; mov rdx, rax
    ; fld dword [rsp]
    ; pop rax
    mov rdx, rax
    shr rdx, MANTISSA_LEN
    mov rbx, EXPONENT
    inc rdx
    sub rdx, rbx                             ; DX - Exponent
    jmp .ContinueNegativeNum

;---------------------------------


;---------------------------------
; It prints number RAX * 10 ^ (-RBX)
;
; Entry:  RAX, RBX, RCX
; Exit:   Buffer
; Destrs: RAX
;---------------------------------

PrintNumber:

    push rax
    push rdx
    push rbx
    push rdi
    push rsi

    mov rdi, rbx

    mov ebx, TEN

    xor rdx, rdx

    xor rsi, rsi                             ; RSI - Counter of digits in the number


.Conditional_1:
    test rax, rax
    je .StopWhile_1

.While_1:
    div ebx
    push rdx
    xor rdx, rdx
    inc rsi
    jmp .Conditional_1

.StopWhile_1:

    mov rbx, rdi
    cmp rbx, rsi
    jae .ZeroStarted                            ; RBX more than length of RAX so number will looks like '0.etc'
    jmp .RSImoreRBX

.Conditional_2:
    test rsi, rsi
    je .StopWhile_2

.While_2:
    pop rax
    call DigitToStr
    dec rsi
    jmp .Conditional_2

.StopWhile_2:

    pop rsi
    pop rdi
    pop rbx
    pop rdx
    pop rax

    ret

.ZeroStarted:
; Выводи нули, пока регистры rbx и rsi не станут равны, потом просто выведи число

    cmp rcx, BUFFER_LEN - 1
    jae .BufferEndZeroStarted

.ContinueZeroStarted:
    mov word [Buffer + rcx], '0.'               ; The number started with '0.'
    add rcx, 2

.Conditional_ZeroStarted:
    cmp rsi, rbx
    je .StopWhile_ZeroStarted

.While_ZeroStarted:
    xor rax, rax
    call DigitToStr
    dec rbx
    jmp .Conditional_ZeroStarted

.StopWhile_ZeroStarted:

    jmp .Conditional_2

.BufferEndZeroStarted:
    push rsi
    call PrintBuffer
    pop rsi
    jmp .ContinueZeroStarted

.RSImoreRBX:
; Print numbers of RAX until RBX = RSI. Then put '.' and print other numbers

.Conditional_RBX:
    cmp rsi, rbx
    je .StopWhile_RBX

.While_RBX:
    pop rax
    call DigitToStr
    dec rsi
    jmp .Conditional_RBX

.StopWhile_RBX:

    cmp rcx, BUFFER_LEN
    je .BufferEndRSImoreRBX

.ContinueRSImoreRBX:
    mov byte [Buffer + rcx], '.'
    inc rcx
    jmp .Conditional_2

.BufferEndRSImoreRBX:
    push rsi
    call PrintBuffer
    pop rsi
    jmp .ContinueRSImoreRBX

;---------------------------------


;---------------------------------
; It moves sign to the buffer
;
; Entry:  RAX, RBX
; Exit:   Buffer
; Destrs: RBX, RDX
;---------------------------------

CheckSign:

    push rax

    push rcx
    mov rcx, rbx
    sub rcx, 1
    shr rax, cl
    pop rcx

    cmp rax, 1
    je .Minus
    pop rax
    mov rdx, FLAG_PLUS

.Done:
    ret

.Minus:
    cmp rcx, BUFFER_LEN
    je .BufferEnd

.Continue:
    pop rax
    neg rax
    mov byte [Buffer + rcx],  MINUS
    inc rcx
    mov rdx, FLAG_MINUS
    jmp .Done

.BufferEnd:
    push rcx
    call PrintBuffer
    pop rcx
    jmp .Continue

;---------------------------------


;---------------------------------
; It translates RAX values
; to the string with value in a form of
; number system of 2 to the power RSI
;
; Entry:  RAX, RSI
; Exit:   Buffer
; Destrs: RAX
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
; Exit:   Buffer
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
    push rsi
    call PrintBuffer
    pop rsi
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
; Destrs: RAX, RDX, RDI
;---------------------------------

PrintArgString:

    push rsi

    call PrintBuffer

    pop rsi

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
    add LOC_VAR_NUM_PRINTED, rcx
    syscall

    xor rcx, rcx

    ret

;---------------------------------

;--------------------------------------------

