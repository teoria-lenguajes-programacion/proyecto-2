Pruebas para Intérprete
=======================

## Una Suma

```sml
- val unaSuma = LetExp (ValDecl(NoRecursiva,IdPat "a", ConstExp (Entera 9)), ApExp (IdExp "+", ParExp (IdExp "a",ConstExp (Entera 1))));

- evalProg unaSuma;
> val it = ConstInt 10 : Valor
```
```sml
val unaSuma = LetExp (ValDecl(Recursiva,IdPat "a", ConstExp (Entera 10)), ApExp (IdExp "+", ParExp (IdExp "a",ConstExp (Entera 1))));

evalProg unaSuma;
```
