module Arm_def

open FStar.Mul
open Words_t
open FStar.Int.Cast
open FStar.Int
open Shift

let int32 = FStar.Int32.t
let uint32 = FStar.UInt32.t
let (+.) = FStar.Int32.add

irreducible let va_qattr = ()// Used to guide normalization in F*'s type system

let int_to_nat32 (i:int) : n:nat32{0<=i /\ i<pow2_32 ==> i == n} =
  int_to_natN pow2_32 i

let int32_in_int16 (i:int32) : Tot bool = - (pow2 15) <= (Int32.v i) && (Int32.v i) <= (pow2 15) - 1

(*****************************************************)
(*                   ARM Registers                   *)
(*****************************************************)

type reg =
 | R0 | R1 | R2 | R3  | R4  | R5  | R6 
 | R7 | R8 | R9 | R10 | R11 | R12 (*13 general-purpose registers R0 - R12*)
 | SP   (*One Stack Pointer*)
 | LR   (*One Link Register*)
 | PC   (*One Program Counter*)
(* | APSR (*One Application Program Status Register*)*)

(*About APSR: we have four flages N Z C V, because APSR is uint32, so we use 0x0000 represents N/Z/C/V is 0, and so on*)
(* we model APSR as a part of state of the arm architecture*)

type addr = int32
type mem_entry = | Mem32 : v:int32 -> mem_entry (*The ARM architecture is a load-store architecture, with a 32-bit addressing range (after ARMv4).*)

type memory = FStar.Map.t addr mem_entry

let regs_t = FStar.FunctionalExtensionality.restricted_t reg (fun _ -> int32)

[@va_qattr] unfold let regs_make (f:reg -> int32) : regs_t = 
  FStar.FunctionalExtensionality.on_dom reg f

type mode = |ARM |Thumb32 |Thumb16  (*|ThumbEE*)

type symbol = string

(*
type global_entry = | Glo : g:symbol -> addr -> global_entry

type global = FStar.Map.t symbol global_entry*)

(*
noeq type mem_state ={
  addresses : memory;
  globals   : global;
}*)

type flag = {
 n : bool;  (*N true => 1; N false => 0*)
 z : bool;
 c : bool;
 v : bool;
}


noeq type arm_state = {
  ok       : bool;
  regs     : regs_t;
  mem      : memory;
  flags    : flag; (*i.e. APSR register*)
(*  globals  : global;*)
  mem_mode : mode;
}

type shift =
 | LSLshift: s:natN 32{1<=s && s <=31} -> shift
 | LSRshift: s:natN 32{1<=s && s <=32} -> shift
 | ASRshift: s:natN 32{1<=s && s <=32} -> shift
 | RORshift: s:natN 32{1<=s && s <=31} -> shift
(* | RRXshift: s:natN 32 -> shift*) (*only x6M*)

(* symbol is usually a label. In instructions and pseudo-instructions it is always a label. In some directives it is a symbol for a variable or a constant. The description of the directive makes this clear in each case.
 * symbol must begin in the first column. It cannot contain any white space character such as a space or a tab unless it is enclosed by bars (|).
 * Labels are symbolic representations of addresses.
 *)

[@va_qattr]
type operand = 
 | OConst : n:int32 -> operand
 | OReg   : r:reg -> operand
 | OShift : r:reg -> s:shift -> operand
(* | OSymbol: sym:symbol -> operand*)

 (*| OSP    : r: reg -> operand
 | OLR    : r: reg -> operand*)
 
 (* OReg should include OSP and OLR, 
  * because the `reg` type includes SP and LR  
  *)

(* In ARM instructions, constant can have any value that can be produced by 
 * rotating an 8-bit value right by any even number of bits within a 32-bit word.!!!
 *)


