		device zxspectrum128
	        org #8000

INT_VECTOR      	equ #B700 ;размер #1C0
num_enemy_sprites	equ 7
lives_adr		equ #50de
money_adr		equ #50fe
wave_view_adr		equ #50f7
waves_adr		equ #50d7
score_adr		equ #50f1
level_adr		equ #50d2
upgrade_power_adr	equ #50e3
upgrade_price_adr	equ #50c3

level_atr	equ #5ad1
lives_atr	equ #5add
money_atr	equ #5afd
waves_atr	equ #5ad9
score_atr	equ #5af1
wave_view_atr	equ #5af7

back_sprites 		equ #6000
back_sprites_offset	equ #800
map_mem			equ #7000
map_color		equ #6100
towers			equ map_mem+#300
		;	position, type
levels_mem		equ #c000
levels_offset		equ #200

way		equ map_mem
way_begin	equ map_mem+#1f0
way_end		equ map_mem+#1f1
way_begin_adr	equ map_mem+#1f2
waves		equ map_mem+#100

create_tower_sound	equ 4
create_wave_sound	equ 6
cancel_sound		equ 7
enemy_finish_sound	equ 8


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
		di
		ld sp,#7fff
		call mouse_pos
;		call init_sprites
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
                EI 
gl_init		call init_game


game_loop	
		ld a,1
		ld (screen_ready),a
		dec a
		ld (int_calk+1),a
		ld a,2
