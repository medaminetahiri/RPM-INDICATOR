;********************************************************************************
;																				*	
;																				*
;			PROJET AFFICHAGE MULTIPLIXE de NOMBRE DE TOURS PAR MINUTE           *
;									D'UNE HELICE                        	 	*
;																				*
;																				*
;********************************************************************************
;																				*	
;								TAHIRI MOHAMED AMINE							*
;																				*
;																				*
;********************************************************************************
	
	
	LIST      p=16F84            ; Definition de processeur
	#include <p16F84.inc>        ; Definitions de variables

	__CONFIG   _CP_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC
	OPTIONVAL	 EQU H'05'    ;    11000101
	INTERMASK    EQU H'B0'
	INTERBASE 	 EQU H'3D'
	OVERFLOW  	 EQU H'09'
	OVERFLOWFFF  EQU H'0A'

	CBLOCK 0x0C   					; debut de la zone variables
	
	w_temp 		: 1				
	status_temp : 1	
	compt		: 1
	uni 		: 1
	diz 		: 1
	cen			: 1	
	mill    	: 1
	for			: 1
	unite 		: 1
	dizie		: 1
	cente		: 1
	tempoc		: 1
	ENDC					; Fin de la zone    

;**********************************************************************
;                      DEMARRAGE SUR RESET                            *
;**********************************************************************

	org 	0x000 			; Adresse de depart apres reset
  	goto    init			; Adresse 0: initialiser

;**********************************************************************
;                      REGIME DINTERUPTION                            *
;**********************************************************************

	org		0x004
	movwf 	w_temp
	swapf	STATUS,w
	movwf	status_temp

	call 	inter
	
	swapf 	status_temp,w
	movwf 	STATUS
	swapf 	w_temp,f
	swapf 	w_temp,w
	retfie

inter
	btfss	INTCON,2
	goto 	interRB0
	goto	intertmr0
	
intertmr0
	bcf		INTCON,2
	INCF 	compt,f
	movf 	compt,w
	sublw 	INTERBASE
	btfss 	STATUS,2
	return
	clrf	compt
	clrf	mill
	movf	uni,w
 	movwf 	unite
	movf	diz,w
	movwf 	dizie
	movf 	cen,w
	movwf 	cente
	
	movlw	.5
	movwf	for
boucle
	movf	unite,w
	addwf	uni,f
	movf	uni,w
	sublw	.9
	btfss	STATUS,0
	call	carrydizi
	movf	dizie,w
	addwf	diz,f
	movf	diz,w
	sublw	.9
	btfss	STATUS,0
	call	carrycent
	movf	cente,w
	addwf	cen,f
	movf	cen,w

	movlw 	.1
	movwf	TMR0
	decfsz	for,f
	goto	boucle

 	clrf 	unite
	movf	uni,w
	movwf 	dizie
	movf 	diz,w
	movwf 	cente
	movf 	cen,w
	movwf 	mill
	clrf	uni
	clrf	diz
	clrf	cen
		
	movf 	mill,w
	sublw 	OVERFLOW
	btfsc 	STATUS,C
	return
	movlw	OVERFLOWFFF
	movwf	unite
	movlw	OVERFLOWFFF
	movwf	dizie
	movlw	OVERFLOWFFF
	movwf	cente
	movlw	OVERFLOWFFF
	movwf	mill
	return
	
interRB0
	call	tempo
	bcf		INTCON,1
	incf	uni,f
	movf 	uni,w
	sublw 	OVERFLOW
	btfsc 	STATUS,C
	return
	clrf	uni
	incf	diz
	movf 	diz,w
	sublw 	OVERFLOW
	btfsc 	STATUS,C
	return
	clrf	diz
	incf	cen
	return
	
	

;*********************************************************************
;                       Diminuer la consommation                     *
;*********************************************************************	

init
	clrf	EEADR				; permet de diminuer la consommation
	bsf		STATUS,RP0			; sélectionner banque 1
	movlw	OPTIONVAL			; charger masque
	movwf	OPTION_REG			; initialiser registre option
	movlw	0x0c				; initialisation pointeur
	movwf	FSR					; pointeur d'adressage indirec

