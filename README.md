# NextBASIC Game Input Driver

This driver helps you to reduce code in any NextBASIC program (especially games) when reading input from joystick or keyboard.

For instance, in a particular game in NextBASIC reading input from joystick would require code similar to this:

```
DEFPROC ReadJoystick()
  LOCAL %k
# Reads joystick port 1
  %k=%IN 31
  IF %k&@10000=16 THEN PROC Fire()
# Masks only the movement bits (@1111)
  %k=%k&15
  IF %k=1 THEN PROC right(): ENDPROC
  IF %k=2 THEN PROC left(): ENDPROC
  IF %k=8 THEN PROC up(): ENDPROC
  IF %k=4 THEN PROC down(): ENDPROC
  IF %k=9 THEN PROC right(): PROC up(): ENDPROC
  IF %k=5 THEN PROC right(): PROC down(): ENDPROC
  IF %k=10 THEN PROC left(): PROC up(): ENDPROC
  IF %k=6 THEN PROC left(): PROC down(): ENDPROC
ENDPROC   
```
and if we need to read from keyboard, more code is needed:

```
DEFPROC ReadKeyboard()
  LOCAL %k
  %k=%31&IN 65278: %l=%31&IN 61438: %m=%31&IN 63486
  IF %k&2=0 THEN PROC Fire()
  IF %k&1 THEN ENDPROC 
  IF %l=19 THEN PROC right(): PROC up(): ENDPROC
  IF %l=11 THEN PROC right(): PROC down(): ENDPROC
  IF %m=15 THEN IF %l=23 THEN left(): PROC up(): ENDPROC
  IF %m=15 THEN IF %l=15 THEN left(): PROC down(): ENDPROC
  IF %l=27 THEN PROC right(): ENDPROC
  IF %m=15 THEN PROC left(): ENDPROC
  IF %l=23 THEN PROC up(): ENDPROC
  IF %l=15 THEN PROC down(): ENDPROC
ENDPROC 
```

With the Game Input Driver, you can replace all the above code with only a couple of lines:

```
DEFPROC ReadJoystickKeyboard()
  DRIVER 125, 4, 1
  REM 12345678901234567890123456789012345678901234567890
ENDPROC
```
And that's it!! Really!!

More complexity would be added to your code if you want to let the player customise the keys used to control the game. Usually you would have to deal with I/O ports, masks and key mappings.
However, with the help of the Game Input Driver, all you need to do is just say what keys you want to map:

```
PROC SetCustomKeys()
  DRIVER 125, 6, 0, CODE "d": REM RIGHT
  DRIVER 125, 6, 1, CODE "a": REM LEFT
  DRIVER 125, 6, 2, CODE "s": REM DOWN
  DRIVER 125, 6, 3, CODE "w": REM UP
  DRIVER 125, 6, 4, CODE "p": REM FIRE 1
  DRIVER 125, 6, 5, CODE "o": REM FIRE 2
ENDPROC
```

And you're good to go!!

Finally, your NextBASIC program will grant support for all joystick interfaces supported by the ZX Spectrum Next firmware for free, including Kempston, Megadrive, Sinclair and Cursor, on both joystick ports. Indeed, you can let the player decide which interface he wants to use in your game and the Game Input Driver will set everything up for you. 

Read on the [API Documentation](https://github.com/paulossilva/gameinput/blob/master/docs/inputDriver_API.txt) on the docs folder and check out the Demo file [input_drv.bas](https://github.com/paulossilva/gameinput/blob/master/input_drv.txt) to see the driver in action and learn more on how to use it.

The following is a recording of the [demo program](https://github.com/paulossilva/gameinput/blob/master/input_drv.txt) in action:

[![Game Input Demo](https://i9.ytimg.com/vi/NbpzBdyLtQs/mq2.jpg?sqp=CKiBuPwF&rs=AOn4CLC0w2LNdz_tEyakZw7cAf4d96J21A)](https://youtu.be/NbpzBdyLtQs "Game Input Demo")

And here is a video showcasing the speed improvement obtained with the use of the driver in a NextBASIC game:

[![Game Input Comparison](https://i9.ytimg.com/vi/8Hs9BYerIzg/mq2.jpg?sqp=CNiKuPwF&rs=AOn4CLCyZerAVtbsoqDDOk-nfPKqMgZxjw)](https://youtu.be/8Hs9BYerIzg "Game Input Comparison")

Left video is using Game Input driver and the right one isn't. Numbers in the screen's bottom are FPS average (1st number) and any frame rate below a minimum threshold (which I've set to 16 fps for CSpect and 25 fps in real hardware), which also makes the border to blink red. Both videos start in sync but the one in the right lags behind a bit towards the end, which is an effect of a lower frame rate. In this experiment, using Game Input alone gave me a 16% increase in the frame rate and not a single frame rate below the minimum rate.
