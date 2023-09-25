;*******************************************************************
;* This stationery serves as the framework for a user application. *
;* For a more comprehensive program that demonstrates the more     *
;* advanced functionality of this processor, please see the        *
;* demonstration applications, located in the examples             *
;* subdirectory of the "Freescale CodeWarrior for HC08" program    *
;* directory.                                                      *
;*******************************************************************

; Include derivative-specific definitions
            INCLUDE 'derivative.inc'
            
;
; export symbols
;
            XDEF _Startup
            ABSENTRY _Startup

;
; variable/data section
;
            ORG    RAMStart         ; Insert your data definition here
ExampleVar: DS.B   1

;
; code section
;
            ORG    ROMStart
            

_Startup:	LDA #$12
			STA SOPT1
			CLR $60 ; Se limpia la seccion de comparar
			LDHX   #RAMEnd+1        ; initialize the stack pointer
            TXS
			BSR MCUInit 
			CLI ; Modulo para habilitar interrupciones

mainLoop:
			LDA #$00 ; punto de inicializacion
			
Secuencia1:	CMP $60 ; Comparamos la memoria con nuestro numero indicado para saber si se quedara aqui o en otro lado
			BNE Secuencia2 ; Checa si esta en 1 o 0 el estado comparado, si no
			LDA #$14 ;cargar primera secuencia de leds
			STA PTBD ; guardar en la seccion declarada.
			CLRA ; Limpieza para arreglar errores
			BSR Retardo_RTI ;Meterle delay para ver el proceso de los leds bien
			CMP $60 ;volver a checar a ver si se presiono el boton de cambio de secuencia
			BNE Secuencia2 ; si asi fuera, cambia a la siguiente secuencia
			LDA #$48 ; se carga la segunda orden de leds de la misma secuencia
			STA PTBD ; se guarda en la seccion declarada
			CLRA ; limpieza por si hay errores
			BSR Retardo_RTI ; retardo para visualizar los leds
			BRA Secuencia1 ; LOOP
			
Secuencia2:	CMP $60 ;se compara en la memoria para saber el estado de la secuencia
			BEQ Secuencia1 ; si hay alguna discrepancia se salta de nuevo a la 1
			LDA #$FF ;cargar primera secuencia de leds
			STA PTBD ; se guarda en la seccion declarada
			LDA $60 ;cargamos la seccion de la comparacion
			BSR Retardo_RTI ; retardo para visualizar los leds
			CMP $60 ; se checa de nuevo con el comparador
			BEQ Secuencia1 ;salta hacia la secuencia 1 si es que son diferentes valores
			LDA #$22 ;cargar primera secuencia de leds
			STA PTBD ; se guarda en la seccion declarada
			LDA $60 ;cargamos la seccion de la comparacion
			BSR Retardo_RTI ; retardo para visualizar los leds
			BEQ Secuencia2 ; LOOP	

;**************************************************************
;* 				RETARDO - Subrutina de retardo                *
;*               Utilizando 1 seg.                            *
;**************************************************************


Retardo_RTI:	LDA #$07
				STA SRTISC
ESPERA:			LDA #$87
				CMP SRTISC
				BNE ESPERA
				LDA #$40
				STA SRTISC
				CLRA
				RTS

;**************************************************************
;* 				MCUInit - Subrutina  		                  *
;*               Utilizando 1 seg.                            *
;**************************************************************

MCUInit:    LDA #$FF
            STA PTBDD  ;Hacer salidas PTBD   
            LDA #$00
            STA PTBD   ;PTBD =$00
            LDA #$52
            STA IRQSC  ;IRQ Enable,
            RTS 
            
;**************************************************************
;* 				Detector - Subrutina		                  *
;*           						                          *
;**************************************************************
DETECTOR:		BSET 2, IRQSC ; apagar IRQF
				CLRA
				CMP $60 ;Guardar el comparador en el lugar deseado			
				BNE Decr ;Si no esta pulsado, sigue
				INC $60 ; incrementa el valor para que se salte esta rutina
				LDA $60
				BRA ET2
Decr:			DEC $60 ; bajar el
ET2:			RTI
			
;**************************************************************
;* spurious - Spurious Interrupt Service Routine.             *
;*             (unwanted interrupt)                           *
;**************************************************************

spurious:				; placed here so that security value
			NOP			; does not change all the time.
			RTI

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************

            ORG	$FFFA

			DC.W  DETECTOR			;
			DC.W  spurious			; SWI
			DC.W  _Startup			; Reset
