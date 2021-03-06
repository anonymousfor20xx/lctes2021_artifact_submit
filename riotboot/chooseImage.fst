module ChooseImage

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


val choose_image_aux1 : rb_hdr_t ->  ST bool 
 (requires (fun h0 -> True))
 (ensures (fun h0 _ h1 -> B.modifies B.loc_none h0 h1))

let choose_image_aux1 img =
 push_frame ();
 let tb = B.alloca img 1ul in
 let b:bool = Lowhdr.rb_hdr_validate tb in
 pop_frame ();
 b

val choose_image_aux : images:B.buffer rb_hdr_t -> len:int{len < B.length images /\ len >= 0} -> option rb_hdr_t -> ST (option UInt32.t)
 (requires (fun h0 -> B.live h0 images))
 (ensures (fun h0 _ h1 -> B.live h1 images))
 (decreases len)

let rec choose_image_aux images len opt =
 match len with
 | 0 -> 
   let img = images.(UInt32.uint_to_t len) in
   let b = choose_image_aux1 img in
     if b = true then
       match opt with
       | Some t -> if img.version <= t.version then Some (t.start_addr) else Some (img.start_addr)
       | None -> None
     else
      begin       
       match opt with
       | Some t -> Some (t.start_addr)
       | None -> None
      end
 | _ -> 
 let img = images.(UInt32.uint_to_t len) in
 let b = choose_image_aux1 img in
     if b = true then
      match opt with
      | None -> choose_image_aux images (len - 1) (Some img)
      | Some t -> if img.version <= t.version then choose_image_aux images (len - 1) opt else choose_image_aux images (len - 1) (Some img)
     else choose_image_aux images (len - 1) opt

val choose_image : images:B.buffer rb_hdr_t{B.length images == rb_slot_numof} -> ST (option UInt32.t)
 (requires (fun h0 -> B.live h0 images))
 (ensures (fun h0 _ h1 -> B.live h1 images))

let choose_image images = choose_image_aux images (rb_slot_numof - 1) None
