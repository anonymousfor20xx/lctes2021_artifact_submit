# Verified ARM assembly model and verified programming of a bootloader for IoT devices

This repository contains the version of ARM in F* presented in the LCTES2021 submission #5.

# Organization

1. arm
   1. [arm_def.fst](https://github.com/anonymousfor20xx/lctes2021_artifact_submit/blob/main/arm/arm_def.fst): syntax + memory model
   2. [arm_semantics.fst](https://github.com/anonymousfor20xx/lctes2021_artifact_submit/blob/main/arm/arm_semantics.fst): semantics
   3. [valid.fst](https://github.com/anonymousfor20xx/lctes2021_artifact_submit/blob/main/arm/valid.fst): valid functions of each instruction 
   4. [properties.fst](https://github.com/anonymousfor20xx/lctes2021_artifact_submit/blob/main/arm/properties.fst): properties/lemmas of our arm model
   5. [jump_to_cpu](https://github.com/anonymousfor20xx/lctes2021_artifact_submit/blob/main/arm/jump_to_cpu.fst): the `cpu_jump_to_image` inplementation and verification.
2. riotboot
   1. [LowKernel.fst](https://github.com/anonymousfor20xx/lctes2021_artifact_submit/blob/main/riotboot/LowKernel.fst): the kernel init module.
   2. [chooseImage.fst](https://github.com/anonymousfor20xx/lctes2021_artifact_submit/blob/main/riotboot/chooseImage.fst): the choose image module.
   3. [Lowhdr.fst](https://github.com/anonymousfor20xx/lctes2021_artifact_submit/blob/main/riotboot/Lowhdr.fst): the header validaty implementation which will call the fletcher32 algorithm.
   4. [Lowfletcher32.fst](https://github.com/anonymousfor20xx/lctes2021_artifact_submit/blob/main/riotboot/Lowfletcher32.fst): the fletcher32 implementation in LowStar.
   5. [rbComm.fst](https://github.com/anonymousfor20xx/lctes2021_artifact_submit/blob/main/riotboot/rbComm.fst): All common information of riotboot. i.e. the image header structure.
   6. [main.c](https://github.com/anonymousfor20xx/lctes2021_artifact_submit/blob/main/riotboot/main.c): A main file to tell the `makefile` to link it with all generated C code. Its executable file is `out/LowKernel`.
   7. `/fletcher32inC`: a C variant of the fletcher32 algorithm, the [original version](https://github.com/RIOT-OS/RIOT/blob/master/sys/checksum/fletcher32.c) is from RIOT project. This file is used to generate the checksum of a given image header. 
   8. `/out`: this directory and its subdirectory is automatically generated by the `makefile`.
   9. `/out/sources`: all generated C code from LowStar files of `riotboot`.
   10. `/out1/sources`: the whole riotboot (+asm code) code.
3. sourceC: the source C code of riotboot from [RIOT project](https://github.com/RIOT-OS/RIOT).


# Running the code

## environment
We recommend using the [Everest script](https://github.com/project-everest/everest) to build the world.

1. Using `opam` to install the ocaml 4.09.1 (recommend using this version). Please refer to [install ocaml](https://ocaml.org/docs/install.html#OPAM)
   - be careful about your access permission when running the command.
   - restart your system after installing ocaml successfully.

2. Installing Z3, FStar and Kremlin from the `everest` project. Seeing [Everest website](https://project-everest.github.io/) and [LowStar user manual](https://fstarlang.github.io/lowstar/html/Setup.html#installing-the-tools) for more information.
```
git clone https://github.com/project-everest/everest
cd everest
./everest check 
# comment: set your path, `FSTAR_HOME` and `KREMLIN_HOME` in the `/etc/profile` file before run the next command. 
# Usually the everst script will add the z3 path to your `.bash_profile` automatically.
./everest pull FStar make kremlin make
```

3. (Option) Using `emacs` as IDE and the [fstar-mode](https://github.com/FStarLang/fstar-mode.el)
   - remember to add a library of the kremlin project to your `~/.emacs`
  ```
  (setq-default fstar-subp-prover-args '("--include" "YOUR-GITHUB-DICOREY/everest/kremlin/kremlib"))
  ```

## Verifying the FStar/LowStar project

1. Running the `fstar.exe your_fstar_or_lowstar_file.fst` to check each Fstar/Lowstar file

2. Or if you install the emacs `fstar-mode`, check the project in the emacs.

## Extracting the C code
In the `riotboot` directory, just run `make LowKernel` to generate 
  - `/out/sources` all C files and 
  - `/out` the executable file named `LowKernel`

To run the executable file, just use the command `./out/LowKernel` in the `riotboot` directory. The terminal will print:
```
Find the suitable image with start address(0d4352)
Please call the function `cpu_jump_to_image`
```
