{12. Construccion paso a paso de arbol B de ORDEN 5.
    Politica underflow: IZQUIERDA.
    Operaciones: +80,+50,+70,+120,+23,+52,+59,+65,+30,+40,
                 +45,+31,+34,+38,+60,+63,+64,
                 -23,-30,-31,-40,-45,-38.

    Orden M=5: max 4 claves, min = ceil(5/2)-1 = 2.

INSERCIONES:
+80: N0=[80]        +50: N0=[50,80]     +70: N0=[50,70,80]
+120: N0=[50,70,80,120]
+23: N0=[23,50,70,80,120] OVERFLOW. M=5 impar -> prom=70.
     N0=[23,50], N1=[80,120]. Raiz N2=[70].
+52: N0=[23,50,52]    +59: N0=[23,50,52,59]
+65: N0=[23,50,52,59,65] OVERFLOW. prom=52.
     N0=[23,50], N3=[59,65]. Padre N2=[52,70].
+30: N0=[23,30,50]    +40: N0=[23,30,40,50]
+45: N0=[23,30,40,45,50] OVERFLOW. prom=40.
     N0=[23,30], N4=[45,50]. Padre N2=[40,52,70].
+31: N0=[23,30,31]    +34: N0=[23,30,31,34]
+38: N0=[23,30,31,34,38] OVERFLOW. prom=31.
     N0=[23,30], N5=[34,38]. Padre N2=[31,40,52,70].
+60: N3=[59,60,65]    +63: N3=[59,60,63,65]
+64: N3=[59,60,63,64,65] OVERFLOW. prom=63.
     N3=[59,60], N6=[64,65]. Padre N2=[31,40,52,63,70] OVERFLOW.
     prom=52. N2=[31,40], N7=[63,70]. Raiz N8=[52].

Arbol tras inserciones:
                    N8: [52]
                   /        \
           N2:[31,40]      N7:[63,70]
          /   |   |   \      /   |   \
    N0:[23,30] N5:[34,38] N4:[45,50] N1:[80,120]
    N3:[59,60] N6:[64,65]

ELIMINACIONES (politica izquierda):
   En M=5: clave_ceder requiere hermano con >= ceil(M/2)=3 claves.
   N5 tiene 2 claves (min) -> no puede ceder. Se fusiona.

-23: N0=[23,30] -> [30] (1 < 2). UNDERFLOW!
     Pol izq: no tiene izq. Der=N5=[34,38] (2 = min). No puede ceder.
     Fusion: N0 + 31(N2) + N5 = [30,31,34,38]. N0=[30,31,34,38]. N5 libre.
     N2=[31,40] -> [40] (1 < 2). N2 UNDERFLOW!
     Der=N7=[63,70] (2 = min). No puede ceder.
     Fusion: N2 + 52(N8) + N7 = [40,52,63,70].
     N2=[40,52,63,70] raiz. N7 libre. N8=[] -> desaparece.

                     N2(raiz): [40,52,63,70]
                    /    |    |    |    \
              N0:[30,31,34,38] N4:[45,50] N3:[59,60] N6:[64,65] N1:[80,120]

-30: N0=[30,31,34,38] -> [31,34,38] (3, OK).
-31: N0=[31,34,38] -> [34,38] (2, OK).
-40: 40 en raiz N2=[40,52,63,70]. Predecesor = 38 (max de N0=[34,38]).
     38 sube a raiz. Eliminar 38 de N0 -> [34] (1 < 2). UNDERFLOW!
     Der=N4=[45,50] (2 = min). No puede ceder.
     Fusion: N0 + 38(N2) + N4 = [34,38,45,50].
     N0=[34,38,45,50]. N4 libre. N2=[52,63,70].

-45: N0=[34,38,45,50] -> [34,38,50] (3, OK).
-38: N0=[34,38,50] -> [34,50] (2, OK).

ARBOL FINAL:
                N2(raiz): [52,63,70]
               /    |    |    \
         N0:[34,50] N3:[59,60] N6:[64,65] N1:[80,120]}
