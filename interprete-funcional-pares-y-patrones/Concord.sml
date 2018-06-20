(* Concordancia de patrones *)

(* se levantar� una excepci�n cuando no se pueda hacer
   concordancia de patrones *)

exception PatronesNoConcuerdan

fun concordar (ConstPat (Entera n)) (ConstInt n')
    = if n = n' then
        ambienteVacio
        (* literales concuerdan, no se producen asociaciones *)
      else
        raise PatronesNoConcuerdan
|   concordar (ConstPat (Booleana b)) (ConstBool b')
    = if b = b' then
        ambienteVacio
        (* literales concuerdan, no se producen asociaciones *)
      else
        raise PatronesNoConcuerdan
|   concordar (ComoPat (ident, pat)) valor
    = (concordar pat valor)
      <|>                           (* extiende ambiente *)
      (ident |-> valor)
|   concordar (IdPat ident) valor
    = ident |-> valor
      (* se asocia ident con valor, en ambiente unitario *)
|   concordar (ParPat (pati,patd)) (Par (vali,vald))
    = (concordar pati vali)
      <|>                           (* extiende ambiente *)
      (concordar patd vald)
|   concordar (RegPat (id::tail)) (Registros (registros))
    = id |-> (busca id registros) <|> concordar (RegPat (tail)) (Registros (registros))
|   concordar (RegPat []) (Registros (registros))
    = ambienteVacio
|   concordar Comodin _
    = ambienteVacio
      (* comod�n concuerda con todo, no produce asociaciones *)
|   concordar _ _
    = raise PatronesNoConcuerdan
      (* patr�n y valor estructuralmente incompatibles *)

(* Atenci�n: la operaci�n <+> no revisa si hay repetici�n de
   variables introducidas por pati y patd *)

(* auxiliar: combina dos listas (de mismo tama�o), mediante la aplicaci�n de una funci�n  *)
fun zipconcat f []      []      = ambienteVacio
|   zipconcat f (x::xs) (y::ys) = (f x y) <|> (zipconcat f xs ys)
|   zipconcat f _       _       = raise PatronesNoConcuerdan   