.data
msg_x:      .asciiz "Digite X (positivo): "
msg_y:      .asciiz "Digite Y (positivo): "
msg_w:      .asciiz "Digite W (nao negativo): "
msg_n:      .asciiz "Digite N, o expoente (nao negativo): "
msg_a:      .asciiz "Digite A (nao negativo): "
msg_b:      .asciiz "Digite B (nao negativo): "
msg_c:      .asciiz "Digite C (nao negativo): "
msg_erro:   .asciiz "Valores invalidos: X e Y devem ser > 0 e os demais >= 0.\n"
msg_z:      .asciiz "\nZ = "

            .align 2
vx:         .word 0
vy:         .word 0
vw:         .word 0
vn:         .word 0
va:         .word 0
vb:         .word 0
vc:         .word 0

.text
.globl main

main:
    # le os valores (cada um em uma linha)
    la   $a0, msg_x
    jal  LER
    sw   $v0, vx
    la   $a0, msg_y
    jal  LER
    sw   $v0, vy
    la   $a0, msg_w
    jal  LER
    sw   $v0, vw
    la   $a0, msg_n
    jal  LER
    sw   $v0, vn
    la   $a0, msg_a
    jal  LER
    sw   $v0, va
    la   $a0, msg_b
    jal  LER
    sw   $v0, vb
    la   $a0, msg_c
    jal  LER
    sw   $v0, vc

    # validacao (X e Y = 0 causariam laco infinito no DIV)
    lw   $t3, vx
    blez $t3, ERRO
    lw   $t3, vy
    blez $t3, ERRO
    lw   $t3, vw
    bltz $t3, ERRO
    lw   $t3, vn
    bltz $t3, ERRO
    lw   $t3, va
    bltz $t3, ERRO
    lw   $t3, vb
    bltz $t3, ERRO
    lw   $t3, vc
    bltz $t3, ERRO

    # parametros: X = $a0, Y = $a1, W = $a2, N = $a3
    # variaveis internas: A = $t0, B = $t1, C = $t2
    lw   $a0, vx
    lw   $a1, vy
    lw   $a2, vw
    lw   $a3, vn
    lw   $t0, va
    lw   $t1, vb
    lw   $t2, vc
    jal  EXPR

    move $t3, $v0               # guarda Z antes das syscalls
    li   $v0, 4
    la   $a0, msg_z
    syscall
    li   $v0, 1
    move $a0, $t3
    syscall
    j    SAIR

ERRO:
    li   $v0, 4
    la   $a0, msg_erro
    syscall

SAIR:
    li   $v0, 10
    syscall

# ---------------------------------------------------
# LER: imprime a mensagem em $a0 e le um inteiro em $v0
# ---------------------------------------------------
LER:
    li   $v0, 4
    syscall
    li   $v0, 5
    syscall
    jr   $ra

# ---------------------------------------------------
# EXPR: Z = [(A/X) + B(C/Y) + (CW)]^N
# ---------------------------------------------------
EXPR:
    addi $sp, $sp, -32
    sw   $a0, 0($sp)            # X
    sw   $a1, 4($sp)            # Y
    sw   $a2, 8($sp)            # W
    sw   $a3, 12($sp)           # N
    sw   $t0, 16($sp)           # A
    sw   $t1, 20($sp)           # B
    sw   $t2, 24($sp)           # C
    sw   $ra, 28($sp)

    lw   $a1, 16($sp)           # A
    jal  DIV                    # A / X  (a0 = X ainda)
    add  $t0, $zero, $v0        # t0 = A/X

    lw   $a1, 24($sp)           # C
    lw   $a0, 4($sp)            # Y
    jal  DIV                    # C / Y
    add  $a0, $zero, $v0        # a0 = C/Y
    lw   $a1, 20($sp)           # B
    jal  MULT                   # B * (C/Y)
    add  $t1, $zero, $v0        # t1 = B(C/Y)

    lw   $a0, 8($sp)            # W
    lw   $a1, 24($sp)           # C
    jal  MULT                   # C * W
    add  $t2, $zero, $v0        # t2 = CW

    add  $a2, $t0, $t1
    add  $a2, $a2, $t2          # a2 = base; a3 = N continua intacto
    jal  POT
    add  $v0, $zero, $v1        # Z

    lw   $ra, 28($sp)
    addi $sp, $sp, 32
    jr   $ra

# ---------------------------------------------------
# DIV: v0 = a1 / a0 (subtracoes sucessivas)
# ---------------------------------------------------
DIV:
    add  $t4, $zero, $zero
LOOP_DIV:
    slt  $t3, $a1, $a0
    bne  $t3, $zero, FIM_DIV
    sub  $a1, $a1, $a0
    addi $t4, $t4, 1
    j    LOOP_DIV
FIM_DIV:
    add  $v0, $zero, $t4        
    jr   $ra

# ---------------------------------------------------
# MULT: v0 = a1 * a0 (somas sucessivas)
# ---------------------------------------------------
MULT:
    add  $t5, $zero, $zero
    add  $t4, $zero, $zero
LOOP_MULT:
    slt  $t3, $t4, $a0
    beq  $t3, $zero, FIM_MULT
    addi $t4, $t4, 1
    add  $t5, $t5, $a1
    j    LOOP_MULT
FIM_MULT:
    add  $v0, $zero, $t5
    jr   $ra

# ---------------------------------------------------
# POT: v1 = a2 ^ a3 (multiplicacoes sucessivas usando MULT)
# ---------------------------------------------------
POT:
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $a2, 12($sp)           # base
    sw   $a3, 8($sp)            # expoente
    addi $t0, $zero, 1
    sw   $t0, 4($sp)            # resultado = 1
    add  $t1, $zero, $zero
    sw   $t1, 0($sp)            # contador = 0
L1:
    lw   $t1, 0($sp)
    lw   $a3, 8($sp)
    beq  $t1, $a3, FIM_POT
    lw   $a1, 4($sp)            # resultado
    lw   $a0, 12($sp)           # base
    jal  MULT
    sw   $v0, 4($sp)
    addi $t1, $t1, 1
    sw   $t1, 0($sp)            
    j    L1
FIM_POT:
    lw   $v1, 4($sp)
    lw   $ra, 16($sp)
    addi $sp, $sp, 20           
    jr   $ra
