(************************************************************)
(***********************REGISTROS****************************)

- val registro1 = RegExp [("a", ConstExp(Entera 1)),
                        ("b", ConstExp(Entera 2))];
> val registro1 = RegExp [("a", ConstExp(Entera 1)), ("b", ConstExp(Entera 2))]
     : Expresion
- evalProg registro1;
> val it = Registros [("a", ConstInt 1), ("b", ConstInt 2)] : Valor     

(* Campos repetidos *)     
- val registro2 = RegExp [("x", ConstExp(Entera 3)),
                        ("x", ConstExp(Entera 4))];
> val registro2 = RegExp [("x", ConstExp(Entera 3)), ("x", ConstExp(Entera 4))]
     : Expresion
- evalProg registro2;
> val it = Registros [("x", ConstInt 3), ("x", ConstInt 4)] : Valor     

(* Campo existente *)
- val regA  = CampoExp(registro1, "a");
> val regA =
    CampoExp(RegExp [("a", ConstExp(Entera 1)), ("b", ConstExp(Entera 2))],
             "a") : Expresion
- evalProg regA;
> val it = ConstInt 1 : Valor

(* Campo inexistente *)
- val regC  = CampoExp(registro1, "c");
> val regC =
    CampoExp(RegExp [("a", ConstExp(Entera 1)), ("b", ConstExp(Entera 2))],
             "c") : Expresion
- evalProg regC;
! Uncaught exception:
! NoEstaEnElDominio  "c"


- val pruFun = LetExp( ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                     regFun);
> val pruFun =
    LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
           IfExp(ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                 RegExp [("a", ConstExp(Entera 1)), ("b", ConstExp(Entera 2))],
                 RegExp [("x", ConstExp(Entera 3)),
                         ("x", ConstExp(Entera 4))])) : Expresion
- evalProg pruFun;
> val it = Registros [("a", ConstInt 1), ("b", ConstInt 2)] : Valor


(* Acceso a campos donde el registro es el resultado de una expresion *)

- val regA1 = CampoExp(pruFun, "a");
> val regA1 =
    CampoExp(LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                    IfExp(ApExp(IdExp "=",
                                ParExp(IdExp "a", ConstExp(Entera 1))),
                          RegExp [("a", ConstExp(Entera 1)),
                                  ("b", ConstExp(Entera 2))],
                          RegExp [("x", ConstExp(Entera 3)),
                                  ("x", ConstExp(Entera 4))])), "a") :
  Expresion
- evalProg regA1;
> val it = ConstInt 1 : Valor

- val regC1 = CampoExp(pruFun, "c");
> val regC1 =
    CampoExp(LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                    IfExp(ApExp(IdExp "=",
                                ParExp(IdExp "a", ConstExp(Entera 1))),
                          RegExp [("a", ConstExp(Entera 1)),
                                  ("b", ConstExp(Entera 2))],
                          RegExp [("x", ConstExp(Entera 3)),
                                  ("x", ConstExp(Entera 4))])), "c") :
  Expresion
- evalProg regC1;
! Uncaught exception:
! NoEstaEnElDominio  "c"


(************************************************************)
(***********************ITERACION****************************)

(* Iteracion exitosa *)
- val iter1 = LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 6)),
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
> val iter1 =
    LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 6)),
           LetExp(ValDecl(NoRecursiva, IdPat "fact",
                          AbsExp [(IdPat "k",
                                   IterExp([("n", IdExp "k",
                                             ApExp(IdExp "-",
                                                   ParExp(IdExp "n",
                                                          ConstExp(Entera 1)))),
                                            ("product", ConstExp(Entera 1),
                                             ApExp(IdExp "*",
                                                   ParExp(IdExp "product",
                                                          IdExp "n")))],
                                           ApExp(IdExp "=",
                                                 ParExp(IdExp "n",
                                                        ConstExp(Entera 0))),
                                           IdExp "product"))]),
                  ApExp(IdExp "fact", IdExp "a"))) : Expresion
