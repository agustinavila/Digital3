;************************************************************************************
; en memoria se encuentran almacenados tres datos:
; dato 1: binario MyS 13b total
; dato 2: BCD 12b + 1b Signo SRC10
; dato 3: SRC2 12b
;
; Se debe encontrar el mayor y verificar si se puede representar en SRC2 8b
; se deben llevar 3 ejemplos que verifiquen  desbordes, con num positivos y negativos.
;************************************************************************************

.data 0200h
dB 12h,37h,01h,28h,05h,12h
;  N1H,N1L,N2H,N2L,N3H,N3L

;numero 1: xxxS MMMM MMMM MMMM 	<- parte alta y despues parte baja
;numero 2: xxxS CCCC DDDD UUUU	<- parte alta y despues parte baja
;numero 3: xxxx MMMM MMMM MMMM	<- parte alta y etc.
;0200 0201 <- N1
;0202 0203 <- N2
;0204 0205 <- N3

.org 0100h

		LXI H,0200h;Carga el puntero apuntando al primer dato
		MOV A,M;	Carga la parte alta del dato 1 AL ACUMULADOR
;convertir numero 1 a src2
		ANI 10H; 	enmascara el bit de signo
		MOV B,M; 	y guarda la parte alta en el registro b
		INX H;		apunta a la parte baja del dato
		MOV C, M;
		JZ pos1; 	si el numero es positivo evita esta parte
; en este momento tenemos en BC el dato entero
		MOV A,B;	TRAE LA PARTE ALTA CON EL BIT DE SIGNO
		ANI 0FH;	ENMASCARA EL BIT DE SIGNO
		MOV B,A;	LO GUARDA EN B
		ORI FFH; 	CARGA EL ACUMULADOR CON FF
		SUB C; 		a ff le resta la parte baja
		INR A; 		le suma 1 para que sea complemento a la base
		MOV C,A; 	guarda la parte baja del complemento
		ORI FFH; 	vuelvo a ponerlo en ff
		SBB B; 		LE RESTA A LA PARTE BAJA FF con carry
		MOV B, A; 	Guarda el dato en B
pos1:	MVI L, 10h; Carga el puntero con la direccion 0210h
		MOV M, B; 	guarda la parte alta del n1 en 0210h
		INR L;
		MOV M, C; 	guarda la parte baja en 0211h
;queda guardado el dato 1 convertido en 0210 y 0211 como src2 16bits


;a partir de aca empieza a convertir el segundo dato:		
		MVI L, 02H; carga el puntero con 0202, donde esta la parte alta del segundo dato
		MOV A, M; 	trae la parte alta
		ANI 10H;		enmascara el bit de signo
		MOV B,M;	trae la parte alta al reg b
		INX H;		incrementa el puntero
		MOV C,M;	trae la parte baja al reg c
		JZ CONV2;	si es cero no lo complementa
		MVI A,99H;	carga el acumulador con 99 para complementar
		SUB B;		le resta b (obtiene el complemento)
		ANI 0FH;
		MOV B, A;	guarda el resultado en b
		MVI A,99H;	repite lo mismo para c
		SUB C;
		ADI 01H;	a la parte baja le suma 1
		DAA;
		MOV C,A;	guarda la parte baja en c	
		MOV A,B;	trae la parte alta al acumulador
		ACI 00H;	le suma si hay algun carry de la parte baja
		DAA;
		MOV B,A;	lo guarda de vuelta en b
CONV2:	MVI L,21H;	PONE EL PUNTERO EN LA PARTE BAJA DEL DATO CONVERTIDO
		MOV A,B;
		MOV M,C;	GUARDA LA PARTE BAJA AHI
		ANI 0FH;
		RAL;
		RAL;
		MOV D,A; 	X4 GUARDADO EN D
		RAL;
		RAL;
		RAL;		X32(PARTE BAJA) CON UN BIT EN EL CARRY
		MOV E,A;	GUARDO EL BIT BAJO EN E
		MVI A,00H;	PONGO EL ACUMULADOR EN 0
		RAL;		LE METE EL BIT QUE ESTABA EN EL CARRY
		MOV C,A;	GUARDA ESTA PARTE ALTA EN C
		MOV A,E;	TRAE DE VUELTA LA PARTE BAJA
		RAL;		
		ADD D;
		ADD E;		SUMO TODAS LAS PARTES BAJAS
		MOV E,A;	GUARDO LA PARTE BAJA EN E
		MOV A,C;	TRAIGO LA PARTE ALTA
		ACI 00H;	LE SUMO SI HUBO CARRY
		MOV D,A;	LO GUARDO EN D
		MOV A,B;	TRAIGO EL DATO ORIGINAL
		ANI 0FH;
		RAR;		LO ROTO DOS VECES PARA OBTENER
		RAR;		LA PARTE ALTA DEL X64
;Aca daria el resultado
		ANI 0FH;		ENMASCARO LOS 4 BITS BAJOS PARA EVITAR QUE SE METAN DATOS AL ROTAR
		ADD D;		LE SUMO LA PARTE ALTA
		MOV D,A;	LO GUARDO EN D
