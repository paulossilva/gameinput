PLUS3DOS    �
 �                                                                                                         � 

 ��2      .install "input.drv"  ; Demo initialization (% �1    ,1    :��30    ;�8     2 � < �j$(7    ,13    ) F � P �i=1    �7     Z �j$(i) d �i n �m$(6    ,8    ) x �i=1    �6     � �m$(i) � �i � �51  3  ,1    �%a,%b � ; Main loop � � � �PrintSettings() � ��=","˓ChangeJoystick1() � ��="."˓ChangeJoystick2() � ��=�(12    )˓RedefineKeys() � �PrintJoysticks() � �ReadJoystick1() � �ReadJoystick2() �
 ��0      �PrintSettings()> ��0     ,4    ;"Joystick 1";�0     ,20    ;"Joystick 2" �%i=1    �7    " j=%i, ��%i+1,2    ;�%i=a;j$(j)6 ��%i+1,18    ;�%i=b;j$(j)@ �%iJ	 �0     TF ��10  
  ,2    ;"<,> chg Joy 1";�10  
  ,18    ;"<.> chg Joy 2"^) ��11    ,2    ;"<DEL> redefine keys"h �r �PrintJoysticks()|	 �0     �0 ��13    ,7    ;"UP";�13    ,23    ;"UP"�j ��15    ,1    ;"LEFT";�15    ,11    ;"RIGHT";�15    ,17    ;"LEFT";�15    ,27    ;"RIGHT"�4 ��17    ,6    ;"DOWN";�17    ,22    ;"DOWN"�l ��19    ,2    ;"FIRE1";�19    ,10  
  ;"FIRE2";�19    ,18    ;"FIRE1";�19    ,26    ;"FIRE2"�6 ��20    ,6    ;"FIRE3";�20    ,22    ;"FIRE3"�	 �1    � �� �ChangeJoystick1()� %a=%a+1� �%a=8�%a=1    � �51  3  ,2    ,%a� �� �ChangeJoystick2() %b=%b+1 �%b=8�%b=1     �51  3  ,3    ,%b& �0 �ReadJoystick1(): �51  3  ,4    ,1    �%cD4 �12345678901234567890123456789012345678901234567890N �PrintBits()X �b �ReadJoystick2()l �51  3  ,5    ,1    v4 �12345678901234567890123456789012345678901234567890� �� �U1()�! ��13    ,7    ;�2    ;"UP"� �� �L1()�# ��15    ,1    ;�2    ;"LEFT"� �� �D1()�# ��17    ,6    ;�2    ;"DOWN"� �� �R1()�% ��15    ,11    ;�2    ;"RIGHT"� � �F1()$ ��19    ,2    ;�2    ;"FIRE1" �  �F2()*% ��19    ,10  
  ;�2    ;"FIRE2"4 �> �F3()H$ ��20    ,6    ;�2    ;"FIRE3"R �\ �U2()f" ��13    ,23    ;�2    ;"UP"p �z �L2()�$ ��15    ,17    ;�2    ;"LEFT"� �� �D2()�$ ��17    ,22    ;�2    ;"DOWN"� �� �R2()�% ��15    ,27    ;�2    ;"RIGHT"� �� �F4()�% ��19    ,18    ;�2    ;"FIRE1"� �� �F5()�% ��19    ,26    ;�2    ;"FIRE2" � �F6()% ��20    ,22    ;�2    ;"FIRE3"$ �. �PrintBits()8 c$="00000000"B �i=1    �8    L �%c&1�c$(9  	  -i)="1"V %c=%c�1` �ijH ��22    ,3    ;�1    ;"BYTE READ 1";�0     ;�23    ,4    ;c$t �~ �RedefineKeys()� �� �"Redefine CUSTOM keyboard"�# �"(Kempston1/Megadrive1 in Joy 1)"� ��	 �1    � �i=1    �6    � �m$(i);� �0     :�GetKey()�l$� �l$�  �51  3  ,6    ,i-1    ,�l$� �i� � ) �"Press any key to continue...":�0     
 � �
 �GetKey()( �2 l$=�< ��l$�""F �=l$P ; String arraysZ �"1 Sinclair 2"d �"2 Kempston 2"n �"3 Kempston 1"x �"4 Megadrive 1"� �"5 Cursor"� �"6 Megadrive 2"� �"7 Sinclair 1"�C �"RIGHT : ","LEFT  : ","DOWN  : ","UP    : ","FIRE1 : ","FIRE2 : "