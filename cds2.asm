
init_game	
		xor a
		ld (int_init+1),a
		out (#fe),a
		inc a
		ld (intro_int+1),a

		ld a,(mouse_switch)
		or a
		JR z,mouse_check_ex     
		ld a,#0f		; мышки нет
		ld (mouse_update+1),a
		ld hl,mz0+1
		ld (ki0+1),hl
		ld hl,mz1+1
		ld (ki2+1),hl
		ld hl,#403e
		ld (mz0),hl
		ld (mz1),hl
		ld a,left
		ld (kiright+1),a
		ld a,right
		ld (kileft+1),a
		ld a,up
		ld (kidown+1),a
		ld a,down
		ld (kiup+1),a
		ld a,#18
		ld (mouse_check_filled),a
		ld a,intro_scan-mouse_check_filled-2
		ld (mouse_check_filled+1),a
		ld a,#20
		ld (intro_text_mouse_check),a
mouse_check_ex
		ld a,7
		call page
		call scr_fading
		ld hl,#4000
		ld de,#4001
		ld bc,#17ff
		ld (hl),l
		ldir
		ld a,(level_current)
		call level_choice
		ld a,5
		ld (bdv+1),a
		ld hl,base_tower_db
		ld (bt_db+1),hl

		ld a,#fe
		ld (towers),a

		ld hl,level_name
		call en_create_show
		xor a
		ld (int_init+1),a
		ld (tower_upgraded_count),a
		ld a,4
		call page
		ld hl,#c000+(36*221)		; base damage sprites
		ld de,base_tower_db
		ld bc,36*3
		ldir
		ld hl,#c000+(36*194)
		ld bc,36
		ldir

		call map_view

		ld a,7
		call page
		call map_create
		ld a,(way_end)
		ld (way_enemy_end+1),a

		ld hl,(way_begin_adr)
		ld a,l
		ld (en_screenl+1),a
		ld a,h
		ld (en_screenh+1),a
		ld hl,lovemoney
		ld de,lives_adr-1
		ld b,8
lm1		ld a,(hl)
		ld (de),a
		inc hl
		inc d
		djnz lm1
		ld de,lives_adr-1+#20
		ld b,8
lm2		ld a,(hl)
		ld (de),a
		inc hl
		inc d
		djnz lm2
		ld a,#46
		ld (lives_atr),a
		ld a,#44
		ld (money_atr),a
		ld a,#45
		ld (waves_atr),a
		ld a,10				; 10 
		ld (lives),a
		ld de,lives_adr
		call view_dec_energy
		ld a,(level_money)
		ld (money),a
		ld de,money_adr
		call view_dec_energy
;		ld a,#46
;		ld (score_atr),a
;		ld de,score_adr
;		ld a,'S'
;		call char_print
		call view_score
		call view_waves
		ld a,(level_current)		
		inc a
		ld de,level_adr
		push de
		call view_dec_energy
		pop de
		dec e
		ld a,'L'
		call char_print

		ld a,#ff
		ld (pause_button_view+1),a
		call pause_button_view

		ld hl,level_atr
		ld (hl),#43
		ld hl,wave_view_atr+2
		ld (hl),#42


		ld a,#46
		ld b,5
		ld hl,score_atr
		ld (hl),a
		inc l
		djnz $-2

		call view_new_towers
		
		ld a,#7
		call page
		ld hl,#4000
		ld de,#c000
		ld bc,#1b00
		ldir

		ld hl,back_sprites
		ld (store_view_adr+1),hl
		ld de,#0000
		call store_view

		ld hl,back_sprites+back_sprites_offset
		ld (store_view_adr+1),hl
		ld de,#0000
		call store_view

		call mouse_store_adr
		call way_view
		xor a		
		call tower_attr_store
		call tower_attr_restore
;		call rmb
		ld hl,waves	; count waves
		ld de,8
		ld b,0
wav_cnt		ld a,(hl)
		cp #ff
		jr z,wav_cnt0
		add hl,de
		inc b
		jr wav_cnt
wav_cnt0	ld a,b
		ld (waves_finish),a
		ld hl,waves
		ld (enemy_create+1),hl
		
		xor a
		ld (waves_counter),a
		ld (towers_count),a
		ld (new_tower_create_flag),a	
		ld (tower_upgrade_flag),a
		ld (tower_preview_range_flag+1),a
		ld (stat_new_tower_flag+1),a
		ld (tower_keys+1),a
		ld (tower_preview_range_restore+1),a
		dec a
;		ld (stat_new_tower_flag+1),a
		ld (stat_upgrade_flag+1),a
		ld (tower_upgrade_range_flag+1),a
		ld (tower_upgrade_range+1),a

		ld hl,towers
		ld (tc_adr+1),hl

                jp enemy_create



en_create_show				; hl: sprite face, de: sprite mask, 13x21
		ld (ecs_face+1),hl	
		xor a
		ld (int_init+1),a
		call screen_48
;		call mouse_restore_screen		
		ld hl,#5900
		ld de,new_wave_old_clr
		ld bc,160
		ldir

		ld hl,#4808		;screen: 480a
		push hl

		ld de,new_wave_old
		ld b,#20
ecs1		push bc
		push hl
		ld bc,#10
		ldir
		pop hl
		call inch
		pop bc
		djnz ecs1
		ld hl,#5929
		ld a,#06
		call ecsc
		ld hl,#5908
		ld a,#46
		call ecsc
		pop de
		push de		; screen

		call window_view
		call pause

		ld de,#4c28
ecs_face	ld hl,0
		call print
		ld b,40
		call pause2
		pop de
achives		ld a,0
		or a
		ret nz		
		ld hl,new_wave_old
		ld b,#20
ecs4		push bc
		push de
		ld bc,16
		ldir
		pop de
		call incd
		pop bc
		djnz ecs4

		ld de,#5900
		ld hl,new_wave_old_clr
		ld bc,160
		ldir
		xor a
		ld (end_wave+1),a
		inc a
		ld (int_init+1),a
		ld a,#46
		jp end_pos_attr

window_view	push de
		ld hl,window_back
		ld bc,#2010
ecs21		push bc
		push de
ecs2		ld a,(hl)
		ld (de),a
		inc hl
		inc e
		dec c
		jr nz,ecs2
		pop de
		call incd
		pop bc
		djnz ecs21
		pop de
		ret

		; kolvo vragov, base energy, begin wait, wait,enemy_list
enemy_create	
		ld hl,waves
		ld a,(hl)
		cp #ff
		jp z,new_game
		ld (enemy_count),a
		ld b,a
		inc hl
		ld e,(hl)
		inc hl
		ld d,(hl)
		ex de,hl
		ld (base_energy_ec+1),hl
		ex de,hl
		inc hl
		ld e,(hl)
		inc hl
		ld d,(hl)
		inc hl
		ld a,(hl)
		ld (base_wait+1),a
		inc hl
		push de
		ld d,(hl)	; enemy_bit_list high 
		inc hl
		ld e,(hl)	; low
		inc hl
		ld (enemy_create+1),hl
		ld hl,enemy_list
		push bc
		ld b,16
		xor a
		ld c,a
el2		srl d
  		rr e
  		jr nc,el1
  		ld (hl),c
  		push af
  		ld a,c
  		ld (one_enemy_num+1),a
  		pop af
  		inc a
  		jr el

el1		ld (hl),#ff
el		inc hl
		inc c
		djnz el2
		ld (one_enemy_flag+1),a

		pop bc
		pop de
		ld hl,enemy
ec1		xor a
		ld (hl),a	; position on way,
		inc hl
		ld (hl),a	; num_spr
		inc hl
first_step	ld (hl),0	; napravlenie
		inc hl
en_screenl	ld (hl),0	; scr_adr
		inc hl
en_screenh	ld (hl),0
		inc hl
		ld (hl),e	; wait
		inc hl
		ld (hl),d
		inc hl
		push hl
		ex de,hl
base_wait	ld de,#40	; add wait time for next enemy
		ld a,r
		and #07
		add e
		ld e,a
		add hl,de
		ex de,hl
		pop hl
		push de

		push hl
		push de
		ld d,0

one_enemy_flag	ld a,0
		dec a
		jr nz,not_one_enemy
one_enemy_num	ld a,0
		jr one_enemy

not_one_enemy	ld a,r
		add b
		ld l,a
		ld h,#80
		ld l,(hl)
		ld a,(hl)
		and #07
one_enemy	ld e,a
		ld hl,enemy_list
		add hl,de
		ld a,(hl)
		cp #ff
		jr z,not_one_enemy
		pop de
		pop hl
		ld (hl),a
		inc hl
		push hl
		ld hl,enemy_lives
		ld e,a
		ld d,0
		add hl,de
		ld e,(hl)
		ld d,0
base_energy_ec	ld hl,0	
		add hl,de	
		ld a,r
		add l
		and 7
		add e
		ld e,a
		ex de,hl
		pop hl
		ld (hl),e	;energy
		inc hl
		ld (hl),d
		inc hl
		ld (hl),0
		inc hl
		ld (hl),0	;slowed
		inc hl
		pop de
		djnz ec1

		ld hl,waves_counter
		inc (hl)
		call view_waves
		ld de,wave_view_adr
		xor a
		ld (enemy_count_ingame+1),a
		call view_dec_energy
		ld a,'E'
		call char_print
		ld a,(enemy_count)
		call view_dec_energy
		ld a,create_wave_sound
		call AFXPLAY
		ld hl,new_wave
		jp en_create_show

store_view	
store_view_adr	ld hl,back_sprites
		ld (hl),e
		inc hl
		ld (hl),d
		inc hl
		ex hl,de
		ld a,(active_screen)
;		xor #80
		add h
		ld h,a
		ld b,#10
s_v1		push hl
		ld a,(hl)
		ld (de),a
		inc l
		inc de
		ld a,(hl)
		ld (de),a
		inc l
		inc de
		ld a,(hl)
		ld (de),a
		inc l
		inc de
		ld a,(hl)
		ld (de),a
		inc de
		pop hl
		call inch
		djnz s_v1

		ex de,hl
		ld (store_view_adr+1),hl
		ld (hl),#ff
		inc hl
		ld (hl),#ff
		ret


clear_status_attr
		ld hl,#5ac0
		ld c,02
tuv22		ld e,l
		ld d,h
		set 7,d
		ld a,#47
		ld b,#10
		ld (hl),a
		ld (de),a
		inc l
		inc e
		djnz $-4
		ld de,#10
		add hl,de
		dec c
		jr nz,tuv22
		ret

clear_menu_tower
		ld de,#50c0
		ld hl,#d0c0
		
		ld b,#10
vtc1		xor a
		ld c,e
		dup 16
		ld (de),a
		ld (hl),a
		inc e
		inc l
		edup
		ld e,c
		call incd
		ld l,e
		ld h,d
		set 7,h
		djnz vtc1
		ret

view_new_towers
		ld a,(money)
		ld (stat_new_tower_money+1),a
		call clear_menu_tower
		call clear_status_attr

st_new_tower	
		ld hl,tower_list
		ld b,4
st_new_tower0	ld a,(hl)
		cp #ff
		jr z,st_new_tower1
		push bc
		push hl
		push af
		ld d,0
		ld e,a
		ld hl,tower_price
		add hl,de
		ld c,(hl)
		ld hl,tower_char
		add hl,de
		ld b,(hl)

		add a,a
		ld e,a
		ld hl,tower_view_adr
		add hl,de
		ld e,(hl)
		inc hl
		ld d,(hl)
		ex de,hl
		pop af
		ld d,a
		call status_tower	
		pop hl
		pop bc
st_new_tower1	inc hl
		djnz st_new_tower0
		ret


map_create
	ld hl,(map)
	push hl
	push hl
	pop de
	inc de
	ld bc,16*11-1
	ld (hl),#ff	; 0 ne prohodimo, 1 - prohodimo
	ldir
	pop hl
	push de
	ld ix,way
	ld a,(way_begin)
	ld e,a
	ld d,0
	add hl,de	;	base point in map
	ld (hl),0

	ld de,16
	ld c,1
mc1	ld a,(ix+0)
	cp #ff
	jr z,map_create_ex
	or a		; 1-right, 0-left, 2-down, 3-up
	jr nz,mc2
	dec hl
	jr mc0
mc2	cp 1
	jr nz,mc3
	inc hl
	jr mc0
mc3	cp 2
	jr nz,mc4
	add hl,de
	jr mc0
mc4	sbc hl,de
mc0	ld (hl),c
	inc c
	inc ix
	jr mc1

map_create_ex
	ld a,c
	pop de
	ld (de),a
	dec a
	ld (way_end),a
	ret


level_choice	push af
		ld a,3
		call page
		pop af
		add a,a
		ld hl,levels_mem
		ld e,l
		ld d,a
		add hl,de
		ld de,map_mem
		push de
		ld bc,#200
		ldir
		pop hl
		ld a,(hl)
		ld (first_step+1),a

		ld a,(hl)
		inc hl
		cp #ff
		jr nz,$-4
		ld de,#7200
		push de
		ld bc,180
		ldir
		pop hl
		ld (map),hl

		ld hl,tower_list
		push hl
		ld b,4
		ld (hl),#ff
		inc hl
		djnz $-3
		pop hl
		ld a,(available_towers_adr)
		ld b,4		
		ld c,0
atl2		rla
		jr nc,atl1
		ld (hl),c
atl1		inc hl
		inc c
		djnz atl2

		ld a,7
		jp page



map_view
	ld hl,map_color
	ld (mvc0+1),hl
	ld hl,(map)
	ex de,hl
	ld ix,scr_adr
	ld bc,#100b
mv1	push bc
	ld l,(ix+0)
	ld a,(ix+1)
	add #40
	ld h,a
	inc ix
	inc ix
	ld (mvs0+1),hl

mv2	push de
	ld a,(de)
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
mvs0	ld hl,0

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
	ld a,(mvs0+1)
	add 2
	ld (mvs0+1),a
mv4	pop bc

mvc0	ld hl,map_color ; #5800

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
	inc l

	ld a,l
	sub #20
	ld l,a
	ld (mvc0+1),hl
	pop de
	inc de
	djnz mv2
	ld hl,(mvc0+1)
	ld bc,#20
	add hl,bc
	ld (mvc0+1),hl

	pop bc
	dec c
	jr nz,mv1
	ld e,l
	inc e
	ld d,h
	ld bc,#3f
	ld (hl),#47
	ldir


		ei
		ld a,1
		ld (map_clr5+1),a
		ld (map_clr3+1),a
		call screen_48

		ld b,7
map_clr2	push bc
		ld ix,map_color
		ld hl,#d800
		ld de,#5800
		ld bc,#300
map_clr1	ld a,(ix+0)
map_clr3	and 1			;cp 1
		ld (hl),a
		ld (de),a
		inc ix
		inc hl
		inc de
		dec bc
		ld a,b
		or c
		jr nz,map_clr1
		halt
		halt
		halt
		halt		
		pop bc
map_clr5	ld a,1
		inc a
		ld (map_clr5+1),a
map_clr6	ld a,(map_clr5+1)
		ld c,a
		sla a
		sla a
		sla a
		or c
		ld (map_clr3+1),a
		djnz map_clr2

		ld hl,map_color
		ld de,#5800
		ld bc,#2c0
		ldir
		ld hl,#5ac0
		ld d,h
		ld e,#c1
		ld c,#40
		ld (hl),#47
		ldir
		ret



                
way_view	
		
;		ld a,(way_begin)
		ld c,0
		ld a,(way_enemy_end+1)
		inc a
		ld (wv_ex+1),a
		
wv0		ld b,0
		ld hl,(map)
wv1		ld a,(hl)
		cp c
		jr nz,wv2
wv_ex		cp 0
		ret z
		call fill_way_view
		halt
		halt
		halt
		halt
		call fill_way_view2
		inc c
		jr wv0
wv2		inc hl
		inc b
		cp 16*11
		jr nz,wv1
		jr wv0

fill_way_view
		push hl
		ld a,b
		call tower_screen_adr
		ld (base_pos_scr+1),hl 	  
		ld a,h
	        RRCA
	        RRCA
 	        RRCA
	        AND 3
 	        OR #58
 	        LD h,a
 	        ld (end_pos_attr+1),hl
 	        ld a,(hl)
 	        ld (fwv20+1),a
		ld (hl),#46
		inc l
 	        ld a,(hl)
 	        ld (fwv21+1),a
		ld (hl),#47
		ld de,#1f
		add hl,de
 	        ld a,(hl)
 	        ld (fwv22+1),a
		ld (hl),#47
		inc l
 	        ld a,(hl)
 	        ld (fwv23+1),a
		ld (hl),#46
		pop hl
		ret

fill_way_view2	push hl
		ld a,b
		call tower_screen_adr
		ld a,h
	        RRCA
	        RRCA
 	        RRCA
	        AND 3
 	        OR #58
 	        LD h,a

fwv20		ld (hl),0
		inc l
fwv21		ld (hl),0
		ld de,#1f
		add hl,de
fwv22		ld (hl),0
		inc l
fwv23		ld (hl),0
		pop hl
		ret


level1 
	db  1, 1, 1, 1, 1, 1, 1, 2, 2,1, 1, 1, 1, 3,3, 1, 1, 1, 1
	db #ff

	include "levels/lev1.asm"

	org levels_mem+#130
; kolvo vragov, base energy, begin wait,0,  wait ,enemy_bit_list - from left
	db 12, 4,  0, #a0, 0, #14,%00000000,%00000001		;1
;	db #ff
	db 17, 11, 0, #20, 0, #22,%00000000,%00000010		;2
	db 28, 30, 0, #20, 0, #16,%00000000,%00000011		;3
	db 20, 45, 0, #40, 0, #14,%00000000,%00000101		;4
	db 13, 60, 0, #20, 0, #18,%00000000,%00000001		;5
	db 10, 80, 0, #20, 0, #30,%00000000,%00001000		;6
	db 20, 60, 0, #50, 0, #14,%00000000,%00000011		;7
	db 40, 110,0, #20, 0, #18,%00000000,%00000001		;8
	db 1,  250, 0, #40, 0, #33,%00000000,%00010000		;13
	db #ff

	org levels_mem+#1d0
	;   123456789abcdef
	db "FIRST ATTACK",#ff

	org levels_mem+#1f0
;way_begin
	db 64
;way_end
		db 20
;way_begin_adr
	dw #0800	
; available towers from right to left
	db %10000000
; money on start level
	db 18


		page 4
		org #c000
tiles		incbin "bin/tiles.C"		;	lenght 9216