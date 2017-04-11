.section .text
.global	main
main:
	.equ ADDR_JP2, 0xFF200070
	.equ JP2_IRQ, 0x00001000
	.equ ADDR_JP1, 0xFF200060
	.equ JP1_IRQ, 0x00000800
	.equ ADDR_JP2_EDGE, 0xFF20007C
	.equ TIMER, 0xff202000
	.equ TIMER_IRQ, 0x00000001
	.equ REDLEDS, 0xff200000
	.equ HBPERIOD,5000000 # seconds
	.equ HBPERIOD2, 45000000 # 40 seconds
	.equ ADDR_PUSHBUTTONS, 0xFF200050
	.equ IRQ_PUSHBUTTONS, 0x00000002
	.equ INTER_ALL, 0x00000083
	.equ PS2,0xFF200100
	.equ PS2_IRQ,0x00000080

timerInit:	
	movia r22,TIMER
	movui r9,%lo(HBPERIOD)
	stwio r9,8(r22)
	movui r9,%hi(HBPERIOD)
	stwio r9,12(r22)
	stwio r0,0(r22) #clear timeout
	movi r9,0x07 #cont, start
	stwio r9,4(r22) #go!

PS2Init:
	#enable the read interrupts
	movia r8, PS2
	movi r10, 0x1
	stwio r10, 4(r8)
	
pushInit: 
	movia r8,ADDR_PUSHBUTTONS
	movia r9,0xE # 0xF = 1111 enabling all keys
	stwio r9,8(r8)  # Enable interrupts on pushbuttons 1,2, and 3\
	movia r9,0xffffffff
    stwio r9,12(r8) # Clear edge capture register to prevent unexpected interrupts
	
	movia r9,INTER_ALL
	wrctl ctl3,r9
	
	movia  r8, 1
    wrctl  ctl0, r8

		

JP1_Init:
	movia r20,ADDR_JP1
	movia r8,0xffffffff #set dir
	stwio r8,4(r20)
	movia r8, 0x0000000
	#stwio r8,0(r20)
JP2init:
	movia r23,ADDR_JP2
	movia r9,0x07f557ff #set motor dir
	stwio r9,4(r23)
	movia r11,0b11111111111111111111111111111111#enable sensor 0
	stwio r11,0(r23)
	#movia r9,0b11111110101111111111101111111111#state mode. 21=0, 26-23=0101
	#movia r9, 0b10111111101111101111111111111111
	#		    33222222222211111111110000000000
	#stwio r9,0(r23)
	#movia r9, 0b10111111110111111111111111111111
	#		    33222222222211111111110000000000
	#stwio r9,0(r23)

	#movia r11,0b11111111111111111111111111111111#enable sensor 0
	#stwio r11,0(r23)
	movia r11,0b11111111101111111111001111111111
	stwio r11,0(r23)
	movia r11,0b00000111110111111111111111111111
	stwio r11,0(r23)
	
	movi r4,1
	call set_direction
	movi r4,300
	movi r5,220
	call set_current_pos
	call draw_screen
	movi r17,0x0
	movi r16,0x0

reset:
	bne r16,r0,keyboardDrive
	movia r11,0b11111111101111111111001111111111
	stwio r11,0(r23)
	movia r11,0b00000111110111111111111111111111
	stwio r11,0(r23)
	#movia r20,ADDR_JP1
	#movia r8, 0x00000000
	#stwio r8,0(r20)
	#beq r17, r0, reset
	
	#movia r19,0b11111111111111101111111111111111
	#or r11,r11,r19
	#movia r19,0b11111111111111101111111111111111
	#and r11,r11,r19#enable sensor 3
    #stwio r11,0(r23)

loop:
	movia r20,ADDR_JP1
	movia r8, 0x00000000
	stwio r8,0(r20)
	
	bne r16,r0,keyboardDrive
	beq r17, r0, motoroff
	#ldwio r5,0(r23)
	#srli r6,r5,17
	#andi r6,r6,0x00000001
	#bne r0,r6,motorfwd
	
	#srli r6,r5,27#shift to the right by 27 bits so that the 4-bit sensor valu is in lower bits
	#andi r6,r6,0x0000000f
	#movi r9,0xf
	movia r23,ADDR_JP2
	ldwio r11,0(r23)
	srli r11,r11,27
	andi r11,r11,0x1
	
	bne r11,r0,motorfwd
	br motorturnL
motorfwd:
	movia r9,0xFFFFFFF8
	ldwio r10,0(r23)
	and r9,r10,r9
	stwio r9,0(r23)
	br loop
motorrev:
	beq r19,r0,motorleft
	movia r9,0xFFFFFFF2
	ldwio r10,0(r23)
	and r10,r10,r9
	movi r9,0x00000002
	or r9,r10,r9
	stwio r9,0(r23)
	br motorrev
motorright:
	movia r9,0xFFFFFFF0
	ldwio r10,0(r23)
	and r10,r10,r9
	movi r9,0x0000000A
	or r9,r10,r9
	stwio r9,0(r23)
	br reset
motorleft:
	beq r18,r0,reset
	movia r9,0xFFFFFFF0
	ldwio r10,0(r23)
	and r9,r10,r9
	stwio r9,0(r23)
	br motorleft
