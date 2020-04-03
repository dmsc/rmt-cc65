; C interface for RMT player

        .define STEREOMODE 0

        .segment "STARTUP"
        .include "rmtplayr.asm"

        .export _rmt_init
        .export _rmt_start
        .export _rmt_stop
        .export _rmt_song_data

        .import popax
        .import RMT_SONG_DATA
        .include "atari.inc"

_rmt_song_data = RMT_SONG_DATA

        .code

_rmt_init:
        pha
        jsr     popax
        tay
        jmp     rmt_init


_rmt_start:
        lda     old_vbi+1
        bne     xit
        lda     VVBLKD
        sta     old_vbi
        lda     VVBLKD+1
        sta     old_vbi+1
        ldy     #<vbi
        ldx     #>vbi
set_vbi:
        lda     #7
        jmp     SETVBV
xit:
        rts

_rmt_stop:
        lda     #0
        ldy     old_vbi
        ldx     old_vbi+1
        sta     old_vbi+1
        jsr     set_vbi
        jmp     rmt_silence

vbi:
    .if FEAT_SFX
        .export _rmt_sfx_channel
        .export _rmt_sfx_note
        .export _rmt_sfx_volume
        .export _rmt_sfx_go
_rmt_sfx_volume = RMTSFXVOLUME
_rmt_sfx_go = *+1
        lda     #0
        bpl     skip_sfx
        asl
        tay
_rmt_sfx_channel = *+1
        ldx     #3
_rmt_sfx_note = *+1
        lda     #12
        jsr     rmt_sfx
        lsr     _rmt_sfx_go
skip_sfx:
    .endif
        jsr     rmt_play
old_vbi = *+1
        jmp     $0000