;EN ESTE MOMENTO ESTARIA EL DATO DE LAS CENTENAS EN EL REG PAR DE
;DEBERIA GUARDARLAS EN MEMORIA???
		MOV A,M;	TRAE LA PARTE BAJA AL ACUMULADOR
		ANI F0H;	ENMASCARA LAS DECENAS
		RAR;		TENGO LAS DECENAS X8
		MOV C,A;	GUARDO ESO EN C
		RAR;		DECENAS X4
		RAR;		DECENAS X2
		ADD C;		LE SUMO LAS DECENAS X8
		MOV C,A;	GUARDO EL DATO EN C
		MOV A,M;	TRAIGO DE VUELTA LA PARTE BAJA
		ANI 0FH;	ENMASCARLO LAS UNIDADES
		ADD C;		SUMO UNIDADES Y DECENAS
		ADD E;		SUMO PARTE BAJA DE CENTENAS
		MOV C,A;	GUARDO ESO EN C
		MOV A,D;	TRAIGO LA PARTE ALTA
		ACI 00H;	LE SUMO SI HAY CARRY;
		MOV B,A;	GUARDO LA PARTE ALTA EN B
;EN ESTE MOMENTO TENGO EL BCD (UNSIGNED) CONVERTIDO A BINARIO UNSIGNED BIEN CONVERTIDO
;A CONTINUACION TENGO QUE VER EL BIT DE SIGNO PARA VER SI COMPLEMENTO O NO
		MVI L, 02H;		VUELVO EL PUNTERO A LA PARTE ALTA
		MOV A,M;	TRAIGO EL DATO
		ANI 10H;		ENMASCARO EL BIT DE SIGNO
		JZ POS2;	SI ES POSITIVO EVITA LA CONVERSION
		ORI FFH; 	CARGA EL ACUMULADOR CON FF
		SUB C; 		a ff le resta la parte baja
		INR A; 		le suma 1 para que sea complemento a la base
		MOV C,A; 	guarda la parte baja del complemento
		ORI FFH; 	vuelvo a ponerlo en ff
		SBB B; 		LE RESTA A LA PARTE BAJA FF con carry
		MOV B, A; 	Guarda el dato en B
POS2:	MVI L, 20h; Carga el puntero con la direccion 0220h
		MOV M, B; 	guarda la parte alta del n1 en 0220h
		INR L;
		MOV M, C; 	guarda la parte baja en 0221h
;EN ESTE MOMENTO TENEMOS GUARDADO EN MEMORIA:
;DATO 1 CONVERTIDO A SRC2 EN 0210 Y 0211
;DATO 2 CONVERTIDO A SRC2 EN 0220 Y 0221

;EL TERCER DATO SE EXPANDE PARA QUE SEA DE 16 BITS
		MVI L, 04H;	SE CARGA EL PUNTERO A LA PARTE ALTA DEL DATO
		MOV A, M;	SE TRAE EL DATO AL ACUMULADOR
		ANI 08H;	ESTE DATO ES DE 12BITS, ASI QUE SE VE EL B3
		JZ CEROS;
		MOV A, M;
		ORI F0H;	PONE LOS 4BITS EXTRA EN 1
		JMP LISTO;
CEROS:	MOV A,M;
		ANI 0FH;	SE PONEN LOS 4 BITS EN 0
LISTO:	INR L;
		MOV C,M;
		MVI L,30H;	SE PONE EL PUNTERO EN 0230H
		MOV M,A;	GUARDA LA PARTE ALTA EN 0230
		INR L;
		MOV M,C;	SE GUARDA LA PARTE BAJA EN 0231

;EN ESTE PUNTO ESTAN TODOS LOS DATOS EN 16BIT SRC2
;DATO 1 CONVERTIDO A SRC2 EN 0210 Y 0211
;DATO 2 CONVERTIDO A SRC2 EN 0220 Y 0221
;DATO 3 EXPANDIDO EN 16BIT   0230 Y 0231

;PARA ANALIZAR CUAL ES EL MAYOR, PRIMERO SE COMPARARAN LAS PARTES ALTAS
;SE COMPARA EL DATO 1 CONTRA LOS DEMAS, YA QUE ES EL QUE MAS AMPLITUD TIENE
;(ESTO NO IMPLICA QUE VAYA A SER MAS GRANDE, PERO PUEDE REPRESENTAR EL MAYOR NUMERO)

;




;A PARTIR DE ACA COMIENZA A COMPARAR VALORES


;Luego, analizar los bytes altos (compararlos). Posibles situaciones:
;1 > 2 -> comparar 1 y 3, el mayor es mayor
;1 = 2 -> comparar con 3, si tambien es igual analizar partes bajas
;1 < 2 -> comparar 2 y 3, el mayor es mayor.
;
;teniendo el mayor, comprobar si se puede representar en 8bits
;para eso, habria que chequear el byte alto? A ver si es ff o 00?
HLT;