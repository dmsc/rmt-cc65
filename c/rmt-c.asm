; C interface for RMT player

        .define STEREOMODE 0

        .segment "STARTUP"
        .include "rmtplayr.asm"

        .export _rmt_init
        .export _rmt_start
        .export _rmt_stop
        .export _rmt_song_data
        .export _rmt_wait_vbi

        .import popax
        .import RMT_SONG_DATA
        .include "atari.inc"

        ; Export volume control depending on features
    .if FEAT_GLOBALVOLUMEFADE
        .export _rmt_global_volume_fade
        _rmt_global_volume_fade = RMTGLOBALVOLUMEFADE
    .endif

        ; Export SFX control depending on features
    .if FEAT_SFX
        .export _rmt_sfx_channel
        .export _rmt_sfx_note
        .export _rmt_sfx_volume
        .export _rmt_sfx_go
    .endif

_rmt_song_data = RMT_SONG_DATA

        .code

_rmt_init:
        pha
        jsr     popax
        tay
        jmp     rmt_init

_rmt_wait_vbi:
        lda     $14
wait:   cmp     $14
        beq     wait
xit:
        rts

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

_rmt_stop:
        ldy     old_vbi
        ldx     old_vbi+1
        jsr     set_vbi
        lda     #0
        sta     old_vbi+1
        jmp     rmt_silence

vbi:
        ldx $D014
        dex
        beq do_play  ; On PAL, play in all ticks
        dec play_time
        bne do_play  ; On NTSC, skip after 5 ticks
        lda #6
        sta play_time
        bne exit_vbi
play_time:
        .byte 6
do_play:
    .if FEAT_SFX
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
exit_vbi:
        jmp     $0000

