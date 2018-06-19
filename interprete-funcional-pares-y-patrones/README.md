Proyecto 2: Intérprete de Pares y Patrones
==========================================
> Willard Zamora 2017239202  
> Carlos Martín Flores González 2015183528

# Documentación

## Representacion utilizada para los registros y cualquier otro valor semántico

Se hace uso de un nuevo tipo de valor Registro, el cual se agrega en Val.sml con el objetivo de implementar RexExp y CampoExp
```sml
   Registros of (Identificador * Valor) list
```

## La solución dada al manejo de registros (expresiones-registro, accesos a campos de un registro)

En RexExp se hace uso del nuevo tipo valor Registros y la función existente de map_ambiente, aplicando a cada par (Identificador, Expresion) la funcion que evalua la expresion y la asocia al identificador.

```sml
  RegExp registros
  =>  let fun map_exp exp' = evalExp ambiente exp'
      in  let val lista = map_ambiente map_exp registros
          in Registros lista
          end
      end
```

Con respecto a CampoExp simplemente se genera el valor registro a partir de la expresion y en ella se hace busca del identificador pasando como ambiente la lista tipo Registros.

```sml
  CampoExp (exp', ident)
  =>  let val Registros lista = evalExp ambiente exp'
      in  busca ident lista
      end
```

## La solución dada a la evaluación de la expresión iterativa.
No implementada 

## La solución dada a la evaluación de la expresión condicional generalizada.
Para esta evaluación se crearon dos condiciones:
1. Cuando se pasa una lista vacía y una expresión final (caso base)
2. Cuando se pasa una lista de la forma `Condicion * Expresion` y una expresión final

Cuando se da el caso **1**, se verifica primero si la `expresionFinal` es de tipo `option`. Si es así, entonces se evalúa la expresión con `evalExp` pasando como argumentos el `ambiente` y el valor que viene dentro de la expresión opcional utilizando la función `valOf`. Si la expresión final no se encuentra se lanza una excepción.

Cuando se pasa una lista de la forma `Condicion * Expresion`, primero se evalúa la condición (`cond`) y en el caso que el resultado sea verdadero (`ConstBool true`) se procede entonces a evaluar la expresion (`expresion`). Si el resultado de la evaluación de `cond` sea falso (`ConstBool false`) entonces se evalúa la expresión pero esta vez pasando como argumento el resultado de evaluar el resto de la lista (`tail`) con la expresión final. De esta forma se va a ir consumiento la lista de forma recursiva y probando cada uno de los pares `Condicion * Expresion`.

```sml
  | CondExp ([], expresionFinal)
     => let
        in
          if isSome(expresionFinal) then 
            evalExp ambiente (valOf(expresionFinal))
          else
            raise NoHayClausulaElse "CondExp: No hay Else"
        end
  | CondExp ((cond, expresion)::tail, expresionFinal)
      => let val condicion = evalExp ambiente cond
         in 
          case condicion of
               (ConstBool false) 
                => ( 
                  evalExp ambiente (CondExp(tail, expresionFinal))
                  )
             | (ConstBool true)  
                => (
                  evalExp ambiente expresion
                   )
          end
```

## La solución dada a las extensiones hechas a los patrones (patrones estratificados [‘as’], patrones-registro).

Se crearon dos casos para hacer la concordancia:
1. Cuando se pasa una lista vacía de identificadores junto con `Registros` (identificador * valor) (caso base)
2. Cuando se pasa una lista de identificadores con la forma `(id::tail)` junto con `Registros`

Cuando se da el caso **1**, se retorna un `ambienteVacio`. Cuando se da el caso **2**, se busca el identificador `id` en la lista de registros para que luego por medio del combinador de ambientes `<|>`, se combine el resultado de la operación anterior junto con el resultado de la invocación a `concordar` pasando por parámtro el resto de la lista de identificadores junto con los `Registros` para ir asociando el resto de identicadores.

A continuación un extracto del código de `Concord.sml`:

```sml
|   concordar (RegPat (id::tail)) (Registros (registros))
    = id |-> (busca id registros) <|> concordar (RegPat (tail)) (Registros (registros))
|   concordar (RegPat []) (Registros (registros))
    = ambienteVacio
```

## La solución dada a la combinación de ambientes con dominios disyuntos (función <|>).
Esta solución fue proporcionada por el profesor.

## Otras modificaciones hechas al intérprete.
No se hicieron otras modificaciones

## Casos de prueba y resultados observados.

### Registros

```sml
- val registro1 = RegExp [("a", ConstExp(Entera 1)),
                        ("b", ConstExp(Entera 2))];
> val registro1 = RegExp [("a", ConstExp(Entera 1)), ("b", ConstExp(Entera 2))]
     : Expresion

(* Campos repetidos *)     
- val registro2 = RegExp [("x", ConstExp(Entera 3)),
                        ("x", ConstExp(Entera 4))];
> val registro2 = RegExp [("x", ConstExp(Entera 3)), ("x", ConstExp(Entera 4))]
     : Expresion

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


(* ValDecl *)
- val pruFun = LetExp(ValDecl(NoRecursiva, IdPat "a", ConstExp(Entera 1)),
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
- 

(* Una Suma *)
- val unaSuma = LetExp (ValDecl(NoRecursiva,IdPat "a", ConstExp (Entera 9)), ApExp (IdExp "+", ParExp (IdExp "a",ConstExp (Entera 1))));

- evalProg unaSuma;
> val it = ConstInt 10 : Valor


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

```

