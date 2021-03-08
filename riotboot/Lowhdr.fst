module Lowhdr

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

open RbComm

let rm = 0x544f4952ul (*RIOTBOOT_MAGIC*)

let offset_chksum = 6us

val rb_hdr_t2uint16_t : rb_hdr_t -> d:B.buffer UInt16.t{B.length d > UInt16.v offset_chksum} -> ST unit
 (requires (fun h0 -> B.live h0 d))
 (ensures (fun h0 _ h1 -> (M.modifies (M.loc_buffer d) h0 h1) /\ B.live h1 d))

let rb_hdr_t2uint16_t s d =
  d.(0ul)<- uint32_to_uint16 (s.magic_number); (*from high to low*)
  d.(1ul)<- uint32_to_uint16 (s.magic_number >>^ 16ul);
  d.(2ul)<- uint32_to_uint16 (s.version);
  d.(3ul)<- uint32_to_uint16 (s.version >>^ 16ul);
  d.(4ul)<- uint32_to_uint16 (s.start_addr);
  d.(5ul)<- uint32_to_uint16 (s.start_addr >>^ 16ul);
  ()

val rb_hdr_checksum_aux : rb_hdr_t -> ST UInt32.t 
(fun h0 -> True) (fun h0 _ h1 -> B.modifies B.loc_none h0 h1)

let rb_hdr_checksum_aux h =
  push_frame ();
  let tb = B.alloca 0us 8ul in 
    rb_hdr_t2uint16_t h tb;
    let res = LowFletcher32.fletcher32 offset_chksum tb in
  pop_frame ();
  res

val rb_hdr_checksum : b:B.buffer rb_hdr_t{B.length b == 1} -> ST UInt32.t
 (requires (fun h0 -> B.live h0 b))
 (ensures (fun h0 _ h1 -> (M.modifies (M.loc_buffer b) h0 h1) /\ B.live h1 b /\ B.modifies B.loc_none h0 h1))

let rb_hdr_checksum b= rb_hdr_checksum_aux b.(0ul)

val rb_hdr_validate : h:B.buffer rb_hdr_t{B.length h == 1} -> ST bool
  (requires (fun h0 -> B.live h0 h))
  (ensures (fun h0 _ h1 -> B.live h1 h /\ B.modifies B.loc_none h0 h1))

let rb_hdr_validate h =
  let h1 = h.(0ul) in
  let hc = rb_hdr_checksum h in
  if (h1.magic_number = rm) && (hc = h1.chksum) then 
    true
  else 
    false
