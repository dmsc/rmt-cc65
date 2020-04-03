
#include <conio.h>

#include "rmt-c.h"

// Song definitions
extern char rmt_song_data[];

// Use statics for local variables
#pragma static-locals (on)

int main(void)
{
    // Init RMT player
    rmt_init( rmt_song_data, 2);

    cputs("Press any key to start song\r\n");
    cgetc();

    rmt_start();
    // Play over channel 3, note 10, max volume
    rmt_sfx_channel = 3;
    rmt_sfx_note = 10;
    rmt_sfx_volume = 0xF0;

    cputs("Press 1 to 8 for SFX,\r\nany other key to end song\r\n");
    while(1) {
        unsigned char c = cgetc() - '0';
        if( c < 9 )
            rmt_sfx_play(c);
        else
            break;
    }

    rmt_stop();

    return 0;
}
