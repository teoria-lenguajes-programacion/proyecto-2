(* Evaluador.

   Este es realmente el interprete.
   Hay un caso para cada variante dentro de las categorias sintacticas.
*)

(* Cuando se trata de invocar un identificador que no corresponde a 
   una función, se activa esta excepción *)

exception NoEsUnaFuncion of string
and       NoSeAplicanReglas

(* evalExp evalua una expresion en un ambiente; se
   produce un valor semantico. *)

fun evalExp ambiente exp =
  case exp of
    ConstExp (Entera n)
       => ConstInt n
  | ConstExp (Booleana b)
       => ConstBool b
  | IdExp ident
       => busca ident ambiente
  | IfExp (cond,expV,expF)
       => let val condicion = evalExp ambiente cond
          in  case condicion of
               (ConstBool false) => evalExp ambiente expF
             | (ConstBool true)  => evalExp ambiente expV
             | _                 => raise ErrorDeTipo "se esperaba valor booleano"
          end
  | ParExp (expI,expD)
      => let val valI = evalExp ambiente expI
             and valD = evalExp ambiente expD
         in Par (valI, valD)
         end
  | LetExp (dec, exp)
      => let val ambientePrima = evalDec ambiente dec
         in evalExp (ambiente <+> ambientePrima) exp
         end
  | ApExp (operador,argumento)
      => let val operacion = evalExp ambiente operador
             and operando  = evalExp ambiente argumento
         in case operacion of
              Primitiva funcion
              => (funcion operando)
            | Clausura (reglas,ambDef,ambRec) 
              => aplicarReglas (ambDef <+> (desenrollar ambRec)) reglas operando
            | _  (* cualquier otra cosa no es una función *)
              => raise ErrorDeTipo "operador no es una función"
         end
  | AbsExp reglas
      => Clausura (reglas, ambiente, ambienteVacio)
  | RegExp ((id,exp)::tail) 
      => ConstInt 77
  | CondExp ((cond, expresion)::tail, expresionFinal)
      => let val condicion = evalExp ambiente cond
         in 
          case condicion of
               (ConstBool false) 
                => CondExp(tail, expresionFinal)
             | (ConstBool true)  
                => evalExp ambiente expresion
             | _                 
                => evalExp ambiente expresionFinal
          end   

and aplicarReglas ambiente reglas valor =
  case reglas of
    []
    => raise NoSeAplicanReglas
  | (pat,exp)::masReglas
    => let val ambienteLoc = concordar pat valor
       in evalExp (ambiente <+> ambienteLoc) exp  (* disparar regla *)
       end
       handle PatronesNoConcuerdan   (* seguir con otras reglas *)
              => aplicarReglas ambiente masReglas valor

and evalDec ambiente dec = 
  case dec of 
    ValDecl ((NoRecursiva, pat, expLocal))
      => let val valor = evalExp ambiente expLocal 
           ; val ambLocal = concordar pat valor
        in (ambiente <|> ambLocal)
        end
  | ValDecl ((Recursiva, pat, expLocal))
      => let val valor    = evalExp ambiente expLocal
           ; val ambLocal = concordar pat valor
        in (ambiente <|> (desenrollar ambLocal))
        end
  | AndDecl (dec1, dec2)
       => let val amb1 = evalDec ambiente dec1
              val amb2 = evalDec ambiente dec2
          in  amb1 <|> amb2 
          end
  | SecDecl (dec1,dec2)
       => let val amb1 = evalDec ambiente dec1
              val amb2 = evalDec (ambiente <+> amb1) dec2
          in  amb1 <|> amb2
          end
  | LocalDecl (dec1,dec2)
       => let val amb1 = evalDec ambiente dec1
              val amb2 = evalDec (ambiente <+> amb1) dec2
          in  amb2
          end                     
;

(* Los programas son expresiones en nuestro lenguaje.  Los unicos
   simbolos globales pre-definidos son los operadores unarios y
   binarios (que se buscan en los ambientes OperacionUnaria y
   Operacion Binaria).  
   Se exportan todas las funciones para que ustedes puedan hacer
   experimentos. *)
   

(* La expresión correspondiente al "programa principal" se evalúa
   en un ambiente vacío. *)

fun evalProg exp = evalExp ambientePrimitivas exp
