{6. Arbol B de orden 4. Insertar empleados por DNI en archivo datos + indice.
   Empleados (DNI, Legajo, Nombre):
   (35M,100,Juan Perez), (40M,101,L. Redivo), (32M,102,N. Lapro),
   (28M,103,L. Scola), (26M,104,A. Nocioni), (37M,105,F. Campazzo),
   (25M,106,E. Ginobili), (23M,107,P. Sanchez), (21M,108,A. Montecchia),
   (36M,109,M. Delia), (45M,110,L. Bolmaro)

   Orden M=4: max 3 claves, min = ceil(4/2)-1 = 1 (no raiz).
   Pares en indice: (DNI, NRR_datos).

Archivo datos: se insertan secuencialmente. NRR = orden de llegada.

Indice (arbol B):

1. +35M: N0=[(35,0)] raiz
2. +40M: N0=[(35,0),(40,1)]
3. +32M: N0=[(32,2),(35,0),(40,1)]
4. +28M: N0=[(28,3),(32,2),(35,0),(40,1)] OVERFLOW
   M=4 par -> prom=35. N0=[(28,3),(32,2)], N1=[(40,1)], raiz N2=[(35,0)]

              N2: [35]
             /      \
         N0:[28,32]  N1:[40]

5. +26M: N0=[(26,4),(28,3),(32,2)]
6. +37M: N1=[(37,5),(40,1)]
7. +25M: N0=[(25,6),(26,4),(28,3),(32,2)] OVERFLOW
   prom=28. N0=[(25,6),(26,4)], N3=[(32,2)], padre N2=[(28,3),(35,0)]

              N2: [28,35]
             /    |    \
         N0:[25,26] N3:[32] N1:[37,40]

8. +23M: N0=[(23,7),(25,6),(26,4)]
9. +21M: N0=[(21,8),(23,7),(25,6),(26,4)] OVERFLOW
   prom=25. N0=[(21,8),(23,7)], N4=[(26,4)], padre N2=[(25,6),(28,3),(35,0)]

              N2: [25,28,35]
             /    |   |   \
         N0:[21,23] N4:[26] N3:[32] N1:[37,40]

10. +36M: N1=[(36,9),(37,5),(40,1)]
11. +45M: N1=[(36,9),(37,5),(40,1),(45,10)] OVERFLOW
    prom=40. N1=[(36,9),(37,5)], N5=[(45,10)], padre N2=[(25,6),(28,3),(35,0),(40,1)] OVERFLOW
    prom=35. N2=[(25,6),(28,3)], N6=[(40,1)], raiz N7=[(35,0)]

ARBOL FINAL:

                    N7: [35]
                   /        \
            N2: [25,28]     N6: [40]
           /    |    \        /    \
      N0:[21,23] N4:[26] N3:[32] N1:[36,37] N5:[45]

Archivo datos (NRR -> DNI):
 0:35M  1:40M  2:32M  3:28M  4:26M  5:37M
 6:25M  7:23M  8:21M  9:36M  10:45M}
