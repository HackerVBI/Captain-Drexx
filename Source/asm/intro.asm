		device zxspectrum128
	        org #7000

scroll		equ #7300
scrollattr	equ #8600

start:	        xor a
	        out (#fe),a
	        ld (spex+1),sp
	        ld sp,#6002
	        ld hl,#5800
	        ld d,h
	        ld e,l
	        inc e
	        ld bc,#2ff
	        ld (hl),l
	        ldir
		call introscr
		call #d000

	        ld hl,scroll
	        ld de,#4012
	        ld (hl),#f9     ; ld sp,hl
    		inc hl

    		ld c,21
d01    		ld b,8
d0		push bc
		push de
		ld b,7
d2     		ld (hl),#e1     ; pop de
		inc hl
		ld (hl),#22
		inc hl
		ld (hl),e
		inc hl
		ld (hl),d
		inc hl
		inc de
		inc de
		djnz d2
		pop de
		pop bc
		call incd
		djnz d0
	        dec c
	        jr nz,d01
	        ld (hl),#31
	        inc hl
	        ld (hl),0
	        inc hl
	        ld (hl),#60
	        inc hl
	        ld (hl),#c9



	        ld hl,scrollattr
	        ld (hl),#f9     ; ld sp,hl
    		inc hl
    		ld c,21
		
da1		
		push hl
d0atr		ld hl,#5812-#20
		ld de,#20
		add hl,de
		ld (d0atr+1),hl
		ex de,hl
		pop hl

		ld b,8
d31		push bc
		push de
		ld b,7
d3		ld (hl),#e1     ; pop de
		inc hl
		ld (hl),#22
		inc hl
		ld (hl),e
		inc hl
		ld (hl),d
		inc hl
		inc de
		inc de
		djnz d3
		ld (hl),#06
		inc hl
		ld (hl),19
		inc hl
		ld (hl),#10
		inc hl
		ld (hl),#fe
		inc hl


/*		ld (hl),#dd
		inc hl
		ld (hl),#29
		inc hl
		ld (hl),#dd
		inc hl
		ld (hl),#29
		inc hl
		ld (hl),#ed
		inc hl
		ld (hl),#69		;48
		inc hl
*/
		pop de
		pop bc
		djnz d31
	
		dec c
		jr nz,da1
	        ld (hl),#31
	        inc hl
	        ld (hl),0
	        inc hl
	        ld (hl),#60
	        inc hl
	        ld (hl),#c9

	        ld de,atrz
	        ld c,42
ad0	        ld b,8
ad2	        push bc
ad1	        ld hl,atrzd
	        ld bc,14
	        ldir
	        pop bc
	        djnz ad2
	        push de
	        ld hl,(ad1+1)
	        ld de,14
	        add hl,de
	        ld (ad1+1),hl
	        pop de
	        dec c
	        jr nz,ad0

		ei
		ld b,95
wt		push bc
		call INx2
		halt
		pop bc
		djnz wt

	        ld hl,#5800
	        ld d,h
	        ld e,l
	        inc e
	        ld bc,#2ff
	        ld (hl),l
	        ldir

	        call scr

mnu		ei 
	        halt
	        di
scrtext	        ld hl,text	; -14*24*8
	        call scroll

	        ld bc,#a0
	        dec bc
	        ld a,b
	        or c
	        jp nz,$-3



	        ld bc,#00fe
atrtext		ld hl,atrz
		call scrollattr


		ld a,2
		out (#fe),a
		ld bc,#114
		dec bc
		ld a,b
		or c
		jr nz,$-3
		xor a
		out (#fe),a
view_ch		ld a,0
		inc a
		and 1
		ld (view_ch),a
		jr z,ex




	        ld hl,(atrtext+1)
	        ld de,14
	        or a
sa1	        adc hl,de
	        ld (atrtext+1),hl
saa2		
		ld a,r
		ld l,a
		ld h,0
		ld a,(hl)
		push af
		cp #1f
		jr nc,saa3
		ld hl,#5aa0
		ld b,#40
		ld a,(hl)
		xor #40
		ld (hl),a
		inc l
		djnz $-5
saa3		pop af
		ld hl,#5af2
		and 7
		or #40
		ld b,12
		ld (hl),a
		inc l
		djnz $-2
	        ld hl,(scrtext+1)
	        ld de,14
	        or a
sa2	        adc hl,de
	        ld a,h
	        cp high (text+14*24*8)
	        jr c,scrtextcheck
	        ld a,(sa1+1)
	        xor 8
	        ld (sa1+1),a
	        ld (sa2+1),a

	        jr scrtextcheck2

scrtextcheck    cp high (text-1)
		jr nz,scrtextcheck2
	        ld a,(sa1+1)
	        xor 8
	        ld (sa1+1),a
	        ld (sa2+1),a
	        ld hl,atrz
	        ld (atrtext+1),hl

	        ld hl,text
scrtextcheck2	ld (scrtext+1),hl

ex		
		call INx2
	       	ld a,#7f
	        in a,(#fe)
	        rra
	        jp c,mnu
	        ei
	        call #d000
	        call INx2
	        call #d000
        	LD	IY,#5C3A
	        LD	HL,#2758
	        EXX	
		LD A,63
		LD I,A
		IM 1
spex		ld sp,0
	        EI
	        ret




INx2   		LD A,255
	        INC A
        	LD (INx2+1),A
	        OR 11111110B
        	LD BC,65533
	        OUT (C),A

		call #d005
	        ret

incd    INC d
        LD A,d
        AND 7
        ret NZ 
        LD A,e
        ADD A,32
        LD e,A
        ret C
        LD A,d
        SUB 8
        LD d,A
	ret

	org #8000
introscr	inchob "cptscr.$C"

	org #9d00
atrz
	org #b000
atrzd	include "spr/aa.asm"

	org #b300
text  	include "spr/ab.asm"
	
	org #d000
	inchob "DEATHWAY.$M.$c"

scr	incbin "spr/cptain.$C.bin"


	savesna "intro.sna",start