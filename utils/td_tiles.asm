		device zxspectrum128
	        org #7000

start
	call cr_scradr

	ld hl,map
	ld bc,16*11
	ld a,176
m1	ld (hl),a
	inc hl
	inc a
	dec bc
	jr nz,m1

	ld hl,map
	ex de,hl
	ld bc,#0b10
mv1	push bc
mv12	ld hl,#58fe
	inc l
	inc l	
	ld (mv12+1),hl
	ld (mvc0+1),hl
mv11	ld hl,#40fe
	inc l
	inc l
	ld (mv11+1),hl
	ld (mvs0+1),hl


mv2	push de
	ld a,(de)
;	inc a
;	jr z,$+4
;	ld a,1
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	push hl	
	add hl,hl
	add hl,hl
	add hl,hl
	pop de
	add hl,de	
	ld de,tiles
	add hl,de
	ex de,hl
mvs0	ld hl,#40fe

	push bc
	ld b,#10
mv3	ld a,(de)
	ld (hl),a
	inc de
	inc l
	ld a,(de)
	ld (hl),a
	inc de
	dec l
	call inch
	djnz mv3
	ld (mvs0+1),hl
mv4	pop bc

mvc0	ld hl,#5800
	ld a,(de)	; color
	inc de
	ld (hl),a
	inc l
	ld a,(de)	; color
	inc de
	ld (hl),a
	dec l
	ld a,l
	add #20
	ld l,a
	ld a,(de)	; color
	inc de
	ld (hl),a
	inc l
	ld a,(de)	; color
	inc de
	ld (hl),a
	dec l
	push de
	ld de,#20
	add hl,de
	pop de
	ld (mvc0+1),hl
	pop de
	inc de
	djnz mv2
	pop bc
	dec c
	jr nz,mv1
	ret


cr_scradr
	ld de,scr_adr
	ld hl,#0000
	ld b,#0b
crsa1	push bc
	ld a,l
	ld (de),a	
	inc de
	ld a,h
	ld (de),a
	inc de
	ld b,#10
crsa3	call inch
	djnz crsa3
	pop bc
	djnz crsa1
	ret


inch    INC H
        LD A,H
        AND 7
        ret NZ 
        LD A,L
        ADD A,32
        LD L,A
        ret C
        LD A,H
        SUB 8
        LD H,A
	ret


scr_adr	ds 16*12*2

map	ds 16*12

		org #c000
tiles		incbin "spr/denizen.C"

	savesna "td_tiles.sna",start