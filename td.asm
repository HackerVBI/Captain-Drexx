		device zxspectrum128
	        org #8000

INT_VECTOR      	equ #be00 ;размер #1C0
num_enemy_sprites	equ 7
lives_adr		equ #50de
money_adr		equ #50fe
wave_view_adr		equ #50f7
waves_adr		equ #50d7
score_adr		equ #50f1
level_adr		equ #50d2
upgrade_power_adr	equ #50c3
upgrade_price_adr	equ #50e3
achives_adr		equ #4888

player_name_adr		equ #4894
input_player_adr	equ #4868+8-#20
your_score_adr		equ #40e8+8-#20
score_view_adr		equ #480e+8
inp_help_adr		equ #48d1

score_table_header	equ #40e8+8-#20
score_table_adr		equ #480a+8
intro_text1_adr		equ #40b0
intro_text2_adr		equ #40f0

level_atr	equ #5ad1
lives_atr	equ #5add
money_atr	equ #5afd
waves_atr	equ #5ad9
score_atr	equ #5af1
wave_view_atr	equ #5af7

new_wave_old_clr	equ #6500
new_wave_old		equ #6600
back_sprites 		equ #6000
back_sprites_offset	equ #800
map_mem			equ #7000
map_color		equ #7c00
	
towers			equ map_mem+#300
		;	position, type
levels_mem		equ #c000
levels_offset		equ #200

way		equ map_mem
waves		equ map_mem+#130
level_name	equ map_mem+#1d0
way_begin	equ map_mem+#1f0
way_end		equ map_mem+#1f1
way_begin_adr	equ map_mem+#1f2
level_money	equ map_mem+#1f5
available_towers_adr	equ map_mem+#1f4



create_tower_sound	equ 4
create_wave_sound	equ 6
cancel_sound		equ 7
enemy_finish_sound	equ 8

end_level	equ 9

; TOWERS list
; 0 type
; 1 position
; 2 fire rating 
; 3 fire rating counter
; 4 num_spr
; 5 -... ranged map cells
; #ff - end of tower
; #fe - end of all towers


/*
сделай в начале выбор Ч "i'm too young to die" (с паузой), и "For the Glory" (без паузы)
Ђcocky assholeї , тоже без паузы, но скорость x2
*/


