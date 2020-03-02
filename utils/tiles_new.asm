		device zxspectrum128
	        org #7000

start


	ld hl,tiles
	ld b,0
mv0	push bc
ts0	ld de,tile_src
	ld b,#10
mv3	ld a,(de)
	ld (hl),a
	inc de
	inc hl
	ld a,(de)
	ld (hl),a
	inc de
	inc hl
	djnz mv3
	ex de,hl
	ld (ts0+1),hl
	ex de,hl
tsa0	ld de,tile_attr	
	ld a,(de)	; color
	inc de
	ld (hl),a
	inc hl
	ld a,(de)	; color
	inc de
	ld (hl),a
	inc hl
	ld a,(de)	; color
	inc de
	ld (hl),a
	inc hl
	ld a,(de)	; color
	inc de
	ld (hl),a
	inc hl
	ex de,hl
	ld (tsa0+1),hl
	ex de,hl
	pop bc
	djnz mv0
	ret




		org #8000
tile_src	include "tileset.asm"

		org #c000	
tiles

	savesna "tiles.sna",start