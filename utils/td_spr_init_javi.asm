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
/*		ld de,en_fired
		ld hl,en_fired_mask
		ld ix,fired
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
*/
;		ld a,#17
;		jp page
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


is_chess_ff	ld bc,#0480
is11		push bc
is21		ld a,(hl)
		xor #ff
		ld (ix+0),a
		inc hl
		ld a,(de)
		ld (ix+1),a
		inc de
		inc ix
		inc ix
		djnz is21
		pop bc
		dec c
		jr nz,is11
		ret

/*
en_sprite_right	include "spr/sol-walk-right-ready.ASM"
en_spr_rgt_mask	include "spr/sol-walk-right-ready_msk.ASM"
en_sprite_left	include "spr/sol-walk-left-ready.ASM"
en_spr_lft_mask	include "spr/sol-walk-left-ready_msk.ASM"
en_sprite_dwn	include "spr/sol-walk-down-ready.ASM"
	include "spr/sol-walk-down-ready.ASM"
en_spr_dwn_mask	include "spr/sol-walk-down-ready_msk.ASM"
	include "spr/sol-walk-down-ready_msk.ASM"
en_sprite_up	include "spr/sol-walk-up-ready.ASM"
	include "spr/sol-walk-up-ready.ASM"
en_spr_up_mask	include "spr/sol-walk-up-ready_msk.ASM"			; inverted
	include "spr/sol-walk-up-ready_msk.ASM"
*/

en_sprite_right	include "spr/creep01-right-ready.ASM"
en_spr_rgt_mask	include "spr/creep01-right-ready_msk.ASM"
en_sprite_left	include "spr/creep01-left-ready.ASM"
en_spr_lft_mask	include "spr/creep01-left-ready_msk.ASM"
en_sprite_dwn	include "spr/creep01-down-ready.ASM"
;	include "spr/sol-walk-down-ready.ASM"
en_spr_dwn_mask	include "spr/creep01-down-ready_msk.ASM"
;	include "spr/sol-walk-down-ready_msk.ASM"
en_sprite_up	include "spr/creep01-up-ready.ASM"
;	include "spr/sol-walk-up-ready.ASM"
en_spr_up_mask	include "spr/creep01-up-ready_msk.ASM"
;	include "spr/sol-walk-up-ready_msk.ASM"

/*

en2_sprite_right	include "spr/tank-right-ready.ASM"
en2_spr_rgt_mask	include "spr/tank-right-ready_msk.ASM"
en2_sprite_left		include "spr/tank-left-ready.ASM"
en2_spr_lft_mask	include "spr/tank-left-ready_msk.ASM"
en2_sprite_dwn		include "spr/tank-down-ready.ASM"
	include "spr/tank-down-ready.ASM"
en2_spr_dwn_mask	include "spr/tank-down-ready_msk.ASM"
	include "spr/tank-down-ready_msk.ASM"
en2_sprite_up		include "spr/tank-up-ready.ASM"
	include "spr/tank-up-ready.ASM"
en2_spr_up_mask		include "spr/tank-up-ready_msk.ASM"
	include "spr/tank-up-ready_msk.ASM"

en_fired		include "spr/enemy_fired.asm"
en_fired_mask		include "spr/enemy_fired_mask.asm"
en_fired_dwn		include "spr/enemy_fired_down.asm"
en_fired_dwn_mask	include "spr/enemy_fired_down_mask.asm"

fired		equ #e000	
fired_dwn	equ fired+#400	
*/
enemy_sprite1	equ #c000	
enemy_sprite2	equ #d000	


        savesna "td_sprites_bnk.sna",start