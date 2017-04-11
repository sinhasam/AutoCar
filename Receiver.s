.section .text

.global _start
_start:
	.equ ADDR_JP1, 0xFF200060
	.equ JP1_IRQ, 0x00000800
	.equ TIMER, 0xff202000
	.equ TIMER_IRQ, 0x00000001
	.equ REDLEDS, 0xff200000
	.equ HBPERIOD, 45000000 # seconds
	.equ INTER_ALL,0x00000000
timerInit:	
	movia r22,TIMER
	movui r9,%lo(HBPERIOD)
	stwio r9,8(r22)
	movui r9,%hi(HBPERIOD)
	stwio r9,12(r22)
	stwio r0,0(r22) #clear timeout
	movi r9,0x07 #cont, start

	stwio r9,4(r22) #go!

JP1_Init:
	movia r23,ADDR_JP1
	stwio r0,4(r23)
	#call draw_screen
	stwio r0, 4(r23)
	
	movia  r3,0xffffffff #CONNECTED TO INTERRUPT ANY OF THE PINS 
	stwio r3,8(r23)
	
	movia r9,INTER_ALL
	wrctl ctl3, r9

	
	movia  r8, 1
    wrctl  ctl0, r8
	movi r19,0
	movia r23,ADDR_JP1
	movia r20,REDLEDS
read:
	ldwio r8,0(r23)
	andi r8,r8,0x1
	beq r8,r0,off
	movi r8,0xffffffff
	stwio r8,0(r20)
	br read
	#andi r8,r8,0x1
	#ldwio r9,0(r20)
	#or r8,r8,r9
off:
	stwio r0,0(r20)
	br read

.section .exceptions, "ax"
interuptHandler:
	wrctl ctl0,r0
	rdctl et, ctl4
	beq et,r0,skip
	movia r2, TIMER_IRQ
	and r2,r2,et
	bne r2,r0,timerInterupt
	br exitHandler
	movia r2, JP1_IRQ
	and r2,r2,et
	beq r2,r0,exitHandler
jp1Interupt:
	movia r23,ADDR_JP1
	ldwio r8,0(r23)
	andi r8,r8,0x1
	movia r2,REDLEDS
	stwio r8,0(r2)
	
	movi r8,0x4
	ldwio r9,0(r2)
	or r8,r8,r9
	stwio r8,0(r2)
	
	beq r8,r0,resetR19
	movi r19,1
	movia r9,ADDR_JP1
	stwio r0,12(r9)
	br exitHandler
resetR19:
	movi r19,0
	movia r9,ADDR_JP1
	stwio r0,12(r9)
	br exitHandler
timerInterupt:
	movia r2,REDLEDS
	ldwio r3,0(r2)
	xori r3,r3,0x8
	stwio r3,0(r2)
	stwio r0,0(r22)#reset timeout
	#call draw_car
	beq r19,r0,exitHandler
	#call draw_obstacle
	#call change_direction
	movi r19,0
exitHandler:
	movi r2,0x1
	wrctl ctl0,r2
	subi ea,ea,4
skip:	
	eret