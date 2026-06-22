{8. Arbol B de orden 4, politica underflow a DERECHA.
   Operaciones: +5, +9, +80, +15, -92, -77.

   Orden M=4: max 3 claves, min no raiz = ceil(4/2)-1 = 1.

Arbol inicial:
      N2: [66]
     /      \
  N0:[22,32,50]  N1:[77,79,92]

+5: N0=[5,22,32,50] OVERFLOW. M=4 par -> prom=32.
    N0=[5,22], N3=[50]. Padre N2=[32,66].

         N2: [32,66]
        /    |    \
    N0:[5,22] N3:[50] N1:[77,79,92]

+9: N0=[5,9,22] (OK)

+80: N1=[77,79,80,92] OVERFLOW. prom=80.
     N1=[77,79], N4=[92]. Padre N2=[32,66,80] (max 3, justo)

           N2: [32,66,80]
          /    |    |    \
      N0:[5,9,22] N3:[50] N1:[77,79] N4:[92]

+15: N0=[5,9,15,22] OVERFLOW. prom=15.
     N0=[5,9], N5=[22]. Padre N2=[15,32,66,80] OVERFLOW.
     prom=32. N2=[15], N6=[66,80]. Nueva raiz N7=[32].

                 N7: [32]
                /         \
           N2: [15]     N6: [66,80]
          /     \         /    |    \
      N0:[5,9] N5:[22] N3:[50] N1:[77,79] N4:[92]

-92: N4=[92] -> [] UNDERFLOW. Pol derecha: no tiene der.
     Caso especial: izq = N1[77,79] (2 claves). Cede 79:
     N1=[77], N4=[79]. Separador en N6 se actualiza: 80 -> 79.
     N6=[66,79].

           N7: [32]
          /         \
      N2: [15]     N6: [66,79]
     /     \        /    |    \
  N0:[5,9] N5:[22] N3:[50] N1:[77] N4:[79]

-77: N1=[77] -> [] UNDERFLOW. Pol der: N4=[79] (1 clave).
     Si cede 79: N4=[]. No puede (underflow).
     Fusion con derecho: bajar 79 + N1[] + N4[79] = [79]
     N1 fusionado=[79]. N4 libre. Padre N6=[66].

Arbol final:
                 N7: [32]
                /         \
           N2: [15]     N6: [66]
          /     \         /    \
      N0:[5,9] N5:[22] N3:[50] N1:[79]}