start:

		di
		ld sp,#7fff
		xor a
		out (#fe),a
		ld a,7
		call page
		ld hl,#5800
		ld de,#5801
		ld bc,#2ff
		ld (hl),l
		ldir
		ld hl,#c000
		ld de,#c001
		ld bc,#1aff
		ld (hl),l
		ldir
/*
		LD BC,#FBDF	; mouse 
		IN L,(C)     ;читаем координату X
		LD B,#FF
		IN A,(C)     ;сравниваем с Y
		CP L
		JR nz,mousecheck     ;если равны, то мышки нет
		ld a,#0f
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
*/
mousecheck	call mouse_pos
		ld hl,sfxbank
		call AFXINIT
		call cr_scradr 
;инициализаци€ прерываний

                LD HL,INT_VECTOR
                LD B,0
                LD A,high INT_VECTOR+1
INIT_ENGINE1    LD (HL),A
                INC HL
                DJNZ INIT_ENGINE1
                LD (HL),A
                LD H,high INT_VECTOR+1
                LD L,H
                LD (HL),#C3
                INC HL
                LD DE,interrupt
                LD (HL),E
                INC HL
                LD (HL),D
                LD A,high INT_VECTOR
                LD I,A
                IM 2
                xor a
                call page
                jp intro

		db 'preved medved! send me letter: waybester@gmail.com!'

gl_init		call init_game


game_loop	
		ld a,1
		ld (screen_ready),a
		dec a
		ld (int_calk+1),a
game_pause	ld a,0
		or a
		jr nz,gl_halt
;		ld a,2
;		out (#fe),a
		call restore_view
		call base_damage_view
end_wave	ld a,1
		or a
		call nz,enemy_create

;		ld a,3		
;		out (#fe),a
		call enemy_pos

;		ld a,4
	;	out (#fe),a
		call spr_store

;		ld a,5
	;	out (#fe),a
		call spr_view

;		ld a,6
	;	out (#fe),a
		call towers_fire
;		ld a,7
	;	out (#fe),a
		call tower_fires_view
		xor a
		ld (screen_ready),a
	;	out (#fe),a
gl_halt		halt
gl_halt1	ld a,(int_calk+1)
		cp 2
		jr nc,game_loop
		halt
	        jp game_loop



interrupt	di
		push af
		ex af,af
		push af
		push hl
		push de
		push bc
		push ix
intro_int	ld a,0
		or a
		jr nz,game_int
		ld a,(current_page)
		push af
		ld a,3
		call page
		call vtplayer
		pop af
		call page
		jp rmc_exit
game_int
;		ld a,7
;		out (#fe),a
                call AFXFRAME
;               ld a,(int_calk+1)
;		ld de,#50e8
;		call view_energy
int_init	ld a,0
		or a
		jp z,rmc_exit

int_calk	ld a,0
		inc a
		ld (int_calk+1),a
md1		LD A,(current_page)
                LD (int_ram+1),A

                ld a,7
                call page

		call mouse_restore_screen
		call mouse_pos
		call mouse_map_adr

tower_upgrade_range_flag
		ld a,#ff
		cp #ff
		call nz,tower_upgrade_range


stat_upgrade_flag
		ld a,#ff
		ld b,a
		cp #ff
		call nz,stat_upgrade
;		ld a,7
;		out (#fe),a


stat_new_tower_flag
		ld a,0
		or a
		call z,stat_new_tower
;		xor a
;		out (#fe),a

                LD A,(screen_ready)
                or a
                jr nz,int_1
                CALL CHANGE_SCREEN
		ld a,1
		ld (screen_ready),a
int_1	
		ld a,(end_wave+1)
		or a
		jr nz,int_ram

tower_preview_range_flag
		ld a,0
		or a
		call nz,tower_preview_range
;		ld a,6
;		out (#fe),a
		call mouse_pressed
;		ld a,7
;		out (#fe),a

int_ram		ld a,7
		call page
		ld a,(end_wave+1)		; fix 
		or a
		call z, mouse_view		

pause_view	ld a,(pause_button_view+1)
		or a
		call nz,pause_view_atr

red_lives_counter
		ld a,0
		or a
		jr z,red_money_counter
		dec a
		ld (red_lives_counter+1),a
		or a
		jr nz,red_money_counter
		call fill_lives_atr


red_money_counter
		ld a,0
		or a
		jr z,rmc_exit
		dec a
		ld (red_money_counter+1),a
		or a
		jr nz,rmc_exit
		ld a,#47
		call fill_money_atr
rmc_exit
;		xor a
;		out (#fe),a
		pop ix
		pop bc
		pop de
		pop hl
		pop af
		ex af,af
		pop af
		ei
		ret

pause_view_atr	ld a,#1f
		dec a
		and #1f
		ld (pause_view_atr+1),a
		or a
		ret nz

		ld hl,level_atr+4
		ld a,(hl)
		xor 4
		ld (hl),a
		set 7,h
		ld (hl),a
		ret


tower_upgrade_range
		ld e,0
		cp e
		ret z
		ld (tower_upgrade_range+1),a
		ld (turt+1),a
		push af		; a: pos
		call tower_preview_range_restore
		call tower_preview_range_store
		pop af


		ld a,(tower_upgrade_price)
		ld c,a
		ld b,#07
		ld a,(money)
		sub c
		jr c,prev_color_r
		ld b,#46
prev_color_r	ld a,b
		ld (preview_color_r+1),a

; range check
tower_upgrade_range_type	
		ld a,0
		or a
		jr nz,tur2
		ld ix,tower_range1
		jr tur

tur2		cp 1
		jr nz,tur3
		ld ix,tower_range2
		jr tur

tur3		cp 2
		jr nz,tur4
		ld ix,tower_range3
		jr tur

tur4		ld ix,tower_range1

tur					; всего три башни по range
		ld a,(ix+0)
		cp #80
		ret z
		ld c,a
turt		ld a,0
		sub c
		push bc
		call tower_pos_attr2
preview_color_r	ld a,0
		ld (hl),a
		ld (de),a
		inc l
		inc e
		ld (hl),a
		ld (de),a
		ld bc,#1f
		add hl,bc
		ld e,l
		ld a,(preview_color_r+1)
		ld (hl),a
		ld (de),a
		inc l
		inc e
		ld (hl),a
		ld (de),a
		pop bc
		inc ix
		jr tur




tower_preview_range
		ld hl,(mouse_map)
		ld a,l	;Y
		add a,a
		add a,a
		add a,a		
		add a,a	
		add h	;X
		ld c,a
		cp #b0		
		jp nc,tower_preview_range_ex

tpr_old		cp #0

		ret z
		ld (tpr_old+1),a
		ld (preview_pos+1),a

		cp #b0
		jr nc,tpr_turr1
		ld (tpr_fill_pos+1),a
		call tower_preview_range_restore
		call tower_preview_range_store

tpr_turr1	ld a,(tower_preview_range_flag+1)	; type
		sub #b0
		rra
tpr_tur		push af
		ld c,a
		ld b,0
		ld hl,tower_price
		add hl,bc
		ld c,(hl)
		ld b,#07
		ld a,(money)
		sub c
		jr c,prev_color
		ld b,#46
prev_color	
		ld hl,(map)
		ld a,(preview_pos+1)
		ld c,a
		ld a,l
		add c		; pos of tower
		ld l,a
		ld a,(hl)
		cp #ff
		jr nc,prev_color2
		ld b,#42
prev_color2
		ld a,b
		ld (preview_color+1),a
		pop af
; range check
		or a
		jr nz,tpr2
		ld ix,tower_range1
		jr tpr

tpr2		cp 1
		jr nz,tpr3
		ld ix,tower_range2
		jr tpr

tpr3		cp 2
		jr nz,tpr4
		ld ix,tower_range3
		jr tpr

tpr4		ld ix,tower_range1

tpr					; всего три башни по range
		ld a,(ix+0)
		cp #80
		jr z,tpr_fill_pos
		ld c,a
preview_pos	ld a,0
		sub c
		cp #b0
		jr nc,tpr0
		push bc
		call tower_pos_attr2
preview_color	ld a,0
		ld (hl),a
		ld (de),a
		inc l
		inc e
		ld (hl),a
		ld (de),a
		ld bc,#1f
		add hl,bc
		ld e,l
		ld a,(preview_color+1)
		ld (hl),a
		ld (de),a
		inc l
		inc e
		ld (hl),a
		ld (de),a
		pop bc
tpr0		inc ix
		jr tpr

tpr_fill_pos	ld a,0
		call tower_pos_attr3
		ld bc,#4707
		jp block_attr_fill



tower_preview_range_ex
		ld (tpr_old+1),a
		jp tower_preview_range_restore

tower_preview_range_store
		ld a,1
		ld (tower_preview_range_restore+1),a
;		call tower_pos_attr
		push hl
		push de
;		ld de,tower_atr_db
;		ld hl,#5800
;		ld bc,#2c0
;		ldir
		ld (tprs_sp+1),sp
		ld sp,#5800
		ld hl,tower_atr_db
		ld a,#2c/2
tprs0
		dup 16
		pop de
		ld (hl),e
		inc hl
		ld (hl),d
		inc hl
		edup
		dec a
		jr nz,tprs0


tprs_sp		ld sp,0
		pop de
		pop hl
		ret




tower_preview_range_restore

		ld a,0
		or a
		ret z
		ld (tprr_sp+1),sp
		ld sp,tower_atr_db
		ld hl,#5800
		ld a,#2c/2
tprr0
		dup 16
		pop bc
		ld (hl),c
		inc l
		ld (hl),b
		dec l
		set 7,h
		ld (hl),c
		inc l
		ld (hl),b
		inc hl
		res 7,h
		edup
		dec a
		jp nz,tprr0
;		push hl
;		push bc
;		ldir
;		pop bc
;		pop hl
;		ld de,#d800
;		ldir


tprr_sp		ld sp,0
		xor a
		ld (tower_preview_range_restore+1),a
		ret




tower_pos_attr
		ld a,(new_tower_create_flag)
tower_pos_attr3	ld c,a
tower_pos_attr2
		call tower_screen_adr
		ld a,h
	        RRCA
	        RRCA
 	        RRCA
	        AND 3
 	        OR #58
 	        LD h,a
		ld b,a
 	        or #80
 	        ld d,a
 	        ld e,l
 	        ld c,l
 	        ex de,hl
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



fill_lives_atr	or a
		jr nz,fill_lives_atr2
		ld a,#46
		call end_pos_attr
		ld a,#47
		jr epa0

fill_lives_atr2	ld a,#42
end_pos_attr	ld hl,0
		push af
		ld a,h
		or #80
		ld d,a
		pop af
		ld e,l
		ld (hl),a
		ld (de),a
		inc l
		inc e
		ld (hl),a
		ld (de),a
		ld bc,#1f
		add hl,bc
		ld e,l
		ld (hl),a
		ld (de),a
		inc l
		inc e
		ld (hl),a
		ld (de),a
epa0		ld (#5ade),a
		ld (#5adf),a
		ld (#dade),a
		ld (#dadf),a
		ret


fill_money_atr	
		ld (#5afe),a
		ld (#5aff),a
		ld (#dafe),a
		ld (#daff),a
		ret

screen_48	ld a,#c0
		ld (active_screen),a
		ld a,7
		jp page

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
print
		push hl
		ld c,0
print_cnt1	ld b,e
print_cnt0	ld a,(hl)
		inc hl
		inc c
		cp #fe
		jr c,print_cnt0
		rr c
		ld a,8
		sub c
		add a,e
		ld e,a
		pop hl
print_p1	ld a,(hl)

		cp #ff
		ret z
		cp #fe
		jr nz,print_p2
		ld a,b
		add #20
		ld e,a
		jr nc,$+6
		ld a,d
		add a,8
		ld d,a
		ld c,0
		inc hl
		push hl
		jr print_cnt1

print_p2	push hl
		call char_print_48
		pop hl
		inc hl
		jr print_p1

char_print_48	push hl
		push de
		push bc
		call char_adr
	        ld b,8
char_print_481  ld a,(hl)

char_print_48_inv
	        cpl
	        ld (de),a
	        inc hl
	        call incd
	        djnz char_print_481
	        pop bc
	        pop de
	        inc e
	        pop hl
	        ret

char_adr	push de
	        ld l,a
	        ld h,0
	        add hl,hl
	        add hl,hl	        
	        add hl,hl
	        ld de,font-#100
	        add hl,de
	        pop de
	        ret

ecsc		ld c,#04
		ld e,a
ecsc0		ld b,#10
		ld (hl),e
		inc l
		djnz $-2
		ld a,l
		add #10
		ld l,a
		dec c
		jr nz,ecsc0
		ret

pause		ld b,#18
pause2		ei
		halt
		djnz $-1
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





;	position on way, num_spr, napravlenie, scr_adr, wait low,high, type, energy, fired, slowed
;	0		 1	  2		3,4		5,6	7	8,9	10,	11
; enemy	db 0,0,1,0,#40,01,0, 0,#ff, 0
	
view_waves	ld de,waves_adr
		ld a,(waves_counter)
		call view_dec_energy
		ld a,'W'
		call char_print
		ld a,(waves_finish)
		jp view_dec_energy

view_3dec	ld h,0
		ld l,a
		ld	bc,-100
		call	Num1
		call char_print
		ld	bc,-10
		call	Num1
		call char_print
		ld	c,-1
		call Num1
		jr char_print

view_dec_energy
		ld h,0
		ld l,a
		ld	bc,-10
		call	Num1
		call char_print
		ld	c,-1
		call Num1

char_print	push af
		push hl
		push de
		push bc
		call char_adr
	        ld a,d
	        xor #80
	        ld b,a
	        ld c,e
	        dup 8
	        ld a,(hl)
	        ld (de),a
	        ld (bc),a
	        inc hl
	        inc d
	        inc b
	        edup
	        pop bc
	        pop de
	        inc e
	        pop hl
	        pop af
	        ret

view_score	
view_score_proc	
		ld hl,(score)
		ld de,score_adr
		ld	bc,-10000
		call	Num1
		call char_print
		ld	bc,-1000
		call	Num1
		call char_print
		ld	bc,-100
		call	Num1
		call char_print
		ld	c,-10
		call	Num1
		call char_print
		ld	c,-1
		call Num1
		jp char_print


Num1:		ld	a,'0'-1
Num2:		inc	a
		add	hl,bc
		jr	c,Num2
		sbc	hl,bc
		ret


symbols		db '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F',';'


; towers
; 0 type	=>tower_char db
; 1 position
; 2 fire rating 
; 3 fire rating counter
; 4 num_spr
; 5 -... ranged map cells
; #ff - end of tower
; #fe - end of all towers

towers_fire	ld ix,enemy
		ld a,(enemy_count)
		or a
		ret z	
		ld b,a

tf		push bc
		ld a,(ix+0)	; #ff - killed
		inc a
		jp z,t_e_next

		ld l,(ix+5)
		ld h,(ix+6)
		dec hl
		ld a,h
		or l
		jp nz,t_e_next

		ld hl,towers-1
tf_next		inc hl
		ld a,(hl)	; tower type	
		cp #fe
		jr z,t_e_next
		ld (freez+1),a
		inc hl		
		inc hl
		ld (fire_timeout+1),hl
		ld (fire_timeout_init+1),hl
		inc hl
		ld a,(hl)
		ld (fire_to_init+1),a
		inc hl
		ld (tower_fires_add+1),hl	; num_spr
		inc hl		
		ld c,(hl)	; power of tower
		inc hl		
tf0		ld a,(hl)	; range towers
		cp #ff		; end of current tower ranged list
		jr z,tf_next	

;	position on way, num_spr, napravlenie, scr_adr, wait low,high, type, energy
;	0		 1	  2		3,4		5,6	7	8
		cp (ix+0)
		jr nz,tf1
		push hl
fire_timeout	ld hl,0
		dec (hl)
		pop hl
		jr nz,tf1
		
		push hl
fire_timeout_init
		ld hl,0
fire_to_init	ld a,0
		ld (hl),a
		pop hl
		ld a,7
tower_fires_add	ld (0),a
freez		ld a,0
		cp 3
		jr nz,not_freezing
		ld a,c		; freeze_power
		ld (ix+11),a	
		jr tf1

not_freezing	ld (ix+10),8	; enemy fireed
		push hl
		ld l,(ix+8)
		ld h,(ix+9)	; ranged enemy, energy -= power of tower
		ld b,0
		sbc hl,bc
		ld (ix+8),l
		ld (ix+9),h
		jr nc,tf11
		ld (ix+0),#ff	; enemy killed
		ld (ix+1),7	; sprites of the DEADd ;)

		ld hl,score
		inc (hl)
		ld a,(money)
		inc a
		ld (money),a
		call dec_enemy_counter
		xor a
		ld (view_scores_update_flag+1),a
tf11		pop hl
tf1		
		inc hl
		jr tf0



t_e_next	ld de,12
		add ix,de
		pop bc
		dec b
		jp nz,tf

view_scores_update_flag
		ld a,0
		or a
	 	ret nz

view_scores_update
		call view_score
		ld a,(money)
		ld de,money_adr
		call view_dec_energy
		call dec_enemy_view
		
		ld a,(lives)
		ld (view_scores_update_flag+1),a
		ld de,lives_adr
		jp view_dec_energy

;		jp mouse_store_adr


base_damage_view			; отображение повреждени€ последней (целевой) башни
		ld a,1
		or a
		ret nz
		inc a
		ld (base_damage_view+1),a
		ld a,(lives)
		rra
		ret c
bdv		ld a,5
		dec a
		ret z
		ld (bdv+1),a
bt_db		ld hl,base_tower_db
base_pos_scr	ld de,0
		ld b,#10
base_dv1	push bc
		ld c,e
		ld a,d
		xor #80
		ld b,a
		ld a,(hl)
		ld (de),a
		ld (bc),a
		inc hl
		inc e
		inc c
		ld a,(hl)
		ld (de),a
		ld (bc),a
		inc hl
		dec e
		call incd
		pop bc
		djnz base_dv1
		ld de,4
		add hl,de
		ld (bt_db+1),hl
		ret

tower_fires_view
		ld hl,towers
tfv0		ld a,(hl)
		cp #fe
		ret z
		ld b,a		; type
		inc hl
		ld a,(hl)	; pos
		inc hl
		push hl
		call tower_screen_adr
		ex de,hl
		pop hl
		inc hl	; rate
		inc hl	;rate_count

		ld a,(hl)	; num_spr
		or a
		jr z,tfv2
		dec (hl)
		dec a		; стрельба, если наинаем проигрывание спрайта фаера башни
		cp 6
		jr nz,tfv2
		
		push hl
		push de
		push bc
		push af
		ld a,r
		and 3
		call AFXPLAY
		pop af
		pop bc
		pop de
		pop hl
		inc a
tfv2		srl a
		push hl
		push de		; de - screen		
		ld l,a
		ld h,0
		add hl,hl
		add hl,hl		
		add hl,hl
		add hl,hl
		add hl,hl
		ex de,hl

		ld l,b
		ld h,0
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl	; x 128
		add hl,de
		ld de,tower_gfx
		add hl,de
		pop de
		di
		ld (tfvs+1),sp
		ld sp,hl
		ex de,hl
		dup 7
		pop de
		ld (hl),e
		inc l
		ld (hl),d
		dec l
		inc h
		edup
		pop de
		ld (hl),e
		inc l
		ld (hl),d
		dec l
		INC H
	        LD A,H
        	AND 7
	        jr NZ,tfvsn
        	LD A,L
	        ADD A,32
        	LD L,A
	        jr C,tfvsn
        	LD A,H
        	SUB 8
	        LD H,A
tfvsn	        
		dup 7
		pop de
		ld (hl),e
		inc l
		ld (hl),d
		dec l
		inc h
		edup
		pop de
		ld (hl),e
		inc l
		ld (hl),d
tfvs		ld sp,0
		ei
		pop hl
tfv3		inc hl
		ld a,(hl)
		cp #ff
		jr nz,tfv3
		inc hl
		jp tfv0


tower_create	ld hl,towers_count
		inc (hl)
				; a: fire rate
				; create tower, b: pos #21, c: type 0
tc_adr		ld hl,towers
		ld (hl),c	; type
		inc hl
		ld (hl),b	; position
		inc hl
		ld (hl),1	; init fire rating 
		inc hl		
		ld (hl),a	; fire rating counter
		inc hl				
		ld (hl),6	; num_spr
		inc hl
		ld e,c
		push hl
		ld d,0
		ld hl,tower_char
		add hl,de
		ld a,(hl)	; power of tower
		pop hl
		ld (hl),a
		inc hl

		ex de,hl

		ld hl,(map)
		ld a,c
; range check
		or a
		jr nz,tr2
		ld ix,tower_range1
		jr tr

tr2		cp 1
		jr nz,tr3
		ld ix,tower_range2
		jr tr

tr3		cp 2
		jr nz,tr4
		ld ix,tower_range3
		jr tr

tr4		ld ix,tower_range1

; create range map
tr		ld a,l
		add b		; pos of tower
		ld l,a
		ld (tr_base+1),hl

tr0		ld a,(ix+0)
		cp #80
		jr z,trn0
tr_base		ld hl,0		; base_point
		add l
up_map_lim	cp 0
		jr c,trn1
dwn_map_lim	cp 176
		jr nc,trn1
		ld l,a
		ld a,(hl)
		inc a
		jr z,trn1
		dec a
		ld (de),a
		inc de
trn1		inc ix
		jr tr0
trn0		ld a,#ff
		ld (de),a	; #ff - end of ranged map cells
		inc de
		ex de,hl
		ld (tc_adr+1),hl
		ld (hl),#fe	; #fe - end of all towers ranged map cells
		ld a,b
		call tower_screen_adr
view_tower_instatus
		push hl
		ld a,c
		ld l,a
		ld h,0
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl	; x 128
		ld de,tower_gfx
		add hl,de
		pop de
		push de
		ld a,d
		xor #80
		ld b,a
		ld c,e
		dup 7
		ld a,(hl)
		ld (de),a
		ld (bc),a
		inc hl
		inc e
		inc c
		ld a,(hl)
		ld (de),a
		ld (bc),a
		inc hl
		dec c
		dec e
		inc d
		inc b
		edup
		ld a,(hl)
		ld (de),a
		ld (bc),a
		inc hl
		inc e
		inc c
		ld a,(hl)
		ld (de),a
		ld (bc),a
		inc hl
		dec c
		dec e
		call incd
		ld a,d
		xor #80
		ld b,a
		ld c,e
		dup 8
		ld a,(hl)
		ld (de),a
		ld (bc),a
		inc hl
		inc e
		inc c
		ld a,(hl)
		ld (de),a
		ld (bc),a
		inc hl
		dec c
		dec e
		inc d
		inc b
		edup
		pop hl
					; attribute
;=========scr adr -> attr adr========
   ;in: DE - screen adress
   ;out:DE - attr adress

		ld a,h
	        RRCA
	        RRCA
 	        RRCA
	        AND 3
 	        OR #58
 	        LD h,a
 	        or #80
 	        ld d,a
 	        ld e,l
 	        ld bc,#1f
 	        push hl
 	        push de
 	        ld a,#46
 	        ld (hl),a
 	        ld (de),a
 	        inc l
 	        inc e
 	        ld (hl),a
 	        ld (de),a
 	        add hl,bc
 	        ld e,l			;!!!! attr
 	        ld (hl),a
 	        ld (de),a
 	        inc e
 	        inc l
 	        ld a,#44
 	        ld (hl),a
 	        ld (de),a
		pop de
		pop hl
		ret

tower_screen_adr
		ld hl,scr_adr
		push af
		and #f0
		jr z,tvc2
		rra
		rra
		rra
		rra
tvc1		inc hl
		inc hl
		dec a
		jr nz,tvc1
tvc2		ld a,(hl)
		inc hl
		ld h,(hl)
		ld l,a
;		ld a,h
;		add #40
;		ld d,a
		ld a,(active_screen)
;		xor #80
		add h
		ld h,a
		pop af
		and #0f
		add a,a
		add l
		ld l,a
;		ld e,a
		ret

spr_view	ld ix,enemy
		ld a,(enemy_count)
		ld b,a
s_view		push bc
		ld a,(ix+0)
		inc a
		jr nz,s_view2
		ld a,(ix+1)
		or a
		jp z,ns_view
		dec (ix+1)
		jr killed

s_view2		ld l,(ix+5)
		ld h,(ix+6)
		dec hl
		ld a,h
		or l
		jp nz, ns_view
		ld a,(ix+10)
		or a
		jr z,s_view1
		dec (ix+10)
		ld hl,fired
		ld de,#400
		ld a,(ix+2)	; napravlenie		
		or a
		jr z,fire_spr_view
		add hl,de
		cp 1
		jr z,$+5
killed		ld hl,fired_dwn
fire_spr_view	ld a,1
		ld (en_page+1),a	; page 1 for explode
		ld a,(ix+1)
		jr s_view0

s_view1		ld a,(ix+7)	; enemy
		ld e,a
		ld d,0
		ld hl,enemy_pages
		add hl,de
		ld a,(hl)
		ld (en_page+1),a
		sla e
		ld hl,enemy_gfx
		add hl,de
		ld a,(hl)
		inc hl
		ld h,(hl)
		ld l,a
		push hl		
		ld a,(ix+2)	; napravlenie
		add a,a
		ld e,a
		ld d,0
		ld hl,enemy_moves
		add hl,de
		ld a,(hl)
		inc hl
		ld h,(hl)
		ld l,a
		pop de
		add hl,de

		ld a,(ix+1)
s_view0		
		push hl
		ld l,a
		ld h,0
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl	; 48 bytes per sprite, x128
		pop de
		add hl,de
		di
en_page		ld a,#1
		call page				
		ld (view_spr_s+1),sp
		ld (view_spr_s2+1),sp
		ld sp,hl
		ld hl,sprbuffer
		dup 4*#16
		pop bc
		ld (hl),c
		inc hl
		ld (hl),b
		inc hl
		edup
view_spr_s2	ld sp,0
		LD A,7
		call page
vsnrscr		ld sp,sprbuffer

		ld e,(ix+3)
		ld d,(ix+4)
		ld a,(active_screen)
;		xor #80
		add d
		ld d,a
		
		ld b,#10
vsnr		ld c,e
		dup 3
		pop hl
		ld a,(de)
		and l
		or h
		ld (de),a
		inc e
		edup

		pop hl
		ld a,(de)
		and l
		or h
		ld (de),a
		ld e,c
		INC d
	        LD A,d
	        AND 7
	        jr NZ,vsn
	        LD A,e
	        ADD A,32
	        LD e,A
	        jr C,vsn
	        LD A,d
	        SUB 8
	        LD d,A
vsn 		djnz vsnr
view_spr_s	ld sp,0
		ei
ns_view		pop bc
		ld de,12
		add ix,de
		dec b
		jp nz, s_view
		ret



restore_view	ld hl,back_sprites
		ld a,(active_screen)
		cp #40
		jr z,r_v1
		ld de,back_sprites_offset
		add hl,de
r_v1		ld (r_s0+1),hl
;		ld a,7
;		call page
r_s0		ld hl,0
		ld e,(hl)
		inc hl
		ld d,(hl)
		inc hl
		ld a,e
		cp #ff
		jr nz,r_s_c1
		ld a,d
		cp #ff
		ret z
r_s_c1		di
		ld (rest_v_s+1),sp
		ld sp,hl
		ex de,hl
		ld a,(active_screen)
;		xor #80
		add h
		ld h,a

		ld c,l
		ld b,#10
r_s1		pop de
		ld (hl),e
		inc l
		ld (hl),d
		inc l
		pop de
		ld (hl),e
		inc l
		ld (hl),d
		ld l,c

		INC h
	        LD A,h
	        AND 7
	        jr NZ,rvsn
	        LD A,l
	        ADD A,32
	        LD l,A
	        jr C,rvsn
	        LD A,h
	        SUB 8
	        LD h,A

rvsn		ld c,l
		djnz r_s1

		ld hl,0
		add hl,sp
		ld (r_s0+1),hl
rest_v_s	ld sp,0	
		ei
		jr r_s0


spr_store	ld hl,back_sprites
		ld de,back_sprites_offset
		ld a,(active_screen)
		cp #40
		jr z,s_stor1
		add hl,de
s_stor1		ld (store_view_adr+1),hl
		ld a,7
		call page
		ld ix,enemy
		ld a,(enemy_count)
		ld b,a
s_stor		ld a,(ix+0)	; #ff - killed
		inc a
		jr nz,stor_count
		ld a,(ix+1)
		or a
		jr z,stor_count2

stor_count	ld l,(ix+5)
		ld h,(ix+6)
		dec hl
		ld a,h
		or l
		jr nz,stor_count2	
		ld e,(ix+3)
		ld d,(ix+4)
		push bc
		push de
		call store_view
		pop de
		pop bc
stor_count2	ld de,12
		add ix,de
		djnz s_stor
		ret

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


enemy_pos	ld ix,enemy
		ld a,1
		ld (end_wave+1),a
		ld a,(enemy_count)
		ld b,a
enemy_pos1	push bc
		ld a,(ix+0)	; #ff - killed
		inc a
		jr nz,enemy_pos20

		ld a,(ix+1)
		or a
		jp z,end_calk
		xor a
		ld (end_wave+1),a		; флаг обработки врагов
		jp end_calk

enemy_pos20	ld l,(ix+5)
		ld h,(ix+6)
		dec hl
		ld a,h
		or l
		jr z,begin_calk
		ld (ix+5),l
		ld (ix+6),h
		xor a
		ld (end_wave+1),a		; флаг обработки врагов
		jp end_calk

begin_calk	xor a
		ld (end_wave+1),a
		ld a,(ix+11)			; freezed
		or a
		jr z,begin_calk2
		dec a
		ld (ix+11),a
		rra
		jr c,end_calk

begin_calk2	ld d,#ff
		ld a,(ix+1)	; num_spr
		inc a
		and num_enemy_sprites
		ld (ix+1),a
		jr nz,en
		ld a,(ix+0)
		inc a
way_enemy_end	cp 0
		jr nz,we
enemy_find_exit	ld a,#ff	;dont calc this enemy
		ld (ix+0),a
		ld a,#20
		ld (red_lives_counter+1),a
		call fill_lives_atr
		ld a,(lives)
		dec a
		ld (lives),a
		jp z,end_game
		xor a
		ld (view_scores_update_flag+1),a
		ld (base_damage_view+1),a
		call dec_enemy_counter
		push ix
		ld a,enemy_finish_sound
		call AFXPLAY
		pop ix
		jr end_calk

we		ld (ix+0),a	
;		ld a,(ix+2)
;		ld (move_old+1),a

		ld d,(ix+2)
		ld l,a
		ld h,high way
		ld a,(hl)	; new napravlenie
		ld (ix+2),a

;	position on way, num_spr, napravlenie, scr_adr, wait low,high, type, energy, fired, slowed
;	0		 1	  2		3,4		5,6	7	8,9	10,	11

en		ld a,(ix+2)
	; napravlenie: 1-right, 0-left, 2-down, 3-up
		or a
		call z,spr_adr_left
		ld a,(ix+2)
		cp 1
		call z,spr_adr_right
		ld a,(ix+2)
		cp 2
		call z,spr_adr_down
		ld a,(ix+2)
		cp 3
		call z,spr_adr_up
end_calk	pop bc
		ld de,12
		add ix,de
		dec b
		jp nz,enemy_pos1
		jp view_scores_update_flag

spr_adr_up
	ld a,d
	cp 0
	call z,spr_adr_right_correct


	ld e,(ix+3)
	ld d,(ix+4)
	call decd
	call decd
	ld (ix+3),e
	ld (ix+4),d
	ret
	; napravlenie: 1-right, 0-left, 2-down, 3-up
spr_adr_down
	ld a,d
	cp 0
	call z,spr_adr_right_correct

	ld l,(ix+3)
	ld h,(ix+4)
	call inch
	call inch
	ld (ix+3),l
	ld (ix+4),h
	ret


spr_adr_right
	ld a,(ix+1)
	or a
	ret nz
spr_adr_left_correct
	ld a,(ix+3)
	inc a
	inc a
	ld (ix+3),a
	ret

	; napravlenie: 1-right, 0-left, 2-down, 3-up
spr_adr_left	
		ld a,d
		cp 2
		ret z
		ld a,d
		cp 3
		ret z

		ld a,(ix+1)
		or a	 ; or a
		ret nz
spr_adr_right_correct
		ld a,(ix+3)
		dec a
		dec a
		ld (ix+3),a
		ret


dec_enemy_counter
enemy_count_ingame
		ld a,0
		inc a
		ld (enemy_count_ingame+1),a
		ret

dec_enemy_view
 		ld de,wave_view_adr
		ld a,(enemy_count_ingame+1)
		jp view_dec_energy


end_game
		xor a
		ld (intro_int+1),a
		ld hl,die_music
		call init_mus
		ld hl,game_over
		call en_create_show
		call pause
		call pause
		ld a,1
		ld (achives+1),a
		ld hl,repeat_game_db
		call en_create_show

eg_check	call mouse_pos
		ld a,(mouse_button)
		cpl
		and #3
		or a
		jr z,eg_check
		cp 1
		jr z,old_score
		call scr_fading
		xor a
		call page
		xor a
		ld (achives+1),a
		jp player_input_name


old_score	ld hl,0
		ld (score),hl
		xor a
		ld (achives+1),a
		inc a
		ld (intro_int+1),a
		call vtmute
		jp repeat_game

new_game	
		xor a
		ld (intro_int+1),a
		inc a
		ld (achives+1),a
		ld hl,win_music
		call init_mus

		ld hl,level_current
		inc (hl)
		ld a,(hl)
		ld hl,(score)
		call pass_code
		ld hl,player_name
		ld de,new_code
		ld bc,6
		ldir
		ld hl,victory
		call en_create_show
		ld hl,achives_adr
		ld (achives_view+1),hl
		ld a,#47
		ld (achiv_clr+1),a
		
achive1		
		ld a,(lives)
		cp #0a		; lives
		jr nz,achive2
		ld hl,aces1	; 	FULL LIFE!
		call achives_view
		ld b,6		; +300 pt
		call update_score

achive2		ld a,(money)
		cp #12
		jr c,achive3
		sub #11
		sra a
		jr z,achive3
;		push af
		ld hl,aces8	; 	RICH MAN! MANY COINS!
		call achives_view
;		pop af
;		ld b,a		; + (moneys - start_money:#0a )*50
achive21	ld hl,money
		dec (hl)
		ld a,(hl)
		or a
		jr z,achive3	
		ld de,money_adr
		call view_dec_energy
		ld hl,(score)
		ld de,10
		add hl,de
		ld (score),hl
		call view_score
		ld b,5
		call pause2

		jr achive21



achive3		ld a,(towers_count)
		add a,a
		ld c,a
		ld a,(tower_upgraded_count)
		cp c
		jr nz,achive4
		ld hl,aces2	; 	100% UPGRADE!
		call achives_view
		ld b,8		; +400 pt
		call update_score

achive4		ld a,(tower_upgraded_count)
		or a
		jr nz,achive5
		ld hl,aces3	; 	0% UPGRADE!
		call achives_view
		ld b,4		; +200 pt
		call update_score

achive5		ld a,(lives)
		cp 1
		jr nz,achive6
		ld hl,aces7		; 	"BRAVE GUY! ONE LIFE ONLY"
		call achives_view
		ld b,10		; +500 pt
		call update_score

achive6		ld a,(towers_count)
		cp 10
		jr c,achive_end

		ld hl,aces4
		ld b,3		; +150 pt
		cp 20
		jr c,achive61
		ld hl,aces5
		ld b,7		; +350 pt
		cp 30
		jr c,achive61
		ld hl,aces5
		ld b,11		; +550 pt
achive61	push bc
		call achives_view
		pop bc
		call update_score
		ld a,2
achive_end
		call key_scan
		or a
		jr z,$-4

		ld hl,(score)
		ld (old_score+1),hl
		xor a
		ld (achives+1),a
		ld a,(level_current)
		cp end_level
		jp z,victory_game
repeat_game	call scr_fading
		ld a,1
		ld (intro_int+1),a
		dec a
		ld (tower_upgraded_count),a
		call vtmute
		ld sp,#7fff
		jp gl_init

victory_game
	

		ld hl,intro_music
		call init_mus
		ld a,7
		call page
		xor a
		ld (intro_int+1),a
		dec a
		ld (lev_view+1),a
		ld (achives+1),a
		call scr_fading

		ld hl,victory_game_over
		call en_create_show

		ld b,9
all_lev_view	push bc

		ld a,7
		call page
		call scr_fading
lev_view	ld a,0
		inc a
		ld (lev_view+1),a
		call level_choice
		ld hl,level_name
		call en_create_show
		xor a
		ld (int_init+1),a

		ld a,4
		call page

		call map_view
		call pause
		pop bc
		djnz all_lev_view

		ld hl,victory_game_over
		call en_create_show

vg1		call key_scan
		or a
		jr z,vg1

		xor a
		call page
;		ld sp,#7fff
		xor a
		ld (achives+1),a
		jp player_input_name


pass_code	ld de,player_name
		ld c,a
		push de
		call decp
		ld l,h
		call decp
		ld a,c
		xor 4
		add #45
		ld (de),a
		pop hl
		push hl
		xor a
		ld b,5
		ld e,(hl)
		add e
		inc hl
		djnz $-3
		ld e,a
		pop hl
		ld b,4
		ld a,(hl)
		xor c
		add #41
		ld (hl),a
		inc hl
		djnz $-6
		inc hl
		ld a,e
		and 7
		add #46
		ld (hl),a
		ret

decp		ld a,l
		and #f0
		rrca
		rrca
		rrca
		rrca
		ld (de),a
		inc de
		ld a,l
		and #0f
		ld (de),a
		inc de
		ret

achives_view	ld de,0
		push hl
		push de
		ld hl,achiv_db
		ld c,#0f
acv2		push de
		ld a,(hl)
		ld (de),a
		inc e
		inc hl
		ld a,(hl)
		ld (de),a
		inc e
		inc hl
		ld b,#0c
		ld a,#ff
		ld (de),a
		inc e
		djnz $-2
		ld a,(hl)
		ld (de),a
		inc e
		inc hl
		ld a,(hl)
		ld (de),a
		inc hl
		pop de
		call incd
		dec c
		jr nz,acv2
		push de
		ld b,#10
		xor a
		ld (de),a
		inc e
		djnz $-2
		pop de
		call incd
		ex de,hl
		ld (achives_view+1),hl
		ex de,hl
		pop hl
		push hl
		ld a,h
	        RRCA
	        RRCA
 	        RRCA
	        AND 3
 	        OR #58
 	        LD h,a
 	        ld b,#10
achiv_clr       ld a,#47
 	        ld (hl),a
 	        inc l
 	        djnz $-2
 	        ld de,#10
 	        add hl,de
 	        ld b,#10
 	        ld (hl),a
 	        inc l
 	        djnz $-2
 	        pop de
 	        pop hl
		call print
		ld hl,achiv_clr+1
		dec (hl)
		ret


update_score	ld a,b
		or a
		ret z
		push bc
		ld hl,(score)
		ld de,50
		add hl,de
		ld (score),hl
		call view_score
		ld b,10
		call pause2
		pop bc
		djnz update_score
		ret


/*
init_sprites	
		ld a,#1
		call page
		ld de,en_fired
		ld hl,en_fired_mask
		ld ix,fired
		call is_chess
		ld de,en_fired_dwn
		ld hl,en_fired_dwn_mask
		call is_chess

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
		ld a,#17
		jp page


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
*/


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


lowbright_atr	
		ld hl,#5800
		ld (mbw_start+1),hl
		ld bc,#2c0
		ld de,map_color
		ldir

		ld bc,#100b
		ld ix,(map)
mbw0		push bc
mbw		ld a,(ix+0)
		cp #ff
		jr nz,mbw2
mbw_start	ld hl,0
		ld e,l
		ld d,h
		set 7,d
		ld a,#41
		ld (hl),a
		ld (de),a
;		res 6,(hl)
		inc l
		inc e
;		res 6,(hl)
		ld (hl),a
		ld (de),a
		ld a,l
		add #1f
		ld l,a
		ld e,a
		ld a,#41
		ld (hl),a
		ld (de),a
;		res 6,(hl)
		inc l
		inc e
		ld (hl),a
		ld (de),a
;		res 6,(hl)

mbw2
		ld hl,(mbw_start+1)
		inc hl
		inc hl
		ld (mbw_start+1),hl
		inc ix
		djnz mbw
		ld hl,(mbw_start+1)
		ld de,#20
		add hl,de
		ld (mbw_start+1),hl
		pop bc
		dec c
		jr nz,mbw0
		ret

		


scr_fading	ei
		ld a,#7f
		ld (fade_clr_and+1),a
		ld b,8
fade_clr2	push bc
		ld hl,#5800
		ld de,#d800
		ld bc,#300
fade_clr1	ld a,(hl)
fade_clr_and	and #7f	
		ld (de),a		;cp 1
		ld (hl),a
		inc hl
		inc de
		dec bc
		ld a,b
		or c
		jr nz,fade_clr1
		halt
		halt
		halt
		halt		
		pop bc
		ld a,(fade_clr_and+1)
		rr a
		ld (fade_clr_and+1),a
		djnz fade_clr2
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



mouse_pressed	ld c,0
		ld a,(mouse_button)
		cpl
		and #3
		or a
		jr nz,mpr0
		ld (mouse_pressed+1),a
		ld a,c
		ret 

mpr0		cp c
		ret z
		ld (mouse_pressed+1),a

		cp 1
		jp nz,rmb2

upgrade_but	ld a,0
		or a
		jr z,tk0
		ld c,a
		xor a
		ld (upgrade_but+1),a
		ld a,(tower_upgrade_flag)
		jp tower_upgrading

tk0		ld hl,(mouse_map)
		ld a,l	;Y
		add a,a
		add a,a
		add a,a		
		add a,a	
		add h	;X
		ld c,a
		cp #ba
		jp z,pause_button_view
		ld a,(tower_preview_range_flag+1)
		or a
		jp nz,set_new_tower
		ld a,(tower_upgrade_flag)
		or a
		jp nz,tower_upgrading
tower_keys	ld a,0
		or a
		jr nz,cmp_towers_ex_keys
		ld a,c
		cp #af
		jp nc,cmp_towers 

		ld hl,(map)
		ld a,c
		add l
		ld l,a
		ld a,(hl)
		cp #ff
		jp nc,rmb2		; #ff - можно ставить башни, else exit

cmp_towers	ld hl,towers	; поиск башни по позиции
mp0		ld a,(hl)
		cp #fe
		jp z,cmp_towers_ex
		ld b,a		; type
		inc hl
		ld a,(hl)	; position
		cp c
		jp z,tower_upgrade_view
mpn0		inc hl
		ld a,(hl)	; range propusk
		cp #ff
		jr nz,mpn0
		inc hl
		jr mp0


cmp_towers_ex 	
		ld a,c
		cp #af
		jp c,rmb2 
		cp #b8
		jp nc,rmb2
cmp_towers_ex_keys
		ld c,a
		xor a
		ld (tower_keys+1),a
		ld a,c
		sub #b0
		rra
		ld hl,tower_list
		ld e,a
		ld d,0
		add hl,de
		ld a,(hl)
		cp #ff
		jp z,rmb2
		ld a,c
		ld (tower_preview_range_flag+1),a
		sub #b0
		and #fe
		add a,a
		add #c0
		ld l,a
		ld h,#5a
		ld e,a
		ld d,#da
		ld bc,#4202
		call block_attr_fill
		jp lowbright_atr

tower_upgrading	ld (tupos+1),a
		ld a,c
		cp #af		
		jp c,rmb2
		ld a,(tower_upgrade_power)
		cp #ff
		jp z,rmb2
		ld a,(tower_upgrade_price)
		ld b,a
		ld a,(money)
		sub b
		jp c,low_money
		ld (money),a
		ld de,money_adr
		push bc
		call view_dec_energy
		pop bc
		ld hl,towers
tu0		inc hl
		ld a,(hl)	; position
tupos		cp 0
		jr z,tower_upgrade1
tun0		inc hl
		ld a,(hl)	; range propusk
		cp #ff
		jr nz,tun0
		inc hl
		jr tu0

tower_upgrade1	inc hl
		inc hl
		inc hl
		inc hl	; power of this tower
		ld a,(tower_upgrade_power)
		ld (hl),a
		call tower_attr_restore
		ld a,(tower_upgrade_flag)
		push af
		call tower_screen_adr
		ld a,h
	        RRCA
	        RRCA
 	        RRCA
	        AND 3
 	        OR #58
 	        LD h,a
 	        ld bc,#21
 	        add hl,bc
 	        or #80
 	        ld d,a
 	        ld e,l
 	        dec (hl)
 	        ex de,hl
 	        dec (hl)
 	        pop af
		
		call tower_attr_store
		xor a
		ld (stat_new_tower_flag+1),a
		call stat_new_tower
		call mouse_store_adr
		ld a,create_tower_sound
		call AFXPLAY
		ld hl,tower_upgraded_count
		inc (hl)
		jp rmb




tower_upgrade_view
		push bc	; in b:type, c:position, in hl- towers+1
		push bc
		push hl
		ld (tower_upgrade_flag),a
		; set on view range and towers
		ld (stat_new_tower_flag+1),a
		ld (tower_upgrade_range_flag+1),a ; pos
		push af
		ld a,b
		ld (tower_upgrade_range_type+1),a ; type
		pop af
		push af
		call tower_attr_restore
		pop af
		call tower_attr_store

		call clear_menu_tower
		ld hl,#5800
		ld de,map_color
		ld bc,#2c0
		ldir

		pop hl
		pop bc
		inc hl
		inc hl
		inc hl
		inc hl	; power of this tower
;		xor a
;		ld (tpr_old+1),a
		ld c,(hl)
		ld hl,tower_upgrade
tuv0		ld e,(hl)	; price
		inc hl
		ld a,(hl)
		cp b
		jr z,tuv2

tuv12		inc hl
		ld a,(hl)
		cp #ff
		jr nz,tuv12

		inc hl
		jr tuv0

tuv2		inc hl
		ld a,(hl)
		cp c
		jr nz,tuv2


tuv21		ld a,e
		ld (tower_upgrade_price),a		
		inc hl
		ld a,(hl)	; in a: new power, e:price
		ld (tower_upgrade_power),a
		cp #ff
		jr nz,tuv24	

		dec hl			; max upgrade
		ld a,(hl)
		ld de,upgrade_power_adr
		push de
		call view_3dec
		pop de
		dec e
		ld a,'F'
		call char_print
		ld de,upgrade_price_adr
		ld a,#2f
		call char_print
		ld a,#2f
		call char_print
		ld a,#ff
		ld (tower_upgrade_price),a
		jr tuv23

tuv24		
		push de
		ld de,upgrade_power_adr
		push de
		call view_3dec
		pop de
		dec e
		ld a,'F'
		call char_print
		pop de
		ld a,e
		ld de,upgrade_price_adr
		call view_dec_energy

		

tuv23		push hl
		push de
		push bc

		call clear_status_attr
		ld hl,upgrade_price_adr-1
		call money_view
/*
		ld de,power_adr-1+#20
		ld b,8
lm2		ld a,(hl)
		ld (de),a
		inc hl
		inc d
		djnz lm2
*/
		ld a,#44
		ld hl,#5ac2
		ld de,#dac2
		call fill_colors
		ld a,#42
		ld l,#e2
		ld e,l
		call fill_colors
		pop bc
		pop de
		pop hl

		pop bc
		ld a,b
		ld (stat_upgrade_flag+1),a
		ld a,(tower_upgrade_price)
		ld c,a
		ld a,(money)
		sub c
		jr c,$+3
		xor a
		ld (st_color+1),a

tuv30
		ld c,b		; вывод типа башни
		ld hl,#50c0
		call view_tower_instatus
		ld (st_clr1+1),hl
		ex de,hl
		ld (st_clr2+1),hl
		jp st_color

stat_upgrade	ld a,(st_color+1)
		ld e,a
		ld a,(tower_upgrade_price)
		ld c,a
		ld a,(money)
		sub c
		jr c,$+3
		xor a
		ld (st_color+1),a
		cp e
		ret z
		xor a
		ld (tower_upgrade_range+1),a
		jr tuv30
		
stat_new_towers	ld a,(st_color+1)
		ld e,a
		ld a,(tower_upgrade_price)
		ld c,a
		ld a,(money)
		sub c
		jr c,$+3
		xor a
		ld (st_color+1),a
		cp e
		ret z

		jr tuv30

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

money_view	ld ix,lovemoney+8
		ld e,l
		ld d,h
		set 7,d
		ld b,8
		ld a,(ix+0)
		ld (de),a
		ld (hl),a
		inc ix
		inc d
		inc h
		djnz $-9
		ret

fill_colors	ld b,4
		ld (hl),a
		ld (de),a
		inc l
		inc e
		djnz $-4
		ret

tower_not_set	ld a,cancel_sound
		jp AFXPLAY



set_new_tower	
		ld hl,towers	; поиск башни по позиции
snt01		ld a,(hl)
		cp #fe
		jr z,begin_set_new_tower
		ld b,a		; type
		inc hl
		ld a,(hl)	; position
		cp c
		jp z,rmb2
snt0		inc hl
		ld a,(hl)	; range propusk
		cp #ff
		jr nz,snt0
		inc hl
		jr snt01


begin_set_new_tower
		ld a,c
		ld hl,(map)
		add l
		ld l,a
		ld a,(hl)
		cp #ff
		jp nz,rmb2		; #ff - можно ставить башни
		push hl
		ld a,c
		ld (new_tower_pos+1),a
		ld a,(tower_preview_range_flag+1)
		sub #b0
		rra
		ld (cmp_towers0+1),a

;		sub #b0
		ld c,a
		ld b,0
		ld hl,tower_price
		add hl,bc
		ld c,(hl)
		pop hl
		ld a,(money)
		sub c
		jr c,low_money
		ld (money),a
		ld (hl),#fe
		ld de,money_adr
		call view_dec_energy
		call tower_preview_range_restore
cmp_towers0	ld c,0
;		sub #b0			; перва€ башн€
					; type
new_tower_pos	ld b,0			; pos

		ld hl,towers_fire_rate
		ld e,c
		ld d,0
		add hl,de
		ld a,(hl)		; fire rate
;				; create tower, b - pos:#21, c - type: 0
		call tower_create
		ld a,(new_tower_pos+1)
		call tower_attr_store
		ld a,create_tower_sound
		call AFXPLAY
		jr rmb

low_money	ld a,#20
		ld (red_money_counter+1),a
		ld a,#42
		call fill_money_atr

rmb2		call tower_not_set
rmb		; exit

rmb1		call tower_preview_range_restore
		ld hl,map_color
		ld de,#5800
		ld bc,#2c0
		push hl
		push bc
		ldir
		pop bc
		pop hl
		ld de,#d800
		ldir

		call tower_attr_restore
		call view_new_towers
		xor a			;exit
		ld (new_tower_create_flag),a	
		ld (tower_upgrade_flag),a
		ld (tower_preview_range_flag+1),a
		ld (stat_new_tower_flag+1),a
		ld (tower_keys+1),a
		dec a
;		ld (stat_new_tower_flag+1),a
		ld (stat_upgrade_flag+1),a
		ld (tower_upgrade_range_flag+1),a
		ld (tower_upgrade_range+1),a
;		ld a,#0f
;		ld (mouse_button),a
		jp mouse_store_adr

tower_attr_store
		call tower_screen_adr
		ld a,h
	        RRCA
	        RRCA
 	        RRCA
	        AND 3
 	        OR #58
 	        LD h,a
		ld b,a
 	        or #80
 	        ld d,a
 	        ld e,l
 	        ld c,l
 	        ex de,hl
       			; hl-attr adr
		ld de,towers_attr	; store atrs db
		ld a,l
		ld (de),a
		inc de
		ld a,h
		ld (de),a
		inc de
		ld a,(hl)
		ld (de),a

		ld a,#47
		ld (hl),a
		ld (bc),a
		inc c
		inc l
		inc de
		ld a,(hl)
		ld (de),a

		ld a,#07
		ld (hl),a
		ld (bc),a
		inc de
		push de
		ld de,#1f
		add hl,de
		pop de
		ld c,l
		ld a,(hl)
		ld (de),a

		ld a,#07
		ld (hl),a
		ld (bc),a
		inc l
		inc c
		inc de
		ld a,(hl)
		ld (de),a

		ld a,#47
		ld (hl),a
		ld (bc),a
		ret


tower_attr_restore
		ld hl,towers_attr	; restore atrs
		ld e,(hl)
		ld c,(hl)
		inc hl
		ld a,(hl)
		ld d,a
		xor #80
		ld b,a
		inc hl
		ld a,(hl)
		ld (de),a
		ld (bc),a
		inc hl
		inc e
		inc c
		ld a,(hl)
		ld (de),a
		ld (bc),a
		inc hl
		push hl
		ex de,hl
		ld de,#1f
		add hl,de
		ex de,hl
		pop hl
		ld c,e
		ld a,(hl)
		ld (de),a
		ld (bc),a
		inc hl
		inc e
		inc c
		ld a,(hl)
		ld (de),a	
		ld (bc),a
		ret

stat_new_tower
			ld a,(money)
stat_new_tower_money	ld e,0
			cp e
			ret z
			ld (stat_new_tower_money+1),a
			xor a
			ld (tpr_old+1),a
			jr st_new_tower



new_tower	ld a,c
		ld (new_tower_create_flag),a
		ld (tower_preview_range_flag+1),a
		push af
		call tower_attr_restore
		pop af
		call tower_attr_store

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


status_tower
			;	ld hl,#50c0
			;	ld b: power, c: price
			;	ld d,0	- type
		ld a,(money)
		sub c
		jr c,$+3
		xor a
		ld (st_color+1),a
		push bc
		push hl
		ld c,d
		call view_tower_instatus
		ld (st_clr1+1),hl
		ex de,hl
		ld (st_clr2+1),hl
		pop hl
		pop bc
		inc l
		inc l
		push bc
		ex de,hl
		ld a,b		; power
		call view_dec_energy
		ex de,hl
		ld de,#1e
		add hl,de
		push hl
		dec l
		call money_view
		pop de
		pop bc
		ld a,c
		call view_dec_energy
st_color	ld a,0
		or a
		ret z		
st_clr1		ld hl,0
st_clr2		ld de,0
 	        ld bc,#4707

block_attr_fill
 	        ld a,b
 	        ld (hl),a
 	        ld (de),a
 	        inc l
 	        inc e
 	        ld a,c
 	        ld (hl),a
 	        ld (de),a
 	        push bc
 	        ld bc,#1f
 	        add hl,bc
 	        pop bc
 	        ld a,c
 	        ld e,l			;!!!! attr
 	        ld (hl),a
 	        ld (de),a
 	        inc e
 	        inc l
 	        ld a,b
 	        ld (hl),a
 	        ld (de),a
 	        ret


mouse_map_adr
		ld hl,(mouse_xy)
		ld a,h
		srl a
		srl a
		srl a		
		srl a
		ld h,a
		ld a,l
		srl a
		srl a
		srl a		
		srl a
		ld l,a
		ld (mouse_map),hl
		ret		

mouse_restore_screen

		ld hl,mouse_screen
		ld a,(active_screen)
		xor #80
mouse_rest_adr	ld de,0
		add d
		ld d,a
		ld b,10
mrs1		ld a,(hl)
		ld (de),a
		inc hl
		inc e
		ld a,(hl)
		ld (de),a
		inc hl
		dec e
		call incd
		djnz mrs1
		ret

mouse_store_adr 
		ld hl,(mouse_xy)
		ld c,l
		ld b,h
		push bc
		srl b
		srl b
		srl b
		srl c
		srl c
		srl c
		call koorp
		pop bc
		ld a,c
		and #07
		add a,h
		ld h,a
		ld (mouse_rest_adr+1),hl
		push hl
		ld de,mouse_screen
		ld a,(active_screen)
		xor #80
		add h
		ld h,a
		push bc
		ld b,10
msa1		ld a,(hl)
		ld (de),a
		inc l
		inc de
		ld a,(hl)
		ld (de),a
		inc de
		dec l
		call inch
		djnz msa1
		pop bc
		pop hl
		ret

mouse_view	
		call mouse_store_adr
		push hl
		ld hl,0		
		ld a,b
		and #07
		or a
		jr z,mvv0
		ld de,40
		add hl,de
		dec a
		jr nz,$-2
mvv0		ld de,mouse_spr
		add hl,de
		pop de
		ld a,(active_screen)
		xor #80
		add d
		ld d,a

		ld b,10
mvv		ld a,(de)
		and (hl)
		inc hl
		or (hl)
		inc hl
		ld (de),a
		inc e
		ld a,(de)
		and (hl)
		inc hl
		or (hl)
		inc hl
		ld (de),a
		dec e
		call incd
		djnz mvv
		ret



mouse_pos	
mouse_update	ld a,0
		or a
		jr nz,key_in
		LD BC,#FADF
		IN A,(C)     ;читаем порт кнопок
		
		
/*
  D0 - лева€ кнопка
  D1 - права€ кнопка
  D2 - средн€€ кнопка

Standard Kempston Mouse
#FADF - buttons
#FBDF - X coord
#FFDF - Y coord
*/
key_in		ld (mouse_button),a
		call key_scan	
ki0		LD hl,MOUSE11+1
		ld a,d
		cp #af
		jr nc,ki5

kileft		and left
		jr z,ki1	
		inc (hl)
		inc (hl)
ki1		ld a,d
kiright		and right
		jr z,ki2
		dec (hl)
		dec (hl)
ki2		LD hl,MOUSE12+1
		ld a,d
kidown		and down
		jr z,ki3
		inc (hl)
		inc (hl)
ki3		ld a,d
kiup		and up
		jr z,ki4
		dec (hl)
		dec (hl)
ki4		ld a,d
		and fire
		or a
		jr z,ki5
		ld a,#0e
		ld (mouse_button),a

ki5		ld a,d
		cp rmb_key
		jr nz,ki8
		ld a,#0d
		ld (mouse_button),a
		jr ki6
		
ki8		call keys_wait_proc
		ld a,d
		cp key_pause
		jp z,pause_button_view

		cp key_tower1
		jr c,ki6
		ld c,a
keys_wait	ld a,0
		or a
		jr z,ki7
		jr ki6

keys_wait_proc	ld a,(keys_wait+1)
		or a
		ret z
		dec a
		ld (keys_wait+1),a
		ret

ki7		ld a,(tower_upgrade_flag)
		or a
		jr z,ki9
		ld a,c
		ld (upgrade_but+1),a
		jr ki10

ki9		ld a,c
		ld (tower_keys+1),a
ki10		xor a
		ld (tpr_old+1),a
		ld a,18
		ld (keys_wait+1),a
		ld a,#0e
		ld (mouse_button),a
ki6
		LD     HL,(mouse_xy)
		LD     BC,#FBDF
mz0		IN     A,(C)
MOUSE11		LD     D,0
		LD     (MOUSE11+1),A
		SUB    D
		CALL   NZ,MOUSE30
		LD     B,#FF
mz1		IN     A,(C)
MOUSE12		LD     D,0
		LD     (MOUSE12+1),A
		SUB    D
		CALL   NZ,MOUSE40
		ld a,h
		cp #f7
		jr c,mouse13
		ld h,#f7
mouse13		ld a,l
		cp #b6
		jr c,mouse14
		ld l,#b6
mouse14		LD     (mouse_xy),HL
		RET

MOUSE30
      JP     M,MOUSE35
      ADD    A,H
      LD     H,A
      RET    NC
      LD     H,#Ff
      RET
MOUSE35
      XOR    #FF
      INC    A
      LD     D,A
      LD     A,H
      SUB    D
      LD     H,A
      RET    NC
      LD     H,0
      RET

MOUSE40
      JP     M,MOUSE45
      LD     E,A
      LD     A,L
      SUB    E
      LD     L,A
      RET    NC
      LD     L,#0
      RET
MOUSE45
      XOR    #FF
      INC    A
      ADD    A,L
      LD     L,A
      RET    NC
      LD     L,#FF
      RET

koorp	ld a,c
	and #18
;	or #c0
	ld h,a
	ld a,c
	and #07
	rrca
	rrca
	rrca
	add a,b
	ld l,a
	ret 	; 14 байт, 53 такта



; ----- alex rider keys

right:			equ #01
left:			equ #02
down:			equ #04
up:			equ #08
fire:			equ #10
rmb_key			equ #f0

key_pause		equ #cf	
key_tower1		equ #b0
key_tower2		equ #b2
key_tower3		equ #b4
key_tower4		equ #b6
key_code		equ #b8

			                     ; in: nothing
                                               ; out:
key_scan                                       ;       d - pressed directions in kempston format
	ld a,#fe                               ; check for CAPS SHIFT
	in a,(#fe)
	rra
	ld hl,key_table - 1         ; selection of appropriate keyboard table
	jr c,.no_cs
	ld hl,cs_key_table - 1      ; hl - keyboard table (zero-limited)
.no_cs:
	ld d,#00                               ; clear key flag
	ld c,#0fe                              ; low address of keyboard port
.loop:
	inc hl                                 ; next key
	ld b,(hl)                              ; high byte of port address from table
	inc b                                  ; end of table check
	dec b
	ret z
	inc hl                                 ; going to key mask
	in a,(c)                               ; reading half-row state
	or (hl)                                ;
	inc hl                                 ; going to key flag
	inc a                                  ; a = half-row state or mask. if #ff - current key isn't pressed
	ld a,d
	jr z,.loop                             ; key isn't pressed
	or (hl)                                ; result or key flag
	ld d,a                                 ; store it
	jr .loop

	; key table format
; 1st byte - high byte of keyboard half-row address
; 2nd byte - inverted key mask (e.g. outer key - #fe, next key - #0fd etc)
; 3rd byte - direction bit

key_table:
	db #0ef, #0fe, fire	;0
	db #0ef, #0fd, up	;9
	db #0ef, #0fb, down	;8
	db #0ef, #0f7, right	;7
	db #0ef, #0ef, left	;6


	db #0f7, #0fe, key_tower1	;1
	db #0f7, #0fd, key_tower2	;2
	db #0f7, #0fb, key_tower3	;3
	db #0f7, #0f7, key_tower4	;4
	db #0f7, #0ef, key_code		;5

	db #0df, #0fe, right	;p
	db #0df, #0fd, left	;o
	db #0fb, #0fe, up	;q
	db #0fd, #0fe, down	;a
	db #07f, #0fb, fire	;m
	db #07f, #0fe, key_pause	;space

	db #000


cs_key_table:
	db #0ef, #0fe, fire	;0
	db #0ef, #0fb, right	;8
	db #0ef, #0f7, up	;7
	db #0ef, #0ef, down	;6
	db #0f7, #0ef, left	;5
	db #07f, #fd , rmb_key	;caps+sym
	db #000


; ---------------- end of alex sources




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

decd    dec d
        LD A,d
	and #07
        cp #7
        ret NZ 
        LD A,e
        sub 32
        LD e,A
        ret c
        LD A,d
        add 8
        LD d,A
	ret



	
;A - номер страницы пам€ти 0..31
page		PUSH AF,BC
                LD (current_page),A
                LD B,A
                LD A,(active_screen)
                DUP 4
                RRCA 
                EDUP 
                XOR #FF
                AND 8
                LD C,A
                LD A,B
                AND 7
                OR C
                OR #10
                LD BC,#7FFD
                OUT (C),A
                POP BC,AF
                
                RET 

current_page    DB 0
active_screen	db #c0

;сделать видимым активный экран и обмен€ть
CHANGE_SCREEN   PUSH AF
                LD A,(active_screen)
                xor #80
                LD (active_screen),A
                POP AF
                RET 

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


pause_button_view
		ld a,#ff
		cpl
		ld (pause_button_view+1),a
		or a
		jr nz,play_button
; pause button
		ld hl,level_adr+3	; #ba
		ld e,l
		ld d,h
		set 7,d
		xor a
		ld (hl),a
		ld (de),a
		inc h
		inc d
		ld b,6
		ld a,#66
		ld (hl),a
		ld (de),a
		inc h
		inc d
		djnz $-4
		ld hl,level_atr+4
		ld (hl),#45
		set 7,h
		ld (hl),#45
		xor a
pause_button_ex	ld (game_pause+1),a
		ld bc,#c000
		dec bc
		ld a,b
		or c
		jr nz,$-3
		jp mouse_store_adr

play_button	ld hl,level_adr+3	; #ba
		ld e,l
		ld d,h
		set 7,d
		ld b,3
		ld a,1
		ld (hl),a
		ld (de),a
		sll a
		inc h
		inc d
		djnz $-6
		ld b,4
		ld (hl),a
		ld (de),a
		srl a
		inc d
		inc h
		djnz $-6
		xor a
		ld (hl),a
		ld (de),a
		ld hl,level_atr+4
		ld a,#46
		ld (hl),a
		set 7,h
		ld (hl),a
		jr pause_button_ex
		

                
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

init_mus	
		ld a,(current_page)
		push af
		push hl
		ld a,3
		call page
		pop hl
		call vt_pl_init
		pop af
		jp page
bend

		include "bin/ayfxplay.a80"

new_wave	db "NEW WAVE",#ff
game_over	DB "GAME OVER, MAN",#ff
new_level 	DB "NEW LEVEL",#ff
victory 	DB "VICTORY!",#fe
		db "CODE "
new_code	db "      ",#ff
repeat_game_db	DB "FIRE TO RESTART",#fe
		db "EXT TO EXIT",#ff
victory_game_over
		DB "CONGRATULATION!",#fe
		db "*WAR IS WON!*",#ff

score_table_head_db
		db "TOP SCORES",#ff

input_player	db "YOUR NAME?",#ff
your_score	db "YOUR SCORE",#ff
inp_help	db "USE O,P,M",#ff
input_code_db	db " TYPE CODE",#ff

aces1		db "FULL LIFE!",#ff
aces2		db "FULL UPGRADE",#ff
aces3		db "NO UPGRADE!",#ff
aces4		db "10 TOWERS",#fe
		db "PERFORMED!",#ff
aces5		db "20 TOWERS",#fe
		db "PERFORMED!",#ff
aces6		db "30 TOWERS",#fe
		db "PERFORMED!",#ff
aces7		db "BRAVE GUY!",#fe
		db "ONE LIFE ONLY",#ff
aces8		db "RICH MAN!",#fe 
		db "MANY COINS!",#ff
;		    -------8-------8-------8-------8

level_current	db 0
waves_counter	db 0
waves_finish	db 0

towers_count		db 0
tower_upgraded_count	db 0
towers_attr		ds 6

new_tower_create_flag	db 0
tower_upgrade_flag	db 0
tower_upgrade_price	db 0
tower_upgrade_power	db 0

tower_list	ds 5

towers_fire_rate	; fire rate
		db #1a,#14,#0e,#20

;		power of fire
tower_char	db 8
		db 5
		db 4
		db 60

	    	; power of upgrade
	    	;price,type, level2, level3, end
tower_upgrade	db 5, 0, 8, 11,20,#ff
		db 8, 1, 5, 9, 14,#ff
		db 12,2, 4, 6, 9, #ff
		db 5, 3, 60, 120, 190,#ff		

tower_price	db #08, #0c, #14, #0a
tower_view_adr	dw #50c0,#50c4,#50c8,#50cc




tower_range1	db -17,-16,-15,-1,1,15,16,17,#80
tower_range2	db -33,-32,-31,-18,-17,-16,-15,-14,-2,-1,1,2,14,15,16,17,18,31,32,33,#80
tower_range3	db -49,-48,-47,-34,-33,-32,-31,-30,-19,-18,-17,-16,-15,-14,-13,-3,-2,-1,1,2,3,13,14,15,16,17,18,19,30,31,32,33,34,47,48,49,#80
; tower_range4	= tower_range1

;	position on way, num_spr, napravlenie, scr_adr, wait low,high, type, energy, fired
;	0		 1	  2		3,4		5,6	7	8,9	10
enemy
	ds 11*128
/*
	db 0,0,1,0,#40,01,0, 0,#ff, 0
	db 0,0,1,0,#40,#80,0 ,1,#ff, 0
	db 0,0,1,0,#40,#c0,0 ,2,#ff, 0
	db 0,0,1,0,#40,20,1 ,3,#ff, 0
*/
enemy_count
	db 1

enemy_list ds 16

screen_ready	db 1
mouse_button	db 0
/*
  D0 - лева€ кнопка
  D1 - права€ кнопка
  D2 - средн€€ кнопка
*/

mouse_xy	dw 0
	; l - X, h- Y
mouse_map	dw 0
mouse_switch	db #ff
mouse_spr	include "spr/mouse_spr.asm"
mouse_screen	ds #14
enemy_gfx	dw enemy_sprite1,enemy_sprite2,enemy_sprite3,enemy_sprite4,enemy_sprite5,enemy_sprite6
enemy_pages 	db 1,1,1,6,6,6
; sprite moves:      right (4*32*4)	 left down up
enemy_moves	dw #400,0,#800,#c00
enemy_lives	db 4, 12, 22, 36, 64,128


scr_adr	ds 16*12*2

sprbuffer	ds 8*32
		dw 0



base_tower_db	ds 5*36

lovemoney defb #00, #6C, #FE, #FA, #74, #29, #12, #04, #00, #04, #7E, #68, #7E, #16, #7E, #20

lives		db 0
money		db 0
score		db 0,0
map		dw 0

player_name	ds 8		
cur_player_char	db "A"

achiv_db
	defb #04, #1F, #F8, #60
	defb #06, #3F,#FC, #E0
	defb #07, #33, #81, #E0
	defb #07, #8D,  #BF, #E0
	defb #07, #FD, #BF, #F0
	defb #0F, #FB,  #DF, #F8
	defb #7F, #FB,  #DF, #FF
	defb #FF, #F7,  #EF, #FE
	defb #3F, #F7,  #DF, #F8
	defb #0F, #FB,  #DF, #F0
	defb #0F, #FB,  #DF, #E0
	defb #07, #FD,  #BD, #E0
	defb #07, #05,  #80, #E0
	defb #06, #3B,  #FC, #20
	defb #04, #1F,  #F8, #00


; --------- INTRO MENU -----------------------




		page 0
		org #c000
intro		
		xor a
		ld (intro_int+1),a
;		ld a,8
		ld (level_current),a
		ld hl,intro_music
		call init_mus
		call view_intro_screen

intro_view	ld a,1
		or a
		call z,clr_intro_text
		xor a
		ld (char_print_48_inv),a
		ld (intro_view+1),a
		ld hl,intro_text1
		ld de,intro_text1_adr
		call print

/*
		ld hl,#49b5
		ld bc,#0207
		ld a,(mouse_switch+1)
		or a
		jr z,ms_fill-1
		ld l,#b8
		ld b,3
		ld e,l
ms_fill		push bc
		ld l,e
		ld a,(hl)
		cpl
		ld (hl),a
		inc l
		djnz $-4
		pop bc
		inc h
		dec c
		jr nz,ms_fill
*/
		ld hl,intro_text2_adr+3
		ld de,intro_text1_buf
		ld bc,#0a20
itb2		push hl
		push bc
itb1		ld a,(hl)
		ld (de),a
		inc l
		inc de
		djnz itb1
		pop bc
		pop hl
		call inch
		dec c
		jr nz,itb2
		ld a,#2f
		ld (char_print_48_inv),a
		ei
intro_scan	halt
		call intro_counter
		or a
		jp z,pl_ex

diz1		ld hl,dizer
		dec l
		dec l
		ld (diz1+1),hl
		ld ix,intro_text1_buf
		ld de,intro_text2_adr+3
		ld bc,#0a20
itb21		push de
		push bc
itb11		ld a,(ix+0)
		and (hl)
		ld (de),a
		inc ix
		inc e
		inc l
		djnz itb11
		ld a,l
		add a,5
		ld l,a
		pop bc
		pop de
		call incd
		dec c
		jr nz,itb21
		ld a,(mouse_switch)
		or a
		jr nz,pl_ex4
		LD BC,#FADF
		IN A,(C)
		cpl
		and 3
		cp 1
		jp z,start_game
pl_ex4		call key_scan
		or a
		jr z,intro_scan
	
		cp fire
		jp z,start_game

		cp key_tower1
		jp z,start_game
		cp key_tower2
		jr z,help
		cp key_tower3
		jp z,credits
		cp key_tower4
		jp z,input_code
mouse_check_filled
		cp key_code
		jp z,mouse_turn
		jr intro_scan

input_code
		xor a
		ld (char_print_48_inv),a
		call clr_intro_text
		ld hl,input_code_db
		ld de,input_player_adr
		call print
		ld a,low player_name_adr+6
		ld (pn_sym+1),a
		call input_text
		call pass_decode
		ld a,c
		or a
		jr z,not_level
		cp end_level
		jr nc,not_level
		ex de,hl
		ld (score),hl
		ld a,#2f
		ld (char_print_48_inv),a
		ld a,c
		ld (level_current),a
		jp start_game

not_level	xor a
		ld (intro_view+1),a
		call intro_counter_init
		ld hl,#59d4
		ld b,#0a
		ld (hl),#46
		inc l
		djnz $-3
		jp intro_view



mouse_turn	ld a,(mouse_switch)
		cpl
		ld (mouse_switch),a
		ld hl,"FF"
		or a
		jr nz,ms_ex
		ld hl," N"
ms_ex		ld (mouse_status),hl
		xor a
		ld (intro_view+1),a


		call intro_counter_init
		jp intro_view

help		call clr_attr
		ld a,1
		ld (intro_view+1),a
		xor a
		ld (char_print_48_inv),a
		ld hl,helper
		ld (hev0+1),hl
		call help_pic
		call hev_in_buf
;		LD A,#43
;		LD (#58A9),A
		call pause
help_scan	halt
		call help_view
		cp #fe
		jp z,intro
		call key_scan
		or a
		jr z,help_scan
		jp intro
		
help_view	ld hl,1
		dec hl
		ld a,h
		or l
		jr z,hev01
		ld (help_view+1),hl
		ret

hev01		ld hl,20
		ld (help_view+1),hl
hev0		ld hl,helper
		ld a,(hl)
		cp #fe
		ret z
hev1		ld de,#4c28
		push hl
		push de
		call hev_clear
		pop de
		pop hl
		
		call print
		inc hl
		ld e,(hl)
		inc hl
		ld d,(hl)
		inc hl
		ld a,(hl)
		inc hl
		push hl
		call help_arrow_view
		pop hl
		ld (hev0+1),hl
		xor a
		ret

hev_buf		equ new_wave_old_clr

hev_clear	ld hl,hev_buf
		ld bc,#1008
hev_clear1	push de
		push bc
		ld a,(hl)
		ld (de),a
		inc hl
		inc e
		djnz $-4
		pop bc
		pop de
		call incd
		dec c
		jr nz,hev_clear1
		ret

hev_in_buf	ld hl,#4c28
		ld de,hev_buf
		ld bc,#1008
hev_ib1		push hl
		push bc
		ld a,(hl)
		ld (de),a
		inc l
		inc de
		djnz $-4
		pop bc
		pop hl
		call inch
		dec c
		jr nz,hev_ib1
		ret

help_arrow_view
		ld l,a
		ld h,0
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		ld bc,help_arrow_db
		add hl,bc
		ld b,8
		push de
havc		ld a,(de)
		and (hl)
		inc hl
		or (hl)
		inc hl
		ld (de),a
		inc d
		djnz havc
		pop hl
		ld a,h
	        RRCA
	        RRCA
 	        RRCA
	        AND 3
 	        OR #58
 	        LD h,a
 	        ld b,4
 	        ld a,(hl)
havclrwait	push bc
 	        ld (hl),#46
 	        ld b,3
 	        call pause
 	        ld (hl),#41
 	        ld b,3
 	        call pause
 	        pop bc
 	        djnz havclrwait
 	        ld (hl),a
		ret

helper
		;   01234567890123456
		db "THIS IS ENEMY"		; text
		db #ff
		dw #409c	;adr
		db 0		; spr

		;   01234567890123456
		db "ENEMY COME FROM"		; text
		db #ff
		dw #506c	;adr
		db 2		; spr

		;   01234567890123456
		db "DEFEND YOUR BASE"		; text
		db #ff
		dw #509c	;adr
		db 2		; spr

		;   01234567890123456
		db "WITH TOWERS"		; text
		db #ff
		dw #483c	;adr
		db 2		; spr

		;   01234567890123456
		db "BUY: KEYS 1:4"		; text
		db #ff
		dw #50a6	;adr
		db 2		; spr

		;   01234567890123456
		db "USE POINTER"		; text
		db #ff
		dw #4077	;adr
		db 0		; spr

		;   01234567890123456
		db "KEMPSTON MOUSE"		; text
		db #ff
		dw #4035	;adr
		db 3		; spr

		;   01234567890123456
		db "Q,A,O,P,M,EXT"
		db #ff
		dw #4038	;adr
		db 2		; spr

		;   01234567890123456
		db "GUN TOWERS"		; text
		db #ff
		dw #50a5	;adr
		db 2		; spr

		;   01234567890123456
		db "FREEZER TOWER"		; text
		db #ff
		dw #50ae	;adr
		db 2		; spr

		;   01234567890123456
		db "FORCE OF TOWER"		; text
		db #ff
		dw #50A4	;adr
		db 2		; spr

		;   01234567890123456
		db "TOWER COST "		; text
		db #ff
		dw #50c4	;adr
		db 2		; spr

		;   01234567890123456
		db "CURRENT LEVEL"		; text
		db #ff
		dw #50B0	;adr
		db 3		; spr

		;   01234567890123456
		db "YOUR SCORE"		; text
		db #ff
		dw #50D0	;adr
		db 3		; spr

		;   01234567890123456
		db "SPACE TO PAUSE"		; text
		db #ff
		dw #50B4	;adr
		db 3		; spr

		;   01234567890123456
		db "CURRENT WAVE"		; text
		db #ff
		dw #50B6	;adr
		db 3		; spr

		;   01234567890123456
		db "ALL WAVES"		; text
		db #ff
		dw #50B9	;adr
		db 3		; spr

		;   01234567890123456
		db "ENEMY KILLED"		; text
		db #ff
		dw #50D6	;adr
		db 3		; spr

		;   01234567890123456
		db "YOUR LIVES"		; text
		db #ff
		dw #50Be	;adr
		db 2		; spr

		;   01234567890123456
		db "YOUR MONEY"		; text
		db #ff
		dw #50DC	;adr
		db 3		; spr

		;   01234567890123456
		db "BUY TOWERS"		; text
		db #ff
		dw #50A1	;adr
		db 2		; spr

		;   01234567890123456
		db "INSTALL TOWERS"		; text
		db #ff
		dw #4865	;adr
		db 3		; spr

		;   01234567890123456
		db "UPGRADE TOWERS"		; text
		db #ff
		dw #4067	;adr
		db 3		; spr

		;   01234567890123456
		db "AND KILL ENEMY!"		; text
		db #ff
		dw #409C	;adr
		db 0		; spr

		;   01234567890123456
		db "USE TURBO 7MGZ"		; text
		db #ff
		dw #009C	;adr
		db 0		; spr

		;   01234567890123456
		db "GOOD LUCK!"		; text
		db #ff
		dw #009C	;adr
		db 0		; spr
		DB #FE


pass_decode	ld hl,player_name+4
		ld a,(hl)
		sub #45
		xor 4
		ld (pass_lev+1),a
		ld c,a	; level
		ld b,4

pd1		dec hl
		ld a,(hl)
		sub #41
		xor c
		ld (hl),a
		djnz pd1
		ld de,0
		push hl
		ld a,(hl)
		rlca
		rlca
		rlca
		rlca
		ld e,a
		inc hl
		ld a,(hl)
		or e
		ld e,a
		inc hl
		ld a,(hl)
		rlca
		rlca
		rlca
		rlca
		ld d,a
		inc hl
		ld a,(hl)
		or d
		ld d,a
		pop hl
		
		xor a
		ld b,5
		ld c,(hl)
		add c
		inc hl
		djnz $-3
		and 7
		add #46
pass_lev	ld c,0
		ld b,(hl)
		cp b
		ret z
		xor a
		ld c,a
		ld d,a
		ld e,a
		ret





start_game	call vtmute
		jp gl_init

intro_counter	ld hl,500
		dec hl
		ld (intro_counter+1),hl
		ld a,h
		or l
		ret nz
intro_counter_init
		ld hl,500
		ld (intro_counter+1),hl
		ret



credits		ld b,10
		call pause2
		call intro_counter_init
		ld a,#46
		ld (#5a1d),a
		ld a,#ff
		ld (cred_print+1),a
		call clr_intro_text
		call cred_inits
credits_flow	
		halt
credits_flow_v	ld a,0
		dec a
		and 3
		ld (credits_flow_v+1),a
		jr nz,credits_flow
		call cred_print
		call cred_flow
		LD BC,#FADF
		IN A,(C)
		cpl
		and 3
		cp 1
		jp z,intro_view

		call key_scan
		or a
		jp z,credits_flow
		jp intro_view


cred_print	ld a,#ff
		inc a
		and 7
		ld (cred_print+1),a
		call z,cred_new_line
cred_view	ld hl,credits_text_db
		ld a,(cred_print+1)
		ld e,a
		ld d,0
		add hl,de
		ld de,#5612
		ld bc,8
		dup #0E
		ld a,(hl)
		ld (de),a
		add hl,bc
		inc e
		edup
		ret

cred_new_line	ld hl,credits_text
		ld a,(hl)
		inc hl
		ld (cred_new_line+1),hl
		cp #fe
		jr z,cred_new_line2
		cp #ff
		jr nz,cred_new_line1
cred_inits	ld hl,credits_text
		ld (cred_new_line+1),hl
cred_new_line2	ld hl,credits_text_db
		ld (crbufadr+1),hl
		ret 

cred_new_line1	call char_adr
crbufadr	ld de,credits_text_db	
		ex de,hl
		dup 8
	        ld a,(de)
	        ld (hl),a
	        inc hl
	        inc de
	        edup
	        ld (crbufadr+1),hl
	        jr cred_new_line
		

credits_adr_from	equ #40B2
credits_adr_to		equ #4792

cred_flow	ld hl,credits_adr_from
		ld (cred_adr_fr+1),hl
		ld hl,credits_adr_to
		ld (cred_adr_to+1),hl
		ld a,#5f
		ld (cred_cnt+1),a
		ld (cred_sp+1),sp
cred_flow1	
cred_adr_fr 	ld hl,0
		call inch
		ld (cred_adr_fr+1),hl
		ld (cred_adr_1+1),hl
cred_adr_to	ld hl,0
		call inch
		ld (cred_adr_to+1),hl
		ld de,#0e
		add hl,de
		
		ld (cred_adr_2+1),hl

cred_adr_1	ld sp,0
		pop hl
		pop de
		pop bc
		pop af
		exx
		pop hl
		pop de
		pop bc
cred_adr_2	ld sp,0
		push bc
		push de
		push hl
		exx
		push af
		push bc
		push de
		push hl
cred_sp		ld sp,0
cred_cnt	ld a,0
		dec a
		ld (cred_cnt+1),a
		jr nz,cred_flow1
		ret

clr_attr	ld hl,#5800
		ld de,#5801
		ld bc,#2ff
		ld (hl),l
		ldir
		ret

view_intro_screen
		call clr_attr
		jp intro_screen



player_input_name
		xor a
		ld (char_print_48_inv),a
		ld (intro_int+1),a
		ld hl,hiscore_music
		call init_mus
		call view_intro_screen
		ei
		ld hl,(top_players_end)
		ex de,hl
		ld hl,(score)
		or a
		sbc hl,de
		jp c,pl_ex

		call input_name
pl_entered	
		ld hl,intro_music
		call init_mus
		ld hl,#59d4
		ld b,#0a
		ld (hl),#46
		inc l
		djnz $-3
		ld ix,top_players+8
		ld b,0
pl_e1		ld hl,(score)
		ld e,(ix+0)
		ld d,(ix+1)
		or a
		sbc hl,de
		jr nc,pl_score
		ld de,10
		add ix,de
		inc b
		ld a,b
		cp 8
		jr nz,pl_e1
		jr pl_ex

pl_score	push ix
		pop hl
		ld de,8
		sbc hl,de
		push hl
		ld a,8
		sub b
		ld c,a
		ld de,top_players+(10*8)-1
		ld hl,top_players+(10*7)-1
pl_s2		ld b,10
		ld a,(hl)
		ld (de),a
		dec hl
		dec de
		djnz $-4
		dec c
		jr nz,pl_s2
		inc de
		ld hl,player_name
		ld bc,8
		ldir
		ld hl,(score)
		ld a,l
		ld (de),a
		inc de
		ld a,h
		ld (de),a

pl_ex		xor a
		ld (char_print_48_inv),a
		ld (level_current),a
		ld l,a
		ld h,a
		ld (score),hl

		call clr_intro_text
		call hiscore_view
		call pause
		ld a,#2f
		ld (char_print_48_inv),a
pl_ex2		halt
tsclr		ld a,#47
		xor 4
		ld (tsclr+1),a
		call top_scores_clr
		call intro_counter
		or a
		jp z,intro_view
		ld a,(mouse_switch)
		or a
		jr nz,pl_ex3
		LD BC,#FADF
		IN A,(C)
		cpl
		and 3
		cp 1
		jp z,intro_view

pl_ex3		call key_scan
		or a
		jr z,pl_ex2
		jp intro_view


clr_intro_text	ld b,#e
cit0		push bc
		ld hl,#40b2
		ld bc,#0d5f
cit1		ld d,h
		ld e,l
		inc e
		push hl
		push bc
		ld a,(de)
		ld (hl),a
		inc e
		inc l
		djnz $-4
		ld (hl),0
		pop bc
		pop hl
		call inch
		dec c
		jr nz,cit1
		halt
		pop bc
		djnz cit0
		ld a,#46
top_scores_clr	ld hl,#58d3
		ld b,10
		ld (hl),a
		inc l
		djnz $-2
		ret

input_name	
		ld hl,your_score
		ld de,your_score_adr
		call print
		ld hl,score
		ld de,score_view_adr
		call print_hex_48
		ld hl,input_player
		ld de,input_player_adr
		call print
		ld a,low player_name_adr+8
		ld (pn_sym+1),a
input_text	ld hl,inp_help
		ld de,inp_help_adr
		call print
		ld hl,#59d4
		ld b,#0a
		ld (hl),1
		inc l
		djnz $-3

		ld hl,player_name
		ld (pn_adr+1),hl
		ld hl,player_name_adr
		ld (pl_scan3+1),hl
pl_scan30	ld a,(cur_player_char)
pl_scan3	ld de,player_name_adr
		call char_print_48
		ld a,"*"
		call char_print_48

pl_scan		call key_scan
		ld d,a
		or a
		jr z,pl_scan4
		and fire
		jr z,pl_scan4

		ld a,(cur_player_char)
pn_adr		ld hl,player_name
		ld (hl),a
		inc hl
		ld (pn_adr+1),hl
		ld hl,(pl_scan3+1)
		inc hl
		ld a,l
pn_sym		cp low player_name_adr+8
		ret z
		ld (pl_scan3+1),hl
		ld b,8
		call pause2
		jr pl_scan30

pl_scan4	ld a,d
		and right
		jr z,pl_scan2
		ld a,(cur_player_char)
		inc a
		cp #5b
		jr z,pl_scan31
		ld (cur_player_char),a
		jr pl_scan31

pl_scan2
		ld a,d
		and left
		jr z,pl_scan31
		ld a,(cur_player_char)
		dec a
		cp #3f
		jr z,pl_scan31
		ld (cur_player_char),a

pl_scan31	halt
		halt
		halt
		halt
		jr pl_scan30


/*

clr_intro_text	ld hl,#40b2
		ld bc,#0e5f
cit1		push hl
		push bc
		xor a
		ld (hl),a
		inc l
		djnz $-2
		halt
		pop bc
		pop hl
		call inch
		dec c
		jr nz,cit1
		ld a,#46
		call top_scores_clr
		ret
*/


hiscore_view	

		ld hl,#481a
		ld b,#40
hvc1		ld (hl),0
		call inch
		djnz hvc1
		ld hl,score_table_head_db
		ld de,score_table_header
		call print
		ld hl,top_players
		ld de,score_table_adr
		ld c,8
hv0		push bc
		ld b,8
hv1		ld a,(hl)
		inc hl
		push hl
		call char_print_48
		pop hl
		djnz hv1
		inc e
		push hl
		call print_hex_48
		pop hl
		inc hl
		inc hl
		ex de,hl
		ld bc,#12
		add hl,bc
		ex de,hl
		pop bc
		dec c
		jr nz,hv0
		ret


	
		
print_hex_48	ld a,(hl)
		inc hl
		ld h,(hl)
		ld l,a
		ld	bc,-10000
		call	Num1
		call char_print_48
		ld	bc,-1000
		call	Num1
		call char_print_48
		ld	bc,-100
		call	Num1
		call char_print_48
		ld	c,-10
		call	Num1
		call char_print_48
		ld	c,-1
		call Num1
		jp char_print_48

/*
print_hex_48	inc hl
		ld a,(hl)
		push hl
		call print_hex_481
		pop hl
		dec hl
		ld a,(hl)

print_hex_481
	        push af
	        and #f0
	        rr a
	        rr a
	        rr a
	        rr a
	        call print_hex_482
	        pop af
	        and #0f
*/
/*
char_print_48	push af
		push hl
		push de
		push bc
		call char_adr
	        dup 8
	        ld a,(hl)
	        ld (de),a
	        inc hl
	        inc d
	        edup
	        pop bc
	        pop de
	        inc e
	        pop hl
	        pop af
	        ret
*/
print_hex_482	

		push de
		call char_adr
	        dup 8
	        ld a,(hl)
	        ld (de),a
	        inc hl
	        inc d
	        edup
	        pop de
	        inc e
	        ret


top_players	db "INTRSPEC"
		dw 190
		db "SANCHEZ "		
		dw 180
		db "AAA     "
		dw 170
		db "ROBUS   "
		dw 160
		db "GRACHEV "
		dw 150
		db "SLIDER  "
		dw 140
		db "JERRI   "
		dw 130
		db "GOBLIN  "
top_players_end	dw 120

intro_text1	db " )",#fe,#fe
		db "1 NEW GAME",#fe
		db "2 HELP",#fe
		db "3 CREDITS",#fe
		db "4 CODE",#fe,#fe
intro_text_mouse_check
		db "5 MOUSE",#fe
		db " O"
mouse_status	db "FF",#fe,#fe

		db " *",#ff


credits_text_db	equ map_mem+#100
		;   012345678901234
credits_text	db "CAPTAIN DREXX  ",#FE
		db "/////////////  ",#FE
		db "TOWER DEFENCE  ",#FE
		db " ) GAME BY )   ",#FE
		db "  HACKER VBI   ",#FE
		db "     2014      ",#FE
		db "               ",#FE
		db "  MUSIC BY     ",#FE
		db "BRIGHTENTAYLE  ",#FE
		db "               ",#FE
		db "AYFX BY SHIRU  ",#FE
		db "               ",#FE
		db "  SPRITES BY   ",#FE
		db "JAVIER ALKANIZ ",#fe
		db "               ",#FE
		db " GRAPHICS BY   ",#FE
		db "CRASH NICKER   ",#FE
		db "     AAA       ",#fe
;		db " * * AND * *   ",#FE
;		db "MARTIN SEVERN  ",#fe
;		db "RAFFAELE CECCO ",#fe
		db "               ",#FE
		db "               ",#FE
		db "////////////// ",#FE
		db "FOR MY FAMILY  ",#FE
		db " +JULIA+LILI+  ",#FE
		db "////////////// ",#FE
		db "               ",#FE
		db "   THANKS TO   ",#FE
		db "    SANCHEZ    ",#FE
		db "   INTROSPEC   ",#FE
		db "     ROBUS     ",#FE
		db " FOR TECH HELP ",#FE
		db "               ",#FE
		db " AND ALL FROM  ",#FE
		db "   ZX.PK.RU    ",#FE
		db "  TSLABS.INFO  ",#FE
		db "  FOR SUPPORT  ",#FE
		db "               ",#FE
		db "      WWW      ",#FE
		db " ZX.KANIV.NET  ",#FE
		db " WAYBESTER)    ",#FE
		db "     GMAIL.COM ",#FE
		DB "               ",#FF

; ASM data file from a ZX-Paintbrush picture with 16 x 32 pixels (= 2 x 4 characters)

; line based output of pixel data:
help_arrow_db
	defb #01, #00, #00, #7E, #01, #7C, #03, #78, #07, #70, #0F, #60, #1F, #40, #BF, #00
	defb #80, #00, #00, #7E, #80, #3E, #C0, #1E, #E0, #0E, #F0, #06, #F8, #02, #FD, #00
	defb #BF, #00, #1F, #40, #0F, #60, #07, #70, #03, #78, #01, #7C, #00, #7E, #01, #00
	defb #FD, #00, #F8, #02, #F0, #06, #E0, #0E, #C0, #1E, #80, #3E, #00, #7E, #80, #00
ends
	display bend-start
	display ends

intro_text1_buf	equ map_mem ;ds 10*8*3


sfxbank		incbin "bin/td.afb"
window_back	include "spr/window.asm"

tower_gfx	include "spr/tower02.asm"
		include "spr/tower03.asm"
		include "spr/tower01.asm"
		include "spr/tower4.asm"

font	 	include  "spr/font.asm"
	org #6000-#2c0
tower_atr_db	

		org #b590
vtinit		inchob "bin/vtplayer.$C" ; b590, #086e
vt_pl_init	equ vtinit+3
vtplayer	equ vtinit+5
vtmute		equ vtinit+8

		org #cc80
help_pic	inchob "spr/helpp.$C"
		org #df00
dizer		incbin "bin/diz.C"

		org #e000
intro_screen 	inchob "spr/in.$C"



		page 1
		org #c000
enemy_sprite1	incbin "bin/kb.bin"
enemy_sprite2	incbin "bin/egg.bin"
enemy_sprite3	incbin "bin/_javi_dog.bin"
fired		incbin "bin/_explode.bin"		
fired_dwn	equ fired+#800





		page 6
		org #c000
enemy_sprite4	incbin "bin/_javi_tank.bin"
enemy_sprite5	incbin "bin/_javi_soldier.bin"
enemy_sprite6	incbin "bin/king.bin"
;enemy_sprite5	incbin "bin/_enemy_rex_soldier.bin"
;enemy_sprite6	incbin "bin/_enemy_rex_tank.bin"


		page 4
		org #c000
tiles		incbin "bin/tiles.C"		;	lenght 9216


		page 3		; LEVELz
		org levels_mem
		include "levels/all_levels.asm"

		; #1dc0
		org #de00
die_music
		inchob "bin/CptDREXX-GO.$m"

win_music
		inchob "bin/CptDREXX-WIN.$m"

hiscore_music
		inchob "bin/CptDREXX-HI.$m"

intro_music
		inchob "bin/CptDREXX_kinda_full.$m"
mus_end
       savesna "td.sna",start
       