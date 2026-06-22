{9. Arbol B de orden 6, politica underflow DERECHA O IZQUIERDA.
   Operaciones: +15, +71, +3, +48, +24, +38, -56, -100.

   Orden M=6: max 5 claves, min no raiz = ceil(6/2)-1 = 2.

Inicial: N0(raiz): [34,56,78,100,176]

+15: N0=[15,34,56,78,100,176] OVERFLOW (6, max 5). M=6 par, 6/2=3 c/u.
     prom=78. N0=[15,34,56], N1=[100,176]. Raiz N2=[78].

            N2: [78]
           /        \
     N0:[15,34,56]  N1:[100,176]

+71: N0=[15,34,56,71] (OK)
+3:  N0=[3,15,34,56,71] (OK, max 5)
+48: N0=[3,15,34,48,56,71] OVERFLOW. prom=48.
     N0=[3,15,34], N3=[56,71]. Padre N2=[48,78].

            N2: [48,78]
           /    |     \
      N0:[3,15,34] N3:[56,71] N1:[100,176]

+24: N0=[3,15,24,34] (OK)
+38: N0=[3,15,24,34,38] (OK, max 5)

-56: N3=[56,71] -> eliminar 56: N3=[71] (1 clave). Min=2. UNDERFLOW!
     Pol D o I: intentar izquierdo = N0[3,15,24,34,38] (5 claves). Cede 38:
     N0=[3,15,24,34], N3=[48,71]. Padre: 38 sube a N2 (reemplaza 48).
     N2=[38,78].

             N2: [38,78]
            /    |     \
       N0:[3,15,24,34] N3:[48,71] N1:[100,176]

-100: N1=[100,176] -> eliminar 100: N1=[176] (1). UNDERFLOW!
      Pol D o I: intentar izq = N3[48,71] (2 claves). Si cede 71: N3=[48] (1). No puede.
      Intentar der: N1 no tiene der.
      Fusion con izq: bajar 78 + N3[48,71] + N1[176] = [48,71,78,176]
      N3 fusionado. N1 libre. Padre N2=[38] (OK como raiz).

Arbol final:
                 N2: [38]
                /        \
           N0:[3,15,24,34]  N3:[48,71,78,176]}