- evalProg iter1;
> val it = ConstInt 720 : Valor

(* Iteracion no exitosa, variable de iteracion repetida *)
- val iter2 = LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 6)),
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
> val iter2 =
    LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 6)),
           LetExp(ValDecl(NoRecursiva, IdPat "fact",
                          AbsExp [(IdPat "k",
                                   IterExp([("n", IdExp "k",
                                             ApExp(IdExp "-",
                                                   ParExp(IdExp "n",
                                                          ConstExp(Entera 1)))),
                                            ("n", ConstExp(Entera 1),
                                             ApExp(IdExp "*",
                                                   ParExp(IdExp "n",
                                                          IdExp "n")))],
                                           ApExp(IdExp "=",
                                                 ParExp(IdExp "n",
                                                        ConstExp(Entera 0))),
                                           IdExp "n"))]),
                  ApExp(IdExp "fact", IdExp "a"))) : Expresion
- evalProg iter2;
! Uncaught exception:
! DominiosNoDisyuntos

(* Iteracion para que devuelva el n mas recientemente definido *)
- val iter3 = LetExp(ValDecl(NoRecursiva, IdPat "n", ConstExp(Entera 1)),                              
                   IterExp([(
                             "n", ConstExp(Entera 1), ApExp(IdExp "+", ParExp(IdExp "n", ConstExp(Entera 1))))                    
                           ],
                           ApExp(IdExp ">",ParExp(IdExp "n", ConstExp(Entera 10))),
                           IdExp "n"
                          ));
> val iter3 =
    LetExp(ValDecl(NoRecursiva, IdPat "n", ConstExp(Entera 1)),
           IterExp([("n", ConstExp(Entera 1),
                     ApExp(IdExp "+", ParExp(IdExp "n", ConstExp(Entera 1))))],
                   ApExp(IdExp ">", ParExp(IdExp "n", ConstExp(Entera 10))),
                   IdExp "n")) : Expresion
- evalProg iter3;
> val it = ConstInt 11 : Valor

(* Iteracion para que devuelva error de no reconocer a n, en la inicializacion de m *)
- val iter4 = IterExp([(
                      "n", ConstExp(Entera 1), ApExp(IdExp "+", ParExp(IdExp "n", ConstExp(Entera 1))))
                   ,  ("m", IdExp "n", ApExp(IdExp "+", ParExp(IdExp "n", IdExp "m")))
                    ],
                    ApExp(IdExp ">",ParExp(IdExp "n", ConstExp(Entera 10))),
                    IdExp "n");
> val iter4 =
    IterExp([("n", ConstExp(Entera 1),
              ApExp(IdExp "+", ParExp(IdExp "n", ConstExp(Entera 1)))),
             ("m", IdExp "n", ApExp(IdExp "+", ParExp(IdExp "n", IdExp "m")))],
            ApExp(IdExp ">", ParExp(IdExp "n", ConstExp(Entera 10))),
            IdExp "n") : Expresion
- evalProg iter4;
! Uncaught exception:
! NoEstaEnElDominio  "n"


(* Iteracion que devuelve un registro *)
- val iter5 = LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 3)),
                   IterExp([(
                             "n", ConstExp(Entera 1), ApExp(IdExp "+", ParExp(IdExp "n", ConstExp(Entera 1))))
                           ],
                           ApExp(IdExp ">", ParExp(IdExp "n", ConstExp(Entera 10))),
                           RegExp[("a", IdExp "a"), ("n", IdExp "n")]
                          ));
> val iter5 =
    LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 3)),
           IterExp([("n", ConstExp(Entera 1),
                     ApExp(IdExp "+", ParExp(IdExp "n", ConstExp(Entera 1))))],
                   ApExp(IdExp ">", ParExp(IdExp "n", ConstExp(Entera 10))),
                   RegExp [("a", IdExp "a"), ("n", IdExp "n")])) : Expresion
