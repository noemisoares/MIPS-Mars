.data
msg_n:      .asciiz "Digite n (1 a 20): "
msg_erro:   .asciiz "Valor invalido: n deve estar entre 1 e 20.\n"
msg_a:      .asciiz "\nElementos de A:\n"
msg_b:      .asciiz "\nElementos de B:\n"
abre_a:     .asciiz "A["
abre_b:     .asciiz "B["
fecha:      .asciiz "]: "
msg_cont:   .asciiz "\nElementos copiados para C (countC): "
msg_c:      .asciiz "\nConteudo de C: "
espaco:     .asciiz " "

            .align 2
vetA:       .space 80
vetB:       .space 80
vetC:       .space 80

.text
.globl main

main:
    # le n
    li   $v0, 4
    la   $a0, msg_n
    syscall
    li   $v0, 5
    syscall
    move $s0, $v0               # s0 = n

    # validacao: 1 <= n <= 20
    blez $s0, ERRO
    slti $t1, $s0, 21
    beq  $t1, $zero, ERRO

    # le os elementos de A
    li   $v0, 4
    la   $a0, msg_a
    syscall
    la   $s1, vetA
    li   $t0, 0
LEIA:
    beq  $t0, $s0, INIB
    li   $v0, 4
    la   $a0, abre_a
    syscall
    li   $v0, 1
    move $a0, $t0
    syscall
    li   $v0, 4
    la   $a0, fecha
    syscall
    li   $v0, 5
    syscall
    sll  $t1, $t0, 2
    add  $t1, $s1, $t1
    sw   $v0, 0($t1)
    addi $t0, $t0, 1
    j    LEIA

    # le os elementos de B
INIB:
    li   $v0, 4
    la   $a0, msg_b
    syscall
    la   $s2, vetB
    li   $t0, 0
LEIB:
    beq  $t0, $s0, CHAMA
    li   $v0, 4
    la   $a0, abre_b
    syscall
    li   $v0, 1
    move $a0, $t0
    syscall
    li   $v0, 4
    la   $a0, fecha
    syscall
    li   $v0, 5
    syscall
    sll  $t1, $t0, 2
    add  $t1, $s2, $t1
    sw   $v0, 0($t1)
    addi $t0, $t0, 1
    j    LEIB

CHAMA:
    # mapeamento: n = $a0, A = $a1, B = $a2, C = $a3
    move $a0, $s0
    la   $a1, vetA
    la   $a2, vetB
    la   $a3, vetC
    jal  PROC1
    move $s3, $v0               # s3 = countC (retorno do procedimento)

    # mostra a quantidade de elementos copiados
    li   $v0, 4
    la   $a0, msg_cont
    syscall
    li   $v0, 1
    move $a0, $s3
    syscall

    # mostra o conteudo de C
    li   $v0, 4
    la   $a0, msg_c
    syscall
    la   $s4, vetC
    li   $t0, 0
MOSTRAC:
    beq  $t0, $s3, SAIR
    sll  $t1, $t0, 2
    add  $t1, $s4, $t1
    lw   $a0, 0($t1)
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, espaco
    syscall
    addi $t0, $t0, 1
    j    MOSTRAC

ERRO:
    li   $v0, 4
    la   $a0, msg_erro
    syscall

SAIR:
    li   $v0, 10
    syscall


PROC1:
    add  $v0, $zero, $zero      # countC = 0
    add  $t0, $zero, $zero      # countA = 0
    addi $t1, $a0, -1           # countB = n - 1
    addi $t5, $zero, 5          # t5 = 5

LOOP:
    beq  $t0, $a0, FIM          # countA == n ?
    add  $t2, $t0, $t0          # 2 x countA
    add  $t2, $t2, $t2          # 4 x countA
    add  $t2, $a1, $t2          # &A[countA]
    lw   $t3, 0($t2)            # t3 = A[countA]
    beq  $t3, $t5, FIM          # A[countA] == 5 ?
    add  $t2, $t1, $t1          # 2 x countB
    add  $t2, $t2, $t2          # 4 x countB
    add  $t2, $a2, $t2          # &B[countB]
    lw   $t4, 0($t2)            # t4 = B[countB]
    beq  $t4, $t5, FIM          # B[countB] == 5 ?
    slt  $t2, $t4, $t3          # B[countB] < A[countA] ?
    bne  $t2, $zero, COPA
    add  $t6, $zero, $t4        # t6 = B[countB]
    j    GRAVC

COPA:
    add  $t6, $zero, $t3        # t6 = A[countA]

GRAVC:
    add  $t2, $v0, $v0          # 2 x countC
    add  $t2, $t2, $t2          # 4 x countC
    add  $t2, $a3, $t2          # &C[countC]
    sw   $t6, 0($t2)            # C[countC] = valor
    addi $t0, $t0, 1            # countA + 1
    addi $t1, $t1, -1           # countB - 1
    addi $v0, $v0, 1            # countC + 1
    j    LOOP

FIM:
    jr   $ra
