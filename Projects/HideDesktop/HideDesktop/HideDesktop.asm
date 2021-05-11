; License: https://github.com/Zalexanninev15/ALP/blob/main/LICENSE

format PE GUI 4.0
entry start
include 'includes\win32a.inc'
section '.data' data readable writeable
szProg db 'ProgMan',0
section '.code' code readable executable
start:
        invoke  FindWindow,szProg,NULL
        invoke  GetWindow,eax,GW_CHILD
        invoke  GetWindow,eax,GW_CHILD
        mov     ebx,eax
        invoke  IsWindowVisible,ebx
        or      eax,eax
        jne     @f
        invoke  ShowWindow,ebx,SW_SHOW
        jmp     loc_exit
@@:
        invoke  ShowWindow,ebx,SW_HIDE
loc_exit:
        invoke  ExitProcess,0
section '.idata' import data readable writeable
library kernel32,"kernel32.dll",\user32,"user32.dll"
include "includes\api\kernel32.inc"
include "includes\api\user32.inc"