- evalProg iter5;
> val it = Registros [("a", ConstInt 3), ("n", ConstInt 11)] : Valor


(************************************************************)
(*********************CONDICIONAL****************************)

(* Condicional exitoso *)
- val cond1 = LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                   CondExp([
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                               ConstExp(Entera 1)),
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 2))),
                               ConstExp(Entera 2))
                           ],
                           Nothing));
> val cond1 =
    LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
           CondExp([(ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                     ConstExp(Entera 1)),
                    (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 2))),
                     ConstExp(Entera 2))], Nothing)) : Expresion
- evalProg cond1;
> val it = ConstInt 1 : Valor

(* Condicional exitoso, se evalua que se ejecute la primera que encuentra *)
- val cond2 = LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                   CondExp([
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                               ConstExp(Entera 1)),
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 2))),
                               ConstExp(Entera 2)),
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                               ConstExp(Entera 3))                            
                           ],
                           Nothing));
> val cond2 =
    LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
           CondExp([(ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                     ConstExp(Entera 1)),
                    (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 2))),
                     ConstExp(Entera 2)),
                    (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                     ConstExp(Entera 3))], Nothing)) : Expresion
- evalProg cond2;
> val it = ConstInt 1 : Valor

(* Se evalua la ejecucion del else *)
- val cond3 = LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 3)),
                   CondExp([
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                               ConstExp(Entera 1)),
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 2))),
                               ConstExp(Entera 2))
                           ],
                           Something (ConstExp(Entera 3))));
> val cond3 =
    LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 3)),
           CondExp([(ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                     ConstExp(Entera 1)),
                    (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 2))),
                     ConstExp(Entera 2))], Something(ConstExp(Entera 3)))) :
  Expresion
- evalProg cond3;
> val it = ConstInt 3 : Valor

(* Condicional no exitoso sin else *)
- val cond4 = LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 4)),
                   CondExp([
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                               ConstExp(Entera 1)),
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 2))),
                               ConstExp(Entera 2))
                           ],
                           Nothing));
> val cond4 =
    LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 4)),
           CondExp([(ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                     ConstExp(Entera 1)),
                    (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 2))),
                     ConstExp(Entera 2))], Nothing)) : Expresion
- evalProg cond4;
! Uncaught exception:
! NoHayClausulaElse  "CondExp: No hay Else"

(************************************************************)
(***********************CONCORDANCIA*************************)

(* Concordancia de patrones con dominios no disyuntos *)
- val conpat1 =  ParPat(IdPat "a", ParPat(IdPat "b", IdPat "a"));
> val conpat1 = ParPat(IdPat "a", ParPat(IdPat "b", IdPat "a")) : Patron
- val conpat2 = (ParExp(ConstExp(Entera 1), ParExp(ConstExp(Entera 2), ConstExp(Entera 3))));
> val conpat2 =
    ParExp(ConstExp(Entera 1), ParExp(ConstExp(Entera 2), ConstExp(Entera 3)))
     : Expresion
- val concord1 = LetExp(ValDecl(NoRecursiva, conpat1, conpat2),
                      IdExp "a");
> val concord1 =
    LetExp(ValDecl(NoRecursiva,
                   ParPat(IdPat "a", ParPat(IdPat "b", IdPat "a")),
                   ParExp(ConstExp(Entera 1),
                          ParExp(ConstExp(Entera 2), ConstExp(Entera 3)))),
           IdExp "a") : Expresion
- evalProg concord1;
! Uncaught exception:
! DominiosNoDisyuntos

(* Concordancia de regitros con dominios no disyuntos *)
- val conreg1 = RegPat ["a", "b", "a"];
> val conreg1 = RegPat ["a", "b", "a"] : Patron
- val conreg2 = RegExp [("a", ConstExp(Entera 1)),
                      ("b", ConstExp(Entera 2))
                       ];
