	
/*
; ------------------- level 1
;  0-left, 1-right, 2-down, 3-up

way	db 1,1,1,1, 2,2,0,0, 0,2,2,1, 1,1,1,1, 3,1,1,2, 2,1,1,1, 2,2,1,1,1,3,3,3,3,1
	db #ff

map	include "level1.asm"
; live and money sprite

	org map_mem+#130
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



;	org map_mem
; ------------------- level 2
; 1-right, 0-left, 2-down, 3-up


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




level2
	org levels_mem + levels_offset

	db 1, 1, 1, 2,  1, 1, 2,  1, 1, 2,  1, 1, 2,  1, 1, 2,  1, 1, 2, 1, 1
	db #ff

	include "levels/lev2.asm"

	org levels_mem + levels_offset+#130
; kolvo vragov, base energy, begin wait,0,  wait ,enemy_bit_list
	db 12, 4,  0, #a0, 0, #0a ,%00000000,%00000001	
	db 37, 21, 0, #20, 0, #0f ,%00000000,%00000011		; only 28 enemy on screen
	db 32, 34, 0, #20, 0, #15 ,%00000000,%00000101
	db 10, 80, 0, #40, 0, #3a ,%00000000,%00000010

	db 13, 60, 0, #20, 0, #19 ,%00000000,%00000001
	db 6,  95, 0, #20, 0, #2a ,%00000000,%00000101
	db 20, 80, 0, #50, 0, #11 ,%00000000,%00000111
	db 40, 122,0, #20, 0, #15 ,%00000000,%00000011	; 8

	db 25, 78, 0, #20, 0, #0e ,%00000000,%00001001
	db 32, 190,0, #a0, 0, #1e ,%00000000,%00000111
	db 10, 240,0, #a0, 0, #17 ,%00000000,%00010111
	db 20, 10, 1, #a0, 0, #13 ,%00000000,%00001011

	db 1,  #10,1, #40, 0, #13 ,%00000000,%00010000
	db #ff


	org levels_mem+ levels_offset+#1d0
	;   123456789abcdef
	db "RUNNING WILD",#ff

	org levels_mem + levels_offset+#1f0
;way_begin
	db 48
;way_end
	db 0
;way_begin_adr
	dw #00c0	
; available towers from right to left
	db %10010000
; money on start level
	db 18






level3
	org levels_mem + levels_offset*2
; 1-right, 0-left, 2-down, 3-up
	db   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   2, 1,1, 2, 2, 2, 2, 2, 2
	db 0,0,0,0,0,0,0,0,3,0,0,3,3,1,3,1,1,1,1,1,1,2,1,1,1,1,1,2,1
	db #ff

; map
;	include "levels/lev3.asm"
	db 10,  11,  12,   6,   7,  12,  10,  16,   3,   1,   2,   3,   5,  53,   2,  14
	db 194, 67,  67,  67,  67,  67,  67,  67,  67,  67,  67,   5,   3,  53,   2,  16
	db 88,  89, 124, 243, 124, 124, 124, 124, 124, 124, 226,  67,  67,  53,   3,   1
	db 66,  66,  66, 123,  65,  65,  65,  65,  65,  65,  65,  64,  67,  53,   5,   4
	db 66,  66,  66,  67,  67,  67,  67,  67,  67,  67,  65,  62,  67,  53,   7,   8
 	db 66,  66,  67,  67,   3, 236, 237,   6,   7,  67,  67,  67, 228,  67,  67, 195
	db 66,  66,  67,  22,   2, 238, 239,   2,   3,   4,  14,   2,  67,  54,  67, 220
 	db 66,  66, 226,  67,  67,   5,   4,  11,   9,   7,   3,   6,  67,  53,  32,  28
	db 66,  66,  66, 224,  67,  67,  67,  67,  67,  67,  67,  67,  67,  53,   4,   3
	db 131, 137, 132,  66, 126,  89, 124, 124, 124, 124, 124, 124, 243, 53,   5,  9
 	db 65,  65, 133,  66,  66,  66,  66,  66,  66,  66,  66,  66,  123, 20,   3,   2
	db 0,#10


	org levels_mem + levels_offset*2 +#130
; kolvo vragov, base energy, begin wait,0,  wait ,enemy_bit_list
	db 12, 4,  0, #a0, 0, #14 ,%00000000,%00000001		; !!! 50 enemys with little waits
	db 17, 11, 0, #20, 0, #12 ,%00000000,%00000011		; only 28 enemy on screen
	db 28, 30, 0, #20, 0, #15 ,%00000000,%00000011
	db 20, 55, 0, #40, 0, #10 ,%00000000,%00000011

	db 13, 70, 0, #20, 0, #18 ,%00000000,%00001001
	db 10, 170,0, #20, 0, #28 ,%00000000,%00000100
	db 20, #b8, 0, #50, 0, #10 ,%00000000,%00000111
	db 90, 180,0, #20, 0, #10 ,%00000000,%00001011

	db 15, 60,1, #20, 0, #24 ,%00000000,%00000100
	db 32, 80,1, #a0, 0, #1e ,%00000000,%00001011
	db 40, 80,1, #a0, 0, #15 ,%00000000,%00000111
	db 20,#f0,1, #a0, 0, #13  ,%00000000,%00001101
	db 1,  70,2, #40, 0, #13  ,%00000000,%00100000 
	db #ff

	org levels_mem+ levels_offset*2+#1d0
	;   123456789abcdef
	db "SANITATION",#ff

	org levels_mem + levels_offset*2+#1f0
;way_begin
	db 16
;way_end
		db 34
;way_begin_adr
	dw #0040	
; available towers from right to left
	db %01000000
; money on start level
	db 18






level4
	org levels_mem + levels_offset*3
; 1-right, 0-left, 2-down, 3-up
	db 1,1,1,1, 2,2,0,0, 0,2,2,1, 1,1,1,1, 3,1,1,2, 2,1,1,1, 2,2,1,1,1,3,3,3,3,1
	db #ff

; map
	include "levels/lev4.asm"

	org levels_mem + levels_offset*3 +#130
; kolvo vragov, base energy, begin wait,0,  wait ,enemy_bit_list
	db 12, 8,  0, #80, 0, #10 ,%00000000,%00000001		; !!! 50 enemys with little waits
	db 17, 20, 0, #20, 0, #13 ,%00000000,%00000011		; only 28 enemy on screen
	db 28, 30, 0, #20, 0, #0b ,%00000000,%00000101
	db 20, 66, 0, #40, 0, #12 ,%00000000,%00000011
	
	db 17, 90, 0, #20, 0, #18 ,%00000000,%00000110
	db 10, 150,0, #20, 0, #20, %00000000,%00000100
	db 20, 170,0, #50, 0, #11 ,%00000000,%00000111
	db 40, 202,0, #20, 0, #16 ,%00000000,%00000011
	
	db 20, 25, 1, #20, 0, #24 ,%00000000,%00001010
	db 32, 80, 1, #60, 0, #18 ,%00000000,%00001011
	db 40, #60,1, #60, 0, #14 ,%00000000,%00001110
	db 50, #e0,1, #60, 0, #14 ,%00000000,%00010011
	db 1,  20, 2, #40, 0, #13 ,%00000000,%00100000
	db #ff

	org levels_mem+ levels_offset*3+#1d0
	;   123456789abcdef
	db "FROM DEPTH",#ff

	org levels_mem + levels_offset*3+#1f0
;way_begin
	db 0
;way_end
		db 34
;way_begin_adr
	dw #0000	
; available towers from right to left
	db %01010000
; money on start level
	db 18





level5
	org levels_mem + levels_offset*4
;way
	db 1,1,1, 2,2,2,2,1,1, 3,3,3,3,3,3,3, 1,1, 2,2,2, 1,1, 3,3,3, 1,1
	db 2,2,2,2,2,  0,0,0,0, 2,2, 1,1,1,1,1,1, 3,3,1, 3,3,1
	db #ff

	include "levels/lev5.asm"


	org levels_mem + levels_offset*4+#130
;waves
	db 12, 4,0, #a0, 0, #14 ,%00000000,%00000011
	db 14, 30, 0, #20, 0, #12 ,%00000000,%00000011
	db 20, 50, 0, #20, 0, #12 ,%00000000,%00000110
;4
	db 10, 40, 0, #40, 0, #1a ,%00000000,%00000111	; begin wait,0,  wait
	db 20, 60, 0, #20, 0, #14 ,%00000000,%00001010
	db 10, 130,0, #20, 0, #34 ,%00000000,%00000011
;7	
	db 20, #80,0, #50, 0, #16 ,%00000000,%00001110
;8	
	db 20, 190,0, #20, 0, #18 ,%00000000,%00011001
;9	
	db 15 ,#0f0,0,#20, 0, #24 ,%00000000,%00010001
;0a	
	db 32, #00,1, #40, 0, #14 ,%00000000,%00010111
;0b	
	db 30, #40,1, #30, 0, #10 ,%00000000,%00011101
;0c	
	db 50, #a8,1, #30, 0, #13 ,%00000000,%00011111
;0e	
	db 1, #040,2, #40, 0, #13 ,%00000000,%00100000
	
	db #ff

	org levels_mem+ levels_offset*4+#1d0
	;   123456789abcdef
	db "SHORT CUT",#ff

	org levels_mem + levels_offset*4+#1f0
; way_begin
	db 64
;way_end		
	db 51
;way_begin_adr	
	dw #0800	
; available towers from right to left
	db %11010000
; money on start level
	db 18





level6
	org levels_mem + levels_offset*5
; 1-right, 0-left, 2-down, 3-up
	db 3,0,0,3,0,0, 3,3,3,3,3,3,3, 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   2
	db 1,2,2,2,2,0, 0,3, 0,3, 0,3, 0,0,2, 0,0,3, 0,0,0,2, 2,1, 2,1,  1,   2, 1,   1,   1,   1,   2,1,   2, 1,   1,   2
	db #ff

; map
	include "levels/lev6.asm"

	org levels_mem + levels_offset*5 +#130
; kolvo vragov, base energy, begin wait,0,  wait ,enemy_bit_list
	db 12, 8,  0, #80, 0, #03 ,%00000000,%00000001		; !!! 50 enemys with little waits
	db 25, 21, 0, #20, 0, #12 ,%00000000,%00000011		; only 28 enemy on screen
	db 28, 55, 0, #20, 0, #11 ,%00000000,%00000101
	db 10, 78, 0, #40, 0, #12 ,%00000000,%00000011

	db 13, 120,0, #20, 0, #18 ,%00000000,%00001000
	db 10, 150,0, #20, 0, #1e, %00000000,%00000100
	db 20, 130,0, #50, 0, #10 ,%00000000,%00000111
	db 30, 190,0, #20, 0, #16 ,%00000000,%00000011
	
	db 15, 230,0, #20, 0, #23 ,%00000000,%00001010
	db 32, 14, 1, #a0, 0, #1e ,%00000000,%00001011
	db 40, 40, 1, #a0, 0, #16 ,%00000000,%00000111
	db 40, 110, 1, #a0, 0, #10 ,%00000000,%00001100
	db 1,  20, 2, #40, 0, #13 ,%00000000,%00010000
	db #ff

	org levels_mem+ levels_offset*5+#1d0
	;   123456789abcdef
	db "TOP SANITATION",#ff

	org levels_mem + levels_offset*5+#1f0
;way_begin
	db 165
;way_end
		db 34
;way_begin_adr
	dw #1668	
; available towers from right to left
	db %01010000
; money on start level
	db 22




level7
	org levels_mem + levels_offset*6
; 1-right, 0-left, 2-down, 3-up
	db 3,3,3, 0,3,3,3,3,3,3, 1,   1,   1,   2,1,   2,2,2,2,1, 2,2,2,1, 1,   3,1,   3
	db 3,3,3,3,3, 1,   3, 1,   1,   1,   2,2,2,2,2,2,  1,   2, 2,2
	db #ff

; map
;	include "levels/lev6.asm"
	db  2, 196,   3,   7,   7,   9,  10,   7,  11,   7, 196,   7,   7,   7, 165,   3
	db  4, 226,  67,  67,  67,  39,  12, 224,  12,  47,  67,  67,  67,  67, 166,  13
	db  3,  67,  57,  46,  67,  67, 120, 116, 118, 228,  67,  57,  46,  67, 166,  11
	db  8,  67,   7,   7, 165,  67, 115, 191, 230,  67, 177,   8,   8,  67, 166,   8
	db  7,  67,   7,   7, 166,  67, 241, 116, 231,  67, 178, 172, 175,  67, 166,  15
	db  3,  67, 236, 237, 166,  67, 123,  45,  96,  67, 178, 173, 176,  67, 166,   2
	db 2,  67, 238, 239, 166,  67,  67,  44,  97,  67, 178,   7,   1,  67, 167,   4
	db  3,  67,  67,  10, 166, 192,  67,  43, 122,  67, 178,  12,   8,  67,  67,   3
	db  8,  46,  67,   7, 167, 171,  67,  18,  67,  67, 179,  10,  10,  46,  67,   7
	db  3,   2,  67,  14, 168, 183,  67,  67,  67, 183, 180,  15,   7,   9,  67,  10
	db 211, 216, 194, 151, 169, 184,  83,  98, 104, 184, 181, 158,   6,   4, 220,   2




	org levels_mem + levels_offset*6 +#130
; kolvo vragov, base energy, begin wait,0,  wait ,enemy_bit_list
	db 12, 8,  0, #80, 0, #03 ,%00000000,%00000001		; !!! 50 enemys with little waits
	db 25, 21, 0, #20, 0, #12 ,%00000000,%00000011		; only 28 enemy on screen
	db 28, 55, 0, #20, 0, #11 ,%00000000,%00000101
	db 10, 78, 0, #40, 0, #12 ,%00000000,%00000011

	db 13, 100,0, #20, 0, #18 ,%00000000,%00000100
	db 10, 130,0, #20, 0, #18, %00000000,%00001000
	db 20, 130,0, #50, 0, #10 ,%00000000,%00000111
	db 30, 190,0, #20, 0, #16 ,%00000000,%00000011
	
	db 15, 230,0, #20, 0, #23 ,%00000000,%00001010
	db 32, 14, 1, #50, 0, #1e ,%00000000,%00001011
	db 40, 40, 1, #50, 0, #16 ,%00000000,%00000111
	db 40, 110,1, #50, 0, #10 ,%00000000,%00001100
	db 1,  20, 2, #40, 0, #13 ,%00000000,%00010000
	db #ff

	org levels_mem+ levels_offset*6+#1d0
	;   123456789abcdef
	db "MACHINE GUN!",#ff

	org levels_mem + levels_offset*6+#1f0
;way_begin
	db 162
;way_end
		db 0
;way_begin_adr
	dw #1662	
; available towers from right to left
	db %00110000
; money on start level
	db #18






level8
	org levels_mem + levels_offset*7
; 1-right, 0-left, 2-down, 3-up
	db 1,1, 1, 2,2,0,2,2,0,2,2,2,  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,  3,1,3,3,0
	db 3,3,0,3,3,0,0,0,0,0,0,3, 1,   1,   1,   1,   1,   1,   1,   1,   2,1

	db #ff

; map
;	include "levels/lev6.asm"
	db      171, 171, 171, 171, 203,  65,  67,  67,  67,  67,  67,  67,  67,  67,  67, 127
	db 	194,  67,  67, 183, 180,  65, 113, 114,  68,  68, 105, 106, 107,  11,  67, 220
	db 	  6,   7,   8, 184, 180,  64,  61,  61,  61,  61,  63, 203,  67,  13,   7, 151
	db 	 10,  12,  67, 185, 180,  59,  92,  93,  93,  94,  58, 180,  67,  56,  11, 150
	db 	  6,   7,  67,  15, 180,  59,  90, 236, 237, 109,  58, 180,  11,  67,   6, 151
	db 	213, 183,  67,   9, 180,  59,  90, 238, 239, 109,  58, 180,  12,  67, 183, 209
	db 	215, 184,  57,   1, 180,  59, 233, 234, 234, 235,  58, 180,   7,  46, 184, 211
	db 	215, 184,  39,  47, 196,  62,  61,  61,  61,  61,  60, 199,  39,  67, 185, 212
	db 	216, 185,  67, 228, 187, 192, 192, 192, 192, 192, 192, 192, 189, 226,  50,  49
	db 	  3,   4,  46, 178, 121, 129, 137, 137, 137, 137, 137, 137, 224, 131, 137, 132
	db 	  4,   1,   2, 178,  88, 133,  88,  89, 124, 124, 124, 124, 124, 124, 124, 136




	org levels_mem + levels_offset*7 +#130
; kolvo vragov, base energy, begin wait,0,  wait ,enemy_bit_list
	db 11, 15, 0, #80, 0, #20 ,%00000000,%00000001		; !!! 50 enemys with little waits
	db 21, 30, 0, #20, 0, #12 ,%00000000,%00000011		; only 28 enemy on screen
	db 18, 80, 0, #20, 0, #0a ,%00000000,%00000101
	db 29, 95, 0, #40, 0, #04 ,%00000000,%00000011

	db 19, 82, 0, #20, 0, #14 ,%00000000,%00000100
	db 13, 93, 0, #20, 0, #10, %00000000,%00001000
	db 20, 88, 0, #50, 0, #04 ,%00000000,%00000100
	db 30, 161,0, #20, 0, #20 ,%00000000,%00000011
	
	db 25, 150,0, #20, 0, #07 ,%00000000,%00001100
	db 16, 13, 1, #50, 0, #17 ,%00000000,%00001011
	db 30, 61, 1, #50, 0, #14 ,%00000000,%00010111
	db 20, 114,1, #50, 0, #25 ,%00000000,%00011100
	db 1,  22, 2, #40, 0, #13 ,%00000000,%00100000
	db #ff

	org levels_mem+ levels_offset*7+#1d0
	;   123456789abcdef
	db "TOUCH AND GO!",#ff

	org levels_mem + levels_offset*7+#1f0
;way_begin
	db 16
;way_end
		db 0
;way_begin_adr
	dw #40
; available towers from right to left
	db %11110000
; money on start level
	db #19




level9
	org levels_mem + levels_offset*8
;  0-left, 1-right, 2-down, 3-up
	db 2,2,2,2,2,2,2,2,2,2
	db 0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
	db 3,3,3,3,3,3,3,3,3,3
	db 1,1,1,1,1,1,1,1,1,1,2,1,2,1,2,2,2,2,2
	db 0,0,2,0,0,0,0,0,0,0,3,0,3,3,3,3,1,3
	db 1,1,1,1,1,1,2,2,2,2
	db 0,0,0,0,3,3,1,1
	db #ff

; map

	db      132,  67,  67,  67,  67, 107,  67,  67,  67,  67,  67, 195, 212, 137, 213, 194
	db	133, 183,  57,  11,   3,   4,  16,   2,   3,   4,   1, 156, 228,  57,  10,  67
	db	196, 184,   2,  47,  67, 107,  67,  67,  67,  67, 207, 158, 107,  67,   7,  67
	db	177, 184,  11, 228,  67, 152, 191, 121, 121, 127, 107, 158,   6, 183,  11,  67
	db	178,  67,  47, 107,  43, 150, 113, 114, 220, 122, 209, 157,  11, 184,   6, 107
	db	224, 172, 175, 183,  43, 151, 208, 110, 111, 125, 209, 157,   8, 184,  12,  67
	db	178, 173, 176, 184,  43, 150, 113, 114,  68, 105, 209, 157,  17, 185,   5,  67
	db	178,  67,  50, 185, 107, 155,  88,  89, 124, 110, 111, 162,  67, 226,  15,  67
	db	178,  67,   4,  46,  67,  67,  67, 107,  67,  67,  67,  67,  57,  14,   4,  67
	db	179, 226,   5,   7,   8,   5,   6,   7,   8,   5,   7,   1,   6,  15,  17,  67
	db	132,  67,  67, 107, 225, 225, 113, 114,  68,  68, 105, 106, 107, 206, 107,  67


	org levels_mem + levels_offset*8 +#130
; kolvo vragov, base energy, begin wait,0,  wait ,enemy_bit_list
	db 11, 15, 0, #80, 0, #20 ,%00000000,%00000010		; !!! 50 enemys with little waits
	db 21, 30, 0, #20, 0, #12 ,%00000000,%00000011		; only 28 enemy on screen
	db 18, 67, 0, #20, 0, #0a ,%00000000,%00000101
	db 29, 92, 0, #40, 0, #04 ,%00000000,%00000111

	db 19, 122, 0, #20, 0, #14 ,%00000000,%00001000
	db 13,  93, 0, #20, 0, #10, %00000000,%00010000
	db 28, #75, 0, #50, 0, #04 ,%00000000,%00001100
	db 32, #c0, 0, #20, 0, #20 ,%00000000,%00001011
	
	db 25, 10,  1, #20, 0, #0a ,%00000000,%00011100
	db 19, #43, 1, #50, 0, #17 ,%00000000,%00001011
	db 30, #c0, 1, #50, 0, #14 ,%00000000,%00011111
	db 20, #f0, 1, #50, 0, #25 ,%00000000,%00111100
	db 1,  #a0, 2, #40, 0, #13 ,%00000000,%00100000
	db #ff

	org levels_mem+ levels_offset*8+#1d0
	;   123456789abcdef
	db "SPIRAL DEFEND",#ff

	org levels_mem + levels_offset*8+#1f0
;way_begin
	db 15
;way_end
		db 0
;way_begin_adr
	dw #021c
; available towers from right to left
	db %11110000
; money on start level
	db #19

