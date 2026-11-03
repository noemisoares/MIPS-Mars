.data
msg_n:      .asciiz "Digite n (1 a 20): "
msg_erro:   .asciiz "Valor invalido: n deve estar entre 1 e 20.\n"
msg_elem:   .asciiz "\nDigite os elementos (um por linha, inteiros nao negativos):\n"
abre:       .asciiz "V["
fecha:      .asciiz "]: "
msg_soma:   .asciiz "\nSoma dos elementos: "
msg_media:  .asciiz "\nMedia aritmetica (parte inteira): "

            .align 2
vetor:      .space 80

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

    # validacao: 1 <= n <= 20 (n = 0 causaria laco infinito na divisao)
    blez $s0, ERRO
    slti $t1, $s0, 21
    beq  $t1, $zero, ERRO

    li   $v0, 4
    la   $a0, msg_elem
    syscall

    # le os elementos do vetor
    la   $s1, vetor
    li   $t0, 0                 # indice
    li   $s2, 0                 # soma (apenas para conferencia)
LEI:
    beq  $t0, $s0, CHAMA
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
    add  $s2, $s2, $v0          # soma de conferencia
    sll  $t1, $t0, 2
    add  $t1, $s1, $t1
    sw   $v0, 0($t1)
    addi $t0, $t0, 1
    j    LEI

CHAMA:
    # mapeamento: n = $a0, vetor = $a1
    move $a0, $s0
    la   $a1, vetor
    jal  PROC4
    move $s3, $v0               # s3 = media (retorno)

    # mostra a soma
    li   $v0, 4
    la   $a0, msg_soma
    syscall
    li   $v0, 1
    move $a0, $s2
    syscall

    # mostra a media
    li   $v0, 4
    la   $a0, msg_media
    syscall
    li   $v0, 1
    move $a0, $s3
    syscall
    j    SAIR

ERRO:
    li   $v0, 4
    la   $a0, msg_erro
    syscall

SAIR:
    li   $v0, 10
    syscall

PROC4:
    add  $v0, $zero, $zero      # soma = 0
    add  $t0, $zero, $zero      # count = 0

LOOP:
    beq  $t0, $a0, MEDIA        # count == n ?
    add  $t1, $t0, $t0          # 2 x count
    add  $t1, $t1, $t1          # 4 x count
    add  $t1, $a1, $t1          # &Vetor[count]
    lw   $t2, 0($t1)            # t2 = Vetor[count]
    add  $v0, $v0, $t2          # soma dos valores do vetor
    addi $t0, $t0, 1            # count + 1
    j    LOOP

MEDIA:
    add  $t3, $zero, $zero
    add  $t3, $zero, $v0        # valor da soma
    add  $t1, $zero, $zero      # quociente = 0

LOOP2:
    slt  $t2, $t3, $a0          # valor da soma < n ?
    bne  $t2, $zero, FIM
    addi $t1, $t1, 1            # conta quantas vezes n cabe na soma
    sub  $t3, $t3, $a0          # valor da soma - n
    j    LOOP2

FIM:
    add  $v0, $zero, $t1        # v0 = media
    jr   $ra
