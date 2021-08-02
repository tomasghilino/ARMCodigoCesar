.data
bienvenida: .asciz "Ingrese una cadena valida poder codificar/decodificar a continuacion: \n"
input: .asciz ""
longitudInput: .space 140
frase: .asciz "OUTPUT: \n"
mensaje: .asciz ""
longitudMensaje: .space 100
clave: .space 100
opciones: .space 100
despedida: .asciz "Se procesaron la siguiente cantidad de caracteres: "
caracteres: .space 100

error_mensaje: .asciz "Usted uso un parametro incorrecto, revise nuevamente. \n"
testeo: .space 100
enter: .ascii "\n"

pista: .asciz "MESSI"
msjpista: .asciz "El desplazamiento que se utilizo con la clave 'MESSI' fue de: 5"

.text

@---------------------------------------------------
@recibe en r0 el puntero a string1
@recibe en r1 el puntero a string2
@r4 = 1 si true, 0 si false
compararString:
        .fnstart
        ciclo10:
        ldrb r3, [r0]   @ cargo string 1 y 2
        ldrb r4, [r1]
        cmp r3, #0      @ si termino de iterar es pq todo es igual = true
        beq true

        cmp r3, r4      @ si char1 != char2 entonces es false
        bne false

        b iterar10       @ si no termino el string todavia, iterar

        iterar10:
        add r0, #1
        add r1, #1      @ siguente char
        b ciclo10
        false:
        mov r4, #0
        b salir10
        true:
        mov r4, #1
        b salir10
        salir10:
        bx lr
        .fnend

@---------------------------------------------------
@ r0, puntero a  'caracteres'
@ toma en r1, r2 ,r3 los ascii de los carac procesados
@ asigna al string 'caracteres' el numero transformado a ascii para imprimir
escribirCarac:
	.fnstart
	ldr r0, =caracteres
	ldrb r4, [r0]

	strb r3,[r0]
	add r0, #1

	ldrb r4, [r0]
	strb r2, [r0]
	add r0, #1

	strb r1, [r0]
	add r0, #1

	mov r6, #'\n'
	strb r6, [r0]

	bx lr
	.fnend
@----------------------------------------------------
convertir:
@input:
@r0=el entero a convertir, @asumo no voy a trabajar con numeros de mas de 3 digitos
@output:
@r1= el codigo ascii de las unidades
@r2= el codigo ascii de las decenas
@r3= el codigo ascii de las centenas
@-------------------------------------------------------------
	.fnstart			@guardamos la dirección de retorno
	push {lr}

	mov r1, r0
	mov r2, #100
	bl division   		@r0= A/B, r1=resto(A/B)
	mov r3, r0    		@r3 = r0/100 @en r3 tenemos las centenaS


	mov r0, r1  		@ r0 = resto(r0/100)
				@calculamos las decenas en el resto que me quedo de la anterior division
	mov r1, r0
	mov r2, #10
	bl division   		@r0= A/B, r1=resto(A/B)
	mov r2, r0
	mov r0, r1

	mov r1, r0

	add r1, #48 		@codigo ascii de las unidades
              			@r2=r2+48 =2 + 48 = 50
	add r2,#48 		@codigo ascii de las decenas
              			@r3=r3+48 =1 + 48 = 49
	add r3, #48 		@codigo ascii de las centenas

	pop {lr}
	bx lr 			@volvemos a donde nos llamaron
	.fnend


@--------------------------------------------------------------
division:
@ dividimos A/B
@ output: r0 = A/B, r1 = resto (A/B)
	.fnstart
 	mov r0, #0
	@while( A >= B )
	ciclo9:
     	cmp r1, r2
     	bcc  finCiclo  @si A<B

     	sub r1, r1, r2
     	add r0, r0, #1
        b ciclo9
	finCiclo:
       	bx lr
	.fnend

@@@----------------------------------------------------------
@ recibe en r0 el puntero a la cadena
@ devuelve en r0 la longitud de la cadena

longitud:
        .fnstart
        mov r1, r0
        mov r0, #0

	ciclo0:
        ldrb r3, [r1, r0]
        cmp r3, #0
        beq salir0

        add r0, #1
        b ciclo0

	salir0:

        bx lr
        .fnend

@---------------------------------------------------------
leerMensaje:

