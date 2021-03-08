Please use the command `gcc ... LowKernel.c -o Lowkernel.o` and `gcc ... main.c -o main.o` to generate .o files and then generate the executable file in your ARM machine.

For more information, please refer to the output of the `makefile` in the directory `/riotboot/makefile`. For instance, In my machine,

```
%riotboot: make LowKernel
✔ [CC,/**anonymous**/riotboot/out/sources/ChooseImage.c]
gcc -I /**anonymous**/Github/everest/kremlin/kremlib/dist/minimal -I /**anonymous**/Github/everest/kremlin/kremlib -I . -I includes -I /**anonymous**/Github/everest/kremlin/include -I /**anonymous**/riotboot/out/sources -Wall -Werror -Wno-unused-variable -Wno-unknown-warning-option -Wno-unused-but-set-variable -g -fwrapv -D_BSD_SOURCE -D_DEFAULT_SOURCE -Wno-parentheses -std=c11 -O0 -c /**anonymous**/riotboot/out/sources/LowKernel.c -o /**anonymous**/riotboot/out/sources/LowKernel.o
✔ [CC,/**anonymous**/riotboot/out/sources/LowKernel.c]
gcc -I /**anonymous**/Github/everest/kremlin/kremlib/dist/minimal -I /**anonymous**/Github/everest/kremlin/kremlib -I . -I includes -I /**anonymous**/Github/everest/kremlin/include -I /**anonymous**/riotboot/out/sources -Wall -Werror -Wno-unused-variable -Wno-unknown-warning-option -Wno-unused-but-set-variable -g -fwrapv -D_BSD_SOURCE -D_DEFAULT_SOURCE -Wno-parentheses -std=c11 -O0 -c main.c -o /**anonymous**/riotboot/out/sources/main.o
✔ [CC,main.c]
gcc -I /**anonymous**/Github/everest/kremlin/kremlib/dist/minimal -I /**anonymous**/Github/everest/kremlin/kremlib -I . -I includes -I /**anonymous**/Github/everest/kremlin/include -I /**anonymous**/riotboot/out/sources -Wall -Werror -Wno-unused-variable -Wno-unknown-warning-option -Wno-unused-but-set-variable -g -fwrapv -D_BSD_SOURCE -D_DEFAULT_SOURCE -Wno-parentheses -std=c11 -O0 /**anonymous**/riotboot/out/sources/RbComm.o /**anonymous**/riotboot/out/sources/LowFletcher32.o /**anonymous**/riotboot/out/sources/Lowhdr.o /**anonymous**/riotboot/out/sources/ChooseImage.o /**anonymous**/riotboot/out/sources/LowKernel.o /**anonymous**/riotboot/out/sources/main.o /**anonymous**/Github/everest/kremlin/kremlib/dist/generic/libkremlib.a -o /**anonymous**/riotboot/out/LowKernel
✔ [LD]
All files linked successfully
```