;*********************************************************************
;                         EFFACEER LA RAM                            *
;*********************************************************************

init1
	clrf	INDF				; effacer ram
	incf	FSR,f				; pointer sur suivant
	btfss	FSR,6				; tester si fin zone atteinte (>=40)
	goto	init1				; non, boucler
	btfss	FSR,4				; tester si fin zone atteinte (>=50)
	goto	init1				; non, boucler
								; sauter au programme principal
	movlw 	INTERMASK
	movwf	INTCON
	bsf		STATUS,5
	clrf	TRISB
	bsf		TRISB,0
	clrf	TRISA	
	bcf 	STATUS,5
	movlw	0xFF
	movwf 	PORTA
	goto	START

carrydizi	
	movlw	.10
	subwf	uni,f	
	incf	diz,f
	return
carrycent
	movlw	.10
	subwf	diz,f	
	incf	cen,f
	return

tempo
	movlw	.150
	movwf	tempoc
temp
	decfsz	tempoc
	goto	temp
	return



;*********************************************************************
;            LA ZONE DE CODAGE-CONVERTIR DE DECIMAL A 7SEG           *
;*********************************************************************
CONVERT_7SEG	

    addwf 	PCL,f
    retlw	B'11111100' 	;return "0" en 7segment C.C
	retlw	B'01100000'		;return "1" en 7segment
	retlw	B'11011010'		;return "2" en 7segment
	retlw	B'11110010'		;return "3" en 7segment
	retlw	B'01100110'		;return "4" en 7segment
	retlw	B'10110110'		;return "5" en 7segment
	retlw	B'10111110'		;return "6" en 7segment
	retlw	B'11100000'		;return "7" en 7segment
	retlw	B'11111110'		;return "8" en 7segment
	retlw	B'11110110'		;return "9" en 7segment
	retlw	B'10001110'		;return "F"	en 7segment
	retlw	B'10011100'		;return "C" en 7segment
	retlw	B'11101110'		;return "A" en 7segment
	retlw	B'00011100'		;return "L" en 7segment
	
	
	;retlw	B'01111110' 	;return "0" en 7segment C.C
	;retlw	B'00001100'		;return "1" en 7segment
;	retlw	B'10110110'		;return "2" en 7segment
;	retlw	B'10011110'		;return "3" en 7segment
;	retlw	B'11001100'		;return "4" en 7segment
;	retlw	B'11011010'		;return "5" en 7segment
;	retlw	B'11111010'		;return "6" en 7segment
;	retlw	B'00001110'		;return "7" en 7segment
;	retlw	B'11111110'		;return "8" en 7segment
;;	retlw	B'11011110'		;return "9" en 7segment
;	retlw	B'11100010'		;return "F"	en 7segment
;	retlw	B'01110010'		;return "C" en 7segment
;	retlw	B'11101110'		;return "A" en 7segment
;	retlw	B'01110000'		;return "L" en 7segment
	return
;*********************************************************************
;                         PROGRAMME PRINCIPALE                       *
;*********************************************************************


START	
	movlw 	.11
 	movwf 	unite
	movlw 	.13
	movwf 	dizie
	movlw 	.12
	movwf 	cente
	movlw 	.11
	movwf 	mill
slee	
	;leep
START2	
	movf 	unite,w
	call	CONVERT_7SEG
	movwf	PORTB
	BCF		PORTA,0
	BSF		PORTA,0	
	movf 	dizie,w
	call	CONVERT_7SEG
	movwf	PORTB
	BCF		PORTA,1
	BSF		PORTA,1	
	movf 	cente,w
	call	CONVERT_7SEG
	movwf	PORTB
	BCF		PORTA,2
	BSF		PORTA,2
	movf 	mill,w
	call	CONVERT_7SEG
	movwf	PORTB
	BCF		PORTA,3
	BSF		PORTA,3
	
	;ovf	compt,w
	;ublw	INTERBASE
	;tfss	STATUS,2
	;ggyuyuuyT2
	;mf	unit,f
	;btfss	STATUS,2
	goto	START2
	;goto	slee
	END
