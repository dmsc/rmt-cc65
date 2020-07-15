; FastBasic interface for RMT player
;
	.define	STEREOMODE 0

        .segment "ALIGNDATA"
        .include "rmtplayr.asm"

        .include "atari.inc"
        .export RMT_INIT, RMT_START, RMT_STOP

        ; Export volume control depending on features
    .if FEAT_GLOBALVOLUMEFADE
        .export RMT_GLOBAL_VOLUME_FADE
        RMT_GLOBAL_VOLUME_FADE = RMTGLOBALVOLUMEFADE
    .endif

        ; Export SFX control depending on features
    .if FEAT_SFX
        .export RMT_SFX_NOTE
        .export RMT_SFX_CHANNEL
        .export RMT_SFX_VOLUME
        .export RMT_SFX_GO
    .endif

        .segment "BYTECODE"

RMT_INIT:
        pla
        tax
        pla
        tay
        pla
        jmp     rmt_init

RMT_START:
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
        jmp     SETVBV  ;Start VBI routine

xit:    rts

RMT_STOP:
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
RMT_SFX_VOLUME = RMTSFXVOLUME
RMT_SFX_GO = *+1
        lda #$0
        bpl skip_sfx
        asl         ; * 2
        tay         ; Y = 2,4,..,16  instrument number * 2 (0,2,4,..,126)
RMT_SFX_CHANNEL = *+1
        ldx #3      ; channel (0..3 or 0..7 for stereo module)
RMT_SFX_NOTE = *+1
        lda #12     ; note (0..60)
        jsr rmt_sfx
        lsr RMT_SFX_GO  ; No more SFX
skip_sfx:
    .endif
        jsr rmt_play
old_vbi = *+1
exit_vbi:
        jmp $0000

