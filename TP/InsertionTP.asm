global 	main
extern 	printf
EXTERN fopen
EXTERN fread
EXTERN puts
EXTERN printf
EXTERN gets

section	.data

	modo db "rb",0
	
	filename db "numerosBinarios.dat",0
	
	mensajeDeErrorDeArchivo db "Error al abrir el archivo",0
	
	mensajeDeLecturaErroneo db "Error al leer el registro",0
	
	longitudDelArreglo dq 0
	
	mensajeDeImpresionDelArreglo db "El arreglo en la posicion: %hi tiene el elemento: %hhi",10,0

	indiceImpresion dq 1

	indiceDeSeleccion dq 0

	indiceParaLaPrimeraImpresion dq 1

	indiceFor dq 1

	indiceWhile dq 1

	mensajeDebug db "OKIK",0

	mensajeFinalDeArreglo db "El arreglo ORDENADO quedo compuesto de la siguiente manera: ",0

	mensajeDeCadaNumeroDeArreglo db "%hhi, ",0

	mensajeIntercambioDeNumeros db "El numero %hhi es menor que %hhi, intercambian posiciones",10,0

	mensajeDeSaltoDeLinea db "",0

	mesajeDeFormaDeImpresion db "Seleccione la forma en la que desea imprimir el arreglo (A/D): ",0

	mensajeDePresentacionDelArregloOriginal db "El arreglo contiene lo siguiente: ",0

	mensajeDePresentacionDeOrdenamiento db "Se aplica el algoritmo de ordenamiento por insercion, entonces se obtiene que: ",10,0

section .bss
	
	idArchivo resq 1		
	
	registro times 0 resb 30
	
	vector times 30 resb 1

	formaDeImpresion resb 1

section	.text
main:
	
	mov rdi,filename
	mov rsi,modo
	call fopen

	cmp rax,0
		je errorAlAbrirArchivo

	mov qword[idArchivo],rax ;;cargo el archivo

	mov rdi,registro
	mov rsi,30
	mov rdx,1
	mov rcx,[idArchivo]
	call fread 				;leo los 30 bytes

	cmp rax,0
		jle EOF


	mov rcx,30				;;seteo los valores para leer 30 campos
	mov rbx,0

	agregarElementos:
		push rcx

		cmp byte[registro+rbx],-128 	
		je finalizarCarga 			;si algun valor es -128 (señal de fin de arreglo) finalizo la carga al vector para ser ordenado

		mov al,byte[registro+rbx] 	;;muevo del registro al vector, para ser manipulado
		mov byte[vector+rbx],al
		inc rbx						;incremento el contador del subindice para obtener los valores del vector y la ubicacion en el vector
		add qword[longitudDelArreglo],1  ;;incremento el contador de la longitud del arreglo para saber la longitud
		pop rcx
		loop agregarElementos

finalizarCarga:

		mov rdi,mensajeDePresentacionDelArregloOriginal
		call puts
		
		mov rbx,[longitudDelArreglo]
		add qword[indiceParaLaPrimeraImpresion],rbx
		
		siguienteElemento:
 
		mov rbx,[indiceDeSeleccion]
		mov rdi,mensajeDeCadaNumeroDeArreglo
		mov rsi,[vector+rbx]
		sub rax,rax
		call printf
		add qword[indiceDeSeleccion],1
		sub qword[indiceParaLaPrimeraImpresion],1

		cmp qword[indiceParaLaPrimeraImpresion],1
			jg siguienteElemento

		mov qword[indiceDeSeleccion],0

	mov rdi,mensajeDeSaltoDeLinea
	call puts

	jmp finDeCargarElementos

	errorAlAbrirArchivo:

		mov rdi,mensajeDeErrorDeArchivo
		call puts
		jmp finDePrograma

	EOF:
		mov rdi,mensajeDeLecturaErroneo
		call puts
		jmp finDePrograma

finDeCargarElementos:
	
	mov rdi,mensajeDePresentacionDeOrdenamiento
	call puts
	
	for:

		add qword[indiceFor],1  ;;muevo indiceFor +1
		mov rdi,[indiceFor] 	;;RDI = indiceFor 
		mov [indiceWhile],rdi		;indiceWhile = RDI
		mov rdi,0
		add rdi,qword[indiceFor]

		cmp rdi,qword[longitudDelArreglo]
		jg fin 					;;comparo si ya compare todo el array (POSICION SE COMPARA CON SIZE DE ARRAY +1)

	while:

		cmp qword[indiceWhile],1
		je for

		sub rax,rax
		sub rcx,rcx

	  	mov	rcx,[indiceWhile]	;rcx = indiceWhile
		dec	rcx							;(indiceWhile-1)
		imul ebx,ecx,1				;(indiceWhile-1)*longElem

		mov	ah,[vector+(ebx-1)]
		mov al,[vector+ebx]		

		cmp al,ah  
		jg for 

		mov	rcx,[indiceWhile]	;rcx = indiceWhile
		dec	rcx							;(indiceWhile-1)
		imul ebx,ecx,1				;(indiceWhile-1)*longElem

		mov	ah,[vector+(ebx-1)]
		mov al,[vector+ebx]	
		mov	[vector+(ebx-1)],al
		mov [vector+ebx],ah 		;;; intercambio los elementos

		mov rdi,mensajeIntercambioDeNumeros
		mov rsi,[vector+(ebx-1)]
		mov rdx,[vector+ebx]
		sub rax,rax
		call printf

		sub qword[indiceWhile],1 			;;;; le resto 1 a indiceWhile
		
		jmp while

fin:
	
	mov rdi,mesajeDeFormaDeImpresion
	call puts

	mov rdi,formaDeImpresion
	call gets

	mov rdi,mensajeFinalDeArreglo
	call puts

	cmp byte[formaDeImpresion],'D'
		je formaDeImpresionDescendente

	siguienteElementoAscendente:
 
		mov rbx,[indiceDeSeleccion]
		mov rdi,mensajeDeCadaNumeroDeArreglo
		mov rsi,[vector+rbx]
		sub rax,rax
		call printf
		add qword[indiceDeSeleccion],1
		sub qword[longitudDelArreglo],1

		cmp qword[longitudDelArreglo],0
			jg siguienteElementoAscendente

		jmp finDePrograma


formaDeImpresionDescendente:
		
		
	siguienteElementoDescendente:

		mov rbx,[longitudDelArreglo]
		dec rbx
		mov rdi,mensajeDeCadaNumeroDeArreglo
		mov rsi,[vector+rbx]
		sub rax,rax
		call printf
		sub qword[longitudDelArreglo],1

		cmp qword[longitudDelArreglo],0
			jg siguienteElementoDescendente

finDePrograma:
	mov rdi,mensajeDeSaltoDeLinea
	call puts
	pop rcx

ret	