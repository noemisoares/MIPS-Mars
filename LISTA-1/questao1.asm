.data
msg_n:      .asciiz "Digite n (inteiro positivo): "
msg_x:      .asciiz "Digite o valor inicial x: "
msg_y:      .asciiz "Digite a razao y (positiva): "
msg_erro:   .asciiz "Valores invalidos: n e y devem ser positivos.\n"
msg_termos: .asciiz "\nTermos da P.A.: "
espaco:     .asciiz " "
msg_xfinal: .asciiz "\nValor de x que superou n: "
msg_cont:   .asciiz "\nQuantidade de termos: "
msg_soma:   .asciiz "\nSoma dos termos: "

.text
.globl main

main:
    # mapeamento: n = $a1, x = $a2, y = $a3

    # le n
    li   $v0, 4
    la   $a0, msg_n
    syscall
    li   $v0, 5
    syscall
    move $a1, $v0

    # le x
    li   $v0, 4
    la   $a0, msg_x
    syscall
    li   $v0, 5
    syscall
    move $a2, $v0

    # le y
    li   $v0, 4
    la   $a0, msg_y
    syscall
    li   $v0, 5
    syscall
    move $a3, $v0

    # validacao: n > 0 e y > 0 (evita laco infinito)
    blez $a1, ERRO
    blez $a3, ERRO

    add  $t0, $zero, $zero  # t0 = 0 (contador de termos)
    add  $s0, $zero, $zero  # s0 = 0 (soma dos termos)

    li   $v0, 4
    la   $a0, msg_termos
    syscall

L1:
    slt  $t1, $a1, $a2      # n < x ?
    bne  $t1, $zero, FIM    # se sim, sai do laco
    add  $s0, $s0, $a2      # soma += x
    addi $t0, $t0, 1        # count++

    # mostra o termo atual
    li   $v0, 1
    move $a0, $a2
    syscall
    li   $v0, 4
    la   $a0, espaco
    syscall

    add  $a2, $a2, $a3      # x = x + y
    j    L1

FIM:
    add  $v1, $zero, $a2    # v1 = x final (termo que superou n)

    # mostra o valor de x
    li   $v0, 4
    la   $a0, msg_xfinal
    syscall
    li   $v0, 1
    move $a0, $v1
    syscall

    # mostra a quantidade de termos
    li   $v0, 4
    la   $a0, msg_cont
    syscall
    li   $v0, 1
    move $a0, $t0
    syscall

    # mostra a soma dos termos
    li   $v0, 4
    la   $a0, msg_soma
    syscall
    li   $v0, 1
    move $a0, $s0
    syscall

    j    SAIR

ERRO:
    li   $v0, 4
    la   $a0, msg_erro
    syscall

SAIR:
    li   $v0, 10
    syscall