@Parametros inputs: no tiene
@Parametros output:
@r0=char leido
	.fnstart
    	mov r7, #3    @ Lectura x teclado
    	mov r0, #0      @ Ingreso de cadena

    	ldr r2, =longitudInput @ Leer # caracteres
    	ldr r1, =input @ donde se guarda la cadena ingresada
    	swi 0        @ SWI, Software interrup
    	ldr r0, [r1]

    	bx lr @volvemos a donde nos llamaron
	.fnend
@----------------------------------------------------------
imprimirString:
      .fnstart
	push {lr}
      @Parametros inputs:
      @r1=puntero al string que queremos imprimir
      @r2=longitud de lo que queremos imprimir
      mov r7, #4 @ Salida por pantalla
      mov r0, #1      @ Indicamos a SWI que sera una cadena
      swi 0    @ SWI, Software interrup
	pop {lr}
      bx lr @salimos de la funcion mifuncion
      .fnend

@--------------------------------------------------------------------- 
@ hace un salto de linea
newLine:
      .fnstart
      push {lr}
      mov r2, #1 @Tamaño de la cadena
      ldr r1, =enter   @Cargamos en r1 la direccion del mensaje
      bl imprimirString
      pop {lr}
      bx lr @salimos de la funcion mifuncion
      .fnend

@----------------------------------------------------------
@ recibe en r1 el puntero al buffer
@ recibe en r2 el puntero a la cadena vacia de mensaje
extraer_mensaje:
        .fnstart
        ciclo1:
        ldrb r3, [r1] @ pos del mensaje input del usuario
        ldrb r0, [r2] @ pos del string vacio
        cmp r3, #59
        beq salirse1      @ hasta aca recorro la cadena y si es ; salgo porque
                         @ termina msj
        strb r3,[r2]    @ agrego el char a la direc de memoria de mensaje

        b iterar1 @ siguiente char

        iterar1:
        add r1, #1
        add r2, #1
        b ciclo1
        salirse1:
        bx lr
        .fnend


@-------------------------------------------------------------------
@ recibe en r1 el puntero al input
@ recibe en r2 el puntero a la cadena vacia de clave
@ en r0 se cuenta las apariciones de ;
extraer_clave:
	.fnstart
	ciclo2:
	ldrb r3,[r1] @ pos del mensaje input del usuario
			 @ pos del string vacio 	@ inicializo el contador en 0

	cmp r3, #59
	beq esPuntoYComa
	bne noEsPuntoYComa


	noEsPuntoYComa:
	cmp r0, #2	@ cuando aparece por segunda vez un ; me salgo
	beq salirse2

	cmp r0, #0
	beq iterar2

	ldrb r6,[r2]

	mov r4, r3
	strb r4, [r2]
	add r2, #1	 @ si r0 = 1 entonces estoy en la clave, agrego el char
	b iterar2	 @ siguiente char

	esPuntoYComa:
	add r0, #1
	b iterar2

	iterar2:
	add r1, #1
	b ciclo2

	salirse2:
	bx lr
	.fnend
@---------------------------------------------------------------------
@ recibe en r1 la direccion de input
@ recibe en r2 la direccion de opcion
@ r0 = contador de ;
extraer_opcion:
	.fnstart
	ciclo3:
	ldrb r3, [r1]
	ldrb r5, [r2]

	cmp r3, #59
	beq esPuntoYComa2
	bne noEsPuntoYComa2

	noEsPuntoYComa2:

	cmp r3, #0
	beq salirse3

	cmp r0, #2
	blt iterar3

	mov r4, r3
	strb r4, [r2]
	b salirse3

	esPuntoYComa2:
	add r0, #1
	b iterar3

	iterar3:
	add r1,	#1
	b ciclo3

	salirse3:
	bx lr
	.fnend
@--------------------------------------------------
@ r0 recibE el puntero al mensaje
@ r6 recibe el shift
codificarlo:
        .fnstart
	push {lr}
        ciclo5:
        ldrb r1, [r0]
        cmp r1, #0
        beq salir5

        cmp r1, #32
        beq iterar5


        add r1, r6	@#95
	cmp r1, #91
	bge sePaso
			@si es mayor a Z
        mov r2, r1
        strb r2, [r0]
        b iterar5

	sePaso:
	sub r1, #26	@ cantidad fija si se pasa 
	mov r2, r1
	strb r2, [r0]
	b iterar5

	iterar5:
        add r0, #1
        b ciclo5
        salir5:
	pop {lr}
        bx lr
        .fnend
