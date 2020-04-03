; RMT4 file converted from sample.rmt with mkreloc
; Original size: $02ab bytes @ $4000
    .export RMT_SONG_DATA
RMT_SONG_DATA:
start:
    .byte "RMT4"
    .byte $40, $09, $01, $01
ptr_instrstable:     .word instrstable     ; start + $0010
ptr_trackslbstable:  .word trackslbstable  ; start + $0022
ptr_trackshbstable:  .word trackshbstable  ; start + $0025
ptr_song:            .word songdata        ; start + $029b
instrstable:
    .word instr_0, instr_1, instr_2, instr_3, instr_4, instr_5, instr_6, instr_7
    .word instr_8
trackslbstable:
    .lobytes track_00, track_01, track_02
trackshbstable:
    .hibytes track_00, track_01, track_02
; Instrument data
instr_0:
    .byte $0c, $0c, $0d, $0d, $00, $00, $80, $00, $00, $00, $00, $00, $00, $44, $0a, $00
instr_1:
    .byte $0c, $0c, $25, $25, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $1a, $90
    .byte $ff, $1a, $a0, $ee, $1a, $80, $dd, $1a, $60, $cc, $1a, $50, $aa, $1a, $40, $77
    .byte $1a, $30, $22, $1a, $20, $00, $10, $00
instr_2:
    .byte $0c, $0c, $2e, $10, $00, $00, $98, $00, $00, $00, $00, $00, $00, $ff, $18, $80
    .byte $ff, $18, $80, $ff, $18, $60, $ee, $18, $40, $dd, $18, $20, $cc, $18, $10, $bb
    .byte $18, $10, $aa, $18, $10, $99, $18, $10, $88, $18, $10, $77, $18, $10, $66, $18
    .byte $10
instr_3:
    .byte $0c, $0c, $3d, $3d, $00, $00, $00, $00, $00, $00, $00, $00, $00, $dd, $18, $60
    .byte $dd, $18, $60, $dd, $18, $60, $dd, $18, $60, $dd, $18, $b0, $dd, $18, $b0, $dd
    .byte $18, $b0, $dd, $18, $b0, $88, $18, $80, $99, $18, $60, $aa, $18, $50, $bb, $18
    .byte $40, $cc, $18, $30, $dd, $18, $20, $ee, $18, $18, $ff, $18, $10, $00, $10, $00
instr_4:
    .byte $0c, $0c, $55, $55, $00, $00, $00, $00, $00, $00, $00, $00, $00, $bb, $1a, $10
    .byte $bb, $18, $10, $bb, $18, $20, $bb, $18, $20, $bb, $18, $28, $bb, $18, $2c, $cc
    .byte $18, $30, $cc, $18, $30, $cc, $18, $30, $cc, $18, $30, $cc, $18, $38, $cc, $18
    .byte $3c, $dd, $18, $40, $dd, $18, $40, $dd, $18, $40, $dd, $18, $40, $dd, $18, $48
    .byte $dd, $18, $4c, $ee, $18, $50, $ee, $18, $50, $ee, $18, $50, $ff, $18, $50, $bb
    .byte $18, $40, $66, $18, $30, $00, $10, $00
instr_5:
    .byte $0c, $0c, $52, $52, $00, $00, $ff, $00, $00, $00, $00, $00, $00, $cc, $14, $01
    .byte $cc, $14, $02, $cc, $14, $01, $cc, $14, $02, $cc, $14, $01, $cc, $14, $02, $cc
    .byte $14, $01, $cc, $14, $02, $cc, $14, $01, $cc, $14, $02, $cc, $14, $02, $cc, $14
    .byte $02, $cc, $14, $01, $cc, $14, $02, $cc, $14, $01, $bb, $14, $02, $bb, $14, $01
    .byte $cc, $14, $02, $dd, $14, $01, $ff, $14, $02, $bb, $14, $03, $77, $14, $02, $33
    .byte $14, $02, $00, $14, $00
instr_6:
    .byte $0c, $0c, $25, $25, $00, $00, $00, $00, $00, $00, $00, $00, $00, $77, $1a, $20
    .byte $aa, $1a, $30, $cc, $1a, $40, $dd, $1a, $50, $ee, $1a, $60, $ff, $1a, $80, $ff
    .byte $1a, $a0, $33, $1a, $90, $00, $10, $00
instr_7:
    .byte $0c, $0c, $0d, $0d, $00, $00, $40, $00, $00, $00, $00, $00, $00, $ff, $4a, $31
instr_8:
    .byte $0c, $0c, $1c, $10, $00, $00, $80, $00, $00, $00, $00, $00, $00, $ff, $72, $2d
    .byte $ff, $02, $ff, $cc, $02, $ff, $99, $02, $00, $66, $02, $00, $33, $32, $01
; Track data
track_00:
    .byte $d0, $03, $7e, $cc, $03, $7e, $cc, $03, $7e, $ce, $03, $d0, $03, $d1, $03, $7e
    .byte $ce, $03, $7e, $ce, $03, $7e, $d3, $03, $7e, $d0, $03, $7e, $cc, $03, $7e, $cc
    .byte $03, $7e, $cc, $03, $7e, $ce, $03, $cc, $03, $cb, $03, $c9, $03, $c7, $03, $fe
    .byte $d0, $03, $7e, $cc, $03, $7e, $cc, $03, $7e, $ce, $03, $d0, $03, $d1, $03, $7e
    .byte $ce, $03, $7e, $ce, $03, $7e, $d3, $03, $7e, $d0, $03, $7e, $cc, $03, $7e, $ce
    .byte $03, $7e, $cb, $03, $7e, $cc, $03, $3e, $07
track_01:
    .byte $c0, $03, $3e, $05, $c0, $03, $7e, $c2, $03, $3e, $05, $c2, $03, $7e, $c0, $03
    .byte $3e, $05, $c0, $03, $7e, $c7, $03, $3e, $05, $c2, $03, $7e, $c0, $03, $3e, $05
    .byte $c0, $03, $7e, $c2, $03, $3e, $05, $c2, $03, $7e, $c0, $03, $fe, $c7, $03, $fe
    .byte $c0, $03, $7e, $c2, $03, $7e, $c0, $03, $fe
track_02:
    .byte $c7, $03, $3e, $05, $c7, $03, $7e, $c9, $03, $3e, $05, $c9, $03, $7e, $c7, $03
    .byte $3e, $05, $c7, $03, $7e, $cb, $03, $3e, $05, $c9, $03, $7e, $c7, $03, $3e, $05
    .byte $c7, $03, $7e, $c9, $03, $3e, $05, $c9, $03, $7e, $c7, $03, $fe, $cb, $03, $fe
    .byte $c7, $03, $3e, $07
; Song data
songdata:
line_00:  .byte $ff, $ff, $ff, $ff
line_01:  .byte $fe, $00, <line_00, >line_00
line_02:  .byte $00, $01, $02, $ff
line_03:  .byte $fe, $02, <line_02, >line_02
