Relocatable RMT player for CC65 suite
=====================================

Set of samples and code to include Raster-Music-Tracker songs with
programs written in CC65 or in FastBasic.


How to convert a song to the relocatable source
-----------------------------------------------

To convert any RMT song to the relocatable format for inclusion in your program,
you need to:

- Export the song from RMT as a stripped file, select "File", "Export as...",
  file type of "RMT stripped song file".
  You can select any memory location, other options are according to your
  needs. Remember to copy the RMT FEATures presented, and write them to the
  file `rmt_feat.asm`, as this file is needed to assemble the player.

- Use the included C program `mkreloc` to convert the RMT file to a relocatable
  assembly file, use as:
  ```
  mkreloc my_song.rmt > tune.asm
  ```


Main player and sample song files
---------------------------------

The file rmtplayr.asm is the full RMT player source, converted to CA65 syntax.


Compile the C samples
---------------------

In the "c" folder, see the "sample.c" file for a simple example of
playing a tune and sound effects.

To compile the sample, use the following command line:

```
cl65  -tatari -o sample.xex sample.c --asm-include-dir .. rmt-c.asm ../tune.asm
```

The files are:
- sample.c : The sample program using the RMT interface.
- rmt-c.h : Header file with function and variable declarations, included from sample.c.
- rmt-c.asm : Assembly code for the C callable functions.


Compile the FastBasic samples
-----------------------------

In the "fastbasic" folder, see the "sample.fb" file for a simple example of
playing a tune and sound effects.

To compile, use the following command line:

```
fb  sample.fb  -X:--include-dir -X:..  rmt-fb.asm  ../tune.asm
```

The files are:
- sample.fb : The sample program using the RMT interface.
- rmt-fb.asm : Assembly code for the FastBasic callable functions.


