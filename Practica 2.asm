.data 0200h
dB 00h,FFh,00h,FFh,FFh,FFh,FFh,FFh,00h,FFh,00h,00h,FFh,FFh,FFh,FFh
.org 00H
	LXI H,0200H;	MVI H,02H; 		FIJA LA PARTE ALTA DE LA MEMORIA
LEE:	IN 00h;		LEE LAS DISTINTAS ENTRADAS
	CMP L;			PARA EVITAR TANTAS LECTURAS, SE FIJA QUE EL DATO
	JZ LEE;			NO HAYA CAMBIADO, SI NO SIGUE LEYENDO
	MOV L, A;		ESA LECTURA LA GUARDA EN LA PARTE BAJA DE MEMORIA
	MOV A, M;		LEE LA RESPUESTA SEGUN LA TABLA DE VERDAD
	OUT 00h;		ESCRIBE EL RESULTADO EN LA SALIDA
	JMP LEE;		VUELVE A LEER LA ENTRADA
	HLT