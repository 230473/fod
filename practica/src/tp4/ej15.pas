{15. Arbol B+ de orden 4, politica underflow a DERECHA.
    Operaciones: +120, +110, +52, +70, +15, -45, -52, +22, +19,
                 -66, -22, -19, -23, -89.

    Orden M=4: max 3 claves.

Inicial:
        N2: 0 (66) 1
       /         \
  N0:(23,45)->1  N1:(66,67,89)->-

+120: N1=(66,67,89,120) OVERFLOW. Split hoja: prom=89.
      N1=(66,67), N3=(89,120). Separador 89 en padre N2: N2=(66,89).

        N2: (66,89)
       /    |     \
  N0:(23,45)->1  N1:(66,67)->3  N3:(89,120)->-

+110: N3=(89,110,120) (OK)
+52:  N0=(23,45,52) (OK)
+70:  N1=(66,67,70) (OK)
+15:  N0=(15,23,45,52) OVERFLOW. Split: prom=45. N0=(15,23), N4=(45,52).
      Separador 45 en padre N2: N2=(45,66,89).

        N2: (45,66,89)
       /    |    |    \
  N0:(15,23)->4 N4:(45,52)->1 N1:(66,67,70)->3 N3:(89,110,120)->-

-45: Eliminar 45 de hoja N4=(45,52) -> (52) (1 clave). Min=ceil(4/2)-1=1. OK.
     Separador 45 en N2 se reemplaza por 52. N2: (52,66,89).

-52: N4=(52) -> () UNDERFLOW (0<1). Pol der: N1=(66,67,70) (3). Cede 66:
     N4=(66), N1=(67,70). Separador en N2: baja 66, sube 67. N2: (52,67,89).

+22: N0=(15,22,23) (OK)
+19: N0=(15,19,22,23) OVERFLOW. Split: prom=22.
     N0=(15,19), N5=(22,23). Separador 22 en padre N2=(22,52,67,89) OVERFLOW.
     Split interno: prom=52. N2=(22), N6=(67,89). Raiz N7=(52).

                 N7: (52)
                /        \
          N2:(22)        N6:(67,89)
         /    \          /    |    \
    N0:(15,19)->5 N5:(22,23) N4:(66) N1:(67,70)->3 N3:(89,110,120)->-

-66: N4=(66) -> () UNDERFLOW. Pol der: N1=(67,70) (2). Cede 67:
     N4=(67), N1=(70). Separador en N6: baja 67, sube 70. N6=(70,89).

-22: N5=(22,23) -> (23) (1, OK min=1)
-19: N0=(15,19) -> (15) (1, OK)
-23: N5=(23) -> () UNDERFLOW. Der = N4=(67) (1). Cede 67: N5=(67), N4=().
     N4 underflow. Fusion N4+N5? Politica: N5 tiene der, N4 underflow.
     Fusion N5+N4+separador N2=(22): (22,67). N5=(22,67). N4 libre.
     Padre N2=(22) pierde separador e hijo -> N2=() UNDERFLOW!
     Pol der: N6=(70,89) (2). Cede 70: N2=(70), N6=(89).
     Padre N7=(52). Baja 52 a N2, sube 70. N7: (70).

                 N7: (70)
                /        \
          N2:(52)       N6:(89)
         /      \         /   \
    N0:(15) N5:(22,67) N1:(70) N3:(89,110,120)

-89: N3=(89,110,120) -> eliminar 89 -> (110,120).
     Separador en N6: 89 se reemplaza por 110. N6=(110).

ARBOL FINAL:
                 N7: (70)
                /        \
          N2:(52)       N6:(110)
         /      \         /   \
    N0:(15) N5:(22,67) N1:(70) N3:(110,120)}
