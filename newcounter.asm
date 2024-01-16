LIST	P=18F4520
#include <P18F4520.INC>
	CONFIG	OSC = XT
	CONFIG	WDT = OFF
	CONFIG	LVP = OFF
	cblock 0x10
	input, DELAY_L, DELAY_H, in_1, in_2, in_3, in_4,Eint,Wint,cs6,cm6,stopf
	endc
	ORG 0x00
	goto  Main
	ORG 0x0008
	goto  Checkint
	
ORG 0x50
Main:   movlw	0x0F
		movwf	ADCON1
		clrf	TRISD
		clrf	PORTD
		clrf	TRISC
		clrf	PORTC
		setf	TRISB
		clrf	in_1
		clrf	in_2
		clrf	in_3
		clrf	in_4
		movlw	d'6'
		movwf	cs6
		movwf	cm6

intcon:
		movlw	b'00000100'
		movwf	T0CON
		movlw	b'01100000'
		movwf	INTCON2
		movlw	b'00001000'
		movwf	INTCON3
		movlw	b'10110000'
		movwf	INTCON
		goto	Restart
Again:		
		movlw	0x85	;movlw	0xAA
		movwf	TMR0H
		movlw	0xEE
		movwf	TMR0L
		bsf		T0CON,TMR0ON
Display: 
		movff	in_1, input
		goto 	bcd_7seg_1
D_1		movwf	PORTC
		clrf	PORTD

		movff	in_2, input
		goto	bcd_7seg_2
D_2		addlw	b'10000000'
     	movwf	PORTC
		incf	PORTD

		movff	in_3, input
     	goto	bcd_7seg_3
D_3    	movwf	PORTC
		incf	PORTD

		movff	in_4, input
		goto	bcd_7seg_4
D_4     movwf	PORTC
		incf	PORTD
		GOTO 	Display

Checkint:
		POP
		btfss	INTCON,INT0IF
		goto	inc4
		btfss 	T0CON,TMR0ON
		goto 	Resume
		btfsc	INTCON3,INT1IF
		goto	Restart
		goto  	Stop

Stop:	
		bcf	 	T0CON,TMR0ON
		bcf		INTCON,INT0IF
		bsf	 	INTCON,GIE
		goto	Display
		
Resume:
		bcf	 	INTCON,INT0IF
		bsf		INTCON,GIE
		goto	Again

Restart:
		bcf	 	T0CON,TMR0ON
		clrf	in_1
		clrf	in_2
		clrf	in_3
		clrf	in_4
		bcf		INTCON3,INT1IF
		bsf		INTCON,GIE
		goto	Display
		
ORG 0x300
inc4:	bcf	  	T0CON,TMR0ON
		incf	in_4,w
		DAW
		andlw	b'00001111'
		movwf	in_4
		BZ		inc3
		bcf		INTCON,TMR0IF
		bsf		INTCON,GIE
		goto 	Again

inc3:	incf	in_3
		decf	cs6
		bz		inc2
		bcf		INTCON,TMR0IF
		bsf		INTCON,GIE
		goto 	Again

inc2:	movlw	d'6'
		movwf	cs6
		clrf	in_3
		incf	in_2,w
		DAW
		ANDLW	b'00001111'
		movwf	in_2
		BZ		inc1
		bcf		INTCON,TMR0IF
		bsf		INTCON,GIE
		goto 	Again

inc1:	incf	in_1
		decf	cm6
		btfsc	STATUS,Z
		goto	Main
		bcf		INTCON,TMR0IF
		bsf		INTCON,GIE
		goto 	Again
		

bcd_7seg_1:	
		MOVLW   low bcd_table
		MOVWF	TBLPTRL
		MOVLW   high bcd_table
		MOVWF	TBLPTRH
		MOVLW   upper bcd_table
		MOVWF	TBLPTRU
		MOVF	input, W
		ADDWF   TBLPTRL, F
	    MOVLW   0
	    ADDWFC  TBLPTRH
	    ADDWFC  TBLPTRU
	    TBLRD*
	    MOVF    TABLAT, W
	   	goto	D_1
bcd_7seg_2:	
		MOVLW   low bcd_table
		MOVWF	TBLPTRL
		MOVLW   high bcd_table
		MOVWF	TBLPTRH
		MOVLW   upper bcd_table
		MOVWF	TBLPTRU
		MOVF	input, W
		ADDWF   TBLPTRL, F
	    MOVLW   0
	    ADDWFC  TBLPTRH
	    ADDWFC  TBLPTRU
	    TBLRD*
	    MOVF    TABLAT, W
	   	goto	D_2
bcd_7seg_3:	
		MOVLW   low bcd_table
		MOVWF	TBLPTRL
		MOVLW   high bcd_table
		MOVWF	TBLPTRH
		MOVLW   upper bcd_table
		MOVWF	TBLPTRU
		MOVF	input, W
		ADDWF   TBLPTRL, F
	    MOVLW   0 
	    ADDWFC  TBLPTRH
	    ADDWFC  TBLPTRU
	    TBLRD*
	    MOVF    TABLAT, W
	   	goto	D_3
bcd_7seg_4:	
		MOVLW   low bcd_table
		MOVWF	TBLPTRL
		MOVLW   high bcd_table
		MOVWF	TBLPTRH
		MOVLW   upper bcd_table
		MOVWF	TBLPTRU
		MOVF	input, W
		ADDWF   TBLPTRL, F
	    MOVLW   0
	    ADDWFC  TBLPTRH
	    ADDWFC  TBLPTRU
	    TBLRD*
	    MOVF    TABLAT, W
	   	goto	D_4
bcd_table	ORG 0x500
db 0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F
End