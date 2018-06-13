(* Este archivo carga todos los componentes del interprete en el
   orden correcto.
*)

use "sintax.sml";  (* sintaxis abstracta del minilenguaje *)
use "ambi.sml";    (* manejo de ambientes *)
use "val.sml";     (* valores semanticos *)
use "concord.sml"; (* concordancia de patrones *)
use "opers.sml";   (* operaciones predefinidas del minilenguaje *)
use "eval.sml";    (* el evaluador *)
(*use "prufun.sml";  (* pruebitas *)*)


val unaSuma = LetExp (ValDecl(NoRecursiva,IdPat "a", ConstExp (Entera 9)), ApExp (IdExp "+", ParExp (IdExp "a",ConstExp (Entera 1))));
val unaSuma2 = LetExp (ValDecl(NoRecursiva,IdPat "a", ConstExp (Entera 9)), ApExp (IdExp "+", ParExp (IdExp "a",ConstExp (Entera 11))));
val a = ("una", unaSuma);
val b = ("dos", unaSuma2);
val c = [a, b];
val d = RegExp(c);
val e = CampoExp(d, "dos");
evalProg e;