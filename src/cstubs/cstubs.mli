(*
 * Copyright (c) 2014 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)

(** Operations for generating C bindings stubs. *)

module Types :
sig
  module type TYPE =
  sig
    include Ctypes_types.TYPE
    type 'a const
    val constant : string -> 'a typ -> 'a const
    (** [constant name typ] retrieves the value of the compile-time constant
        [name] of type [typ].  It can be used to retrieve enum constants,
        #defined values and other integer constant expressions.

        The type [typ] must be either an integer type such as [bool], [char],
        [int], [uint8], etc., or a view (or perhaps multiple views) where the
        underlying type is an integer type.

        When the value of the constant cannot be represented in the type there
        will typically be a diagnostic from either the C compiler or the OCaml
        compiler.  For example, gcc will say

           warning: overflow in implicit constant conversion *)
  end

  module type BINDINGS = functor (F : TYPE) -> sig end

  val write_c : Format.formatter -> (module BINDINGS) -> unit
end


module type FOREIGN =
sig
  type 'a fn
  val foreign : string -> ('a -> 'b) Ctypes.fn -> ('a -> 'b) fn
  val foreign_value : string -> 'a Ctypes.typ -> 'a Ctypes.ptr fn
end

module type BINDINGS = functor (F : FOREIGN with type 'a fn = unit) -> sig end

val write_c : Format.formatter -> prefix:string -> (module BINDINGS) -> unit
(** [write_c fmt ~prefix bindings] generates C stubs for the functions bound
    with [foreign] in [bindings].  The stubs are intended to be used in
    conjunction with the ML code generated by {!write_ml}.

    The generated code uses definitions exposed in the header file
    [cstubs_internals.h].
*)

val write_ml : Format.formatter -> prefix:string -> (module BINDINGS) -> unit
(** [write_ml fmt ~prefix bindings] generates ML bindings for the functions
    bound with [foreign] in [bindings].  The generated code conforms to the
    {!FOREIGN} interface.

    The generated code uses definitions exposed in the module
    [Cstubs_internals]. *)