;		out (#fe),a
		call restore_view
		call base_damage_view
end_wave	ld a,1
		or a
		call nz,enemy_create

		ld a,3		
;		out (#fe),a
		call enemy_pos

		ld a,4
;		out (#fe),a
		call spr_store

		ld a,5
;		out (#fe),a
		call spr_view

		ld a,6
;		out (#fe),a
		call towers_fire
		ld a,7
;		out (#fe),a
		call tower_fires_view
		xor a
		ld (screen_ready),a
;		out (#fe),a
		halt
gl_halt1	ld a,(int_calk+1)
		cp 2
		jr nc,game_loop
		halt
	        jp game_loop



interrupt	di
		push af
		push hl
		push de
		push bc
		push ix
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

stat_new_tower_flag		
		ld a,#ff
		or a
		call z,stat_new_tower

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

towers_fading	ld a,#ff
		or a
		call nz,tower_view_fade
		ld a,(end_wave+1)		; fix 
		or a
		call z, mouse_view		

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
		ei
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

tur3		ld ix,tower_range3

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
		cp #af		
		jr c,tower_preview_range_ex

tpr_old		cp #0
		ret z
		ld (tpr_old+1),a

		push af
		call tower_preview_range_restore
		call tower_preview_range_store
		pop af
		sub #b0
		rrca

		cp 3
		ret nc
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
prev_color	ld a,b
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

tpr3		ld ix,tower_range3

tpr					; всего три башни по range
		ld a,(ix+0)
		cp #80
		ret z
		ld c,a
		ld a,(new_tower_create_flag)
		sub c
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
		inc ix
		jr tpr

tower_preview_range_ex
		ld (tpr_old+1),a
		jp tower_preview_range_restore

tower_preview_range_store
		ld a,1
		ld (tower_preview_range_restore+1),a
		call tower_pos_attr
		push hl
		push de
		ld de,tower_atr_db
		ld hl,#5800
		ld bc,704
		ldir

/*
		ld de,tower_atr_db
		ld bc,#0c0c
tprs2		push bc
tprs1		ld a,(hl)
		ld (de),a
		inc l
		inc de
		djnz tprs1
		ld bc,#20-6
		add hl,bc
		pop bc
		dec c
		jr nz,tprs2
*/

		pop de
		pop hl
		ret


tower_preview_range_restore

		ld a,0
		or a
		ret z
		ld hl,tower_atr_db
		ld de,#5800
		ld bc,704
		push hl
		push bc
		ldir
		pop bc
		pop hl
		ld de,#d800
		ldir
/*
		call tower_pos_attr
		ld ix,tower_atr_db
		ld bc,#0c0c
tprr2		push bc
tprr1		ld a,(ix+0)
		ld (de),a
		ld (hl),a
		inc ix
		inc e
		inc l
		djnz tprr1
		ld bc,#20-6
		add hl,bc
		ex de,hl
		add hl,bc
		ex de,hl
		pop bc
		dec c
		jr nz,tprr2
*/
		xor a
		ld (tower_preview_range_restore+1),a
		ret

tower_pos_attr
		ld a,(new_tower_create_flag)
		ld c,a
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


vtc_chunk_color_init
		xor a
		ld (vtc_chunk+1),a
		ld (towers_fading+1),a
		ld a,16
		ld (vtc1_chunk+1),a
		ret

tower_view_fade
vtc_chunk	ld a,0
		inc a
		ld (vtc_chunk+1),a
		cp #3d
		jr nz,vtc0_chunk

		call vtc_chunk_color_init

vtc0_chunk	

		ld hl,chunks
		ld e,a
		ld d,0
		add hl,de
		push hl
		pop ix
		ld de,#50c0
		ld hl,#d0c0
		
		ld b,#10
vtc1		push bc
		ld a,(ix+0)
		ld c,a
		ld b,e

		dup 12
		ld a,(de)
		and c
		ld (de),a
		ld (hl),a
		inc e
		inc l
		edup

		ld e,b
		call incd
		ld l,e
		ld h,d
		set 7,h
		ld bc,6
		add ix,bc
		pop bc
		dec b
		jp nz,vtc1

vtc_chunk_clr	ld a,0
		dec a
		and 3
		ld (vtc_chunk_clr+1),a
		ret nz
vtc1_chunk	ld a,15
		dec a
		ld (vtc1_chunk+1),a
		rra
		jr nc,vtc2_chunk
		or #40
vtc2_chunk	ld bc,#14
		ld hl,#5ac0
		ld d,#da
		ld e,l
		dup 12
		ld (hl),a
		ld (de),a
		inc l
		inc e
		edup
		add hl,bc
		ld e,l
		dup 12
		ld (hl),a
		ld (de),a
		inc l
		inc e
		edup
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

en_create_show				; hl: sprite face, de: sprite mask, 13x21
		ld (ecs_face+1),hl	
		ex de,hl
		ld (ecs_mask+1),hl
		xor a
		ld (int_init+1),a
		ld a,7
		call page
		call mouse_restore_screen
		ld hl,#5900
		ld de,new_wave_old_clr
		ld bc,128
		ldir
		ld hl,#592a
		ld a,#06
		call ecsc
		ld hl,#5909
		ld a,#46
		call ecsc
		call pause
		ld hl,#080a
		ld a,(active_screen)
		xor #80
		add h
		ld h,a
		push hl
		push hl
		ld de,new_wave_old
		ld b,#15
ecs1		push bc
		push hl
		dup 13
		ldi
		edup
		pop hl
		call inch
		pop bc
		djnz ecs1
		pop de
		push de
ecs_mask	ld hl,0
		ld bc,#150d
ecs21		push bc
		push de
ecs2		ld a,(de)
		and (hl)
		ld (de),a
		inc hl
		inc e
		dec c
		jr nz,ecs2
		pop de
		call incd
		pop bc
		djnz ecs21
		call pause
		pop de
ecs_face	ld hl,new_wave
		ld bc,#150d
ecs31		push bc
		push de
ecs3		ld a,(de)
		or (hl)
		ld (de),a
		inc hl
		inc e
		dec c
		jr nz,ecs3
		pop de
		call incd
		pop bc
		djnz ecs31
		call pause
		ld hl,new_wave_old
		pop de
		ld b,#15
ecs4		push bc
		push de
		dup 13
		ldi
		edup
		pop de
		call incd
		pop bc
		djnz ecs4
		ld de,#5900
		ld hl,new_wave_old_clr
		ld bc,128
		ldir
		ld de,#d900
		ld hl,new_wave_old_clr
		ld bc,128
		ldir
		xor a
		ld (end_wave+1),a
		inc a
		ld (int_init+1),a
		ld a,#46
		jp end_pos_attr



ecsc		push af
		ld a,h
		or #80
		ld d,a
		pop af
		ld bc,#0f03
ecsc0		ld e,l
		push bc
		ld (hl),a
		ld (de),a
		inc l
		inc e
		djnz $-4
		pop bc
		push de
		ld de,#11
		add hl,de
		pop de
		dec c
		jr nz,ecsc0
		ret

pause		ld b,#40
pause2		ei
		halt
		djnz $-1
		ret


		; kolvo vragov, base energy, begin wait, wait
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
		ld (enemy_create+1),hl
		
		ld hl,enemy
ec1		xor a
		ld (hl),a	; position on way,
		inc hl
		ld (hl),a	; num_spr
		inc hl
		inc a
		ld (hl),a	; napravlenie
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
		add hl,de
		ex de,hl
		pop hl
		push de
		ld a,r		; type
		and 1
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
		ex de,hl
		pop hl
		ld (hl),e	;energy
		inc hl
		ld (hl),d
		inc hl
		ld (hl),0
		inc hl
		pop de
		djnz ec1

		ld hl,waves_counter
		inc (hl)
		call view_waves
		ld de,wave_view_adr
		xor a
		ld (enemy_count_ingame+1),a
		call view_energy
		ld a,'E'
		call char_print
		ld a,(enemy_count)
		call view_energy
		ld a,create_wave_sound
		call AFXPLAY
		ld hl,new_wave
		ld de,new_wave_mask
		jp en_create_show





;	position on way, num_spr, napravlenie, scr_adr, wait low,high, type, energy, fired
;	0		 1	  2		3,4		5,6	7	8	9
; enemy	db 0,0,1,0,#40,01,0, 0,#ff, 0
	
view_waves	ld de,waves_adr
		ld a,(waves_counter)
		call view_energy
		ld a,'W'
		call char_print
		ld a,(waves_finish)
		jp view_energy

view_score	ld a,#46
		ld (score_atr),a
		ld de,score_adr
		ld a,'S'
		call char_print
		ld hl,score+1
		ld a,(hl)
		push hl
		call view_energy
		pop hl
		dec hl
		ld a,(hl)


view_energy
	        push af
	        and #f0
	        rr a
	        rr a
	        rr a
	        rr a
	        call char_view
	        pop af
	        and #0f

char_view	
		push de
		ld e,a
	        ld d,0
	        ld hl,symbols
	        add hl,de
	        ld a,(hl)
	        pop de

char_print	push de
		push de
	        ld l,a
	        ld h,0
	        add hl,hl
	        add hl,hl	        
	        add hl,hl
	        ld de,font-#fa
	        add hl,de
	        pop de
	        ld a,d
	        add #c0-#40
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
	        pop de
	        inc e
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
		jr nz,t_e_next

		ld hl,towers-1
tf_next		inc hl
		ld a,(hl)	; tower type
		cp #fe
		jr z,t_e_next
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
		ld a,3
tower_fires_add	ld (0),a
		ld (ix+10),8	; enemy fireed
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

t_e_next	ld de,11
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
		call view_energy
		call dec_enemy_view
		
		ld a,(lives)
		ld (view_scores_update_flag+1),a
		ld de,lives_adr
		jp view_energy


base_damage_view
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
		ld b,d
		res 7,b
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
		cp 2
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
tfv2		
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
		ld (hl),3	; num_spr
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
		ld a,c

		ex de,hl

		ld hl,(map)
; range check
		or a
		jr nz,tr2
		ld ix,tower_range1
		jr tr

tr2		cp 1
		jr nz,tr3
		ld ix,tower_range2
		jr tr

tr3		ld ix,tower_range3

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
		ld b,d
		set 7,b
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
		ld b,d
		set 7,b
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
		ld a,(ix+2)	; napravlenie		
		cp 2
		jr c,$+5
killed		ld hl,fired_dwn
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
		ld de,11
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
stor_count2	ld de,11
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
		jr end_calk

begin_calk	xor a
		ld (end_wave+1),a
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
		jr z,end_game
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
		ld d,(ix+2)
		ld l,a
		ld h,high way
		ld a,(hl)	; new napravlenie
		ld (ix+2),a

;	position on way, num_spr, napravlenie, scr_adr, wait low,high, type, energy, fired
;	0		 1	  2		3,4		5,6	7	8,9	10

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
		ld de,11
		add ix,de
		dec b
		jp nz,enemy_pos1

		jp view_scores_update_flag

dec_enemy_counter
enemy_count_ingame
		ld a,0
		inc a
		ld (enemy_count_ingame+1),a
		ret

dec_enemy_view
 		ld de,wave_view_adr
		ld a,(enemy_count_ingame+1)
		jp view_energy



new_game	ld hl,new_level
		ld de,new_level_mask
		call en_create_show
		ld a,(level_current)
		inc a
		ld (level_current),a
		cp 2
		jr z,end_game
		call scr_fading
		ld sp,#7fff
		jp gl_init


end_game	ld hl,game_over
		ld de,game_over_mask
		call en_create_show
		jp end_game



spr_adr_up
	ld e,(ix+3)
	ld d,(ix+4)
	call decd
	call decd
	ld (ix+3),e
	ld (ix+4),d
	ret

spr_adr_down
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
	ld a,(ix+3)
	inc a
	inc a
	ld (ix+3),a
	ret

spr_adr_left
	ld a,(ix+1)
	or a
	ret nz
	ld a,(ix+3)
	dec a
	dec a
	ld (ix+3),a
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
	ld b,#0c
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
	

		ei
		ld a,1
		ld (map_clr5+1),a
		ld (map_clr3+1),a
		ld b,7
map_clr2	push bc
		ld hl,map_color
		ld de,#5800
		ld bc,#300
map_clr1	ld a,(hl)
map_clr3	and 1			;cp 1
		ld (de),a
map_clr4	inc hl
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
		ld bc,#300
		ldir
		ld hl,#5ac0
		ld d,h
		ld e,#c1
		ld c,#40
		ld (hl),#47
		ldir
		ret

scr_fading	ld a,7
		call page
		ei
		ld b,8
		ld e,#7f
fade_clr2	push bc
		ld hl,#5800
		ld bc,#300
fade_clr1	ld a,(hl)
		and e			;cp 1
		ld (hl),a
		inc hl
		dec bc
		ld a,b
		or c
		jr nz,fade_clr1
		halt
		halt
		halt
		halt		
		pop bc
		rr e
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
	ret z
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
		jp nz,rmb

		ld hl,(mouse_map)
		ld a,l	;Y
		add a,a
		add a,a
		add a,a		
		add a,a	
		add h	;X
		ld c,a
		ld a,(new_tower_create_flag)
		or a
		jp nz,cmp_towers
		ld a,(tower_upgrade_flag)
		or a
		jp nz,tower_upgrading
		ld hl,(map)
		ld a,c
		add l
		ld l,a
		ld a,(hl)
		cp #ff
		jp nz,tower_not_set		; #ff - можно ставить башни
				; поиск башни по позиции
		ld hl,towers
mp0		ld a,(hl)
		cp #fe
		jp z,new_tower
		ld b,a		; type
		inc hl
		ld a,(hl)	; position
		cp c
		jr z,tower_upgrade_view
mpn0		inc hl
		ld a,(hl)	; range propusk
		cp #ff
		jr nz,mpn0
		inc hl
		jr mp0

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
		call view_energy
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
		
		ld a,create_tower_sound
		call AFXPLAY
		call tower_preview_range_restore
		call tower_attr_restore
		jp rmb3


tower_upgrade_view
		push bc	; in b:type, c:position, in hl- towers+1
		push bc
		push hl
		ld (tower_upgrade_flag),a
		; set on view range and towers
;		ld (stat_upgrade_flag+1),a
		ld (tower_upgrade_range_flag+1),a ; pos
		push af
		ld a,b
		ld (tower_upgrade_range_type+1),a ; type
		pop af
		push af
		call tower_attr_restore
		pop af
		call tower_attr_store

		call vtc_chunk_color_init
		
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
		call view_energy
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
		call view_energy
		pop de
		dec e
		ld a,'F'
		call char_print
		pop de
		ld a,e
		ld de,upgrade_price_adr
		call view_energy

		

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

tuv30		ld c,b		; вывод типа башни
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

fill_colors	ld b,3
		ld (hl),a
		ld (de),a
		inc l
		inc e
		djnz $-4
		ret

tower_not_set	ld a,cancel_sound
		jp AFXPLAY


cmp_towers 	xor a
		ld (tower_preview_range_flag+1),a
		ld a,c
		cp #af		
		jr c,rmb2
		sub #b0
		rra
		ld (cmp_towers0+1),a

;		sub #b0
		ld c,a
		ld b,0
		ld hl,tower_price
		add hl,bc
		ld c,(hl)
		ld a,(money)
		sub c
		jr c,low_money
		ld (money),a
		ld de,money_adr
		call view_energy
		call tower_preview_range_restore
cmp_towers0	ld a,0
;		sub #b0			; перва€ башн€
		ld c,a			; type
		ld a,(new_tower_create_flag)
		ld b,a			; pos:
		ld hl,towers_fire_rate
		ld e,c
		ld d,0
		add hl,de
		ld a,(hl)		; fire rate
;				; create tower, b - pos:#21, c - type: 0
		
		call tower_create
		ld a,(new_tower_create_flag)
		call tower_attr_store
		ld a,create_tower_sound
		call AFXPLAY

		jp rmb1

low_money	ld a,#20
		ld (red_money_counter+1),a
		ld a,#42
		call fill_money_atr
		ld a,cancel_sound
		call AFXPLAY

rmb2		call tower_not_set
rmb		; exit
		call tower_preview_range_restore
rmb1		call tower_attr_restore
rmb3		call vtc_chunk_color_init

		xor a			;exit
		ld (new_tower_create_flag),a	
		ld (tower_upgrade_flag),a
		dec a
		ld (stat_new_tower_flag+1),a
		ld (stat_upgrade_flag+1),a
		ld (tower_upgrade_range_flag+1),a
		ld (tower_upgrade_range+1),a

view_tower_clear	
		ld a,1
		ld (towers_fading+1),a
		jp mouse_restore_screen

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
		xor a
		ld (towers_fading+1),a
		ld (stat_new_tower_flag+1),a
		ld a,(money)
		ld (stat_new_tower_money+1),a
		call clear_status_attr

st_new_tower	ld hl,#50c0
		ld d,0	; type
		ld bc,#0808	;	ld b: power, c: price

		call status_tower

		ld hl,#50c4
		ld d,1	; type
		ld bc,#050c

		call status_tower

		ld hl,#50c8
		ld d,2	; type
		ld bc,#0414

status_tower
			;	ld hl,#50c0
			;	ld b: power, c: price
			;	ld a,0	- type
		ld a,(money)
		sub c
		jr c,$+3
		xor a
		ld (st_color+1),a
		push bc
		push hl
		ld c,d
		call  view_tower_instatus
		ld (st_clr1+1),hl
		ex de,hl
		ld (st_clr2+1),hl
		pop hl
		pop bc
		inc l
		inc l
		push bc
		ex de,hl
		push bc
		ld a,'F'
		call char_print
		pop bc
		ld a,b		; power
		call char_view
		
		ex de,hl
		ld de,#1e
		add hl,de
		push hl
		dec l
		call money_view
		pop de
		pop bc
		ld a,c
		call view_energy
st_color	ld a,0
		or a
		ret z		
st_clr1		ld hl,0
st_clr2		ld de,0
 	        ld bc,#1f
 	        ld a,#47
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
 	        ld a,#07
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
		ret

mouse_view	
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
		call mouse_store_adr
		pop hl

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
		LD BC,#FADF
		IN A,(C)     ;читаем порт кнопок
		ld (mouse_button),a
		
/*
  D0 - лева€ кнопка
  D1 - права€ кнопка
  D2 - средн€€ кнопка

Standard Kempston Mouse
#FADF - buttons
#FBDF - X coord
#FFDF - Y coord
*/
key_in
		call key_scan	
		LD hl,MOUSE11+1
		ld a,d

		and left
		jr z,ki1	
		inc (hl)
		inc (hl)
ki1		ld a,d
		and right
		jr z,ki2
		dec (hl)
		dec (hl)
ki2		LD hl,MOUSE12+1
		ld a,d
		and down
		jr z,ki3
		inc (hl)
		inc (hl)
ki3		ld a,d
		and up
		jr z,ki4
		dec (hl)
		dec (hl)
ki4		ld a,d
		and fire
		or a
		jr z,ki5
		ld a,#0e
		ld (mouse_button),a
ki5

		LD     HL,(mouse_xy)
		LD     BC,#FBDF
		IN     A,(C)
MOUSE11		LD     D,0
		LD     (MOUSE11+1),A
		SUB    D
		CALL   NZ,MOUSE30
		LD     B,#FF
		IN     A,(C)
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

	db #0f7, #0fe, left	;1
	db #0f7, #0fd, right	;2
	db #0f7, #0fb, down	;3
	db #0f7, #0f7, up	;4
	db #0f7, #0ef, fire	;5

	db #0df, #0fe, right	;p
	db #0df, #0fd, left	;o
	db #0fb, #0fe, up	;q
	db #0fd, #0fe, down	;a
	db #07f, #0fb, fire	;m
	db #07f, #0fe, fire	;space

	db #000


cs_key_table:
	db #0ef, #0fe, fire	;0
	db #0ef, #0fb, right	;8
	db #0ef, #0f7, up	;7
	db #0ef, #0ef, down	;6
	db #0f7, #0ef, left	;5

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
                ;LD C,A
                ;LD A,B
                ;RLCA
                ;RLCA
                ;RLCA
                ;AND #C0
                ;OR C
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
 ;               LD A,(current_page)
;                CALL page
                POP AF
                RET 

init_game	
		xor a
		ld (int_init+1),a
		out (#fe),a
		ld hl,#5800
		ld de,#5801
		ld bc,#2ff
		ld (hl),l
		ldir
		ld a,(level_current)
		call level_choice
		ld a,(way_end)
		
		ld (way_enemy_end+1),a
		ld a,#fe
		ld (towers),a
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

		ld a,0
		call page
		call map_create
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
		call view_energy
		ld a,18
		ld (money),a
		ld de,money_adr
		call view_energy
		call view_score
		call view_waves
		ld a,(level_current)		
		inc a
		ld de,level_adr
		push de
		call view_energy
		pop de
		dec e
		ld a,'L'
		call char_print

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
		

		call mouse_view
		call way_view
		xor a		
		call tower_attr_store
		call tower_attr_restore
;		call rmb
		ld hl,waves	; count waves
		ld de,6
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
		ld hl,towers
		ld (tc_adr+1),hl

                jp enemy_create
                
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
		inc hl
		cp #ff
		jr nz,$-4
		ld (map),hl
		ld a,7
		jp page


		include "ayfxplay.a80"

level_current	db 0
waves_counter	db 0
waves_finish	db 0

towers_count	db 0

towers_attr	ds 6

new_tower_create_flag	db 0
tower_upgrade_flag	db 0
tower_upgrade_price	db 0
tower_upgrade_power	db 0

towers_fire_rate	; fire rate
		db #1a,#14,#0e

;		power of fire
tower_char	db 8
		db 5
		db 4		

	    	; power of upgrade
	    	;price,type, level2, level3, end
tower_upgrade	db 5, 0, 8, 11,20,#ff
		db 8, 1, 5, 9, 14,#ff
		db 12,2, 4, 6, 9, #ff

tower_price	db #08, #0c, #14, #1a,#25

tower_range1	db -17,-16,-15,-1,1,15,16,17,#80
tower_range2	db -33,-32,-31,-18,-17,-16,-15,-14,-2,-1,1,2,14,15,16,17,18,31,32,33,#80
tower_range3	db -49,-48,-47,-34,-33,-32,-31,-30,-19,-18,-17,-16,-15,-14,-13,-3,-2,-1,1,2,3,13,14,15,16,17,18,19,30,31,32,33,34,47,48,49,#80

;	position on way, num_spr, napravlenie, scr_adr, wait low,high, type, energy, fired
;	0		 1	  2		3,4		5,6	7	8,9	10
enemy_lives	db 4, 8, 11, 15, 22
enemy
	ds 10*128
/*
	db 0,0,1,0,#40,01,0, 0,#ff, 0
	db 0,0,1,0,#40,#80,0 ,1,#ff, 0
	db 0,0,1,0,#40,#c0,0 ,2,#ff, 0
	db 0,0,1,0,#40,20,1 ,3,#ff, 0
*/
enemy_count
	db 1

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

mouse_spr	include "spr/mouse_spr.asm"
mouse_screen	ds #14
enemy_gfx	dw enemy_sprite1,enemy_sprite2,enemy_sprite1,enemy_sprite2	; 4 enemys
enemy_pages 	db 1,1,1,1
; sprite moves:      right (4*32*4)	 left down up
enemy_moves	dw #400,0,#800,#c00

scr_adr	ds 16*12*2
new_wave_old	ds 273
new_wave_old_clr	ds 128

sprbuffer	ds 8*32
		dw 0


chunks		incbin "spr/chunk.C"
sfxbank		incbin "td.afb"

tower_gfx	include "spr/tower2.asm"
		include "spr/tower.asm"
		include "spr/tower3.asm"		

font	 	incbin "spr/rex_font.mem"
new_wave	include "spr/nw.asm"
new_wave_mask	include "spr/nw_mask.asm"
game_over	include "spr/game_over.asm"
game_over_mask	include "spr/game_over_mask.asm"
new_level 	include "spr/new_level.asm"
new_level_mask 	include "spr/new_level_mask.asm"
base_tower_db	ds 5*36

lovemoney defb #00, #6C, #FE, #FA, #74, #29, #12, #04, #00, #04, #7E, #68, #7E, #16, #7E, #20

lives		db 0
money		db 0
score		db 0,0
map		dw 0

tower_atr_db

		page 4
		org #c000
tiles		incbin "spr/denizen.C"

	
/*
; ------------------- level 1
; 1-right, 0-left, 2-down, 3-up

way	db 1,1,1,1, 2,2,0,0, 0,2,2,1, 1,1,1,1, 3,1,1,2, 2,1,1,1, 2,2,1,1,1,3,3,3,3,1
	db #ff

map	include "level1.asm"
; live and money sprite

	org map_mem+#100
; kolvo vragov, base energy, begin wait,0,  wait
waves	db 12,  4,  0,  #a0, 0, #14		; !!! 50 enemys with little waits
	db 17, 11, 0, #20, 0, #12		; only 28 enemy on screen
	db 28, 30, 0, #20, 0, #15
	db 20, 36, 0, #40, 0, #12
	db 13, 60, 0, #20, 0, #18
	db 10, 150, 0, #20, 0, #30
	db 20, 80, 0, #50, 0, #10
	db 90, 140,0, #20, 0, #18
	db 15, 220,0, #20, 0, #28
	db 32, 150,0, #a0, 0, #20
	db 80, 200,0, #a0, 0, #18
	db 80, 90,1, #a0, 0, #13
	db 1,  20,2, #40, 0, #13
	db #ff

	org map_mem+#1f0
way_begin	db 0
way_end		db 34
way_begin_adr	dw #0000	


*/
	page 3
	org levels_mem
;	org map_mem
; ------------------- level 2
; 1-right, 0-left, 2-down, 3-up


level1

	db 1,1,1,1, 2,2,0,0, 0,2,2,1, 1,1,1,1, 3,1,1,2, 2,1,1,1, 2,2,1,1,1,3,3,3,3,1
	db #ff

; map
	include "level1.asm"

	org levels_mem+#100
; kolvo vragov, base energy, begin wait,0,  wait
	db 12,  4,  0,  #a0, 0, #14		; !!! 50 enemys with little waits
	db 17, 11, 0, #20, 0, #12		; only 28 enemy on screen
	db 28, 30, 0, #20, 0, #15
	db 20, 36, 0, #40, 0, #12
	db 13, 60, 0, #20, 0, #18
	db 10, 110, 0, #20, 0, #30
	db 20, 80, 0, #50, 0, #10
	db 90, 140,0, #20, 0, #18
	db 15, 220,0, #20, 0, #24
	db 32, 190,0, #a0, 0, #20
	db 80, 240,0, #a0, 0, #18
	db 80, 90,1, #a0, 0, #13
	db 1,  20,2, #40, 0, #13
	db #ff

	org levels_mem+#1f0
;way_begin
	db 0
;way_end
		db 34
;way_begin_adr
	dw #0000	


	org levels_mem + levels_offset
level2

;way
	db 1,1,1, 2,2,2,2,1,1, 3,3,3,3,3,3,3, 1,1, 2,2,2, 1,1, 3,3,3, 1,1
	db 2,2,2,2,2,  0,0,0,0, 2,2, 1,1,1,1,1,1, 3,3,1, 3,3,1
	db #ff

	include "level2.asm"


	org levels_mem + levels_offset+#100
;waves
	db 12	
	dw 4
	db #a0, 0, #14		
	
	db 14, 30, 0, #20, 0, #12
	db 20, 50, 0, #20, 0, #10
	
	db 10		; kolvo vragov
	dw 40		; base energy,
	db #40, 0, #1a	; begin wait,0,  wait

	db 20 
	dw 60
	db #20, 0, #14
	
	db 10
	dw 130
	db #20, 0, #34

;7	
	db 20
	dw #80
	db #50, 0, #16
	
	db 20, 130,0, #20, 0, #18
	
	db 15
	dw #0a0
	db #20, 0, #24
	
	db 32
	dw #0b0
	db #a0, 0, #20
	
	db 80
	dw #0f0
	db #a0, 0, #18
	
	db 80
	dw #190
	db #a0, 0, #13
	
	db 1
	dw  #0220
	db #40, 0, #13
	
	db #ff

	org levels_mem + levels_offset+#1f0
; way_begin
	db 64
;way_end		
	db 51
;way_begin_adr	
	dw #0800	





		page 1
		org #c000
		incbin "sprite_bnk1.bin"

fired		equ #e000	
fired_dwn	equ fired+#400	

enemy_sprite1	equ #c000	
enemy_sprite2	equ #d000	



       savesna "td.sna",start