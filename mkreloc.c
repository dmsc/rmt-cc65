#include <stdio.h>
#include <stdlib.h>

static int get_word(FILE *f)
{
    int c1, c2;
    if( 0 > (c1 = getc(f)) || 0 > (c2 = getc(f)) )
        return -1;
    return (c1 & 0xFF) | ((c2 << 8)&0xFF00);
}

static int rword(unsigned char *data, int i)
{
    return data[i] | (data[i+1]<<8);
}

static int read_rmt(const char *fname)
{
    int err = -1;
    FILE *f = fopen(fname, "rb");
    if( !f )
    {
        perror(fname);
        return err;
    }
    int start, end;
    if( get_word(f) < 0 ||
        (start = get_word(f)) < 0 ||
        (end = get_word(f)) < 0 ||
        end < start )
    {
        fprintf(stderr,"%s: invalid RMT file\n", fname);
        goto err_close;
    }
    int len = end+1-start;
    unsigned char *buf = malloc(len);
    if( !buf )
    {
        perror(fname);
        goto err_close;
    }
    if( 1 != fread(buf, len, 1, f) )
    {
        fprintf(stderr,"%s: short RMT file\n", fname);
        goto err_fbuf;
    }
    if( buf[0] != 'R' || buf[1] != 'M' || buf[2] != 'T' ||
        (buf[3] != '4' && buf[3] != '8') )
    {
        fprintf(stderr,"%s: invalid signature, not an RMT file\n", fname);
        goto err_fbuf;
    }

    printf("; RMT%c file converted from %s with mkreloc\n"
           "; Original size: $%04x bytes @ $%04x\n", buf[3], fname, len, start);

    // Read parameters from file:
    int rtracks = buf[3] - '0';
    int instrtab = rword(buf,8) - start;
    int trklotab = rword(buf,10) - start;
    int trkhitab = rword(buf,12) - start;
    int songptr  = rword(buf,14) - start;
    if( instrtab != 0x10 )
    {
        fprintf(stderr,"%s: malformed file (instrument table = $%04x)\n", fname, instrtab);
        goto err_fbuf;
    }
    int numinstr = trklotab - instrtab;
    if( numinstr < 0 || (numinstr & 1) || trklotab >= len )
    {
        fprintf(stderr,"%s: malformed file (num instruments = $%04x)\n", fname, numinstr);
        goto err_fbuf;
    }
    int numtrk = trkhitab - trklotab;
    if( numtrk < 0 || numtrk > 0xFF || trkhitab >= len )
    {
        fprintf(stderr,"%s: malformed file (num tracks = $%04x)\n", fname, numtrk);
        goto err_fbuf;
    }

    // Read all tracks addresses searching for the lowest address
    int first_track = 0xFFFF;
    for(int i=0; i<numtrk; i++)
    {
        int x = buf[trklotab+i] + (buf[trkhitab+i]<<8);
        if( x )
        {
            x -= start;
            if( x < 0 || x >= songptr )
            {
                fprintf(stderr,"%s: malformed file (track %d = $%04x [0:$%x])\n",
                        fname, i, x, songptr);
                goto err_fbuf;
            }
            if( x < first_track )
                first_track = x;
        }
    }
    // Read all instrument addresses searching for the lowest address
    int first_instr = 0xFFFF;
    for(int i=0; i<numinstr; i+=2)
    {
        int x = rword(buf,instrtab+i);
        if( x )
        {
            x -= start;
            if( x < 0 || x >= first_track )
            {
                fprintf(stderr,"%s: malformed file (instrument %d = $%04x [0:$%x])\n",
                        fname, i, x, first_track);
                goto err_fbuf;
            }
            if( x < first_instr )
                first_instr = x;
        }
    }

    if( first_instr < 0 || first_instr >= len ||
        first_track < 0 || first_track >= len )
    {
        fprintf(stderr,"%s: malformed file (first track/instr = $%04x/$%04x)\n", fname,
                first_track, first_instr);
        goto err_fbuf;
    }
    if( trkhitab + numtrk != first_instr )
    {
        fprintf(stderr,"%s: malformed file (track/instr = $%04x/$%04x)\n", fname,
                trkhitab + numtrk, first_instr);
        goto err_fbuf;
    }
    if( first_track < first_instr )
    {
        fprintf(stderr,"%s: malformed file (track < instr = $%04x/$%04x)\n", fname,
                first_track, first_instr);
        goto err_fbuf;
    }

    // Write assembly output
    printf("    .export RMT_SONG_DATA\n"
           "RMT_SONG_DATA:\n"
           "start:\n"
           "    .byte \"RMT%c\"\n"
           "    .byte $%02x", buf[3], buf[4]);
    for(int i=5; i<8; i++)
        printf(", $%02x", buf[i]);
    printf("\nptr_instrstable:     .word instrstable     ; start + $%04x\n"
             "ptr_trackslbstable:  .word trackslbstable  ; start + $%04x\n"
             "ptr_trackshbstable:  .word trackshbstable  ; start + $%04x\n"
             "ptr_song:            .word songdata        ; start + $%04x\n",
             instrtab, trklotab, trkhitab, songptr);
    // List of instruments:
    int *instr_pos = calloc(65536,sizeof(int));
    printf("instrstable:");
    for(int i=0; i<numinstr; i+=2)
    {
        int loc = rword(buf,i+instrtab) - start;
        if( i % 16 == 0 )
            printf("\n    .word ");
        else
            printf(", ");
        if( loc >= first_instr && loc < first_track && loc < len)
        {
            instr_pos[loc] = (i>>1) + 1;
            printf("instr_%d", i>>1);
        }
        else if ( loc == -start )
            printf("  $0000");
        else
        {
            fprintf(stderr,"%s: malformed file (instr %d = $%04x [%x:%x])\n", fname,
                    i, loc, first_instr, first_track);
            goto err_finstr;
        }
    }
    // List of tracks:
    int *track_pos = calloc(65536,sizeof(int));
    printf("\n"
           "trackslbstable:");
    for(int i=0; i<numtrk; i++)
    {
        int loc = buf[i+trklotab] + (buf[i+trkhitab]<<8) - start;
        if( i % 8 == 0 )
            printf("\n    .lobytes ");
        else
            printf(", ");
        if( loc >= first_track && loc < songptr && loc < len)
        {
            track_pos[loc] = i + 1;
            printf("track_%02x", i);
            // printf("(start + $%04x)", loc);
        }
        else if ( loc == -start )
            printf("$0000");
        else
        {
            fprintf(stderr,"%s: malformed file (track %d = $%04x [%x:%x)\n", fname,
                    i, loc, first_track, songptr);
            goto err_ftrack;
        }
    }
    printf("\n"
           "trackshbstable:");
    for(int i=0; i<numtrk; i++)
    {
        int loc = buf[i+trklotab] + (buf[i+trkhitab]<<8) - start;
        if( i % 8 == 0 )
            printf("\n    .hibytes ");
        else
            printf(", ");
        if( loc >= first_track && loc < songptr && loc < len)
            printf("track_%02x", i);
            // printf("(start + $%04x)", loc);
        else if ( loc == -start )
            printf("$0000");
        else
        {
            fprintf(stderr,"%s: malformed file (track %d = $%04x [%x:%x)\n", fname,
                    i, loc, first_track, songptr);
            goto err_ftrack;
        }
    }
    // Print instruments
    printf("\n; Instrument data");
    for(int i=first_instr, l=0; i<first_track; i++, l++)
    {
        if( instr_pos[i] )
        {
            printf("\ninstr_%d:", instr_pos[i]-1);
            instr_pos[i] = 0;
            l = 0;
        }
        if( l % 16 == 0 )
            printf("\n    .byte ");
        else
            printf(", ");
        printf("$%02x", buf[i]);
    }
    for(int i=0; i<65536; i++)
    {
        if( instr_pos[i] != 0 )
            fprintf(stderr, "%s: missing instrument data for %d at $%04x\n",
                    fname, instr_pos[i], i);
    }
    // Print tracks
    printf("\n; Track data");
    for(int i=first_track, l=0; i<songptr; i++, l++)
    {
        if( track_pos[i] )
        {
            printf("\ntrack_%02x:", track_pos[i]-1);
            track_pos[i] = 0;
            l = 0;
        }
        if( l % 16 == 0 )
            printf("\n    .byte ");
        else
            printf(", ");
        printf("$%02x", buf[i]);
    }
    for(int i=0; i<65536; i++)
    {
        if( track_pos[i] != 0 )
            fprintf(stderr, "%s: missing track data for %d at $%04x\n",
                    fname, track_pos[i], i);
    }
    // Print SONG
    printf("\n; Song data\nsongdata:");
    int jmp = 0, l = 0;
    for(int i=songptr; i<len; i++, l++)
    {
        if( jmp == -2 )
        {
            jmp = 0x10000 + buf[i];
            continue;
        }
        else if( jmp > 0 )
        {
            jmp = (0xFFFF & (jmp | (buf[i]<<8))) - start;
            if( 0 == ((jmp - songptr) % rtracks) && jmp >= songptr && jmp < len )
            {
                int lnum = (jmp - songptr) / rtracks;
                printf(", <line_%02x, >line_%02x", lnum, lnum);
            }
            else
            {
                fprintf(stderr,"%s: malformed file (song jump bad $%04x [%x:%x])\n", fname,
                        jmp, songptr, len);
                printf(", <($%x+songdata), >($%x+songdata)", jmp, jmp);
            }
            jmp = 0;
            // Allows terminating song on last JUMP
            if( i+1 == len && rtracks == 8 )
                l += 4;

            continue;
        }
        else if( jmp == -1 )
            jmp = -2;

        if( l % rtracks == 0 )
        {
            printf("\nline_%02x:  .byte ", l / rtracks);
        }
        else
            printf(", ");
        printf("$%02x", buf[i]);
        if ( buf[i] == 0xfe )
        {
            if( (l % rtracks) != 0 )
                fprintf(stderr,"%s: malformed file (misplaced jump)\n", fname);
            else
                jmp = -1;
        }
    }
    printf("\n");
    if( jmp )
        fprintf(stderr,"%s: malformed file (song jump incomplete)\n", fname);
    else if( 0 != l%rtracks )
        fprintf(stderr,"%s: malformed file (song incomplete - %d %d)\n", fname, rtracks, len-songptr);
    else
        err = 0;

err_ftrack:
    free(track_pos);
err_finstr:
    free(instr_pos);
err_fbuf:
    free(buf);
err_close:
    fclose(f);
    return err;
}

int main(int argc, char **argv)
{
    if( argc != 2 )
    {
        fprintf(stderr, "%s: invalid number of arguments.\n\n"
                "Usage: %s [file.rmt]\n", argv[0], argv[0]);
        return 1;
    }
    if( read_rmt(argv[1]) )
        return 1;
    return 0;

}