> val conreg2 = RegExp [("a", ConstExp(Entera 1)), ("b", ConstExp(Entera 2))] :
  Expresion
- val concord2 = LetExp(ValDecl(NoRecursiva, conreg1, conreg2),
                      IdExp "a");
> val concord2 =
    LetExp(ValDecl(NoRecursiva, RegPat ["a", "b", "a"],
                   RegExp [("a", ConstExp(Entera 1)),
                           ("b", ConstExp(Entera 2))]), IdExp "a") : Expresion
- evalProg concord2;
! Uncaught exception:
! DominiosNoDisyuntos

(* Concordancia de registros de tamannos diferentes  *)
- val conreg3 = RegPat ["a", "b"];
> val conreg3 = RegPat ["a", "b"] : Patron
- val conreg4 = RegExp [("a", ConstExp(Entera 1)),
                      ("b", ConstExp(Entera 2)),
                      ("c", ConstExp(Entera 3))
                     ];
> val conreg4 =
    RegExp [("a", ConstExp(Entera 1)), ("b", ConstExp(Entera 2)),
            ("c", ConstExp(Entera 3))] : Expresion
- val concord3 = LetExp(ValDecl(NoRecursiva, conreg3, conreg4),
                      ApExp(IdExp "+", ParExp(IdExp "a", IdExp "b")));
> val concord3 =
    LetExp(ValDecl(NoRecursiva, RegPat ["a", "b"],
                   RegExp [("a", ConstExp(Entera 1)),
                           ("b", ConstExp(Entera 2)),
                           ("c", ConstExp(Entera 3))]),
           ApExp(IdExp "+", ParExp(IdExp "a", IdExp "b"))) : Expresion
- evalProg concord3;
> val it = ConstInt 3 : Valor

(* Concordancia de registros no exitosa *)
- val conreg5 = RegPat ["a", "d"];
> val conreg5 = RegPat ["a", "d"] : Patron
- val conreg6 = RegExp [("a", ConstExp(Entera 1)),
                      ("b", ConstExp(Entera 2)),
                      ("c", ConstExp(Entera 3))
                     ];
> val conreg6 =
    RegExp [("a", ConstExp(Entera 1)), ("b", ConstExp(Entera 2)),
            ("c", ConstExp(Entera 3))] : Expresion
- val concord4 = LetExp(ValDecl(NoRecursiva, conreg5, conreg6),
                      ApExp(IdExp "+", ParExp(IdExp "a", IdExp "d"))); 
> val concord4 =
    LetExp(ValDecl(NoRecursiva, RegPat ["a", "d"],
                   RegExp [("a", ConstExp(Entera 1)),
                           ("b", ConstExp(Entera 2)),
                           ("c", ConstExp(Entera 3))]),
           ApExp(IdExp "+", ParExp(IdExp "a", IdExp "d"))) : Expresion
- evalProg concord4;
! Uncaught exception:
! NoEstaEnElDominio  "d"


(* Concordancia de un registro con una constante  *)
- val conreg7 = RegPat ["a", "b"];
> val conreg7 = RegPat ["a", "b"] : Patron
- val concord5 = LetExp(ValDecl(NoRecursiva, conreg7, ConstExp(Entera 8)),
                      IdExp "a");
> val concord5 =
    LetExp(ValDecl(NoRecursiva, RegPat ["a", "b"], ConstExp(Entera 8)),
           IdExp "a") : Expresion
- evalProg concord5;
! Uncaught exception:
! PatronesNoConcuerdan

(************************************************************)
(**************************COMOPAT***************************)

