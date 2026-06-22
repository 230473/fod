{20. Arbol B+ de orden 5, politica IZQUIERDA O DERECHA.
    Operaciones: +250, -300.

    Orden M=5: max 4 claves por nodo.

Formato: nodo: hijos(sep) o (claves)->sig

Inicial:
N8: 2 (70)
N2: 0 (50)
N7: 5 (90) 6 (120) 3 (210) 9 (300)
N0: (40)->
N4: (50)->
N5: (70)(80)->
N6: (90)(100)->
N3: (120)(200)->
N9: (210)(220)(230)(240)->
N1: (400)(500)-> -

Arbol:
                  N8: [70]
                 /      \
            N2:[50]      N7:[90,120,210,300]
           /      \      /    |    |    |    \
      N0:(40) N4:(50) N5:(70,80) N6:(90,100) N3:(120,200) N9:(210,220,230,240) N1:(400,500)

+250: N9=(210,220,230,240,250) OVERFLOW (5, max 4). M=5 impar -> prom=230 (copia).
      N9=(210,220), N10=(230,240,250). Separador 230 en padre N7.
      N7=[90,120,210,230,300] OVERFLOW. prom=210. N7=[90,120], N11=[230,300].
      Raiz N8=[70,210].

                    N8: [70,210]
                   /         \
           N2:[50]        N7:[90,120]    N11:[230,300]
          /     \         /    |    \     /    |    \
     N0:(40) N4:(50) N5:(70,80) N6:(90,100) N3:(120,200) N9:(210,220) N10:(230,240,250) N1:(400,500)

-300: Buscar 300 en hojas: N10=(230,240,250) -> no. N1=(400,500) -> no.
      Separador 300 en N11 (entre hijos 10 y 1). Se reemplaza con la
      primera clave del hijo derecho (N1) = 400. N11=[230,400].
      No hay underflow (2 = min). No se modifica la hoja N1.

ARBOL FINAL:
                    N8: [70,210]
                   /         \
           N2:[50]        N7:[90,120]      N11:[230,400]
          /     \         /    |    \       /    |    \
     N0:(40) N4:(50) N5:(70,80) N6:(90,100) N3:(120,200) N9:(210,220) N10:(230,240,250) N1:(400,500)}
