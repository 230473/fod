{5. Defina los siguientes conceptos:
   - Overflow
   - Underflow
   - Redistribucion
   - Fusion o concatenacion

   En los dos ultimos casos, cuando se aplica cada uno?}

{Overflow: se produce cuando se quiere agregar una clave a un nodo que ya tiene
la cantidad maxima de claves permitidas (M-1). Se soluciona creando un nuevo
nodo, distribuyendo las claves equitativamente y promocionando la clave del
medio (o la menor de las mayores si M es par) al nodo padre.}

{Underflow: se produce cuando tras una eliminacion un nodo (que no es la raiz)
queda con menos de la cantidad minima de claves (ceil(M/2)-1). Requiere
redistribucion o fusion para resolverse.}

{Redistribucion: se aplica cuando un nodo tiene underflow y un hermano
adyacente tiene claves de sobra (al menos ceil(M/2) claves). Consiste en
pasar una clave del hermano al nodo con underflow, ajustando la clave del
padre que los separa. El hermano no debe quedar en underflow luego de ceder.}

{Fusion o concatenacion: si un hermano adyacente esta al minimo y no se puede
redistribuir, se concatena el nodo con underflow con un nodo adyacente y la
clave del padre que los separa, disminuyendo la cantidad de nodos y en
algunos casos la altura del arbol. La fusion puede propagar el underflow
hacia arriba.}