(* Concordancia exitosa  *)
- val comop1 = ComoPat("x", ParPat(IdPat "y", IdPat "z"));
> val comop1 = ComoPat("x", ParPat(IdPat "y", IdPat "z")) : Patron
- val comop2 = ParExp(ConstExp(Entera 2), ConstExp(Entera 3));
> val comop2 = ParExp(ConstExp(Entera 2), ConstExp(Entera 3)) : Expresion
- val compat1 = LetExp(ValDecl(NoRecursiva, comop1, comop2),
                     ParExp( ApExp(IdExp "+", ParExp(IdExp "y", IdExp "z")),
                             IdExp "x"));
> val compat1 =
    LetExp(ValDecl(NoRecursiva, ComoPat("x", ParPat(IdPat "y", IdPat "z")),
                   ParExp(ConstExp(Entera 2), ConstExp(Entera 3))),
           ParExp(ApExp(IdExp "+", ParExp(IdExp "y", IdExp "z")), IdExp "x")) :
  Expresion
- evalProg compat1;
> val it = Par(ConstInt 5, Par(ConstInt 2, ConstInt 3)) : Valor

(* Concordancia donde el se tienen nombres repetidos, error  *)
- val comop3 = ComoPat("x", ParPat(IdPat "x", IdPat "z"));
> val comop3 = ComoPat("x", ParPat(IdPat "x", IdPat "z")) : Patron
- val compat2 = LetExp(ValDecl(NoRecursiva, comop3, comop2),
                     IdExp "y");
> val compat2 =
    LetExp(ValDecl(NoRecursiva, ComoPat("x", ParPat(IdPat "x", IdPat "z")),
                   ParExp(ConstExp(Entera 2), ConstExp(Entera 3))), IdExp "y")
     : Expresion
- evalProg compat2;
! Uncaught exception:
! DominiosNoDisyuntos

(* Concordancia donde no se tiene exito *)
- val comop4 = ComoPat("x", ParPat(IdPat "y", ConstPat(Entera 1)));
> val comop4 = ComoPat("x", ParPat(IdPat "y", ConstPat(Entera 1))) : Patron
- val compat3 = LetExp(ValDecl(NoRecursiva, comop4, comop2),
                     IdExp "y");
> val compat3 =
    LetExp(ValDecl(NoRecursiva,
                   ComoPat("x", ParPat(IdPat "y", ConstPat(Entera 1))),
                   ParExp(ConstExp(Entera 2), ConstExp(Entera 3))), IdExp "y")
     : Expresion
- evalProg compat3;
! Uncaught exception:
! PatronesNoConcuerdan

(************************************************************)
(*****DECLARACIONES COLATERALES, SECUENCIALES y LOCALES******)

- val val1 = ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1));
> val val1 = ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)) : Declaracion
- val val2 = ValDecl(NoRecursiva, IdPat "b", ConstExp(Entera 2));
> val val2 = ValDecl(NoRecursiva, IdPat "b", ConstExp(Entera 2)) : Declaracion
- val val3 = ValDecl(NoRecursiva, IdPat "c", ApExp(IdExp "+", ParExp(IdExp "a", ConstExp(Entera 2))));
> val val3 =
    ValDecl(NoRecursiva, IdPat "c",
            ApExp(IdExp "+", ParExp(IdExp "a", ConstExp(Entera 2)))) :
  Declaracion
- val val4 = ValDecl(NoRecursiva, IdPat "d", ApExp(IdExp "+", ParExp(IdExp "f", ConstExp(Entera 3))));
> val val4 =
    ValDecl(NoRecursiva, IdPat "d",
            ApExp(IdExp "+", ParExp(IdExp "f", ConstExp(Entera 3)))) : Declaracion

(***** Declaraciones colaterales *****)

(* Declaracion colateral exitosa *)
- val colat1 = LetExp(AndDecl(val1, val2), 
                    ApExp(IdExp "+", ParExp(IdExp "a", IdExp "b")));
> val colat1 =
    LetExp(AndDecl(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                   ValDecl(NoRecursiva, IdPat "b", ConstExp(Entera 2))),
           ApExp(IdExp "+", ParExp(IdExp "a", IdExp "b"))) : Expresion
