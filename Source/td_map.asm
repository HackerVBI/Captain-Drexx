		device zxspectrum128
	        org #7000

INT_VECTOR      EQU #B700 ;размер #1C0
num_enemy_sprites	equ 7
lives_adr	equ #50de
money_adr	equ #50fe
back_sprites 	equ #6000
mouse_screen	equ #6e00
start:
		di
/*
		ld a,#17
		ld bc,#7ffd
		out (c),a
		ld a,#ff
		ld (#c000),a
		ld a,#1d
		ld bc,#7ffd
		out (c),a
		ld a,#ff
		ld (#c001),a
*/


		ld sp,#5fff
;		call init_game
init_game	
		xor a
		out (#fe),a
		ld hl,#5800
		ld de,#5801
		ld bc,#2ff
		ld (hl),#47
		ldir
		call mouse_pos
		call init_sprites
		call cr_scradr
		ld a,(way_end)
		ld (way_enemy_end+1),a
		ld a,#3
		call page
		call map_view
		ld a,#5
		call page
		call map_create
		call enemy_create
		ld a,12			; fire rate
		ld bc,#1100		; create tower, pos:#21, type 0
		call tower_create
		ld a,12			; fire rate
		ld bc,#5301
		call tower_create
		ld a,8			; fire rate
		ld bc,#4700
		call tower_create
		ld a,12			; fire rate
		ld bc,#6c00
		call tower_create
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
		ld (#5add),a
		ld a,#44
		ld (#5afd),a
		ld a,12
		ld (lives),a
		ld de,lives_adr
		call view_energy
		ld a,0
		ld (money),a
		ld de,money_adr
		call view_energy
		ld b,5
		ld hl,#5aee
		ld a,#46
fc1		ld (hl),a
		inc l
		djnz fc1
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
		ld de,#0000
		call store_view
		ld de,#0000
		call store_view
		ld de,#0000
		call store_view
		ld hl,back_sprites+#400
		ld (store_view_adr+1),hl
		ld de,#0000
		call store_view
		ld de,#0000
		call store_view
		ld de,#0000
		call store_view
		ld de,#0000
		call store_view


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
                call mouse_view
game_loop	
		ld a,1
		ld (screen_ready),a
		ld a,2
;		out (#fe),a
		call restore_view
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

/*		ld ix,enemy
		ld de,#50e5
		ld b,8
energy_view	ld a,(ix+0)	; position
		call view_energy
		ld a,(ix+8)
		call view_energy
;		ld a,#10
;		call char_view
;		inc e
		push de
		ld de,10
		add ix,de
		pop de
		djnz energy_view
*/

		xor a
		ld (screen_ready),a
;		out (#fe),a
;		halt
		halt		
	        jp game_loop

interrupt	di
		push af
		push hl
		push de
		push bc
		push ix
                LD A,(current_page)
                LD (int_ram+1),A
                ld a,7
                call page
		call mouse_restore_screen
                LD A,(screen_ready)
                or a
                jr nz,int_1
                CALL CHANGE_SCREEN
		ld a,1
		ld (screen_ready),a
int_1	
		call mouse_pos
		call mouse_map_adr
		call mouse_view
		call mouse_pressed                

int_ram		ld a,7
		call page
		pop ix
		pop bc
		pop de
		pop hl
		pop af
		ei
		ret


enemy_create	ld hl,enemy
		ld de,1
		ld a,128
		ld (enemy_count),a
		ld b,a
ec1		xor a
		ld (hl),a	; position on way,
		inc hl
		ld (hl),a	; num_spr
		inc hl
		inc a
		ld (hl),a	; napravlenie
		inc hl
		dec a
		ld (hl),a	; scr_adr
		inc hl
		ld a,#00
		ld (hl),a
		inc hl
		ld (hl),e	; wait
		inc hl
		ld (hl),d
		inc hl
		push hl
		ex de,hl
		ld de,#20	; add wait time for next enemy
		add hl,de
		ex de,hl
		pop hl
		ld a,r		; type
		and 1
		ld (hl),a
		inc hl
		ld a,r		; energy
		or #20
		ld (hl),a
		inc hl
		ld (hl),0
		inc hl
		djnz ec1
		ret
;	position on way, num_spr, napravlenie, scr_adr, wait low,high, type, energy, fired
;	0		 1	  2		3,4		5,6	7	8	9
; enemy	db 0,0,1,0,#40,01,0, 0,#ff, 0
	


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

char_view	push de
		push de
		ld e,a
	        ld d,0
	        ld hl,symbols
	        add hl,de
	        ld a,(hl)
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

towers_fire	ld ix,enemy
		ld a,(enemy_count)	
		ld b,a
tf		ld a,(ix+0)	; #ff - killed
		inc a
		jr z,t_e_next

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
		ld d,0
		ld e,a
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
		push hl
		ld hl,tower_char
		add hl,de
		ld c,(hl)	; power of tower
		pop hl
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
		ld (ix+9),7	; enemy fireed

		ld a,(ix+8)	; ranged enemy, energy -= power of tower
		sub c
		ld (ix+8),a
		jr nc,tf1
		ld (ix+0),#ff	; enemy killed
		ld a,(money)
		inc a
		ld (money),a
		ld de,money_adr
		push hl
		call view_energy
		pop hl
tf1		inc hl
		jr tf0

t_e_next	ld de,10
		add ix,de
		djnz tf
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
		dec a
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
;		ld a,10			; fire rate
;		ld bc,#1100		; create tower, pos:#21, type 0

	

tc_adr		ld hl,towers
		ld (hl),c	; type
		inc hl
		ld (hl),b	; position
		inc hl
		ld (hl),a	; fire rating 
		inc hl		
		ld (hl),a	; fire rating counter
		inc hl				
		ld (hl),3	; num_spr
		inc hl
		ld a,c
		ex de,hl

		ld hl,map
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
		ld b,#10
tvv1		ld a,(hl)
		ld (de),a
		inc hl
		inc e
		ld a,(hl)
		ld (de),a
		inc hl
		dec e
		call incd
		djnz tvv1
		ret

tower_screen_adr
		ld hl,scr_adr
		push af
		and #f0
		rra
		rra
		rra
		rra
tvc1		inc hl
		inc hl
		dec a
		jr nz,tvc1
		ld a,(hl)
		inc hl
		ld h,(hl)
		ld l,a
		ld a,(active_screen)
;		xor #80
		add h
		ld h,a
		pop af
		and #0f
		add a,a
		add l
		ld l,a
		ret

spr_view	ld ix,enemy
		ld a,(enemy_count)
		ld b,a
s_view		push bc
		ld a,(ix+0)
		inc a
		jp z,ns_view
		ld l,(ix+5)
		ld h,(ix+6)
		dec hl
		ld a,h
		or l
		jp nz, ns_view
		ld a,(ix+9)
		or a
		jr z,s_view1
		dec (ix+9)
		ld hl,fired
		ld a,(ix+2)	; napravlenie		
		cp 2
		jr c,$+5
		ld hl,fired_dwn
		ld a,(ix+1)
		jr s_view0

s_view1		ld a,(ix+7)	; enemy
		add a,a
		ld e,a
		ld d,0
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
		ld a,#1
		call page				
		ld (view_spr_s+1),sp
		ld sp,hl
		ld hl,sprbuffer
		dup 4*#16
		pop bc
		ld (hl),c
		inc hl
		ld (hl),b
		inc hl
		edup
vsnrscr		ld sp,sprbuffer
		LD A,7
		call page
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
		ld de,10
		add ix,de
		dec b
		jp nz, s_view
		ret



restore_view	ld hl,back_sprites
		ld de,#400
		ld a,(active_screen)
		cp #40
		jr z,r_v1
		add hl,de
r_v1		ld (r_s0+1),hl
		ld a,7
		call page
r_s0		ld hl,0
		ld e,(hl)
		inc hl
		ld d,(hl)
		inc hl
		ld a,e
		or d
		cp #ff
		ret z
		di
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
		ld de,#400
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
		jr z,stor_count
		ld l,(ix+5)
		ld h,(ix+6)
		dec hl
		ld a,h
		or l
		jr nz,stor_count	
		ld e,(ix+3)
		ld d,(ix+4)
		push bc
		push de
		call store_view
		pop de
		pop bc
stor_count	ld de,10
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
		ld a,(enemy_count)
		ld b,a
enemy_pos1	push bc
		ld a,(ix+0)	; #ff - killed
		inc a
		jr z,end_calk

		ld l,(ix+5)
		ld h,(ix+6)
		dec hl
		ld a,h
		or l
		jr z,begin_calk
		ld (ix+5),l
		ld (ix+6),h
		jr end_calk

begin_calk	ld a,(ix+1)	; num_spr
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
		ld a,(lives)
		dec a
		ld (lives),a
		jr z,end_game
		ld de,lives_adr
		call view_energy
		jr end_calk

we		ld (ix+0),a	
		ld d,(ix+2)
		ld l,a
		ld h,high way
		ld a,(hl)	; new napravlenie
		ld (ix+2),a
/*
		cp 2
		jr c,en
		ld a,1
		cp d
		jr nz,en
		ld c,(ix+3)
		inc c
		inc c
		ld (ix+3),c
*/
;		0	 1		2	3, 4	5	 6	7	8
;	position on way, num_spr, napravlenie, scr_adr, wait low,high, type, energy

en		ld a,(ix+2)
	; napravlenie: 1-right, 0-left, 2-down, 3-up
		push af
		or a
		call z,spr_adr_left
		pop af
		push af
		cp 1
		call z,spr_adr_right
		pop af
		cp 2
		call z,spr_adr_down
		cp 3
		call z,spr_adr_up
end_calk	pop bc
		ld de,10
		add ix,de
		dec b
		jr nz,enemy_pos1
		ret


end_game	ld a,#ff
		ld de,lives_adr
		call view_energy
		di
		halt





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


spr_adr_up
	ld e,(ix+3)
	ld d,(ix+4)
	call decd
	call decd
	ld (ix+3),e
	ld (ix+4),d
	xor a
	ret

spr_adr_down
	ld l,(ix+3)
	ld h,(ix+4)
	call inch
	call inch
	ld (ix+3),l
	ld (ix+4),h
	xor a
	ret


spr_adr_right
	ld a,(ix+1)
	or a
	ret nz
	ld a,(ix+3)
	inc a
	inc a
	ld (ix+3),a
	xor a
	ret

spr_adr_left
	ld a,(ix+1)
	or a
	ret nz
	ld a,(ix+3)
	dec a
	dec a
	ld (ix+3),a
	xor a
	ret




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
	ld de,map
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

mvc0	ld hl,#5800

	ld a,(de)	; color
	or #40
	inc de
	ld (hl),a
	inc l
	ld a,(de)	; color
	or #40
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
	ret


map_create
	ld hl,map
	push hl
	ld de,map+1
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
	
mouse_pressed
		ld a,(mouse_button)
		cpl
		and #3
		or a
		ret z
		cp 1
		ret nz

		ld hl,(mouse_map)
		ld a,l	;Y
		add a,a
		add a,a
		add a,a		
		add a,a	
		add h	;X
		ld c,a
		ld hl,towers
mp0		ld a,(hl)
		cp #fe
		ret z
		ld b,a		; type
		inc hl
		ld a,(hl)	; position
		cp c
		jr z,mp1
mpn0		inc hl
		ld a,(hl)
		cp #ff
		jr nz,mpn0
		inc hl
		jr mp0

mp1		ld a,b
		ld de,#50e0
		call view_energy
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



;	position, type
towers		ds 30*3
towers_count	db 0

;		power of fire
tower_char	db 8
		db 4
		db 3		

tower_range1	db -17,-16,-15,-1,1,15,16,17,#80
tower_range2	db -33,-32,-31,-18,-17,-16,-15,-14,-2,-1,1,2,14,15,16,17,18,31,32,33,#80
tower_range3	db -49,-48,-47,-34,-33,-32,-31,-30,-19,-18,-17,-16,-15,-14,-13,-3,-2,-1,1,2,3,13,14,15,16,17,18,19,30,31,32,33,34,47,48,49,#80



sprites		; 2*16, 32 bytes
;	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db #aa,#aa, #55,#55,#aa,#aa, #55,#55,#aa,#aa, #55,#55,#aa,#aa, #55,#55
	db #aa,#aa, #55,#55,#aa,#aa, #55,#55,#aa,#aa, #55,#55,#aa,#aa, #55,#55

	db #05,#05,5,5	; color

	db #aa,#aa, #55,#55,#aa,#aa, #55,#55,#aa,#aa, #55,#55,#aa,#aa, #55,#55
	db #aa,#aa, #55,#55,#aa,#aa, #55,#55,#aa,#aa, #55,#55,#aa,#aa, #55,#55
	db 4,4,4,4	; color, 36 bytes

	db #aa,#aa, #55,#55,#aa,#aa, #55,#55,#aa,#aa, #55,#55,#aa,#aa, #55,#55
	db #aa,#aa, #55,#55,#aa,#aa, #55,#55,#aa,#aa, #55,#55,#aa,#aa, #55,#55
	db 2,2,2,2	; color, 36 bytes

	db #aa,#aa, #55,#55,#aa,#aa, #55,#55,#aa,#aa, #55,#55,#aa,#aa, #55,#55
	db #aa,#aa, #55,#55,#aa,#aa, #55,#55,#aa,#aa, #55,#55,#aa,#aa, #55,#55
	db 6,6,6,6	; color, 36 bytes

; 	1 - spr,2 - color


;	position on way, num_spr, napravlenie, scr_adr, wait low,high, type, energy, fired
;	0		 1	  2		3,4		5,6	7	8	9
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

enemy_gfx	dw enemy_sprite1,enemy_sprite2,enemy_sprite1,enemy_sprite1	; 4 enemys
enemy_pages 	dw #1,#1,#1,#1
; sprite moves:      right (4*32*4)	 left down up
enemy_moves	dw #400,0,#800,#c00

tower_gfx	include "spr/tower2.asm"
		include "spr/tower.asm"

scr_adr	ds 16*12*2

font 	incbin "spr/rex_font.mem"


sprbuffer	ds 4*16

en_sprite_right	include "spr/rex_spr_right.asm"
en_spr_rgt_mask	include "spr/rex_spr_right_mask.asm"
en_sprite_left	include "spr/rex_spr_left.asm"
en_spr_lft_mask	include "spr/rex_spr_left_mask.asm"
en_sprite_dwn	include "spr/rex_spr_down.asm"
en_spr_dwn_mask	include "spr/rex_spr_down_mask.asm"
en_sprite_up	include "spr/rex_spr_down.asm"
en_spr_up_mask	include "spr/rex_spr_down_mask.asm"

en2_sprite_right	include "spr/enemy_bike_right.asm"
en2_spr_rgt_mask	include "spr/enemy_bike_right_mask.asm"
en2_sprite_left		include "spr/enemy_bike_left.asm"
en2_spr_lft_mask	include "spr/enemy_bike_left_mask.asm"
en2_sprite_dwn		include "spr/enemy_bike_down.asm"
en2_spr_dwn_mask	include "spr/enemy_bike_down_mask.asm"
en2_sprite_up		include "spr/enemy_bike_down.asm"
en2_spr_up_mask		include "spr/enemy_bike_down_mask.asm"

en_fired		include "spr/enemy_fired.asm"
en_fired_mask		include "spr/enemy_fired_mask.asm"
en_fired_dwn		include "spr/enemy_fired_down.asm"
en_fired_dwn_mask	include "spr/enemy_fired_down_mask.asm"

fired		equ #e000	
fired_dwn	equ fired+#400	

enemy_sprite1	equ #c000	

enemy_sprite2	equ #d000	



	org #5f00
; 1-right, 0-left, 2-down, 3-up
way	db 1,1,1,1, 2,2,0,0, 0,2,2,1, 1,1,1,1, 3,1,1,2, 2,1,1,1, 2,2,1,1,1,3,3,3,3,1
	db #ff

way_begin	db 0
way_end		db 34

lives		db 0
money		db 0
map	include "level1.asm"


; live and money sprite
lovemoney defb #00, #6C, #FE, #FA, #74, #29, #12, #04, #00, #04, #7E, #68, #7E, #16, #7E, #20

	page 3
	org #c000
tiles	incbin "spr/denizen.C"
	




        savesna "td.sna",start