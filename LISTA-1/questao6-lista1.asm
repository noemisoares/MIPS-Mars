.data
msg_p:      .asciiz "Digite o numero de pares (1 a 10): "
msg_erro:   .asciiz "Valor invalido: use de 1 a 10 pares.\n"
msg_ini:    .asciiz "\nDigite as palavras de M1 (um inteiro por linha):\n"
abre:       .asciiz "M1["
fecha:      .asciiz "]: "
msg_cont:   .asciiz "\nPalavras contadas ($v0): "
msg_m2:     .asciiz "\nConteudo copiado para M2 (inclui o par final): "
espaco:     .asciiz " "

            .align 2
M1:         .space 88
M2:         .space 88

.text
.globl main

main:
    # le o numero de pares
    li   $v0, 4
    la   $a0, msg_p
    syscall
    li   $v0, 5
    syscall
    move $s0, $v0               # s0 = p

    blez $s0, ERRO
    slti $t1, $s0, 11
    beq  $t1, $zero, ERRO

    sll  $s1, $s0, 1            # s1 = 2p (total de palavras)

    li   $v0, 4
    la   $a0, msg_ini
    syscall

    # le as palavras de M1
    la   $s2, M1
    li   $t0, 0
LEI:
    beq  $t0, $s1, SENT
    li   $v0, 4
    la   $a0, abre
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
    j    LEI

SENT:
    # par de seguranca apos a ultima palavra: (-100, 200) satisfaz a parada
    sll  $t1, $s1, 2
    add  $t1, $s2, $t1
    li   $t2, -100
    sw   $t2, 0($t1)
    li   $t2, 200
    sw   $t2, 4($t1)

    # mapeamento: M1 = $a0, M2 = $a1
    la   $a0, M1
    la   $a1, M2
    jal  PROC6
    move $s3, $v0               # s3 = palavras contadas

    li   $v0, 4
    la   $a0, msg_cont
    syscall
    li   $v0, 1
    move $a0, $s3
    syscall

    # mostra M2: palavras contadas + o par final (nao contado)
    li   $v0, 4
    la   $a0, msg_m2
    syscall
    addi $s4, $s3, 2
    la   $s5, M2
    li   $t0, 0
MOSTRA:
    beq  $t0, $s4, SAIR
    sll  $t1, $t0, 2
    add  $t1, $s5, $t1
    lw   $a0, 0($t1)
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, espaco
    syscall
    addi $t0, $t0, 1
    j    MOSTRA

ERRO:
    li   $v0, 4
    la   $a0, msg_erro
    syscall

SAIR:
    li   $v0, 10
    syscall

PROC6:
    add  $v0, $zero, $zero
LOOP:
    lw   $t1, 0($a0)            # 1a palavra em M1
    lw   $t2, 4($a0)            # 2a palavra em M1
    sw   $t1, 0($a1)            # 1a palavra em M2
    sw   $t2, 4($a1)            # 2a palavra em M2
    addi $t3, $zero, 150
    addi $t4, $zero, -1020
    addi $t5, $zero, -5
    slt  $t0, $t4, $t1          # -1020 < 1a palavra?
    beq  $t0, $zero, TESTA2
    slt  $t0, $t1, $t5          # 1a palavra < -5?
    beq  $t0, $zero, TESTA2
    slt  $t0, $t3, $t2          # 150 < 2a palavra?
    beq  $t0, $zero, TESTA2
    j    FIM

CONTA:
    addi $v0, $v0, 2            # count de palavras
    addi $a0, $a0, 8
    addi $a1, $a1, 8
    j    LOOP

TESTA2:
    slt  $t0, $t4, $t2          # -1020 < 2a palavra?
    beq  $t0, $zero, CONTA
    slt  $t0, $t2, $t5          # 2a palavra < -5?
    beq  $t0, $zero, CONTA
    slt  $t0, $t3, $t1          # 150 < 1a palavra?
    beq  $t0, $zero, CONTA
    j    FIM

FIM:
    jr   $ra
