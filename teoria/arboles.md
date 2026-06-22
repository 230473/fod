# Fundamentos de Organización de Datos – Árboles

## Índice

- [1. Motivación](#1-motivación)
- [2. Árboles binarios](#2-árboles-binarios)
- [3. Árboles AVL](#3-árboles-avl)
- [4. Árboles multicamino](#4-árboles-multicamino)
- [5. Árboles B](#5-árboles-b)
  - [5.1 Propiedades](#51-propiedades)
  - [5.2 Organización física (archivo índice como árbol B)](#52-organización-física-archivo-índice-como-árbol-b)
  - [5.3 Búsqueda](#53-búsqueda)
  - [5.4 Inserción (overflow)](#54-inserción-overflow)
  - [5.5 Eliminación (underflow)](#55-eliminación-underflow)
  - [5.6 Políticas de resolución de underflow](#56-políticas-de-resolución-de-underflow)
- [6. Árboles B*](#6-árboles-b)
  - [6.1 Propiedades](#61-propiedades)
  - [6.2 Inserción](#62-inserción)
- [7. Árboles B+](#7-árboles-b)
  - [7.1 Propiedades](#71-propiedades)
  - [7.2 Búsqueda](#72-búsqueda)
  - [7.3 Inserción](#73-inserción)
  - [7.4 Eliminación](#74-eliminación)
  - [7.5 Prefijos simples](#75-prefijos-simples)
- [8. Comparativa B vs B* vs B+](#8-comparativa-b-vs-b-vs-b)

---

### 1. Motivación

Los **índices clásicos** (ver `indices.md`) en memoria tienen un problema fundamental: **no siempre caben en RAM**.

- Para un archivo de N registros, el índice completo tiene N entradas.
- Si N es grande (millones), el índice también es grande.
- Almacenar el índice en disco y hacer búsqueda binaria implica muchas lecturas.
- Mantener el índice ordenado al insertar/eliminar es costoso.

**Solución**: usar **árboles balanceados** como estructura de índice persistente en disco.

Los árboles ofrecen:

- Búsqueda O(Log N) con **pocos accesos a disco** (3-4 para millones de registros).
- Inserción y eliminación con rebalanceo automático a bajo costo.
- Persistencia: el índice vive en disco, no ocupa RAM permanentemente.
- Crecimiento y contracción controlados.

### 2. Árboles binarios

Un **árbol binario de búsqueda** es una estructura donde cada nodo tiene a lo sumo dos hijos (izquierdo y derecho).

Para implantarlo en disco, cada nodo se almacena como un registro en un archivo:

```pascal
type
  tNodoBinario = record
    clave: longint;
    hijoIzq: integer;  // NRR del hijo izquierdo (-1 si no tiene)
    hijoDer: integer;  // NRR del hijo derecho (-1 si no tiene)
  end;

  tArchArbol = file of tNodoBinario;
```

```
          MM (NRR 0)
         /          \
    CD (1)          UV (2)
    /    \          /    \
  AB(3)  GT(4)   PR(5)  ZR(6)
```

**Ventaja**: simple, cada nodo tiene clave + 2 punteros a hijos.

**Problema**: se desbalancean fácilmente. Si las claves llegan ordenadas (ej: AB, BC, CD, DE...), el árbol degenera en una lista, y la búsqueda pasa a ser O(N).

#### 2.1 Inserción en árbol binario

```pascal
procedure Insertar(var A: tArchArbol; elem: tNodoBinario);
var
  padre, actual: tNodoBinario;
  posActual: integer;
  found: boolean;
begin
  if (filesize(A) = 0) then
  begin
    // Árbol vacío: el nuevo nodo es la raíz
    elem.hijoIzq := -1;
    elem.hijoDer := -1;
    write(A, elem);
  end
  else
  begin
    // Posicionar el nuevo nodo al final del archivo
    seek(A, filesize(A));
    elem.hijoIzq := -1;
    elem.hijoDer := -1;
    write(A, elem);
    posActual := filesize(A) - 1;  // NRR del nuevo nodo

    // Buscar al padre desde la raíz
    seek(A, 0);
    read(A, padre);
    found := false;
    while not found do
    begin
      if (elem.clave < padre.clave) then
      begin
        if (padre.hijoIzq = -1) then
        begin
          padre.hijoIzq := posActual;
          found := true;
        end
        else
        begin
          seek(A, padre.hijoIzq);
          read(A, padre);
        end;
      end
      else
      begin
        if (padre.hijoDer = -1) then
        begin
          padre.hijoDer := posActual;
          found := true;
        end
        else
        begin
          seek(A, padre.hijoDer);
          read(A, padre);
        end;
      end;
    end;
    // Re-grabar el padre con el nuevo puntero
    seek(A, filepos(A) - 1);
    write(A, padre);
  end;
end;
```

**Costo**: log₂(N) lecturas + 2 escrituras (buscar padre + actualizar puntero).

#### 2.2 Búsqueda en árbol binario

```pascal
function Buscar(var A: tArchArbol; clave: longint): integer;
var
  nodo: tNodoBinario;
  posActual: integer;
  found: boolean;
begin
  Buscar := -1;  // no encontrado
  if (filesize(A) = 0) then exit;

  seek(A, 0);
  read(A, nodo);
  found := false;
  while not found do
  begin
    if (clave = nodo.clave) then
    begin
      Buscar := filepos(A) - 1;  // retorna NRR del nodo encontrado
      found := true;
    end
    else if (clave < nodo.clave) then
    begin
      if (nodo.hijoIzq = -1) then
        found := true  // no existe
      else
      begin
        seek(A, nodo.hijoIzq);
        read(A, nodo);
      end;
    end
    else
    begin
      if (nodo.hijoDer = -1) then
        found := true  // no existe
      else
      begin
        seek(A, nodo.hijoDer);
        read(A, nodo);
      end;
    end;
  end;
end;
```

**Costo**: O(log₂ N) accesos a disco en el peor caso.

#### 2.3 Borrado en árbol binario

Para eliminar un nodo, este debe ser **terminal** (sin hijos). Si no lo es, se **intercambia** con la **menor clave del subárbol derecho** (sucesor in-order), y luego se elimina esa hoja.

```pascal
function MenorDelSubarbolDer(var A: tArchArbol; posNodo: integer): integer;
var
  nodo: tNodoBinario;
  posMenor: integer;
begin
  // Ir al hijo derecho, luego todo a la izquierda
  seek(A, posNodo);
  read(A, nodo);
  posMenor := nodo.hijoDer;
  seek(A, posMenor);
  read(A, nodo);
  while (nodo.hijoIzq <> -1) do
  begin
    posMenor := nodo.hijoIzq;
    seek(A, posMenor);
    read(A, nodo);
  end;
  MenorDelSubarbolDer := posMenor;
end;

procedure Eliminar(var A: tArchArbol; clave: longint);
var
  nodo, hijo, menor: tNodoBinario;
  posNodo, posMenor: integer;
begin
  posNodo := Buscar(A, clave);
  if (posNodo = -1) then exit;

  seek(A, posNodo);
  read(A, nodo);

  // Caso 1: es hoja (sin hijos)
  if (nodo.hijoIzq = -1) and (nodo.hijoDer = -1) then
  begin
    // Marcar como eliminado (ej: clave = -1)
    nodo.clave := -1;
    seek(A, posNodo);
    write(A, nodo);
  end
  // Caso 2: tiene un hijo
  else if (nodo.hijoIzq = -1) or (nodo.hijoDer = -1) then
  begin
    // Reemplazar por el único hijo
    if (nodo.hijoIzq <> -1) then
      hijo.clave := nodo.hijoIzq
    else
      hijo.clave := nodo.hijoDer;
    // Copiar el hijo a la posición del nodo eliminado
    seek(A, nodo.hijoIzq <> -1 ? nodo.hijoIzq : nodo.hijoDer);
    read(A, hijo);
    seek(A, posNodo);
    write(A, hijo);
  end
  // Caso 3: tiene dos hijos
  else
  begin
    // Intercambiar con el menor del subárbol derecho
    posMenor := MenorDelSubarbolDer(A, posNodo);
    seek(A, posMenor);
    read(A, menor);
    // Copiar el menor a la posición del nodo a eliminar
    menor.hijoIzq := nodo.hijoIzq;
    menor.hijoDer := nodo.hijoDer;
    seek(A, posNodo);
    write(A, menor);
    // Eliminar el nodo que ahora está duplicado (era el menor)
    nodo.clave := -1;
    seek(A, posMenor);
    write(A, nodo);
  end;
end;
```

**Costo**: log₂(N) lecturas para buscar + 2 escrituras para intercambiar/eliminar.

#### 2.1 Árboles binarios paginados

Alternativa que busca mejorar la performance en disco: en lugar de transferir un nodo por vez, se agrupan varios nodos en **páginas** (bloques) que se transfieren completas.

- Cada página contiene una cantidad fija de nodos del árbol binario, almacenados en direcciones físicas cercanas.
- Al buscar, se transfiere la página completa en un solo acceso a disco.
- Si una página contiene K nodos, la búsqueda es O(Log_{K+1} N).

**Problema**:
- Construcción descendente: no se sabe de antemano qué nodos deben estar juntos en la misma página.
- El árbol se va llenando de forma impredecible: cuando llega un nuevo nodo que debería ir a una página, esta puede estar en otra zona del disco.
- Se necesita un algoritmo muy costoso de implementar y mantener.
- El beneficio no justifica el costo → en la práctica se usan directamente árboles multicamino balanceados (B, B+, B*).

### 3. Árboles AVL

Un **árbol AVL** es un árbol binario **balanceado en altura**. Para cada nodo, la diferencia de altura entre sus dos subárboles no supera 1.

- Altura máxima: `1.44 * log₂(N + 2)` en el peor caso.
- Búsqueda: O(Log N).
- Las inserciones y eliminaciones usan **rotaciones** para mantener el balance, restringidas a un área local del árbol.
- Siguen siendo árboles binarios: cada nodo tiene solo 2 hijos.

**Problema para disco**: al ser binarios, la altura sigue siendo relativamente grande. Para N = 1.000.000, la altura es ~20 niveles → 20 accesos a disco. Sigue siendo mucho.

### 4. Árboles multicamino

Un **árbol multicamino** generaliza el árbol binario: cada nodo tiene **K punteros a hijos** y **K-1 claves**.

```
          [34]        [95]
         /    |        |    \
        /     |        |     \
    [15,30] [40,60] [76,85] [99]
```

- Cuantos más hijos por nodo, **menor la profundidad** del árbol.
- Orden del árbol: cantidad máxima de hijos por nodo.
- Pero: si no está balanceado, puede degenerar igual que un binario.

**Solución**: combinar multicamino + balanceo → **árboles B**.

### 5. Árboles B

#### 5.1 Propiedades

Un **árbol B de orden M** cumple:

1. Cada nodo tiene como máximo **M descendientes** (hijos) y **M-1 elementos** (claves).
2. La raíz no tiene descendientes o tiene al menos 2.
3. Un nodo con X descendientes contiene X-1 elementos.
4. Todos los nodos (excepto raíz) tienen como mínimo **[M/2] – 1** elementos y como máximo **M-1** elementos.
5. Todos los **nodos terminales** (hojas) están al mismo nivel.

```
Ejemplo: Árbol B de orden 4 (M=4)
      ┌─────────── 67 ───────────┐
      │                          │
   ┌─ 25 ─┐                 ┌─ 70,76,82 ─┐
   │      │                 │            │
  90     93                 99          105
```

#### 5.2 Organización física (archivo índice como árbol B)

El árbol B se implanta como un **archivo de nodos** (no de registros de datos). Cada nodo es un registro del archivo índice.

```pascal
const M = ...;  // orden del árbol

type
  tRegistroDato = record
    codigo: longint;
    nombre: string[50];
  end;

  tNodoB = record
    cant_claves: integer;
    claves: array[1..M-1] of longint;
    enlaces: array[1..M-1] of integer;  // NRR al registro de datos
    hijos: array[1..M] of integer;      // NRR a nodos hijos (-1 si no tiene)
  end;

  tArchDatos = file of tRegistroDato;
  tArchIndice = file of tNodoB;
```

```
Archivo físico del árbol B (orden 4):
NRR 0: cant=2 | claves=[67]        | hijos=[1, 2, -1]
NRR 1: cant=1 | claves=[25]        | hijos=[3, -1, -1]
NRR 2: cant=3 | claves=[70,76,82]  | hijos=[4,5,6,-1]
NRR 3: cant=0 | (hoja vacía)

Archivo de datos (referenciado por enlaces):
NRR 0: 25|Maria
NRR 1: 67|Pedro
NRR 2: 40|Luis
NRR 3: 96|Franco
```

**Alternativa: archivo de datos como árbol B**. En lugar de tener un índice separado, los datos se almacenan directamente en los nodos del árbol. Problema: los registros de datos suelen ser grandes, lo que reduce el orden M y aumenta la altura.

#### 5.3 Búsqueda

```
Buscar clave K en el árbol:
1. Leer nodo raíz
2. Buscar K en el nodo actual:
   - Si está → fin (encontró)
   - Si no está → tomar el puntero hijo anterior a la clave mayor que K
   - Si el puntero es nulo → K no existe
   - Si no → leer el nodo hijo y repetir desde paso 2
```

**Performance**:
- Mejor caso: 1 lectura (la clave está en la raíz).
- Peor caso: **h** lecturas, donde **h** es la altura del árbol.
- Altura máxima: `h <= 1 + log_{[M/2]}((N+1)/2)`
- Para M = 512 y N = 1.000.000 → h <= 3.37 → **4 lecturas** para encontrar cualquier registro.

#### 5.4 Inserción (overflow)

Las inserciones siempre se hacen en **nodos terminales** (hojas).

**Caso 1: sin overflow**
- El nodo tiene lugar disponible.
- Se inserta la clave ordenadamente en el nodo.
- Solo reacomodamientos internos.
- Costo: h lecturas + 1 escritura.

**Caso 2: con overflow (nodo lleno)**
1. Se crea un nuevo nodo.
2. La **primera mitad** de las claves se mantiene en el nodo original.
3. La **segunda mitad** de las claves se traslada al nuevo nodo.
4. La **menor clave de la segunda mitad** se promociona al nodo padre.
5. Si el padre también está lleno → el overflow se **propaga** hacia arriba.
6. Si la raíz se desborda → se divide y se crea una nueva raíz → **aumenta la altura del árbol en 1**.

```
Ejemplo: insertar 80 en árbol B orden 4

Estado inicial (nodo hoja lleno):
┌──────────────┐
│ 25 │ 40 │ 67 │
└──────────────┘

Insertar 80 → overflow. Dividir:
Nodo original:  ┌──────┐     Nuevo nodo:  ┌──────┐
                │ 25 │                     │ 67 │ 80 │
                └──────┘                   └──────┘
Promocionar 40 al padre
```

**Performance**:
- **Mejor caso**: H lecturas + 1 escritura (el nodo terminal tiene lugar).
- **Peor caso**: H lecturas + (2H + 1) escrituras (overflow propagado hasta la raíz).

**Estudios realizados**:
- M = 10 → 25% de las inserciones producen división.
- M = 100 → solo 2% de las inserciones producen división (98% se resuelven con el mejor caso).

#### 5.5 Eliminación (underflow)

Las eliminaciones siempre se hacen desde **nodos terminales**.

- Si la clave a eliminar **no está en una hoja**: se reemplaza con la **menor clave del subárbol derecho** (o la mayor del izquierdo), y se elimina de la hoja.
- **Mejor caso**: el nodo queda con >= [M/2]-1 claves → solo se reacomoda el nodo.
- **Peor caso (underflow)**: el nodo queda con < [M/2]-1 claves → se necesita redistribuir o concatenar.

**Redistribución**: se trasladan claves de un **nodo adyacente hermano** (mismo padre, punteros adyacentes) si este tiene suficientes.

**Concatenación (fusión)**: si el hermano adyacente está al mínimo y no puede prestar, se **fusionan** ambos nodos, disminuyendo la cantidad de nodos y potencialmente la altura del árbol.

**Performance**:
- **Mejor caso**: h lecturas + 1 escritura (sin underflow, solo se reacomoda el nodo).
- **Peor caso**: 2h-1 lecturas + h+1 escrituras (concatenación que puede propagarse hasta la raíz y decrementar la altura).

#### 5.6 Políticas de resolución de underflow

| Política | Redistribución | Concatenación |
|:---------|:--------------|:--------------|
| **Izquierda** | Intentar con hermano izquierdo | Fusionar con izquierdo |
| **Derecha** | Intentar con hermano derecho | Fusionar con derecho |
| **Izquierda o derecha** | Intentar izquierdo, si no, derecho | Fusionar con izquierdo |
| **Derecha o izquierda** | Intentar derecho, si no, izquierdo | Fusionar con derecho |

**Caso especial**: si el nodo es hoja de un extremo, se intenta con el único hermano disponible.

### 6. Árboles B*

#### 6.1 Propiedades

Variante del árbol B donde cada nodo (excepto raíz y hojas) está lleno **por lo menos en 2/3 partes** (en lugar de 1/2 como en B).

- Cada página tiene máximo M descendientes.
- Cada página (excepto raíz y hojas) tiene al menos **[(2M – 1) / 3]** descendientes.
- La raíz tiene al menos 2 descendientes (o ninguno).
- Todas las hojas al mismo nivel.
- Una página no hoja con K descendientes contiene K-1 llaves.
- Una página hoja contiene entre [(2M – 1)/3] – 1 y M-1 llaves.

**Objetivo**: mayor ocupación del espacio → árboles más anchos y menos profundos → menos accesos a disco.

#### 6.2 Inserción

En lugar de dividir inmediatamente cuando un nodo se llena, B* intenta **redistribuir** con un hermano adyacente. Si ambos están llenos, se reparten las claves entre los **tres nodos** (el original, el hermano y uno nuevo), quedando cada uno aproximadamente 2/3 lleno.

| Estrategia | Descripción | Costo mejor | Costo peor |
|:-----------|:------------|:-----------|:-----------|
| **Derecha** | Redistribuir con hermano derecho (o izquierdo si es el último) | RRWW | RRWWW |
| **Izquierda o derecha** | Redistribuir con izquierdo, si no con derecho | RRWW | RRRWWW |
| **Izquierda y derecha** | Repartir entre los tres nodos → quedan 3/4 llenos | RRWW | RRRWWWW |

(R = read, W = write, por nivel)

**Estrategia de reemplazo LRU (Last Recently Used)**: para mejorar performance en árboles B*, los nodos más usados recientemente se mantienen en un buffer en RAM. Al leer un nodo, si está en el buffer se evita un acceso a disco.

### 6.3 Acceso secuencial indizado

Un **archivo de acceso secuencial indizado** permite dos formas de visualizar la información:

1. **Indizada**: registros ordenados por una clave (mediante un árbol B como índice).
2. **Secuencial**: acceso secuencial con registros físicamente contiguos y ordenados.

**Problema**: recorrer todos los nodos del árbol para extraer registros en orden secuencial es ineficiente. Mantener el archivo físicamente ordenado es costoso para inserciones/eliminaciones.

**Solución**: tratar cada nodo hoja del árbol B como un bloque de datos ordenado, y **enlazar** los nodos hoja secuencialmente. Esto es exactamente lo que hacen los árboles B+ (ver sección 7), donde las hojas están vinculadas por un puntero `sig`.

**Inserción de Estevez**: al dividir un nodo hoja, se divide el bloque (misma algoritmica que árboles B) con costo de 2 escrituras (nodo modificado + nuevo nodo). Los nodos quedan ordenados y enlazados.

**Eliminación**: un nodo con pocos elementos puede ser concatenado/fusionado con el nodo hermano adyacente.

**Ventaja**: cada bloque está ordenado y los nodos están enlazados para recorrido secuencial a bajo costo.

### 7. Árboles B+

#### 7.1 Propiedades

Los árboles B+ constituyen una **mejora sobre los árboles B**: conservan el acceso aleatorio rápido y además permiten **recorrido secuencial rápido**.

El árbol B+ tiene dos componentes:

1. **Conjunto índice**: nodos internos (no contienen datos, solo claves separadoras). Proporcionan acceso indizado a los registros.
2. **Conjunto secuencia**: nodos hoja que contienen **todos los registros** del archivo. Las hojas están **vinculadas entre sí** (lista enlazada) para facilitar el recorrido secuencial rápido.

```
                       ┌───── 88 ─────┐
                       │              │
                  ┌─ 50,75 ─┐    ┌─ 100 ─┐
                  │         │    │       │
    ┌─── 8,23,50,75 ─── 88,100 ─── 121 ───┐
    │                                      │
  (hojas enlazadas: 50→51→52→...→56)
```

**Diferencias clave con Árbol B**:
- En B, los datos están en cualquier nodo. En B+, los datos están **solo en las hojas**.
- En B+, las hojas están **enlazadas secuencialmente** → permite recorrido ordenado sin retroceder.
- En B+, las claves de los nodos internos son solo **separadores** (copias de claves de hojas).

#### 7.2 Búsqueda

Similar al árbol B, pero **siempre debe continuar hasta el último nivel** (las hojas), porque solo allí están los datos. Incluso si se encuentra la clave en un nodo interno, es solo un separador; el dato real está en la hoja.

#### 7.3 Inserción

**Overflow en hoja** (nodo terminal lleno):
1. El nodo afectado se divide en 2, distribuyendo las claves equitativamente.
2. Una **copia** de la clave del medio (o la menor de las claves mayores) se **promociona** al nodo padre.
3. A diferencia de B, en B+ se promociona una **copia**, no se mueve la clave original.

**Overflow en nodo interno**: mismo tratamiento que en árboles B (la clave se mueve, no se copia).

#### 7.4 Eliminación

La eliminación en B+ es **más simple** que en B porque las claves siempre se eliminan de las hojas.

**Caso 1: sin underflow**
- Si al eliminar una clave la cantidad restante es >= [M/2]-1 → la operación termina.
- Las claves en nodos raíz o internos **no se modifican** aunque sean copia de la clave eliminada.

**Caso 2: underflow**
- Si la cantidad de claves es menor a [M/2]-1 → se intenta **redistribuir** con un hermano adyacente (tanto en nodos hoja como en índice).
- Si la redistribución no es posible → se **fusionan** los nodos.

Las políticas de underflow son las mismas que en árboles B (izquierda, derecha, izquierda o derecha, derecha o izquierda).

#### 7.5 Prefijos simples

Un **árbol B+ de prefijos simples** utiliza **separadores más cortos** en el conjunto índice, derivados de las claves que limitan un bloque en el conjunto secuencia.

En lugar de almacenar la clave completa en los nodos internos, se almacena solo el **prefijo mínimo** que permite diferenciar entre dos hojas adyacentes.

```
Sin prefijos simples:    Con prefijos simples:
Raíz: Garcia, Gomez      Raíz: G
       ↓                          ↓
Hojas: Garcia, Gomez,   Hojas: Garcia, Gomez,
       Gonzalez, ...            Gonzalez, ...
```

**Ventaja**: los nodos internos ocupan menos espacio → pueden tener mayor orden M → menor altura del árbol → menos accesos a disco.

### 8. Comparativa B vs B* vs B+

| Característica | B | B* | B+ |
|:--------------|:--|:--|:--|
| Ocupación mínima del nodo | 50% | 66% | 50% |
| Ubicación de los datos | Cualquier nodo | Cualquier nodo | Solo hojas |
| Recorrido secuencial | Lento (complejo) | Lento | Rápido (hojas enlazadas) |
| Inserción | Split al llenarse | Redistribuir antes de split | Split con copia al padre |
| Eliminación | Estándar | Estándar | Más simple (siempre en hoja) |
| Tiempo de búsqueda | Igual | Igual | Igual |
| Uso típico | Índices generales | Alta densidad de ocupación | Archivos secuenciales indizados |

### 9. Ejemplos prácticos paso a paso

#### 9.1 Construcción de un árbol B (orden 4)

Insertar secuencia: 43, 2, 53, 88, 75, 80, 15, 49, 60, 20, 57, 24.

Cada nodo del archivo físico guarda: `punteros a hijos | datos (claves) | #claves`.

**Paso 1 — +43**: raíz = nodo 0, un solo elemento.
```
nodo 0: [-1, -1 | 43 | 1]
```

**Paso 2 — +2**: entra en nodo 0.
```
nodo 0: [-1, -1, -1 | 2, 43 | 2]
```

**Paso 3 — +53**: entra en nodo 0.
```
nodo 0: [-1, -1, -1, -1 | 2, 43, 53 | 3]
```

**Paso 4 — +88**: nodo 0 lleno → overflow.
1. Dividir: nodo 0 ← [2, 43], nuevo nodo 1 ← [88]
2. Promocionar 53 a nueva raíz (nodo 2)
3. raíz = nodo 2
```
nodo 0: [-1, -1, -1 | 2, 43 | 2]          ← hijo izq
nodo 1: [-1, -1 | 88 | 1]                ← hijo der
nodo 2: [0, 1 | 53 | 1] ▸ raíz           ← raíz
```

**Paso 5 — +75**: va a nodo 1 (subárbol derecho de 53).
```
nodo 1: [-1, -1, -1 | 75, 88 | 2]
```

**Paso 6 — +80**: entra en nodo 1.
```
nodo 1: [-1, -1, -1, -1 | 75, 80, 88 | 3]
```

**Paso 7 — +15**: va a nodo 0.
```
nodo 0: [-1, -1, -1, -1 | 2, 15, 43 | 3]
```

**Paso 8 — +49**: nodo 0 lleno → overflow.
1. Dividir nodo 0: nodo 0 ← [2, 15], nuevo nodo 3 ← [49]
2. Promocionar 43 al padre (nodo 2). Nodo 2 ahora tiene [43, 53] y apunta a 0, 3, 1.
```
nodo 0: [-1, -1, -1 | 2, 15 | 2]
nodo 1: [-1, -1, -1, -1 | 75, 80, 88 | 3]
nodo 2: [0, 3, 1 | 43, 53 | 2]           ← raíz
nodo 3: [-1, -1 | 49 | 1]
```

**Paso 9 — +60**: va a nodo 1.
```
nodo 1: [-1, -1, -1 | 60, 75 | 2]
nodo 2: [0, 3, 1, 4 | 43, 53, 80 | 3]   ← se actualizan punteros
nodo 4: [-1, -1 | 88 | 1]               ← nuevo por división de 1
```

El nodo 1 se dividió al insertar 60 y 75 → quedó [60, 75], se creó nodo 4 para [88], se promocionó 80.

**Paso 10 — +20**: entra en nodo 0.
```
nodo 0: [-1, -1, -1, -1 | 2, 15, 20 | 3]
```

**Paso 11 — +57**: entra en nodo 1.
```
nodo 1: [-1, -1, -1, -1 | 57, 60, 75 | 3]
```

**Paso 12 — +24**: nodo 0 lleno → overflow.
1. Dividir nodo 0: [2, 15] y nuevo nodo 5 [24]
2. Promocionar 20 al padre. Nodo 2 se llena con [20, 43, 53, 80] → overflow.
3. Dividir nodo 2: [20, 43] y nuevo nodo 6 [80]
4. Promocionar 53 a nueva raíz (nodo 7).

```
nodo 0: [-1, -1, -1 | 2, 15 | 2]
nodo 1: [-1, -1, -1, -1 | 57, 60, 75 | 3]
nodo 2: [0, 5, 3 | 20, 43 | 2]
nodo 3: [-1, -1 | 49 | 1]
nodo 4: [-1, -1 | 88 | 1]
nodo 5: [-1, -1 | 24 | 1]
nodo 6: [1, 4 | 80 | 1]
nodo 7: [2, 6 | 53 | 1] ▸ raíz (nueva, altura +1)
```

#### 9.2 Underflow: redistribución vs concatenación

**Caso redistribución** (árbol orden 10, borrar 39):

```
Estado inicial:     .. 45   70 ..
                   /     |     \
         13 24 28 39   48 50 52 56 61 67 69   ...
                         ↑
                  (nodo en underflow si se borra 39)
```

Borrar 39 del nodo izquierdo → queda con 3 elementos (mínimo para M=10 es 4) → underflow.
- Intentar concatenar: 3 + 7 (hermano) + 1 (del padre) = 11 > M-1 → imposible.
- **Redistribuir** con hermano derecho: pasar 45 del padre al izquierdo, subir 48 al padre.

```
Resultado:          .. 48   70 ..
                   /     |     \
         13 24 28 45   50 52 56 61 67 69   ...
```

**Caso concatenación** (árbol orden 10):

```
Estado inicial:     .. 45   70 ..
                   /     |     \
         13 24 28 39   48 52 56 61   ...
```

Borrar 39 → underflow en izquierdo (3 < 4). Hermanos: derecho tiene 4 (mínimo).
- No se puede redistribuir (el derecho quedaría en underflow).
- **Concatenar**: fusionar izquierdo + derecho + elemento del padre.

```
Resultado:          .. 70 ..
                   /        \
         13 24 28 45 48 52 56 61   ...
```

El nodo padre pierde un hijo → si entra en underflow, se propaga hacia arriba.

#### 9.3 Construcción de un árbol B* (orden 4)

Misma secuencia: 43, 2, 53, 88, 75, 80, 15, 49, 60, 20, 57, 24.

Hasta llenarse, se comporta igual que B. La diferencia aparece al insertar 49 cuando el nodo 0 está lleno [2, 15, 43]. En B* se intenta redistribuir antes de dividir:

**Inserción de +49** (nodo 0 lleno):
- Se redistribuye con el hermano adyacente derecho (nodo 1: [75, 80, 88]).
- Resultado: nodo 0 ← [2, 15], nodo 1 ← [80, 88], nodo 2 ← [43, 75].
- Nodo 3 ← [49, 53].

```
nodo 0: [-1, -1, -1 | 2, 15 | 2]
nodo 1: [-1, -1, -1 | 80, 88 | 2]
nodo 2: [0, 3, 1 | 43, 75 | 2]           ← raíz
nodo 3: [-1, -1, -1 | 49, 53 | 2]
```

**Políticas de inserción en B* — ejemplo con +55**:

Partiendo de un árbol con nodo 0=[2,15,20] lleno, nodo 3=[49,53,60] lleno:

- **Política derecha**: se intenta redistribuir con el hermano derecho. Si está lleno, se dividen 3 nodos (original + hermano + nuevo).
- **Política izquierda**: se intenta con el izquierdo. Si es posible, se rebalancea.
- **Izquierda o derecha**: intenta izquierdo, si no, derecho, si no, divide 3 nodos.
- **Izquierda y derecha**: reparte entre 3 nodos (2 originales + 1 nuevo) quedando ≈ 75% llenos.

#### 9.4 Construcción de un árbol B+ (orden 4)

Misma secuencia. El nodo B+ tiene un campo extra: `sig` (puntero al siguiente nodo hoja).

**Estado final** (después de insertar los 12 elementos):

```
nodo 0: [-1, -1, -1, -1 | 2, 15, 20 | 3 | 4]  ← hoja, sig → nodo 4
nodo 1: [-1, -1, -1 | 53, 57 | 2 | 5]          ← hoja, sig → nodo 5
nodo 2: [0, 4, 1 | 43, 53 | 2 | -1]            ← nodo interno
nodo 3: [-1, -1, -1 | 80, 88 | 2 | -1]         ← hoja
nodo 4: [-1, -1 | 43, 49 | 2 | 1]              ← hoja, sig → nodo 1
nodo 5: [-1, -1, -1 | 60, 75 | 2 | 3]          ← hoja, sig → nodo 3
nodo 6: [-1, -1 | 80 | 1 | -1]                 ← nodo interno
nodo 7: [2, 6 | 60 | 1 | -1] ▸ raíz

Recorrido secuencial por las hojas:
  nodo 0 (2,15,20) → nodo 4 (43,49) → nodo 1 (53,57) → nodo 5 (60,75) → nodo 3 (80,88)
```

**Claves en nodos internos** (conjunto índice):
- Nodo 7 (raíz): [60] — separador
- Nodo 2: [43, 53] — separadores
- Nodo 6: [80] — separador

**Las hojas** contienen los datos reales y están **enlazadas** por el campo `sig` para recorrido secuencial rápido. Esto es lo que diferencia a B+ de B: todo el conjunto secuencia se puede recorrer en orden de clave sin retroceder en el árbol.

---

### Autoevaluación

1. ¿Qué problema tienen los árboles binarios para su uso como índice persistente en disco?
2. ¿Cuál es la diferencia entre un árbol AVL y un árbol binario común?
3. ¿Por qué los árboles multicamino son preferibles a los binarios para índices en disco?
4. En un árbol B de orden M: ¿cuál es el mínimo y máximo de elementos por nodo (hoja y no hoja)?
5. ¿Qué ocurre cuando se inserta en un nodo lleno de un árbol B? Describir overflow.
6. ¿Qué opciones hay cuando se elimina un elemento y se produce underflow?
7. ¿Cuál es la diferencia fundamental entre B y B+ en cuanto a la ubicación de los datos?
8. ¿Qué ventaja tienen los prefijos simples en un árbol B+?
9. ¿Cómo se calcula la altura máxima de un árbol B? (fórmula)
10. ¿Cuándo conviene usar LRU en árboles B*?

> **Ejercicio sugerido**: construir un árbol B de orden 5 paso a paso (lápiz y papel) con la secuencia 43,2,53,88,75,80,15,49,60,20,57,24. Repetir con árbol B+ y B* del mismo orden. Verificar con la herramienta HEA de la cátedra.
