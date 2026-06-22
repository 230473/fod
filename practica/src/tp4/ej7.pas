{7. Arbol B de orden 5, politica underflow a IZQUIERDA.
   Operaciones: +320, -390, -400, -533.

   Orden M=5: max 4 claves, min no raiz = ceil(5/2)-1 = 2.

Arbol inicial:
          N2: [220, 390, 455, 541]
         /    |     |     |     \
    N0:[10,150] N1:[225,241,331,360] N4:[400,407] N5:[508,533] N3:[690,823]

+320: Insertar en N1 -> [225,241,320,331,360] OVERFLOW (5, max 4)
      M=5 impar -> prom=320 (pos 3). N1=[225,241], N6=[331,360].
      Padre N2: [220,320,390,455,541] OVERFLOW
      prom=390. N2=[220,320], N7=[455,541]. Raiz N8=[390].

                     N8: [390]
                    /         \
             N2:[220,320]    N7:[455,541]
            /    |    \       /    |     \
       N0:[10,150] N1:[225,241] N6:[331,360] N4:[400,407] N5:[508,533] N3:[690,823]

-390: 390 en raiz N8. Predecesor = 320 de N2. 320 sube a raiz: N8=[320].
      Eliminar 320 de N2: queda [220] (1 clave). Min=2. UNDERFLOW!
      N2=[220] solo admite 2 hijos. N1 y N6 se fusionan: N1=[225,241,331,360].
      N2=[220] con hijos N0 y N1.
      Pol izq: no tiene hermano izq. Der = N7[455,541] (2). No puede ceder.
      Fusion con der: bajar 320 + N2[220] + N7[455,541] = [220,320,455,541].
      N2 fusionado. N7 libre. Raiz N8=[] -> desaparece. Nueva raiz = N2.

      N2(raiz): [220,320,455,541]
     /    |     |     |     \
  N0:[10,150] N1:[225,241,331,360] N4:[400,407] N5:[508,533] N3:[690,823]

-400: N4=[400,407] -> [407] (1). Min=2. UNDERFLOW!
      Pol izq: N1=[225,241,331,360] (4). Cede 360: N1=[225,241,331].
      N4=[360,407]. Padre: baja 320 a N4, sube 360. N2=[220,360,455,541].
      N4=[320,407] (2, OK).

-533: N5=[508,533] -> [508] (1). Min=2. UNDERFLOW!
      Pol izq: N4=[320,407] (2). Cede 407: N4=[320] (1, underflow). No.
      Fusion con izq: N4[320,407] + 455 + N5[508] = [320,407,455,508].
      N5 libre. N2 pierde 455: [220,360,541].

ARBOL FINAL:
      N2(raiz): [220,360,541]
     /    |     |     \
  N0:[10,150] N1:[225,241,331] N4:[320,407,455,508] N3:[690,823]}
