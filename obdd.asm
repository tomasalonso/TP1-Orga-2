extern free
extern malloc
extern dictionary_add_entry
extern obdd_mgr_get_next_node_ID
extern is_true
extern is_constant
extern obdd_apply_and_fkt
extern obdd_apply_or_fkt
extern dictionary_key_for_value

TRUE_VAR2 DB "1", 0
FALSE_VAR2 DB "0", 0

%define OFFSET_mgrID 0           ;manager
%define OFFSET_mgrgnodeID 4
%define OFFSET_mgrgvarID 8
%define OFFSET_mgrtrue 12
%define OFFSET_mgrfalse 20
%define OFFSET_mgrvars 28

%define OFFSET_nodevarID 0       ;node
%define OFFSET_nodenodeID 4
%define OFFSET_noderef 8
%define OFFSET_nodehigh 12
%define OFFSET_nodelow 20

%define OFFSET_obddmgr 0       ;obdd
%define OFFSET_obddroot 8

global obdd_mgr_mk_node
obdd_mgr_mk_node:
;RDI = mgr, RSI = var, RDX = high, RCX = low
push rbp
mov rbp, rsp
push rbx
push r12
push r14
push r15


mov r12, rdi
mov r14, rdx
mov r15, rcx

mov rdi, [r12 + OFFSET_mgrvars]
call dictionary_add_entry
mov eax, eax
mov ebx, eax
mov rdi, 28
call malloc
mov [rax], ebx
mov rbx, rax
mov rdi, r12
call obdd_mgr_get_next_node_ID
mov eax, eax
mov [rbx + OFFSET_nodenodeID], eax
cmp r14, 0
je .skip
add dword [r14 + OFFSET_noderef], 1
.skip:
cmp r15, 0
je .skip2
add dword [r15 + OFFSET_noderef], 1
.skip2:
mov [rbx + OFFSET_nodehigh], r14
mov [rbx + OFFSET_nodelow], r15
mov dword [rbx + OFFSET_noderef], 0
mov rax, rbx

pop r15
pop r14
pop r12
pop rbx
pop rbp
ret

global obdd_node_destroy
obdd_node_destroy:
push rbp
mov rbp, rsp
push rbx
push r12

mov rbx, rdi
mov edx, [rbx + OFFSET_noderef]
cmp edx, 0
jne .fin3

mov r12, [rbx + OFFSET_nodehigh]
cmp r12, 0
je .if2
mov qword [rbx + OFFSET_nodehigh], 0
sub dword [r12 + OFFSET_noderef], 1
mov rdi, r12
call obdd_node_destroy

.if2:
mov r12, [rbx + OFFSET_nodelow]
cmp r12, 0
je .prefin
mov qword [rbx + OFFSET_nodelow], 0
sub dword [r12 + OFFSET_noderef], 1
mov rdi, r12
call obdd_node_destroy

.prefin:
mov dword [rbx + OFFSET_nodevarID], 0
mov dword [rbx + OFFSET_nodenodeID], 0
mov rdi, rbx
call free

.fin3:
pop r12
pop rbx
pop rbp
ret

global obdd_create
obdd_create:
 push rbp
 mov rbp, rsp
 push r12
 push r13

 mov r12, rdi
 mov r13, rsi

mov rdi, 16
call malloc
mov [rax + OFFSET_obddmgr], r12
mov [rax + OFFSET_obddroot],  r13

pop r13
pop r12
pop rbp

ret

global obdd_destroy
obdd_destroy:
push rbp
mov rbp, rsp
push r12
sub rsp, 8

mov r12, rdi
mov rdi, [r12 + OFFSET_obddroot]
cmp rdi, 0
je .skip3
call obdd_node_destroy
mov qword [r12 + OFFSET_obddroot], 0
.skip3:
mov qword [r12 + OFFSET_obddmgr], 0
mov rdi, r12
call free

add rsp, 8
pop r12
pop rbp
ret

global obdd_node_apply
obdd_node_apply:
push rbp
mov rbp, rsp
push rbx
push r12      ;rdi, r12 bool *func apply
push r13      ;rsi, r13 mgr
push r14      ;rdx, r14 left node
push r15      ;rcx, r15 right node

mov r12, rdi
mov r13, rsi
mov r14, rdx
mov r15, rcx

mov rdi, [r13 + OFFSET_mgrvars]
mov esi, [r14 + OFFSET_nodevarID]
call dictionary_key_for_value

mov rbx, rax
mov rdi, [r13 + OFFSET_mgrvars]
mov esi, [r15 + OFFSET_nodevarID]
call dictionary_key_for_value

mov r10, rbx ;left_var en r10
mov r11, rax ;right_var en r11
push r11
push r10
mov rdi, r13
mov rsi, r14
call is_constant

mov ebx, eax
mov rdi, r13
mov rsi, r15
call is_constant

mov r8d, ebx ;r8 is left constant
mov r9d, eax ;r9 is right constant
push r9
push r8
and r8, r9
je .saltear

mov rdi, r13
mov rsi, r14
call is_true

