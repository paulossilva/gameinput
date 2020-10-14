



                OPT     --zxnext
                DEVICE	ZXSPECTRUMNEXT
                OUTPUT  build/input.bin

                org     $0000

; ******************************************************
; Game Input NextBASIC Driver
; By Paulo Silva
;
; October, 2020
;
; https://github.com/paulossilva/gameinput
;
; ******************************************************
;
;   This driver aims to ease game controller programming in NextBASIC by providing an easy-to-use and consistent API,
;   which prevents the programmer from dealing with low level details such as joystick/keyboard ports, bit masking, key mapping etc.
;   Even better, the Game Input Driver provides a way to call predefined NextBASIC procedures (PROCs) for you, so that there's no
;   need to test input data read from joystick or keyboard.
;   Read the Driver's API documentation for more detail.
;
; * Driver API calls:
;   - 1: read joystick port settings
;   - 2: change settings for joystick 1 (left joystick)
;   - 3: change settings for joystick 2 (right joystick)
;   - 4: read input from left joystick/keyboard
;   - 5: read input from right joystick/keyboard
;   - 6: map custom key
; ******************************************************
API_Entry:
                ld      c, b                    ; preserve call id
                djnz    bnot1
                jr      Read_Settings           ; API call id = 1; return NextREG 05 joystick settings
bnot1:          djnz    bnot2
                jr      Write_Settings          ; API call id = 2; write joystick 1 settings in NextREG 05
bnot2:          djnz    bnot3
                jr      Write_Settings          ; API call id = 3; write joystick 2 settings in NextREG 05
bnot3:          djnz    bnot4
                jr      Read_Input              ; API call id = 4; read left joystick
bnot4:          djnz    bnot5
                jr      Read_Input              ; API call id = 5; read right joystick
bnot5:          djnz    bnot6                   ; API call id = 6; maps custom key
reloc_api_entry_1:
                jp      Map_Customkey
bnot6:
                bit     7,c                     ; Standard API $80 - install driver 
                ld      de, $4205               ; set Kempston1 and Kempston 2 as default
                jr      nz, Write_Reg05
api_error:
                scf
                ret
; ******************************************************
; Read joystick settings
; Output:
;    BC - Joystick 1 settings value
;    DE - Joystick 2 settings value
; ******************************************************
Read_Settings:
                ld      d, b                    ; b = 0 -> d = 0
reloc_read_settings_1:
                call    Read_Reg05
                ld      e, a                    ; preserve settings
                and     $32                     ; select Joystick 2
                rlca                            ; adjust bitmask to Josystick 1's pattern 
                rlca
                ld      b, d                    ; b = 0
reloc_read_settings_2:
                call Lookup_Settings
                ld      a, e
                ld      e, c                    ; DE = Joystick 2 settings  
                and     $c8                     ; select Joystick 1
Lookup_Settings:
reloc_read_settings_3:
                ld      hl, Settings_table_end
                ld      c, 7
                cpdr
                inc     c                       ; c -> 1..7
                ret
; ******************************************************
; Read NextREG 05 subroutine
; bc - register (port) address
; Output:
;   a  - register contents
; ******************************************************
Read_Reg05:
                ld      bc, $243b               ; reads REG $05
                ld      a, $05                      
                out     (c), a               
                ld      b, $25                  ; bc = $253b                 
                in      a, (c)
                ret
Settings_table_start:
                db      %00000000               ; Sinclair 2
                db      %00001000               ; Kempston 2
                db      %01000000               ; Kempston 1
                db      %01001000               ; Megadrive 1
                db      %10000000               ; Cursor
                db      %10001000               ; Megadrive 2
Settings_table_end:
                db      %11000000               ; Sinclair 1
; ******************************************************
; Write joystick settings
;
; First, it looks up the joystick/keyboard's reading routine entry point and stores it in memory.
; Afterwards, it deals with the settings value and write it on NextReg 05.
; 
; Input:
;   DE - Joystick settings value
; Locals:
;   HL - pointer to joystick settings cache
; ******************************************************
Write_Settings:
                ld      d, b                    ; b = 0 -> d = 0; d 
                ld      a, e
                and     $07
                ret     z                       ; if e = 0, do nothing
