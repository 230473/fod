{17. Arbol B+ de orden 4, politica IZQUIERDA O DERECHA.
    Operaciones: +4, +44, -94.

    Orden M=4: max 3 claves.
    En B+: nodos internos separadores, hojas datos + sig.

Arbol inicial (N1 es hoja alcanzable via cadena sig):
                  N7: (69)
                 /        \
           N2:(30,51)    N6:(94)
          /   \           /    \
    N0:(5,10,20) N3:(51,60) N4:(69,80) N5:(104)-> N1:(400,500)->-
    Hojas: N0->N3->N4->N5->N1->-

+4: N0=(4,5,10,20) OVERFLOW. M=4 par -> prom=10 (copia).
    N0=(4,5), N8=(10,20). Separador 10 en N2: N2=(10,30,51).

               N7: (69)
              /        \
        N2:(10,30,51) N6:(94)
       /   |   |   \   /    \
  N0:(4,5) N8:(10,20) N3:(51,60) N4:(69,80) N5:(104)->N1:(400,500)->-
  Hojas: N0->N8->N3->N4->N5->N1->-

+44: Insertar 44 en N3=(44,51,60) (3 claves, justo).

-94: Buscar 94 en hojas: N4=(69,80) sig N5=(104) -> no. Separador 94 en N6 se elimina.
     N6=() (0 claves, min interno=1). UNDERFLOW!
     Pol I/D: N2=(10,30,51) (3). Redistribucion: N2 cede 51 a N7.
     N7 da 69 a N2. N3 pasa a N6.
     N2=(10,30,69), N6=(51). N7=[] raiz.

               N7: [] (raiz)
              /        \
        N2:(10,30,69) N6:(51)
       /   |   |   \    /   \
  N0:(4,5) N8:(10,20) N3:(44,51,60) N4:(69,80)->N5:(104)->N1:(400,500)->-
  Hojas: N0->N8->N3->N4->N5->N1->-}