type condition = (*Here we just show some conditions, more conditions will be added in the future ^^! *)
 | EQ (*Equal            : Z -> 1*)
 | NE (*Not equal        : Z -> 0*)
 | CS (*Higher or same   : C -> 1*)
 | CC (*Lower            : C -> 0*)
 | MI (*Negative         : N -> 1*)
 | PL (*Positive or zero : N -> 0*)
 | VS (*Overflow         : V -> 1*)
 | VC (*No overflow      : V -> 0*)
 | LT (*signed <  : N and V differ // Note we also have unsigned <, i.e. LO*)
 | LE (*signed <= : Z -> 1, N and V diff*)
 | GT (*signed >  : Z -> 0, N and V diff*)
 | GE (*signed >= : N and V same*)
 | AL (*always    : Any. i.e. no change*)

(*****************************************************)
(*                ARM Instructions                   *)
(*****************************************************)

type ins = 
 | ADC  : rd:reg -> rn:operand -> op2:operand -> ins
 | ADCc : cond:condition -> rd:reg -> rn:operand -> op2:operand -> ins
 | ADCs : rd:reg -> rn:operand -> op2:operand -> ins
 | ADCsc: cond:condition -> rd:reg -> rn:operand -> op2:operand -> ins
 
 | ADD  : rd:reg -> rn:reg -> op2:operand -> ins
 | ADDc : cond:condition -> rd:reg -> rn:reg -> op2:operand -> ins
 | ADDs : rd:reg -> rn:reg -> op2:operand -> ins
 | ADDsc: cond:condition -> rd:reg -> rn:reg -> op2:operand -> ins
 
 | AND  : rd:reg -> rn:reg -> op2:operand -> ins
 | ANDc : cond:condition -> rd:reg -> rn:reg -> op2:operand -> ins
 | ANDs : rd:reg -> rn:reg -> op2:operand -> ins
 | ANDsc: cond:condition -> rd:reg -> rn:reg -> op2:operand -> ins
 
 | ASR  : rd:reg -> rn:reg -> rs:shift -> ins
 | ASRc : cond:condition -> rd:reg -> rn:reg -> rs:shift -> ins
 | ASRs : rd:reg -> rn:reg -> rs:shift -> ins
 | ASRsc: cond:condition -> rd:reg -> rn:reg -> rs:shift -> ins
 
 | BX   : rm:reg -> ins
 | BXc  : cond:condition -> rm:reg -> ins
 
 | CMN  : rn:reg -> op2:operand -> ins
 | CMNc : cond:condition -> rn:reg -> op2:operand -> ins
 | CMP  : rn:reg -> op2:operand -> ins
 | CMPc : cond:condition -> rn:reg -> op2:operand -> ins
 
 | EOR  : rd:reg -> rn:reg -> op2:operand -> ins
 | EORc : cond:condition -> rd:reg -> rn:reg -> op2:operand -> ins
 | EORs : rd:reg -> rn:reg -> op2:operand -> ins
 | EORsc: cond:condition -> rd:reg -> rn:reg -> op2:operand -> ins
 
 | LDR  : rt:reg -> rn:reg -> offset:operand -> ins
 | LDRc : cond:condition -> rt:reg -> rn:reg -> offset:operand -> ins
 
 | LSL  : rd:reg -> rn:reg -> rs:shift -> ins
 | LSLc : cond:condition -> rd:reg -> rn:reg -> rs:shift -> ins
 | LSLs : rd:reg -> rn:reg -> rs:shift -> ins
 | LSLsc: cond:condition -> rd:reg -> rn:reg -> rs:shift -> ins
 
 | LSR  : rd:reg -> rn:reg -> rs:shift -> ins 
 | LSRc : cond:condition -> rd:reg -> rn:reg -> rs:shift -> ins 
 | LSRs : rd:reg -> rn:reg -> rs:shift -> ins 
 | LSRsc: cond:condition -> rd:reg -> rn:reg -> rs:shift -> ins 
 
 | MOV  : rd:reg -> op2:operand -> ins
 | MOVc : cond:condition -> rd:reg -> op2:operand -> ins
 | MOVs : rd:reg -> op2:operand -> ins
 | MOVsc: cond:condition -> rd:reg -> op2:operand -> ins
 
 | MUL  : rd:reg -> rn:reg -> rm:reg -> ins
 | MULc : cond:condition -> rd:reg -> rn:reg -> rm:reg -> ins
 | MULs : rd:reg -> rn:reg -> rm:reg -> ins
 | MULsc: cond:condition -> rd:reg -> rn:reg -> rm:reg -> ins
 
 | NEG  : rd:reg -> rm:reg -> ins
 | NEGc : cond:condition -> rd:reg -> rm:reg -> ins
 
 | NOP  : ins
 | NOPc : cond:condition -> ins
 
 | ORN  : rd:reg -> rn:reg -> op2:operand -> ins
 | ORNc : cond:condition -> rd:reg -> rn:reg -> op2:operand -> ins
 | ORNs : rd:reg -> rn:reg -> op2:operand -> ins
 | ORNsc: cond:condition -> rd:reg -> rn:reg -> op2:operand -> ins
 
 | ORR  : rd:reg -> rn:reg -> op2:operand -> ins
 | ORRc : cond:condition -> rd:reg -> rn:reg -> op2:operand -> ins
 | ORRs : rd:reg -> rn:reg -> op2:operand -> ins
 | ORRsc: cond:condition -> rd:reg -> rn:reg -> op2:operand -> ins
 
 | ROR  : rd:reg -> rm:reg -> rs:shift -> ins
 | RORc : cond:condition -> rd:reg -> rm:reg -> rs:shift -> ins
 | RORs : rd:reg -> rm:reg -> rs:shift -> ins
 | RORsc: cond:condition -> rd:reg -> rm:reg -> rs:shift -> ins
 
 | STR  : rt:reg -> rn:reg -> offset:operand -> ins
 | STRc : cond:condition -> rt:reg -> rn:reg -> offset:operand -> ins
 
 | SUB  : rd:reg -> rn:reg -> op2:operand -> ins
 | SUBc : cond:condition -> rd:reg -> rn:reg -> op2:operand -> ins
 | SUBs : rd:reg -> rn:reg -> op2:operand -> ins
 | SUBsc: cond:condition -> rd:reg -> rn:reg -> op2:operand -> ins

(*ARM processors are typical of RISC processors in that only load and store instructions can access memory. Data processing instructions operate on register contents only.
*)

(*The use of SWP and SWPB is deprecated in ARMv6 and above.!!!*)

(*If you use PC (R15) as Rn or Operand2, the value used is the address of the instruction plus 8.*)

(*****************************************************)
(*                        Code                       *)
(*****************************************************)

type precode (t_ins:Type0) (t_ocmp:Type0) =
  | Ins: ins:t_ins -> precode t_ins t_ocmp
  | Block: block:list (precode t_ins t_ocmp) -> precode t_ins t_ocmp
  | IfElse: ifCond:t_ocmp -> ifTrue:precode t_ins t_ocmp -> ifFalse:precode t_ins t_ocmp -> precode t_ins t_ocmp
  | While: whileCond:t_ocmp -> whileBody:precode t_ins t_ocmp -> precode t_ins t_ocmp

type ocmp =
  | OEq: o1:operand -> o2:operand -> ocmp
  | ONe: o1:operand -> o2:operand -> ocmp
  | OLe: o1:operand -> o2:operand -> ocmp
  | OGe: o1:operand -> o2:operand -> ocmp
  | OLt: o1:operand -> o2:operand -> ocmp
  | OGt: o1:operand -> o2:operand -> ocmp

type code = precode ins ocmp
(*type code = precode ins_scond ocmp*)
type codes = list code

(*****************************************************)
(*                     Validity                      *)
(*****************************************************)

val load_mem: addr:int32 -> m:memory -> Pure int32 
  (requires True)
  (ensures fun n -> match Map.sel m addr with Mem32 v -> v == n)

let load_mem addr m =
  match Map.sel m addr with
  | Mem32 v -> v

val store_mem: addr:int32 -> v:int32 -> m:memory -> Tot memory

let store_mem addr v m = Map.upd m addr (Mem32 v)