reloc_write_settings_1:
                ld      hl, jump_table-2        ; store jump address in cache 
                add     hl, de
                add     hl, de                  
                ld      e, (hl)
                inc     hl
                ld      d, (hl)                 ; DE = (jump_table + c)
                ld      l, c                    
                bit     0, l                    ; joystick 1 ?
                jr      nz, jump_port2
reloc_write_settings_2:
                ld      (PORT1), de
                jr      jump_write
jump_port2:
reloc_write_settings_3:
                ld      (PORT2), de
jump_write:
                dec     a                       ; settings range 0..6
reloc_write_settings_4:
                ld      hl, Settings_table_start
                add     hl, a
                ld      d, (hl)                 ; d - Joystick 1 settings (xy00z000)
                ld      e, $37                  ; e - Joystick 1 bitmask
                bit     0, c                    ; if call id = 3, adjust rotation
                jr      z, Write_Reg05    
                srl     d                       ; Adjust settings and bitmask for Joystick 2
                srl     d
                ld      e, $cd
Write_Reg05:
reloc_write_settings_5:
                call    Read_Reg05              ; acc - register contents
                and     e                       ; mask unchanged bits
                or      d                       ; add settings bits
                nextreg 5, a                    ; write nextreg 5
                ret
; ******************************************************
; Read Input
; - Reads input from joystick port as defined in the firmware settings, which can have be of the following:
;   * Kempston 1
;   * Kempston 2
;   * Megadrive 1
;   * Megadrive 2
;   * Sinclair 1 (12345)
;   * Sinclair 2 (67890)
;   * Cursor (56780)
; ******************************************************
; Input:
; de - create PROC calls
; Output:
; c  - byte read from joystick port/keyboard
; ******************************************************
; locals:
; d    - byte read from joystick/keyboard
; bc   - maps joystick/keyboard ports to read
; hl   - points to mapped key data                
; ******************************************************
Read_Input:
                push    bc                      ; preserve call id
                ld      d, c                    
reloc_read_input_1:
                ld      ix, (PORT1)             ; load jump address from cache
                bit     0, c
                jr      z, jump_input
reloc_read_input_2:
                ld      ix, (PORT2)
jump_input:
reloc_read_input_3:
                ld      hl, CURSOR              ; keyboard mapping base address
                ld      c, 12                   ; keyboard mappings offset (bc=12)
                jp      (ix)
Sinclair_2:
                add     hl, bc
Sinclair_1:
                add     hl, bc
Cursor:
                ld      d, b                    ; b = 0 -> d = 0
                jr      Keyboard
Kempston_2:
Megadrive_2:
                ld      c, $37                  ; bc = $xx37
                jr      Joystick
Kempston_1:
Megadrive_1:
                ld      c, $1f                  ; bc = $xx1f
Joystick:
                ld      a, d                    ; call id
                in      d, (c)
                rrca                            ; After reading left joystick (call id=4), read CUSTOM keyboard
                jr      c, Return
reloc_read_input_4:
                ld      hl, CUSTOM              
; ******************************************************
; Read Keyboard mapped keys
; Input:
;   hl - keyboard mapping
; Output:
;   d  - pressed keys (same pattern used in joystick)
; Locals:
; bc - keyboard port to read
; e, a - temps
; ******************************************************
Keyboard:
                ld      c, $fe
                push    de
                ld      e, b                    ; b = 0 -> e = 0                 
                ld      b, 6                    ; # of keys to read
keyboard_loop:
                push    bc
reloc_read_input_5:
                call    Read_KEY                ; read a key and store it in e
                rr      e
                pop     bc
                djnz    keyboard_loop
                srl     e                       ; no more keys to read, adjust e 
                srl     e
                ld      a, e
                pop     de
                or      d
                ld      d, a
Return:
                ld      a, d                    ; preserve input byte read
                ex      af, af'
                pop     bc                      ; restore call id
                dec     e                       ; before return, check callback parameter
reloc_read_input_6:
                call    p, Callback             ; create callbacks
                ex      af, af'
                ld      c, a                    ; return joystick moves and keys pressed to NextBASIC
                ld      b, 0
                and     a                       ; clear carry flag to indicate sucess
                ret
