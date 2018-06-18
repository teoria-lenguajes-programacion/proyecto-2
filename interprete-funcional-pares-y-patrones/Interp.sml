(* Este archivo carga todos los componentes del interprete en el
   orden correcto.
*)

use "sintax.sml";  (* sintaxis abstracta del minilenguaje *)
use "ambi.sml";    (* manejo de ambientes *)
use "val.sml";     (* valores semanticos *)
use "concord.sml"; (* concordancia de patrones *)
use "opers.sml";   (* operaciones predefinidas del minilenguaje *)
use "eval.sml";    (* el evaluador *)

val iter1 = LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 6)),
               LetExp(ValDecl(NoRecursiva, IdPat "fact",
                 AbsExp [(IdPat "k",
                    IterExp([
                       ("n", IdExp "k", ApExp(IdExp "-", ParExp(IdExp "n", ConstExp(Entera 1))))
                    ,  ("product", ConstExp(Entera 1), ApExp(IdExp "*", ParExp(IdExp "product", IdExp "n")))
                    ],
                    ApExp(IdExp "=",ParExp(IdExp "n", ConstExp(Entera 0))),
                    IdExp "product"))
                 ])
               , ApExp(IdExp "fact", IdExp "a")));



(* Iteracion no exitosa, variable de iteracion repetida
*)
val iter2 = LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 6)),
               LetExp(ValDecl(NoRecursiva, IdPat "fact",
                 AbsExp [(IdPat "k",
                    IterExp([(
                       "n", IdExp "k", ApExp(IdExp "-", ParExp(IdExp "n", ConstExp(Entera 1))))
                    ,  ("n", ConstExp(Entera 1), ApExp(IdExp "*", ParExp(IdExp "n", IdExp "n")))
                    ],
                    ApExp(IdExp "=",ParExp(IdExp "n", ConstExp(Entera 0))),
                    IdExp "n"))
                 ])
               , ApExp(IdExp "fact", IdExp "a")));



(* Iteracion para que devuelva el n mas recientemente definido
*)
val iter3 = LetExp(ValDecl(NoRecursiva, IdPat "n", ConstExp(Entera 1)),                              
                   IterExp([(
                             "n", ConstExp(Entera 1), ApExp(IdExp "+", ParExp(IdExp "n", ConstExp(Entera 1))))                    
                           ],
                           ApExp(IdExp ">",ParExp(IdExp "n", ConstExp(Entera 10))),
                           IdExp "n"
                          ))
                 
               


(* Iteracion para que devuelva error de no reconocer a n, en la inicializacion
   de m
*)
val iter4 = IterExp([(
                      "n", ConstExp(Entera 1), ApExp(IdExp "+", ParExp(IdExp "n", ConstExp(Entera 1))))
                   ,  ("m", IdExp "n", ApExp(IdExp "+", ParExp(IdExp "n", IdExp "m")))
                    ],
                    ApExp(IdExp ">",ParExp(IdExp "n", ConstExp(Entera 10))),
                    IdExp "n");
                 
               

(* Iteracion que devuelve un registro *)
val iter5 = LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 3)),
                   IterExp([(
                             "n", ConstExp(Entera 1), ApExp(IdExp "+", ParExp(IdExp "n", ConstExp(Entera 1))))
                           ],
                           ApExp(IdExp ">", ParExp(IdExp "n", ConstExp(Entera 10))),
                           RegExp[("a", IdExp "a"), ("n", IdExp "n")]
                          ));