mov ebx, eax
mov rdi, r13
mov rsi, r15
call is_true

mov edi, ebx
mov esi, eax
call r12
cmp eax, 1
jne .else

mov rdi, r13
mov rsi, TRUE_VAR2
xor rdx, rdx
xor rcx, rcx
call obdd_mgr_mk_node
jmp .endingshort

.else:
mov rdi, r13
mov rsi, FALSE_VAR2
xor rdx, rdx
xor rcx, rcx
call obdd_mgr_mk_node
jmp .endingshort

.saltear:
pop r8
cmp r8, 1
jne .if1
je .prend1

.if1:
pop r9
cmp r9, 1
jne .if2
je .prend2

.if2:
mov r8d, [r14 + OFFSET_nodevarID]
mov r9d, [r15 + OFFSET_nodevarID]
cmp r8, r9
je .prend3
jl .prend2
push r9
jmp .prend1

.prend1:
mov rdi, r12
mov rsi, r13
mov rdx, r14
mov rcx, [r15 + OFFSET_nodehigh]
call obdd_node_apply
push rax
mov rdi, r12
mov rsi, r13
mov rdx, r14
mov rcx, [r15 + OFFSET_nodelow]
call obdd_node_apply
mov rdi, r13
pop rdx
pop r9
pop r10
pop rsi
mov rcx, rax
call obdd_mgr_mk_node
jmp .ending

.prend2:
mov rdi, r12
mov rsi, r13
mov rdx, [r14 + OFFSET_nodehigh]
mov rcx, r15
call obdd_node_apply
push rax
mov rdi, r12
mov rsi, r13
mov rdx, [r14 + OFFSET_nodelow]
mov rcx, r15
call obdd_node_apply
jmp .final2y3

.prend3:
mov rdi, r12
mov rsi, r13
mov rdx, [r14 + OFFSET_nodehigh]
mov rcx, [r15 + OFFSET_nodehigh]
call obdd_node_apply
push rax
mov rdi, r12
mov rsi, r13
mov rdx, [r14 + OFFSET_nodelow]
mov rcx, [r15 + OFFSET_nodelow]
call obdd_node_apply

.final2y3:
mov rdi, r13
pop rdx
pop rsi
pop r11
mov rcx, rax
call obdd_mgr_mk_node
jmp .ending

.endingshort:
pop r8
pop r9
pop r10
pop r11

.ending:
pop r15
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret

global is_tautology
is_tautology:
push rbp
mov rbp, rsp
push rbx
push r12
push r13
push r14

mov r12, rdi
mov r13, rsi
call is_constant
mov eax, eax

cmp eax, 0
je .skip4
mov rdi, r12
mov rsi, r13
call is_true
mov eax, eax
jmp .fin

.skip4:
mov rdi, r12
mov rsi, [r13 + OFFSET_nodehigh]
call is_tautology
mov ebx, eax
mov rdi, r12
mov rsi, [r13 + OFFSET_nodelow]
call is_tautology
mov r14d, eax
mov edi, ebx
mov esi, r14d
call obdd_apply_and_fkt
mov eax, eax

.fin:
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret

global is_sat
is_sat:

push rbp
mov rbp, rsp
push rbx
push r12
push r13
push r14

mov r12, rdi
mov r13, rsi
call is_constant
mov eax, eax

cmp eax, 0
je .skip5
mov rdi, r12
mov rsi, r13
call is_true
mov eax, eax
jmp .fin2

.skip5:
mov rdi, r12
mov rsi, [r13 + OFFSET_nodehigh]
call is_sat
mov ebx, eax
mov rdi, r12
mov rsi, [r13 + OFFSET_nodelow]
call is_sat
mov r14d, eax
mov edi, ebx
mov esi, r14d
call obdd_apply_or_fkt
mov eax, eax

.fin2:
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret

global str_len
str_len:
mov rax, 0
.ciclo:
mov sil, [rdi]
cmp sil, 0
je .final
inc rdi
inc rax
jmp .ciclo

.final:
ret

global str_copy
str_copy:
push rbp
mov rbp, rsp
push rbx
push r12

mov r12, rdi
mov rdi, r12
call str_len
mov rdi, rax
inc rdi
call malloc
mov rsi, rax
.ciclar:
mov bl, [r12]
mov [rax], bl
cmp bl, 0
je .fin6
inc r12
inc rax
jmp .ciclar

.fin6:

mov rax, rsi
pop r12
pop rbx
pop rbp
ret

global str_cmp
str_cmp:
push rbp
mov rbp, rsp

.ciclo:
mov cl, [rdi]
mov dl, [rsi]
cmp cl, 0
je .comparo
cmp dl, 0
je .devuelveN
cmp cl, dl

je .seguir
jl .devuelveP
jmp .devuelveN

.seguir:
inc rdi
inc rsi
jmp .ciclo

.comparo:
cmp dl, 0
je .devuelve0
jne .devuelveP

.devuelveP:
mov rax, 1
jmp .fin4

.devuelveN:
mov rax, -1
jmp .fin4

.devuelve0:
mov rax, 0

.fin4:
pop rbp
ret
