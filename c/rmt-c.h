#ifndef RMT_C_H
#define RMT_C_H

// Interface to RMT player
extern void __fastcall__ rmt_init(const char *data, unsigned char song);
extern void __fastcall__ rmt_start(void);
extern void __fastcall__ rmt_stop(void);

// Global volume fading - only enabled if feature is defined
// 0 means normal volume, 255 means complete silent.
extern unsigned char rmt_global_volume_fade;

// Interface for playing SFX - only available if feature is defined

// Sets channel to play as SFX
extern unsigned char rmt_sfx_channel;
// Sets note to play
extern unsigned char rmt_sfx_note;
// Sets SFX volume level (from $10 to $F0)
extern unsigned char rmt_sfx_volume;
extern unsigned char rmt_sfx_go;

// Signal the player to play a SFX with given instrument
#define rmt_sfx_play( instrument ) \
    do { rmt_sfx_go = instrument | 128; } while(0)

// Wait for SFX to start.
#define rmt_sfx_wait() while( rmt_sfx_go > 127 );

// Wait for VBI
extern void __fastcall__ rmt_wait_vbi(void);

#endif // RMT_C_H
