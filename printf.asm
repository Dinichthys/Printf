section .data

WRITE_FUNC      equ 0x1
PRINT_NUMBER    equ 0x1
STDOUT          equ 0x1

END_SYMBOL      equ 0x0
ARG_SYMBOL      equ '%'
JUMP_TABLE_FIRST_SYM equ 'b'
%define JUMP_TABLE_LEN  'x'-'b' + 1

DONE_RESULT      equ 0x0
INVALID_ARGUMENT equ 0x1

ADDRESS_LEN_POW_2 equ 0x3
STACK_ELEM_SIZE   equ 0x8

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
    mov rsi, qword [r8]              ; Move pointer of string to RSI
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
; Dest:  RCX, RDX, RSI, RDI, R8, R11
;--------------------------------------------

MyPrintfReal:

    mov rcx, 0x0                                ; Start counting arguments

    mov rax, WRITE_FUNC
    mov rdi, STDOUT
    mov rdx, PRINT_NUMBER                       ; Make parameters of syscall

.Conditional:
    cmp byte [rsi], END_SYMBOL
    je .Done                                    ; Check if there is the end of the string

.While:
    cmp byte [rsi], ARG_SYMBOL
    je .PrintArgument                           ; Check if an argument is needed

    syscall                                     ; Print symbol

    inc rsi                                     ; RSI is the pointer of the next symbol of the string
    jmp .Conditional

.Done:
    mov rax, DONE_RESULT

.StopPrint:
    jmp ExitFunction

.PrintArgument:
    inc rsi

    xor rax, rax
    mov al, byte [rsi]                          ; Move char to RAX
    sub rax, JUMP_TABLE_FIRST_SYM

    push rbx
    push rax
    shl rax, ADDRESS_LEN_POW_2                  ; Multiply RAX by the len of address (8 bytes)
    pop rbx
    add rax, rbx                                ; RAX = RAX * 9
    pop rbx

    add rax, .JumpTable
    jmp rax

.InvalidArgument:

    mov rax, INVALID_ARGUMENT
    jmp .StopPrint

.JumpTable:
    times JUMP_TABLE_LEN jmp .InvalidArgument


;--------------------------------------------

