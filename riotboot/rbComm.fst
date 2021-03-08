module RbComm

type rb_hdr_t = {magic_number : UInt32.t; 
                 version : UInt32.t; 
                 start_addr : UInt32.t; 
                 chksum : UInt32.t}
                 
val rb_slot_numof : nat
let rb_slot_numof = 2

val rb_slot0 : rb_hdr_t
let rb_slot0 = {magic_number = 0x544f4952ul; version = 0x1007ul; start_addr = 0x00001100ul; chksum = 0xbf96bea8ul}

val rb_slot1 : rb_hdr_t
let rb_slot1 = {magic_number = 0x544f4952ul; version = 0x14ul; start_addr = 0x00010010ul; chksum = 0x5deb9dc6ul}
