{11. Construccion paso a paso de arbol B de ORDEN 4.
    Politica underflow: izquierda o derecha.
    Operaciones: +50, +70, +40, +15, +90, +120, +115, +45, +30,
                 +100, +112, +77, -45, -40, -50, -90, -100.

    Orden M=4: max 3 claves, min = ceil(4/2)-1 = 1.

INSERCIONES:
+50:  N0=[50]
+70:  N0=[50,70]
+40:  N0=[40,50,70]
+15:  N0=[15,40,50,70] OVERFLOW. M=4 par -> prom=50.
      N0=[15,40], N1=[70]. Raiz N2=[50].
+90:  N1=[70,90]
+120: N1=[70,90,120]
+115: N1=[70,90,115,120] OVERFLOW. prom=115.
      N1=[70,90], N3=[120]. Padre N2=[50,115].
+45:  N0=[15,40,45]
+30:  N0=[15,30,40,45] OVERFLOW. prom=40.
      N0=[15,30], N4=[45]. Padre N2=[40,50,115].
+100: N1=[70,90,100]
+112: N1=[70,90,100,112] OVERFLOW. prom=100.
      N1=[70,90], N5=[112]. Padre N2=[40,50,100,115] OVERFLOW.
      prom=100. N2=[40,50], N6=[115]. Raiz N7=[100].
+77:  N1=[70,77,90]

Arbol tras inserciones:
             N7: [100]
            /         \
       N2:[40,50]    N6:[115]
      /    |    \      /    \
  N0:[15,30] N4:[45] N1:[70,77,90] N5:[112] N3:[120]

ELIMINACIONES:
-45: N4=[45] -> [] UNDERFLOW. Pol I o D: izq=N0[15,30] cede 30.
     N0 cede 30 (derecha) -> sube al padre como separador.
     Separador 40 baja a N4.
     N0=[15], N4=[40]. Padre N2=[30,50].

             N7: [100]
            /         \
        N2:[30,50]   N6:[115]
       /    |    \     /    \
   N0:[15] N4:[40] N1:[70,77,90] N5:[112] N3:[120]

-40: N4=[40] -> [] UNDERFLOW.
     Pol I/D: izq=N0[15] (1 = min). No puede ceder.
     Der=N1[70,77,90] (3 > 1). Cede 70 (izquierda de N1):
     N1 cede 70 -> sube al padre. Separador 50 baja a N4.
     N1=[77,90], N4=[50]. N2=[30,70].

             N7: [100]
            /         \
        N2:[30,70]   N6:[115]
       /    |    \     /    \
   N0:[15] N4:[50] N1:[77,90] N5:[112] N3:[120]

-50: N4=[50] -> [] UNDERFLOW.
     Pol I/D: izq=N0[15] (1 = min). No puede ceder.
     Der=N1[77,90] (2 > 1). Cede 77:
     N1=[90], N4=[70]. N2=[30,77].

             N7: [100]
            /         \
        N2:[30,77]   N6:[115]
       /    |    \     /    \
   N0:[15] N4:[70] N1:[90] N5:[112] N3:[120]

-90: N1=[90] -> [] UNDERFLOW.
     Pol I/D: izq=N4=[70] (1 = min). No puede ceder.
     Der=N5=[112] (1 = min). No puede ceder.
     Fusion con izq: N4[70] + 77(N2) + N1[] = [70,77].
     N4=[70,77]. N1 libre. N2 pierde 77 e hijo N1: N2=[30].

             N7: [100]
            /         \
        N2:[30]      N6:[115]
       /      \        /     \
  N0:[15] N4:[70,77] N5:[112] N3:[120]

-100: N7=[100] raiz. Predecesor = 77 (max de N4).
      77 sube a raiz. N4=[70,77] -> [70] (1, min=1 OK). N7=[77].

Arbol final:
              N7: [77]
             /         \
        N2:[30]      N6:[115]
       /      \        /     \
  N0:[15] N4:[70] N5:[112] N3:[120]}
