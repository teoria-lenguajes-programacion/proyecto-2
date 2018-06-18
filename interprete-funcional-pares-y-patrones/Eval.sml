(* Evaluador.

   Este es realmente el interprete.
   Hay un caso para cada variante dentro de las categorias sintacticas.
*)

(* Cuando se trata de invocar un identificador que no corresponde a 
   una funci�n, se activa esta excepci�n *)

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
            | _  (* cualquier otra cosa no es una funci�n *)
              => raise ErrorDeTipo "operador no es una funci�n"
         end
  | AbsExp reglas
      => Clausura (reglas, ambiente, ambienteVacio)
  | RegExp registros
      => let fun map_exp exp' = evalExp ambiente exp'
         in let val lista = map_ambiente map_exp registros
            in Registros lista
            end
         end
  | CampoExp (exp', ident)
      => let val Registros lista = evalExp ambiente exp'
         in  busca ident lista
         end
  | IterExp (lista, condicionExp, trueExp)
      => let fun modificar ambiente' exp' = evalExp ambiente' exp'
         in let val listaAmb = ini_ambiente modificar lista ambiente
            in let fun ciclo listaAmb' 
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
        in ambLocal
        end
  | ValDecl ((Recursiva, pat, expLocal))
      => let val valor    = evalExp ambiente expLocal
           ; val ambLocal = concordar pat valor
        in (desenrollar ambLocal)
        end
  | AndDecl (dec1, dec2)
       => let val amb1 = evalDec ambiente dec1
              val amb2 = evalDec ambiente dec2
          in  amb1 <|> amb2 
          end
  | SecDecl (dec1,dec2)
       => let val amb1 = evalDec ambiente dec1
              val amb2 = evalDec (ambiente <+> amb1) dec2
          in  amb1 <+> amb2
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
   

(* La expresi�n correspondiente al "programa principal" se eval�a
   en un ambiente vac�o. *)

fun evalProg exp = evalExp ambientePrimitivas exp
