/* 
  This file was generated by KreMLin <https://github.com/FStarLang/kremlin>
  KreMLin invocation: krml -verbose -d reachability -I . -I includes -tmpdir /Users/syuan/GoogleDrive/PhD/FstarCode/LCTES2021/riotboot/out/sources -no-prefix FStarFiles /Users/syuan/GoogleDrive/PhD/FstarCode/LCTES2021/riotboot/out/out.krml -ccopt -O0 main.c -add-include "kremlin/internal/compat.h" -bundle LowStar.*,Prims -bundle FStar.* -o /Users/syuan/GoogleDrive/PhD/FstarCode/LCTES2021/riotboot/out/LowKernel
  F* version: cfb65605
  KreMLin version: 03ccd42f
 */

#include "LowKernel.h"

void LowKernel_kernel_init()
{
  RbComm_rb_hdr_t images[2U] = { RbComm_rb_slot0, RbComm_rb_slot1 };
  FStar_Pervasives_Native_option__uint32_t slot = ChooseImage_choose_image(images);
  if (slot.tag == FStar_Pervasives_Native_Some)
  {
    uint32_t start_addr = slot.v;
    LowStar_Printf_print_string("Find the suitable image with start address(0d");
    LowStar_Printf_print_u32(start_addr);
    LowStar_Printf_print_string(")\nPlease call the function `cpu_jump_to_image`\n");

    __asm__ __volatile__ (/* volatile: disable optimizations */
      "ldr  r1, [%0] \n\t"     /* r1 = *image_address */
      "msr  msp, r1 \n\t"      /* MSP = r1 */
      "ldr  %0, [%0, #4] \n\t" /* r0 = *(image_address + 4) */
      "orr  %0, %0, #1 \n\t"   /* r0 |= 0x1 (set thumb bit) */
      "bx   %0 \n\t"           /* branch to image */
      :                        /* No outputs */
      : "r" (start_addr)       /* input: image_address */
      : "r0", "r1"             /* clobber: ri may be modified */
    );
  }
  else if (slot.tag == FStar_Pervasives_Native_None)
    LowStar_Printf_print_string("no suitable image found\n");
  else
  {
    KRML_HOST_EPRINTF("KreMLin abort at %s:%d\n%s\n",
      __FILE__,
      __LINE__,
      "unreachable (pattern matches are exhaustive in F*)");
    KRML_HOST_EXIT(255U);
  }
}
