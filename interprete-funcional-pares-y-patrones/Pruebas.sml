(*
   Pruebas para la revision de la primera tarea programada
*)



(************************************************************)
(***********************REGISTROS****************************)

val registro1 = RegExp [("a", ConstExp(Entera 1)),
                        ("b", ConstExp(Entera 2))];

(* Campos repetidos
*)
val registro2 = RegExp [("x", ConstExp(Entera 3)),
                        ("x", ConstExp(Entera 4))];


(* Acceso a campo
*)
val regA  = CampoExp(registro1, "a");  (* Campo existente *)
val regC  = CampoExp(registro1, "c");  (* Campo inexistente *)


val regFun = IfExp(ApExp (IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                   registro1,
                   registro2);

val pruFun = LetExp( ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                     regFun);

(* Acceso a campos donde el registro es el resultado de una expresion
*)
val regA1 = CampoExp(pruFun, "a");
val regC1 = CampoExp(pruFun, "c");






(************************************************************)
(***********************ITERACION****************************)


(* Iteracion exitosa
*)
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




(************************************************************)
(*************************COND*******************************)


(* Condicional exitoso *)
val cond1 = LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                   CondExp([
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                               ConstExp(Entera 1)),
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 2))),
                               ConstExp(Entera 2))
                           ],
                           Nothing));


(* Condicional exitoso, se evalua que se ejecute la primera que encuentra *)
val cond2 = LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
                   CondExp([
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                               ConstExp(Entera 1)),
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 2))),
                               ConstExp(Entera 2)),
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                               ConstExp(Entera 3))                            
                           ],
                           Nothing));


(* Se evalua la ejecucion del else *)
val cond3 = LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 3)),
                   CondExp([
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                               ConstExp(Entera 1)),
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 2))),
                               ConstExp(Entera 2))
                           ],
                           Something (ConstExp(Entera 3))));



(* Condicional no exitoso sin else *)
val cond4 = LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 4)),
                   CondExp([
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 1))),
                               ConstExp(Entera 1)),
                            (ApExp(IdExp "=", ParExp(IdExp "a", ConstExp(Entera 2))),
                               ConstExp(Entera 2))
                           ],
                           Nothing));


(************************************************************)
(***********************CONCORDANCIA*************************)

(* Concordancia de patrones con dominios no disyuntos *)
val conpat1 =  ParPat(IdPat "a", ParPat(IdPat "b", IdPat "a"));
val conpat2 = (ParExp(ConstExp(Entera 1), ParExp(ConstExp(Entera 2), ConstExp(Entera 3))));

val concord1 = LetExp(ValDecl(NoRecursiva, conpat1, conpat2),
                      IdExp "a");


(* Concordancia de regitros con dominios no disyuntos *)
val conreg1 = RegPat ["a", "b", "a"];
val conreg2 = RegExp [("a", ConstExp(Entera 1)),
                      ("b", ConstExp(Entera 2))
                       ];

val concord2 = LetExp(ValDecl(NoRecursiva, conreg1, conreg2),
                      IdExp "a");


(* Concordancia de registros de tama¤os diferentes  *)
val conreg3 = RegPat ["a", "b"];
val conreg4 = RegExp [("a", ConstExp(Entera 1)),
                      ("b", ConstExp(Entera 2)),
                      ("c", ConstExp(Entera 3))
                     ];

val concord3 = LetExp(ValDecl(NoRecursiva, conreg3, conreg4),
                      ApExp(IdExp "+", ParExp(IdExp "a", IdExp "b")));



(* Concordancia de registros no exitosa *)
val conreg5 = RegPat ["a", "d"];
val conreg6 = RegExp [("a", ConstExp(Entera 1)),
                      ("b", ConstExp(Entera 2)),
                      ("c", ConstExp(Entera 3))
                     ];

val concord4 = LetExp(ValDecl(NoRecursiva, conreg5, conreg6),
                      ApExp(IdExp "+", ParExp(IdExp "a", IdExp "d")));


