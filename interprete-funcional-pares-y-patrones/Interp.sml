(* Este archivo carga todos los componentes del interprete en el
   orden correcto.
*)

use "sintax.sml";  (* sintaxis abstracta del minilenguaje *)
use "ambi.sml";    (* manejo de ambientes *)
use "val.sml";     (* valores semanticos *)
use "concord.sml"; (* concordancia de patrones *)
use "opers.sml";   (* operaciones predefinidas del minilenguaje *)
use "eval.sml";    (* el evaluador *)

val iter3 = LetExp(ValDecl(NoRecursiva, IdPat "n", ConstExp(Entera 1)),                              
                   IterExp([(
                             "n", ConstExp(Entera 1), ApExp(IdExp "+", ParExp(IdExp "n", ConstExp(Entera 1))))                    
                           ],
                           ApExp(IdExp ">",ParExp(IdExp "n", ConstExp(Entera 10))),
                           IdExp "n"
                          ));
evalProg iter3;