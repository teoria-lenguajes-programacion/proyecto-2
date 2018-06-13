Pruebas para Intérprete
=======================

## Una Suma

```sml
- val unaSuma = LetExp (ValDecl(NoRecursiva,IdPat "a", ConstExp (Entera 9)), ApExp (IdExp "+", ParExp (IdExp "a",ConstExp (Entera 1))));

- evalProg unaSuma;
> val it = ConstInt 10 : Valor
```
```sml
- val unaSuma = LetExp (ValDecl(Recursiva,IdPat "a", ConstExp (Entera 10)), ApExp (IdExp "+", ParExp (IdExp "a",ConstExp (Entera 1))));

- evalProg unaSuma;
> val it = ConstInt 11 : Valor
```

## Declaración expresión entera
```sml
- val dec = ValDecl(Recursiva,IdPat "a", ConstExp (Entera 9));
- evalDec [] dec;
> val it = [("a", ConstInt 9)] : (string * Valor) list
```

## Evaluación un `AndDecl`
```sml
- val dec1 = ValDecl(Recursiva,IdPat "a", ConstExp (Entera 5));
- val dec2 = ValDecl(Recursiva,IdPat "b", ConstExp (Entera 9));
- val andDec = AndDecl(dec1, dec2);
- evalDec [] (andDec);
> val it = [("b", ConstInt 9), ("a", ConstInt 5)] : (string * Valor) list
```

## Evaluación de un `LocalDecl`
```sml
- val dec1 = ValDecl(Recursiva,IdPat "a", ConstExp (Entera 5));
- val dec2 = ValDecl(Recursiva,IdPat "b", ConstExp (Entera 9));
- val localDec = LocalDecl(dec1, dec2);
- evalDec [] (localDec);
> val it = [("b", ConstInt 9), ("a", ConstInt 5)] : (string * Valor) list
```

## Evaluación de un `RegExp`
```sml
- val a = ("the-a", ConstExp(Entera 11));
- val b = ("the-b", ConstExp(Entera 21));
- val c = [a, b];
- val d = RegExp(c);
- evalProg d;
> val it = ConstInt 77 : Valor
> 
```

## Evaluación de `CondExp`
```sml
- val a = IdExp "+";
- val b = ConstExp(Entera 1);
- val c = [(a,b)];
- val d = NONE;
- val e = CondExp(c, d);
> val e = CondExp([(IdExp "+", ConstExp(Entera 1))], NONE) : Expresion
```