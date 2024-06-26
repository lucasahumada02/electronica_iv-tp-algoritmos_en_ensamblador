/* En este archivo escribirás tu solución.
 * Para ello deberás completar las rutinas en código
 * ensamblador.
 * Puedes usar los registros R0 a R12 pues ya está preservado
 * el valor de los registros que deben mantenerse.
 * Los registros R0 a R3 contienen los argumentos al entrar a
 * la rutina y contendrán el valor devuelto al salir.
 * Si realizas un llamado a subrutina, los registros R0 a R3 y el
 * registro R12 pueden cambiar su valor (y en particular, R0 contiene 
 * normalmente el valor devuelto), los registros R4 a R11 preservan
 * su valor.
 */
.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.macro defun nombre
    .section .text.\nombre
    .global \nombre
    .type \nombre, %function
\nombre:
.endm

.macro endfun nombre
    .size \nombre, . - \nombre
.endm


/**
 * Sumar dos enteros de 32 bit
 *  suma(2,3) => 5
 * Entrada
 *  a->R0, b->R1 : sumandos, enteros de 32 bit con signo 
 * Salida
 *  R0     : suma, entero de 32 bit con signo
 */
defun suma
    push {r4-r11,lr}
    
    add R0,R1
    
    pop {r4-r11,pc}
endfun suma

/**
 * Sumar los números de un arreglo en memoria de enteros de
 * 32 bit con resultado de 64 bit.
 *
 * sumatoria(5,(uint32_t[]){1,2,3,4,5}) => 15
 *
 * Entrada 
 *  n->R0    : Cantidad de números en registro R0, entero de 32 bit
 *  b->R1    : Dirección en memoria del primer número, puntero a
 *             entero de 32 bit con signo.
 * Salida
 *  R1:R0 : Sumatoria, entero de 64 bit con signo 
 */
defun sumatoria
    push {r4-r11,lr}
    
    mov R3, R0
    mov R4,R1
    mov R0, #0
    mov R1, #0
    mov R2, #0

    lazo_suma:
        cmp R2, R3
        bge f
        ldr R5, [R4,R2,lsl #2]
        cmp R5, #0
        blt negativo
        adds R0,R0,R5
        adc R1,#0
        bal fin

    negativo: 
        adds R0, R0, R5
        adc R1,#-1
    fin:
        add R2, R2, #1
        b lazo_suma

    f:
        pop {r4-r11,pc}
endfun sumatoria

/**
 * Encuentra la posicion del máximo elemento de un arreglo
 *
 * posicion_maximo(4,(uint32_t[]){1,4,2,3}) => 1
 *
 * Entrada:
 *  n->R0 : cantidad de números en el arreglo, entero de 32 bit
 *  b->R1 : posición en memoria del primer número, puntero
 *          a entero de 32 bit con signo.
 * Salida:
 *  R0 : posición del máximo elemento en el arreglo, entero
 *       de 32 bit.
 */
defun posicion_maximo
    push {r4-r11,lr}
    
    mov R3, R0
    mov R4, R1
    mov R0, #0
    cmp R3, #1
    ble exit
    ldr R1, [R4, R0,lsl#2]
    mov R2, #1

bucle:
    cmp R2,R3
    bge exit
    ldr R5, [R4, R2,lsl#2]
    cmp R1,R5
    bge fin_posicion_max
    mov R1,R5
    mov R0,R2
    fin_posicion_max:
    add R2,R2,#1
    b bucle

    exit:
        pop {r4-r11,pc}
endfun posicion_maximo

/**
 * Ordenar de menor a mayor un arreglo de números en memoria.
 * La ordenación es en el lugar, sobreescribiendo el arreglo
 * original.
 *
 * uint32_t vals[]={4,1,3,5,2,6,7};
 * ordenar_en_sitio_menor_a_mayor(7,vals)
 * luego vals contendrá {1,2,3,4,5,6,7}
 *
 * Entrada:
 *  n->R0 : Cantidad de números en el arreglo, entero de 32 bit
 *  b->R1 : Dirección del primer número, puntero a entero de
 *          32 bit con signo.
 * Salida:
 *  Sin valor de salida. El arreglo dado debe haber sido ordenado
 *  sobreescribiendo los valores originales.
 */
defun ordenar_en_sitio_menor_a_mayor
    push {r4-r11,lr}
   
   mov R4, R0
   mov R5, R1
   sub R6, R4, #1

lazo_ordena:
    cmp R6, #0
    ble fin_orden
    add R0,R6,#1
    mov R1,R5
    bl posicion_maximo
    ldr R7, [R5,R6,lsl #2]
    ldr R8, [R5,R0,lsl #2]
    str R7,[R5, R0, lsl #2]
    str R8 ,[R5, R6, lsl #2]
    sub R6,#1
    b lazo_ordena
fin_orden:
    pop {r4-r11,pc}
endfun ordenar_en_sitio_menor_a_mayor