- evalProg colat1;
> val it = ConstInt 3 : Valor

(* Declaracion colateral exitosa  *)
- val colat2 = LetExp(AndDecl(val1, val2), 
                    IdExp "a");
> val colat2 =
    LetExp(AndDecl(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                   ValDecl(NoRecursiva, IdPat "b", ConstExp(Entera 2))),
           IdExp "a") : Expresion
- evalProg colat2;
> val it = ConstInt 1 : Valor

(* Declaracion colateral no exitosa  *)
- val colat3 = LetExp(AndDecl(val1, val3), 
                    IdExp "c");
> val colat3 =
    LetExp(AndDecl(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                   ValDecl(NoRecursiva, IdPat "c",
                           ApExp(IdExp "+",
                                 ParExp(IdExp "a", ConstExp(Entera 2))))),
           IdExp "c") : Expresion
- evalProg colat3;
! Uncaught exception:
! NoEstaEnElDominio  "a"

(* Declaracion colateral no exitosa  *)
- val colat4 = LetExp(AndDecl(val1, val1), 
                    IdExp "a");
> val colat4 =
    LetExp(AndDecl(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                   ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1))),
           IdExp "a") : Expresion
- evalProg colat4;
! Uncaught exception:
! DominiosNoDisyuntos

(****** Declaraciones secuenciales *****)

(* Declaracion secuencial exitosa *)
- val sec1 = LetExp(SecDecl(val1, val2), 
                  ApExp(IdExp "+", ParExp(IdExp "a", IdExp "b")));
> val sec1 =
    LetExp(SecDecl(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                   ValDecl(NoRecursiva, IdPat "b", ConstExp(Entera 2))),
           ApExp(IdExp "+", ParExp(IdExp "a", IdExp "b"))) : Expresion
- evalProg sec1;
> val it = ConstInt 3 : Valor

(* Declaracion secuencial exitosa *)
- val sec2 = LetExp(SecDecl(val1, val3), 
                  IdExp "c");
> val sec2 =
    LetExp(SecDecl(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                   ValDecl(NoRecursiva, IdPat "c",
                           ApExp(IdExp "+",
                                 ParExp(IdExp "a", ConstExp(Entera 2))))),
           IdExp "c") : Expresion
- evalProg sec2;
> val it = ConstInt 3 : Valor            


(***** Declaraciones locales *****)

(* Declaracion local exitosa *)
- val loc1 = LetExp(LocalDecl(val1, val3),
                  IdExp "c");
> val loc1 =
    LetExp(LocalDecl(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                     ValDecl(NoRecursiva, IdPat "c",
                             ApExp(IdExp "+",
                                   ParExp(IdExp "a", ConstExp(Entera 2))))),
           IdExp "c") : Expresion

(* Declaracion local no exitosa *)
- val loc2 = LetExp(LocalDecl(val1, val4),
                  IdExp "d");
> val loc2 =
    LetExp(LocalDecl(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                     ValDecl(NoRecursiva, IdPat "d",
                             ApExp(IdExp "+",
                                   ParExp(IdExp "f", ConstExp(Entera 3))))),
           IdExp "d") : Expresion
- evalProg loc2;
! Uncaught exception:
! NoEstaEnElDominio  "f"

(* Declaracion local no exitosa *)
- val loc3 = LetExp(LocalDecl(val1, val3),
                  IdExp "a");
> val loc3 =
    LetExp(LocalDecl(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                     ValDecl(NoRecursiva, IdPat "c",
                             ApExp(IdExp "+",
                                   ParExp(IdExp "a", ConstExp(Entera 2))))),
           IdExp "a") : Expresion
- evalProg loc3;
! Uncaught exception:
! NoEstaEnElDominio  "a"

(************************************************************)
(*****************DECLARACIONES RECURSIVAS*******************)