(* Concordancia de un registro con una constante  *)
val conreg7 = RegPat ["a", "b"];

val concord5 = LetExp(ValDecl(NoRecursiva, conreg7, ConstExp(Entera 8)),
                      IdExp "a");



(************************************************************)
(**************************COMOPAT***************************)

(* Concordancia exitosa  *)
val comop1 = ComoPat("x", ParPat(IdPat "y", IdPat "z"));
val comop2 = ParExp(ConstExp(Entera 2), ConstExp(Entera 3));

val compat1 = LetExp(ValDecl(NoRecursiva, comop1, comop2),
                     ParExp( ApExp(IdExp "+", ParExp(IdExp "y", IdExp "z")),
                             IdExp "x"));


(* Concordancia donde el se tienen nombres repetidos, error  *)
val comop3 = ComoPat("x", ParPat(IdPat "x", IdPat "z"));

val compat2 = LetExp(ValDecl(NoRecursiva, comop3, comop2),
                     IdExp "y");



(* Concordancia donde no se tiene exito *)
val comop4 = ComoPat("x", ParPat(IdPat "y", ConstPat(Entera 1)));

val compat3 = LetExp(ValDecl(NoRecursiva, comop4, comop2),
                     IdExp "y");



(************************************************************)
(*****DECLARACIONES COLATERALES, SECUENCIALES y LOCALES******)


(* Declaraciones *)
val val1 = ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1));
val val2 = ValDecl(NoRecursiva, IdPat "b", ConstExp(Entera 2));
val val3 = ValDecl(NoRecursiva, IdPat "c", ApExp(IdExp "+", ParExp(IdExp "a", ConstExp(Entera 2))));
val val4 = ValDecl(NoRecursiva, IdPat "d", ApExp(IdExp "+", ParExp(IdExp "f", ConstExp(Entera 3))));


(***** Declaraciones colaterales *****)

(* Declaracion colateral exitosa *)
val colat1 = LetExp(AndDecl(val1, val2), 
                    ApExp(IdExp "+", ParExp(IdExp "a", IdExp "b")));


(* Declaracion colateral exitosa  *)
val colat2 = LetExp(AndDecl(val1, val2), 
                    IdExp "a");

(* Declaracion colateral no exitosa  *)
val colat3 = LetExp(AndDecl(val1, val3), 
                    IdExp "c");

(* Declaracion colateral no exitosa  *)
val colat4 = LetExp(AndDecl(val1, val1), 
                    IdExp "a");



(****** Declaraciones secuenciales *****)

(* Declaracion secuencial exitosa *)
val sec1 = LetExp(SecDecl(val1, val2), 
                  ApExp(IdExp "+", ParExp(IdExp "a", IdExp "b")));

(* Declaracion secuencial exitosa  *)
val sec2 = LetExp(SecDecl(val1, val3), 
                  IdExp "c");


(***** Declaraciones locales *****)

(* Declaracion local exitosa *)
val loc1 = LetExp(LocalDecl(val1, val3),
                  IdExp "c");

(* Declaracio local no exitosa *)
val loc2 = LetExp(LocalDecl(val1, val4),
                  IdExp "d");

(* Declaracion local no exitosa *)
val loc3 = LetExp(LocalDecl(val1, val3),
                  IdExp "a");



(************************************************************)
(*****************DECLARACIONES RECURSIVAS*******************)


(* Factorial recursivo exitoso *)
val fact1 = LetExp(ValDecl(Recursiva, IdPat "fact",
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
                                 



(* Factorial recursivo no exitoso *)
val fact2 = LetExp(ValDecl(NoRecursiva, IdPat "fact",
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



                  
                          
(* Funciones mutuamente recursivas exitosas  *)

val mut1 = LetExp(ValDecl(Recursiva, ParPat(IdPat "f", IdPat "g"),
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



(* Funciones mutuamente recursivas no exitosas  *)

val mut2 = LetExp(ValDecl(NoRecursiva, ParPat(IdPat "f", IdPat "g"),
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

                                                                         



                             






    