motoroff:
	movia r9,0x0000000F
	ldwio r10,0(r23)
	or r9,r10,r9
	stwio r9,0(r23)
	br reset
motorturnL:
	movi r19,8
	movi r18,21

	movia r20,ADDR_JP1
	movia r8, 0x00000001
	stwio r8,0(r20)
	call draw_obstacle
	call change_direction
	br motorrev
	
keyboardDrive:
	movi r8,2
	movi r9,3
	movi r10,4
	movi r11,5
	movia r23,ADDR_JP2
	beq r16,r8,controlFWD
	beq r16,r9,controlREV
	beq r16,r10,controlLEFT
	beq r16,r11,controlRIGHT
controlOFF:
	movia r9,0xFFFFFFFF
	stwio r9,0(r23)
	movi r12,1
	beq r16,r12,keyboardDrive
	br reset

controlFWD:
	movia r9,0xFFFFFFF8
	ldwio r10,0(r23)
	and r9,r10,r9
	stwio r9,0(r23)
	br keyboardDrive
controlREV:
	movia r9,0xFFFFFFF2
	ldwio r10,0(r23)
	and r10,r10,r9
	movi r9,0x00000002
	or r9,r10,r9
	stwio r9,0(r23)
	br keyboardDrive
controlLEFT:
	movia r9,0xFFFFFFF0
	ldwio r10,0(r23)
	and r9,r10,r9
	stwio r9,0(r23)
	br keyboardDrive
controlRIGHT:
	movia r9,0xFFFFFFF0
	ldwio r10,0(r23)
	and r10,r10,r9
	movi r9,0x0000000A
	or r9,r10,r9
	stwio r9,0(r23)
	br keyboardDrive
	
.section .exceptions, "ax"

interuptHandler:
	wrctl ctl0,r0
	rdctl et, ctl4
	movia r2, TIMER_IRQ
	and r2,r2,et
	bne r2,r0,timerInterupt
	movia r2, IRQ_PUSHBUTTONS
	and r2,r2,et
	bne r2,r0,pushInterupt
	movia r2, PS2_IRQ
	and r2,r2,et
	beq r2,r0,exitHandler
	
ps2Interupt:
	movia r2,REDLEDS
	ldwio r3,0(r2)#load LEDS
	xori r3,r3,0x80
	stwio r3,0(r2)
	movia r8,PS2
	ldwio r9,0(r8)
	beq r16,r0,exitHandler
	andi r9,r9,0x00FF
	movi r10,0xF0
	beq r9,r10,stopCar
	br checkDirection
stopCar:
	movi r16,6#does this cause issues? no
	br exitHandler
checkDirection:
	movi r10,6
	beq r16,r10,turnCarOff
	movi r10,0x1D
	beq r9,r10,UP
	movi r10,0x1B
	beq r9,r10,DOWN
	movi r10,0x1C
	beq r9,r10,LEFT
	movi r10,0x23
	beq r9,r10,RIGHT
	movi r16,1
	br exitHandler
turnCarOff:
	movi r16,1#does this cause issues? no
	br exitHandler
UP:
	movi r16,2
	br exitHandler
DOWN:
	movi r16,3
	br exitHandler
LEFT:
	movi r16,4
	br exitHandler
RIGHT:
	movi r16,5
	br exitHandler
pushInterupt:
	movia r8,ADDR_PUSHBUTTONS
	ldwio r3,12(r8)
	andi r2,r3,0x8
	beq r2,r0,keyboardSet
	movi r16,0
	xori r17,r17,0x1
	movia r2,REDLEDS
	ldwio r3,0(r2)#load LEDS
	xori r3,r3,0x04
	stwio r3,0(r2)
	br exitHandler
keyboardSet:
	movia r2,REDLEDS
	ldwio r3,0(r2)#load LEDS
	xori r3,r3,0x04
	stwio r3,0(r2)
	movia r8,ADDR_PUSHBUTTONS
	ldwio r3,12(r8)
	andi r2,r3,0x4
	beq r2,r0,resetSet
	movi r2,1
	beq r16,r2,toggle
	beq r16,r0,toggle
	movi r16,0
	movi r17,0
	br exitHandler
toggle:
	xori r16,r16,0x1
	movi r17,0
	br exitHandler
resetSet:
	movia r8,ADDR_PUSHBUTTONS
	ldwio r3,12(r8)
	andi r2,r3,0x2
	beq r2,r0,exitHandler
	movi r16,0
	movi r17,0
	call draw_screen
	br exitHandler
timerInterupt:
	movia r2,REDLEDS
	ldwio r3,0(r2)#load LEDS
	xori r3,r3,0x01
	stwio r3,0(r2)
	movia r8,TIMER
	stwio r0,0(r8)#reset timeout
    subi r19,r19,1
	subi r18,r18,1
	mov r4,r17
	call draw_car
	br exitHandler
exitHandler:
	movia r2, ADDR_JP2_EDGE           # clear edge capture register from GPIO JP2 
	movia r3,0xffffffff
	stwio r3,0(r2)
	movia r2,ADDR_PUSHBUTTONS
	stwio r3,12(r2) # Clear edge capture register to prevent unexpected interrupts
	movi r2,0x1
	wrctl ctl0,r2
	subi ea,ea,4
	eret