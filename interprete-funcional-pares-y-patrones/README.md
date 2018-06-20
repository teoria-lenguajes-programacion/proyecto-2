Instituto Tecnológico de Costa Rica  
Escuela de Ingeniería en Computación  
Maestría en Computación  
Teoría de los Lenguajes de Programació

**Proyecto 2**  

Profesor:  
Ignacio Trejos Zelaya  

Alumnos:
Carlos Martín Flores González  
Willard Zamora Cárdenas  

19 de Junio, 2018

------


## Contenidos
1. [Estrategia de solución](#estrategia-de-solución)
2. [Reflexiones sobre la experiencia](#reflexiones-sobre-la-experiencia)
3. [Documentación](#documentacion)
	4. [Representacion utilizada para los registros y cualquier otro valor semántico](#representacion-utilizada-para-los-registros-y-cualquier-otro-valor-semántico)

## Estrategia de solución
Se empezó el desarrollo del proyecto por medio de la exploración del código proporcionado por el profesor. Se ejecutaron pruebas sobre el mismo con el fin de entender cómo funcionaba y las partes del código que se ejercitaban luego de cada invocación.

Una vez que se tuvo un mejor conocimiento del funcionamiento se estudió el código del intéprete imperativo para incluir el manejo de las declaraciones en este proyecto. Este fue el primer logro. Luego de se empezaron a estudiar los casos de las expresiones `RegExp` y `CampoExp` pero en principio no se logró con una solución por lo que se decidió continuar con `CondExp`. Al estudiar cómo funcionaba el `cond` de Scheme se logró adaptar en relativamente poco tiempo el código que se venia desarrollando para dicha expresión.

Luego de la experiencia anterior, se podría decir que ya se estaba "entrando en calor" con el código SML y gracias a esto se fue desarrollando, probando y puliendo el código para las expresiones `RegExp` y `CampoExp`. 

Aunque en principio se decidió no implementar `IterExp` porque era opcional, se empezaron a probar los casos proporcionados por el profesor pero estos no se lograron entender. En la última clase se consultó al profesor sobre esto y dio pie a que se lograra implementar `IterExp`.

El proceso de desarrollo en general se dio a partir de discusión, desarrollo, pruebas y validación entre los miembros del equipo.

## Reflexiones sobre la experiencia

### Martín Flores
Esta fue mi primera experiencia con Standar ML. A pesar que ya tenía experiencia en otros lenguajes de programción funcionales, este al ser nuevo siempre presenta retos y más cuando hay que cumplir con alguna entrega. Durante el desarrollo del proyecto, navegué por varios sitios Web y pude comprobar que este es un lenguaje que goza de mucha aceptación dentro de las universidades principalemente en cursos de teoría de lenguajes de programación o bien para introducir conceptos de programación funcional.

En principio, aunque puede resultar algo diferente, conforme uno se va adentrando pude notar que es un lenguaje en el que se pueden lograr mucha expresividad, el concepto del `datatype` me parece muy para la definición de tipos a un "bajo costo" en términos de codificación. 

No se pudo encontrar buenas herramientas de _tooling_ para desarrollar en Standard ML. El _plugin_ de Sublime Text ayuda pero es limitado. El intérprete de _Moscow ML_ también es limitado a la hora de introducir código.

### Willard Zamora

### Plano grupal
Willard y Martín se conocieron durante el curso y nunca habían trabajado juntos en ningún proyecto, a pesar de esto durante el desarrollo se notó que contaban con intereses similares y se lograron complementar bien. Se considera que la comunicación constante fue un factor clave en lograr que el proyecto avanzara y se fuera puliendo paulatinamente. Durante varias de las video-llamadas que se llevaron a cabo para el desarrollo, los puntos de vista del uno y el otro fueron dándole forma al resultado final.

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

Se empieza por inicializar una lista con ini_ambiente (identificador con expresion de inicializar) y durante este proceso se verifica que el dominio sea disjunto, en caso de que lo sea se procede con la evaluación de condicionExp, si esta es verdadera se actualiza la lista con act_ambiente (identificador con expresion actualizar), si es falsa se evalua trueExp. Durante el proceso del ciclo se va hace un ambiente temporal que incluye el ambiente original concatenado con la lista actual, en el caso inicial es el ambiente original <+> la lista de valores inicializados y en los demás es ambiente original con la lista de valores actualizados, este ambiente temporal hace uso del ambiente original sin extenderlo innecesariamente, manteniendo siempre los últimos valores de la lista. 

```sml
  IterExp (lista, condicionExp, trueExp)
  =>  let fun modificar ambiente' exp' = evalExp ambiente' exp'
      in  let val listaAmb = ini_ambiente modificar lista ambiente
          in  let fun ciclo listaAmb' 
              = let 
                  val iterAmb = (ambiente <+> listaAmb')
                in
                  case (evalExp iterAmb condicionExp) of
                  (ConstBool false) 
                  => ciclo (act_ambiente modificar lista iterAmb)
                  | (ConstBool true)  
                  => evalExp iterAmb trueExp
                end
                in ciclo listaAmb
                end
          end
      end
```

## La solución dada a la evaluación de la expresión condicional generalizada.

Para esta evaluación se crearon dos condiciones:

1. Cuando se pasa una lista vacía y una expresión final (caso base)
2. Cuando se pasa una lista de la forma `Condicion * Expresion` y una expresión final

Cuando se da el caso **1**, se verifica primero si la `expresionFinal` es de alguno de los tipos opcionales definidos (`Something` o `Nothing`). En el caso que `expresionFinal` sea de tipo `Something`, quiere decir que la expresión si contiene una expresión final que puede ser evaluada. Para evaluar esta expresión se usa `evalExp`. En el caso que no se incluya una `expresionFinal` se lanza una excepción.

Cuando se pasa una lista de la forma `Condicion * Expresion`, primero se evalúa la condición (`cond`) y en el caso que el resultado sea verdadero (`ConstBool true`) se procede entonces a evaluar la expresion (`expresion`). Si el resultado de la evaluación de `cond` sea falso (`ConstBool false`) entonces se evalúa la expresión pero esta vez pasando como argumento el resultado de evaluar el resto de la lista (`tail`) con la expresión final. De esta forma se va a ir consumiento la lista de forma recursiva y probando cada uno de los pares `Condicion * Expresion`.

```sml
  | CondExp ([], expresionFinal)
     => let
        in
          case expresionFinal of
          (Something expFinal) => evalExp ambiente expFinal
          | Nothing  => raise NoHayClausulaElse "CondExp: No hay Else"
        end
  | CondExp ((cond, expresion)::tail, expresionFinal)
      => let val condicion = evalExp ambiente cond
         in 
          case condicion of
               (ConstBool false) 
                => evalExp ambiente (CondExp(tail, expresionFinal))
             | (ConstBool true)  
                => evalExp ambiente expresion
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

Las sigiuentes funciones fueron agregadas a Ambi.sml, ini_ambiente y act_ambiente realizan el mismo recorrido que map_ambiente, pero sobre una lista de tripletas.

1. ini_ambiente aplica la expresión de inicialización al identificador y va verificando que los dominios sean disjuntos conforme recorre la lista.
2. act_ambiente aplica la expresión de actualización al identificador.
3. existe_en_lista busca en una lista de tripletas (identificador * _ * _ ) que no existan identificadores repetidos.


```sml
fun existe_en_lista ident []
    = false
|   existe_en_lista ident ((ident',_,_)::ambiente)
    = if ident = ident' 
      then true
      else existe_en_lista ident ambiente

fun ini_ambiente f [] ambiente
    = []
|   ini_ambiente f ((ident, expIni, expAct)::cola) ambiente    
    = if existe_en_lista ident cola then
        raise DominiosNoDisyuntos
      else
        (ident,(f ambiente expIni))::(ini_ambiente f cola ambiente)

fun act_ambiente f [] ambiente
    = []
|   act_ambiente f ((ident, expIni, expAct)::cola) ambiente    
    = (ident,(f ambiente expAct))::(act_ambiente f cola ambiente)
```

## Casos de prueba y resultados observados.

Las siguientes pruebas fueron tomadas del archivo `PruebasFun.sml`. 

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
```

#### Iteración
```sml
(* Iteración exitosa *)
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
```
### Expresión condicional `CondExp`
```sml
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

### Concordancia de patrones


### Expresión `ComoPat`
```sml

```

### Declaraciones colaterales, secuenciales y locales
```sml
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
```

### Declaraciones Recursivas
```sml
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
                                                                       ApExp(IdExp "-",Par",
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
                                                                       ApExp(IdExp "-",P"y",
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
```