; *************************************************
; Reads mapped key
;
; hl - MSB of keyboard port to read (lookup table)
; c  - must have LSB of keyboard port (always $FE)
; hl+1 - bitmask used to identify the key press (lookup table)
; a - mapped key condition
;     0 - key pressed
;     1 - key not pressed
;
; Output:
; Carry Flag
;     0 - key not pressed
;     1 - key pressed
; *************************************************
Read_KEY:
                ld      b, (hl)
                in      a, (c)                  ; read keyboard port for mapped key
                inc     hl
                and     (hl)                    ; get mapped key bit; clear carry flag
                inc     hl                      ; point to next mapped key
                ret     nz                      ; key not pressed
                scf                             ; key pressed
                ret                             
;*************************************************
; Creates callbacks to PROCs
; Input:
; d  - input byte
; c  - call id
; local:
; de - pointer to next NextBASIC line
; hl - pointer to statement to add
;*************************************************
Callback:
                ld      a, (NXTBNK)             
                cpl
                ret     nz                      ; Do nothing if running in a BANK (NXTLIN != $ff)
                ld      a, d                       
		ld	hl, (NXTLIN)		; Next BASIC line
		add	hl, 4			; 1st statement
		ex	hl, de
reloc_read_input_7:
		ld	hl, PROCS1
                bit     0, c                    ; check call id for left joystick
                jr      z, jump_procs2
reloc_read_input_8:
                ld      hl, PROCS2
jump_procs2:
                ld      c, 7                    ; # of PROC calls to add
add_proc_loop:
reloc_read_input_9:
                call    add_proc                
                dec     c
                jr      nz, add_proc_loop
end_proc:
		ld	a, $ea			; add REM token
		ld	(de), a
                ret
add_proc:
                push    bc
		ld	c, 6                    
                rrca
                jr      nc, next_proc          
		ldir                            ; add PROC call
next_proc:
                add     hl, bc                  ; adjust pointer to next PROC
                pop     bc
                ret
NXTBNK          defl    $5B77
NXTLIN		defl	$5C55
PROCS1:
        	db	$93, "R1()", $3a
 		db	$93, "L1()", $3a
		db	$93, "D1()", $3a
		db	$93, "U1()", $3a
		db	$93, "F1()", $3a
		db	$93, "F2()", $3a
		db	$93, "F3()", $3a
PROCS2:
        	db	$93, "R2()", $3a
 		db	$93, "L2()", $3a
		db	$93, "D2()", $3a
		db	$93, "U2()", $3a
		db	$93, "F4()", $3a
		db	$93, "F5()", $3a
		db	$93, "F6()", $3a
; ******************************************************
; Map custom key, by looking up in KEY_MAP
; DE - Key id to map to:
;  0 - RIGHT key
;  1 - LEFT key
;  2 - DOWN key
;  3 - UP key
;  4 - FIRE key
;  5 - FIRE 2 key
; HL - char code for the key to be mapped
; ******************************************************
Map_Customkey:
                ld      a, $05                  ; check DE value
                sub     e
                scf                             ; set carry flag to indicate failure
                ret     m
reloc_map_custom_1:
                ld      ix, CUSTOM              ; pointer to custom key mappings
                ld      d, b                    ; b = 0 -> d = 0
                ld      a, e
                add     e
                ld      e, a
                add     ix, de                  
Lookup_key:
                ld      a, l                    ; key to search for
reloc_map_custom_2:
                ld      hl, KEYBOARD_MAP
                ld      d, $fe                  ; 1st keyboard row
Lookup_row:
                ld      bc, 5                   ; # of keys to lookup in a row
                cpir                            ; do (HL)==A?; HL++; BC-- while (!Z && BC>0)
                jr      z, Key_Found
                rlc     d                       ; Key isn't in this row. Selects next row
                jr      c, Lookup_row           ; Lookup in the next one
                scf                             ; Not found. Set carry flag to indicate failure
                ret                              
Key_Found:
                ld      b, c                    ; c has key position in the row
                inc     b
                ld      a,$80                   ; prepare mask before rotation
