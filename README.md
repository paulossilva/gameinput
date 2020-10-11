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

More complexity would be added if you want to let the player customize the keys used to control the game.

With the Game Input Driver, you can replace all the above code with only a couple of lines:

```
DRIVER ID, 4, 1
REM 12345678901234567890123456789012345678901234567890
```
And that's it!! Really!!

Read on the [API Documentation](https://github.com/paulossilva/gameinput/blob/master/docs/inputDriver_API.txt) on the docs folder and check out the Demo file [input_drv.bas](https://github.com/paulossilva/gameinput/blob/master/input_drv.txt) to see the driver in action and learn more on how to use it.

# Note
This driver doesn't have an official ZXNextOS ID. I'm using id number 51 for test purposes only.
