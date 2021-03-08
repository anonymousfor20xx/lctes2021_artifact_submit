/* 
  This file was generated by KreMLin <https://github.com/FStarLang/kremlin>
  KreMLin invocation: krml -verbose -d reachability -I . -I includes -tmpdir /Users/syuan/GoogleDrive/PhD/FstarCode/LCTES2021/riotboot/out/sources -no-prefix FStarFiles /Users/syuan/GoogleDrive/PhD/FstarCode/LCTES2021/riotboot/out/out.krml -ccopt -O0 main.c -add-include "kremlin/internal/compat.h" -bundle LowStar.*,Prims -bundle FStar.* -o /Users/syuan/GoogleDrive/PhD/FstarCode/LCTES2021/riotboot/out/LowKernel
  F* version: cfb65605
  KreMLin version: 03ccd42f
 */

#ifndef __LowKernel_H
#define __LowKernel_H
#include "kremlin/internal/compat.h"
#include "kremlib.h"


#include "RbComm.h"
#include "ChooseImage.h"
#include "LowStar_Prims.h"

void LowKernel_kernel_init();


#define __LowKernel_H_DEFINED
#endif