(* Factorial recursivo exitoso *)
- val fact1 = LetExp(ValDecl(Recursiva, IdPat "fact",
                    AbsExp[(IdPat "f",
                        CondExp([
                                 (ApExp(IdExp "=", ParExp(IdExp "f", ConstExp(Entera 0))),
                                   ConstExp(Entera 1)),
                                 (ApExp(IdExp "=", ParExp(IdExp "f", ConstExp(Entera 1))),
                                   ConstExp(Entera 1))
                                ],
                                Something
                                 (ApExp(IdExp "*", ParExp(IdExp "f", ApExp(IdExp "fact",
                                                                           ApExp(IdExp "-", ParExp(IdExp "f", ConstExp(Entera 1))))
                                                         )))

                                  ))
                            ]),
                  ApExp(IdExp "fact", ConstExp(Entera 5)));
> val fact1 =
    LetExp(ValDecl(Recursiva, IdPat "fact",
                   AbsExp [(IdPat "f",
                            CondExp([(ApExp(IdExp "=",
                                            ParExp(IdExp "f",
                                                   ConstExp(Entera 0))),
                                      ConstExp(Entera 1)),
                                     (ApExp(IdExp "=",
                                            ParExp(IdExp "f",
                                                   ConstExp(Entera 1))),
                                      ConstExp(Entera 1))],
                                    Something(ApExp(IdExp "*",
                                                    ParExp(IdExp "f",
                                                           ApExp(IdExp "fact",
                                                                 ApExp(IdExp "-",
                                                                       ParExp(#,
                                                                              #))))))))]),
           ApExp(IdExp "fact", ConstExp(Entera 5))) : Expresion
- evalProg fact1;
> val it = ConstInt 120 : Valor

(* Factorial recursivo no exitoso *)
- val fact2 = LetExp(ValDecl(NoRecursiva, IdPat "fact",
                    AbsExp[(IdPat "f",
                        CondExp([
                                 (ApExp(IdExp "=", ParExp(IdExp "f", ConstExp(Entera 0))),
                                   ConstExp(Entera 1)),
                                 (ApExp(IdExp "=", ParExp(IdExp "f", ConstExp(Entera 1))),
                                   ConstExp(Entera 1))
                                ],
                                Something
                                 (ApExp(IdExp "*", ParExp(IdExp "f", ApExp(IdExp "fact",
                                                                           ApExp(IdExp "-", ParExp(IdExp "f", ConstExp(Entera 1))))
                                                         )))

                                  ))
                            ]),
                  ApExp(IdExp "fact", ConstExp(Entera 5)));
> val fact2 =
    LetExp(ValDecl(NoRecursiva, IdPat "fact",
                   AbsExp [(IdPat "f",
                            CondExp([(ApExp(IdExp "=",
                                            ParExp(IdExp "f",
                                                   ConstExp(Entera 0))),
                                      ConstExp(Entera 1)),
                                     (ApExp(IdExp "=",
                                            ParExp(IdExp "f",
                                                   ConstExp(Entera 1))),
                                      ConstExp(Entera 1))],
                                    Something(ApExp(IdExp "*",
                                                    ParExp(IdExp "f",
                                                           ApExp(IdExp "fact",
                                                                 ApExp(IdExp "-",
                                                                       ParExp(#,
                                                                              #))))))))]),
           ApExp(IdExp "fact", ConstExp(Entera 5))) : Expresion
- evalProg fact2;
! Uncaught exception:
! NoEstaEnElDominio  "fact"

(* Funciones mutuamente recursivas exitosas *)
- val mut1 = LetExp(ValDecl(Recursiva, ParPat(IdPat "f", IdPat "g"),
                   (ParExp(
                    AbsExp[(IdPat "x",
                            ApExp(IdExp "+", ParExp(ConstExp(Entera 1),
                                                    ApExp(IdExp "g",
                                                          ApExp(IdExp "-", ParExp(IdExp "x",
                                                                                  ConstExp(Entera 1)))))
                           ))],
                    AbsExp[(IdPat "y",
                            IfExp( ApExp(IdExp "<", ParExp(IdExp "y",
                                                                 ConstExp(Entera 0))),
                                         IdExp "y",
                                         ApExp(IdExp "+", ParExp(ConstExp(Entera 1),
                                                                 ApExp(IdExp "f",
                                                                       ApExp(IdExp "-",ParExp(IdExp "y",
                                                                                              ConstExp(Entera 1)
                                                                                             )
                                                                            )
                                                                      )
                                                                )
                                              )                                         
                                       )
                                
                            )]
                  ))),
                  ApExp(IdExp "f", ConstExp(Entera 10)));
> val mut1 =
    LetExp(ValDecl(Recursiva, ParPat(IdPat "f", IdPat "g"),
                   ParExp(AbsExp [(IdPat "x",
                                   ApExp(IdExp "+",
                                         ParExp(ConstExp(Entera 1),
                                                ApExp(IdExp "g",
                                                      ApExp(IdExp "-",
                                                            ParExp(IdExp "x",
                                                                   ConstExp#))))))],
                          AbsExp [(IdPat "y",
                                   IfExp(ApExp(IdExp "<",
                                               ParExp(IdExp "y",
                                                      ConstExp(Entera 0))),
                                         IdExp "y",
                                         ApExp(IdExp "+",
                                               ParExp(ConstExp(Entera 1),
                                                      ApExp(IdExp "f",
                                                            ApExp(IdExp "-",
                                                                  ParExp#))))))])),
           ApExp(IdExp "f", ConstExp(Entera 10))) : Expresion
- evalProg mut1;
> val it = ConstInt 10 : Valor

(* Funciones mutuamente recursivas no exitosas *)
- val mut2 = LetExp(ValDecl(NoRecursiva, ParPat(IdPat "f", IdPat "g"),
                   (ParExp(
                    AbsExp[(IdPat "x",
                            ApExp(IdExp "+", ParExp(ConstExp(Entera 1),
                                                    ApExp(IdExp "g",
                                                          ApExp(IdExp "-", ParExp(IdExp "x",
                                                                                  ConstExp(Entera 1)))))
                           ))],
                    AbsExp[(IdPat "y",
                            IfExp( ApExp(IdExp "<", ParExp(IdExp "y",
                                                                 ConstExp(Entera 0))),
                                         IdExp "y",
                                         ApExp(IdExp "+", ParExp(ConstExp(Entera 1),
                                                                 ApExp(IdExp "f",
                                                                       ApExp(IdExp "-",ParExp(IdExp "y",
                                                                                              ConstExp(Entera 1)
                                                                                             )
                                                                            )
                                                                      )
                                                                )
                                              )                                         
                                       )
                                
                            )]
                  ))),
                  ApExp(IdExp "f", ConstExp(Entera 10)));
> val mut2 =
    LetExp(ValDecl(NoRecursiva, ParPat(IdPat "f", IdPat "g"),
                   ParExp(AbsExp [(IdPat "x",
                                   ApExp(IdExp "+",
                                         ParExp(ConstExp(Entera 1),
                                                ApExp(IdExp "g",
                                                      ApExp(IdExp "-",
                                                            ParExp(IdExp "x",
                                                                   ConstExp#))))))],
                          AbsExp [(IdPat "y",
                                   IfExp(ApExp(IdExp "<",
                                               ParExp(IdExp "y",
                                                      ConstExp(Entera 0))),
                                         IdExp "y",
                                         ApExp(IdExp "+",
                                               ParExp(ConstExp(Entera 1),
                                                      ApExp(IdExp "f",
                                                            ApExp(IdExp "-",
                                                                  ParExp#))))))])),
           ApExp(IdExp "f", ConstExp(Entera 10))) : Expresion
- evalProg mut2;
! Uncaught exception:
! NoEstaEnElDominio  "g"