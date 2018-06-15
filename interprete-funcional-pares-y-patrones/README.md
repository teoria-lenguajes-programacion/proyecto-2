Proyecto 2: Intérprete de Pares y Patrones
==========================================
> Willard Zamora 2017239202  
> Carlos Martín Flores González 2015183528

# Documentación

## Representacion utilizada para los registros y cualquier otro valor semántico

## La solución dada al manejo de registros (expresiones-registro, accesos a campos de un registro)

## La solución dada a la evaluación de la expresión iterativa.
No implementada 

## La solución dada a la evaluación de la expresión condicional generalizada.
Para esta evaluación se crearon dos condiciones:
1. Cuando se pasa una lista vacía y una expresión final (caso base)
2. Cuando se pasa una lista de la forma `Condicion * Expresion` y una expresión final

Cuando se da el caso `1`, se verifica primero si la `expresionFinal` es de tipo `option`. Si es así, entonces se evalúa la expresión con `evalExp` pasando como argumentos el `ambiente` y el valor que viene dentro de la expresión opcional utilizando la función `valOf`. Si la expresión final no se encuentra se lanza una excepción.

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

## La solución dada a la combinación de ambientes con dominios disyuntos (función <|>).
Esta solución fue proporcionada por el profesor.

## Otras modificaciones hechas al intérprete.

## Casos de prueba y resultados observados.