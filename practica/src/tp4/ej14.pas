{14. Arbol B+ de orden 4, politica underflow a DERECHA.
    Operaciones: +80, -400, -50, -11, -77.

    Orden M=4: max 3 claves por nodo.
    En B+: nodos internos solo separadores, hojas tienen datos + sig.

Formato: nodo_interno: hijos (separadores)
         nodo_hoja: (claves) -> sig

Inicial:
        N4: 0 (340) 1 (400) 2 (500) 3
        /       |        |        \
   N0:(11,50,77)->1  N1:(340,350,360)->2  N2:(402,410,420)->3  N3:(520,530)->-

+80: Insertar 80 en hoja N0: [11,50,77,80] OVERFLOW (4, max 3).
     Split hoja: M=4 par -> prom=77 (copia). N0=[11,50], N5=[77,80].
     Insertar separador 77 en padre N4: [340,400,500,77] -> [77,340,400,500] OVERFLOW.
     M=4 par -> prom=340. N4=[77], N6=[400,500]. Raiz N7=[340].

              N7: [340]
             /         \
        N4:[77]      N6:[400,500]
       /    \         /    |    \
  N0:[11,50]->5  N5:[77,80]->1  N1:[340,350,360]->2  N2:[402,410,420]->3  N3:[520,530]->-
  Hojas: N0->N5->N1->N2->N3->-

-400: No existe en hojas (N1=[340,350,360] < 400, N2=[402,410,420] > 400).
      Solo era separador en N6. No se elimina de hojas. N6=[400,500] igual.

-50: N0=[11,50] -> [11] (1). Min hoja B+ orden 4 = ceil(4/2)-1 = 1. OK.

-11: N0=[11] -> [] UNDERFLOW (0 < 1). Pol der: N5=[77,80] (2).
     Cede 77: N0=[77], N5=[80]. Separador 77 en N4 se mantiene.
     N0=[77] (1, OK).

-77: N0=[77] -> [] UNDERFLOW. Der=N5=[80] (1). Cede 80: N0=[80], N5=[].
     Fusion: N0 + N5 = [77,80] (fusion de hojas, separador 77 de N4 se descarta).
     N0=[77,80]. N5 libre. N4 pierde key 77 e hijo N5: N4=[] (0 < 1). UNDERFLOW!
     N4 como nodo interno con underflow. Pol der: N6=[400,500] (2). Cede 400.
     N4 recibe separador 340 de N7. N1 pasa a ser hijo derecho de N4.
     N4=[340], hijos N0(<340) y N1(>=340).
     N6=[500], hijos N2(<500) y N3(>=500).
     N7=[340] -> [400] (400 de N6 sube al padre).

ARBOL FINAL:
               N7: [400]
              /         \
         N4:[340]      N6:[500]
        /    \         /    \
   N0:[77,80]->1  N1:[340,350,360] N2:[402,410,420] N3:[520,530] -> -
   Hojas: N0->N1->N2->N3->-}