Rotate_mask:
                rlc     a
                djnz    Rotate_mask             ; acc has bitmask
                ld      (ix+00), d              ; save keyboard port for custom Key
                ld      (ix+01), a              ; save bitmask for custom key
                and     a                       ; clear carry flag to indicate sucess
                ret
CUSTOM:                                         ; Keyboard port (MSB), bitmask     
                db      $df, $01                ; RIGHT (P)
                db      $df, $02                ; LEFT (O)
                db      $fd, $01                ; DOWN (A)
                db      $fb, $01                ; UP (Q)
                db      $7f, $01                ; FIRE 1 (SPACE)
                db      $7f, $04                ; FIRE 2 (M)
CURSOR:                                         ; Keyboard port (MSB), bitmask    
                db      $ef, $04                ; 8
                db      $f7, $10                ; 5
                db      $ef, $10                ; 6
                db      $ef, $08                ; 7
                db      $ef, $01                ; 0
                db      $7f, $04                ; M
SINCLAIR1:                                      ; Keyboard port (MSB), bitmask
                db      $f7, $08                ; 4
                db      $f7, $01                ; 1
                db      $f7, $02                ; 2
                db      $f7, $04                ; 3             
                db      $f7, $10                ; 5
                db      $7f, $04                ; M
SINCLAIR2:                                      ; Keyboard port (MSB), bitmask
                db      $ef, $02                ; 9                
                db      $ef, $10                ; 6
                db      $ef, $08                ; 7
                db      $ef, $04                ; 8
                db      $ef, $01                ; 0
                db      $7f, $04                ; M
KEYBOARD_MAP:
                db      "v","c","x","z",$00     ; fe - 11111110
                db      "g","f","d","s","a"     ; fd - 11111101
                db      "t","r","e","w","q"     ; fb - 11111011
                db      "5","4","3","2","1"     ; f7 - 11110111
                db      "6","7","8","9","0"     ; ef - 11101111
                db      "y","u","i","o","p"     ; df - 11011111
                db      "h","j","k","l",$0d     ; bf - 10111111
                db      "b","n","m",$00," "     ; 7f - 01111111
reloc_port1:
PORT1:          dw      Kempston_1
reloc_port2:
PORT2:          dw      Kempston_2
jump_table
reloc_jump_table_1:
                dw      Sinclair_2
reloc_jump_table_2:
                dw      Kempston_2
reloc_jump_table_3:
                dw      Kempston_1
reloc_jump_table_4:
                dw      Megadrive_1
reloc_jump_table_5:
                dw      Cursor
reloc_jump_table_6:
                dw      Megadrive_2
reloc_jump_table_7:
                dw      Sinclair_1

; this ensures the build is 512 long (not 100% sure why though - probably memory baseds)
	IF $ > 512
		DISPLAY "Driver code exceeds 512 bytes"
		shellexec "exit", "1"	
	ELSE
		defs    512-$
	ENDIF

reloc_start:
        defw	reloc_api_entry_1+2
        defw	reloc_read_settings_1+2
        defw    reloc_read_settings_2+2
        defw    reloc_read_settings_3+2
        defw    reloc_write_settings_1+2
        defw    reloc_write_settings_2+3
        defw    reloc_write_settings_3+3
        defw    reloc_write_settings_4+2
        defw    reloc_write_settings_5+2
        defw    reloc_read_input_1+3
        defw    reloc_read_input_2+3
        defw    reloc_read_input_3+2
        defw    reloc_read_input_4+2
        defw    reloc_read_input_5+2
        defw    reloc_read_input_6+2
        defw    reloc_read_input_7+2
        defw    reloc_read_input_8+2
        defw    reloc_read_input_9+2
        defw    reloc_map_custom_1+3
        defw    reloc_map_custom_2+2
        defw    reloc_port1+1
        defw    reloc_port2+1
        defw    reloc_jump_table_1+1
        defw    reloc_jump_table_2+1
        defw    reloc_jump_table_3+1
        defw    reloc_jump_table_4+1
        defw    reloc_jump_table_5+1
        defw    reloc_jump_table_6+1
        defw    reloc_jump_table_7+1
reloc_end: