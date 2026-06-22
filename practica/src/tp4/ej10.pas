{10. Arbol B de orden 5, politica underflow a DERECHA.
    Operaciones: +450, -485, -511, -614.

    Orden M=5: max 4 claves, min no raiz = ceil(5/2)-1 = 2.

Inicial:
        N2: [315, 485, 547, 639]
       /    |     |     |     \
  N0:[148,223] N1:[333,390,442,454] N4:[508,511] N5:[614,633] N3:[789,915]

+450: N1=[333,390,442,450,454] OVERFLOW (5, max 4). M=5 impar -> prom=442.
      N1=[333,390], N6=[450,454]. Padre N2=[315,442,485,547,639] OVERFLOW
      prom=485. N2=[315,442], N7=[547,639]. Nueva raiz N8=[485].

                   N8: [485]
                  /         \
           N2:[315,442]   N7:[547,639]
          /    |    \       /    |    \
      N0:[148,223] N1:[333,390] N6:[450,454] N4:[508,511] N5:[614,633] N3:[789,915]

-485: Raiz N8=[485]. Predecesor = 442 (del subarbol izq).
      442 sube a raiz. Eliminar 442 de N2: queda [315] (1). Min=2. UNDERFLOW!
      Pol der: N7[547,639] (2 claves). Cede 547: N7=[639] (1, underflow). No.
      Fusion con der: bajar 442 + N2[315] + N7[547,639] = [315,442,547,639]
      N2 fusionado. N7 libre. Raiz N8=[] -> desaparece. Nueva raiz = N2.

      N2 (raiz): [315,442,547,639]
     /    |     |     |     \
  N0:[148,223] N1:[333,390] N6:[450,454] N4:[508,511] N5:[614,633] N3:[789,915]

-511: N4=[508,511] -> [508] (1). Min=2. UNDERFLOW!
      Pol der: N5[614,633] (2 claves). Cede 614: N5=[633] (1). No.
      Fusion con der: bajar 547 + N4[508] + N5[614,633] = [508,547,614,633]
      N4 fusionado. N5 libre. Padre N2=[315,442,639].

                N2: [315,442,639]
               /    |     |     \
          N0:[148,223] N1:[333,390] N6:[450,454] N4:[508,547,614,633] N3:[789,915]

-614: N4=[508,547,614,633] -> eliminar 614: N4=[508,547,633] (3, OK, min=2)
      No hay underflow.

ARBOL FINAL:
                N2: [315,442,639]
               /    |     |     \
          N0:[148,223] N1:[333,390] N6:[450,454] N4:[508,547,633] N3:[789,915]}
