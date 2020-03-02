		device zxspectrum128
	        org #7000

INT_VECTOR      EQU #B700 ;размер #1C0
num_enemy_sprites	equ 7
lives_adr	equ #50de
money_adr	equ #50fe
back_sprites 	equ #6000
mouse_screen	equ #6e00

; TOWERS list
; 0 type
; 1 position
; 2 fire rating 
; 3 fire rating counter
; 4 num_spr
; 5 -... ranged map cells
; #ff - end of tower
; #fe - end of all towers


start:

init_sprites	
;		ld a,#1
;		call page
		di
		ld sp,#5fff
/*
		ld de,en_fired_left
		ld hl,en_fired_left_mask
		ld ix,fired
		call is_chess
		ld de,en_fired
		ld hl,en_fired_mask
		call is_chess
		ld de,en_fired_dwn
		ld hl,en_fired_dwn_mask
		call is_chess
*/

		ld de,en_sprite_right
		ld hl,en_spr_rgt_mask
		ld ix,enemy_sprite1
		call is_chess
		ld de,en_sprite_left
		ld hl,en_spr_lft_mask
		call is_chess

		ld de,en_sprite_dwn
		ld hl,en_spr_dwn_mask
		call is_chess
		ld de,en_sprite_up
		ld hl,en_spr_up_mask
		call is_chess		

/*
		ld de,en2_sprite_right
		ld hl,en2_spr_rgt_mask
		ld ix,enemy_sprite2
		call is_chess
		ld de,en2_sprite_left
		ld hl,en2_spr_lft_mask
		call is_chess

		ld de,en2_sprite_dwn
		ld hl,en2_spr_dwn_mask
		call is_chess
		ld de,en2_sprite_up
		ld hl,en2_spr_up_mask
		call is_chess
;		ld a,#17
;		jp page
*/
		ret


is_chess	ld bc,#0480
is1		push bc
is2		ld a,(hl)
		ld (ix+0),a
		inc hl
		ld a,(de)
		ld (ix+1),a
		inc de
		inc ix
		inc ix
		djnz is2
		pop bc
		dec c
		jr nz,is1
		ret


en_sprite_right	include "king/king_right.asm"
en_spr_rgt_mask	include "king/king_right_mask.asm"
en_sprite_left	include "king/king_left.asm"
en_spr_lft_mask	include "king/king_left_mask.asm"
en_sprite_dwn	include "king/king_down.asm"
en_spr_dwn_mask	include "king/king_down_mask.asm"
en_sprite_up	include "king/king_up.asm"
en_spr_up_mask	include "king/king_up_mask.asm"

/*
en2_sprite_right	include "spr/enemy_bike_right.asm"
en2_spr_rgt_mask	include "spr/enemy_bike_right_mask.asm"
en2_sprite_left		include "spr/enemy_bike_left.asm"
en2_spr_lft_mask	include "spr/enemy_bike_left_mask.asm"
en2_sprite_dwn		include "spr/enemy_bike_down.asm"
en2_spr_dwn_mask	include "spr/enemy_bike_down_mask.asm"
en2_sprite_up		include "spr/enemy_bike_down.asm"
en2_spr_up_mask		include "spr/enemy_bike_down_mask.asm"
*/
/*
en_fired		include "../spr/enemy_fired.asm"
en_fired_mask		include "../spr/enemy_fired_mask.asm"
en_fired_left		include "../spr/enemy_fired_left.asm"
en_fired_left_mask	include "../spr/enemy_fired_left_mask.asm"

en_fired_dwn		include "../spr/enemy_fired_down.asm"
en_fired_dwn_mask	include "../spr/enemy_fired_down_mask.asm"
*/
fired		equ #e000	
fired_left	equ fired+#400	
fired_dwn	equ fired_left+#800	

enemy_sprite1	equ #c000	
enemy_sprite2	equ #d000	


        savesna "td_sprites_bnk.sna",start