module LowKernel

open FStar.Integers
open FStar.Int
open FStar.Int.Cast

module B = LowStar.Buffer
module C = LowStar.Comment
module M = LowStar.Modifies
module P = LowStar.Printf

open FStar.HyperStack.ST
open LowStar.BufferOps

open LowFletcher32
open Lowhdr
open RbComm
open ChooseImage

let kernel_init () : ST unit
  (requires fun _ -> True)
  (ensures fun h _ h' -> True)
 = 
 push_frame();
 let images:B.buffer rb_hdr_t = B.alloca_of_list [rb_slot0; rb_slot1] in
 let slot = choose_image images in
 pop_frame();
 
 begin
   match slot with
   | Some start_addr -> P.(printf "Find the suitable image with start address(0d%ul)\nPlease call the function `cpu_jump_to_image`\n" start_addr done)
   | None -> P.(printf "no suitable image found\n" done)
 end