@----------------------------------------------------
decodificarlo:
@recibe en r0 puntero del mensaje
@ r6 = shift
	.fnstart
	push {lr}
        ciclo6:
        ldrb r1, [r0]
        cmp r1, #0
        beq salir6

        cmp r1, #32
        beq iterar6


        sub r1, r6
	cmp r1, #64	@ si es menor que A
	ble sePaso2

        mov r2, r1
        strb r2, [r0]
        b iterar6

	sePaso2:
	add r1, #26	@ cantidad fija si se pasa
	mov r2, r1
	strb r2, [r0]
	b iterar6

        iterar6:
        add r0, #1
        b ciclo6
        salir6:
	pop {lr}
	bx lr
	.fnend
@-------------------------------------------------------------------------------
@ r0 -- recibe el puntero del ascii
@ r6 -- devuelve el inmediato del entero
convertir_ascii_a_entero:
	.fnstart
	push {lr}
	ldrb r1, [r0]
	sub r1, #0x30
	mov r6, r1
	b salir7
	salir7:
	pop {lr}
	bx lr
	.fnend

@---------------------------------------------------

.global main
main:

	ldr r1, =bienvenida
	mov r2, #90
	bl imprimirString		 @ imprime "Ingrese una cadena valida para poder codificar/decodificar a continuacion:"
	bl newLine
	bl newLine

	bl leerMensaje	 		@ input = leerMensaje *esto lee el string del usuario*
	bl newLine
	bl newLine

	ldr r1, =frase
	mov r2, #90
	bl imprimirString		 @imprime "OUTPUT:"

	ldr r1, =input
	ldr r2, =mensaje
	bl extraer_mensaje		@ mensaje = extraer_mensaje(input)

	ldr r1, =input
	ldr r2, =clave
	mov r0, #0
	bl extraer_clave		@ clave = extraer_clave(input)


	ldr r1, =input
	ldr r2, =opciones
	mov r0, #0
	bl extraer_opcion		@ opcion = extraer_opcion(input)

	ldr r0, =clave
	bl longitud
	cmp r0, #1			@ if (longitud(clave) > 1) : decodificarConPista (en esta funcion se verifica todo igual)
	bgt decodificarConPista		@ if (longitud(clave) == 1) : decodificarConEntero
	b decodificarConEntero

	decodificarConEntero:
	ldr r0, =clave			@Aca se convierte el ascii a entero
	bl convertir_ascii_a_entero	@ y se decide si codificar o decodificar

	ldr r1, =opciones
	ldrb r1,[r1]
	cmp r1, #'C'			@ if(opcion == 'C') : codificarlo(mensaje)
        bne check2

 	ldr r0, =mensaje
	bl codificarlo
	b imprimirOutput

	check2:
	cmp r1, #'D'			@ if(opcion == 'D') : decodificarlo(mensaje)
        bne error			@ si no es 'C' o 'D' la opcion, tira msj de error

	ldr r0, =mensaje
	bl decodificarlo
	b imprimirOutput

	error:
	ldr r1, =error_mensaje
	mov r2, #99
	bl imprimirString
	b fin

	decodificarConPista:
	ldr r0, =clave
	ldr r1, =pista
	bl compararString
	cmp r4, #0			@ Si la clave no es "MESSI", tira msj error porque no es entero ni palabra clave
	beq error

	ldr r0, =mensaje
	mov r6, #5			@ La pista "MESSI" tiene un shift de 5
	bl decodificarlo

	mov r2, #100
	ldr r1, =msjpista
	bl imprimirString		@ imprimir(msjpista) una vez que se decodifique con el shift de "MESSI"
	bl newLine

	imprimirOutput:			@ imprimirOutput lo que hace es informar de los caracteres procesados
	mov r2, #100
	ldr r1, =mensaje
	bl imprimirString		@ imprime el mensaje codificado / decodificado
	bl newLine


	ldr r0, =mensaje
	bl longitud
	bl convertir
	bl escribirCarac		@ pasa los carac procesados a ascii
	bl newLine


	mov r2, #100
	ldr r1, =despedida
	bl imprimirString		@ imprime el mensaje final con los carac procesados

fin:
	mov r7, #1
	swi #0
