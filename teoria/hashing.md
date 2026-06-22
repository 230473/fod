# Fundamentos de Organización de Datos – Hashing (Dispersión)

## Índice

- [1. Introducción y motivación](#1-introducción-y-motivación)
- [2. Definición](#2-definición)
- [3. Parámetros fundamentales](#3-parámetros-fundamentales)
  - [3.1 Función de hash](#31-función-de-hash)
  - [3.2 Tamaño de las cubetas](#32-tamaño-de-las-cubetas)
  - [3.3 Densidad de empaquetamiento](#33-densidad-de-empaquetamiento)
- [4. Colisión vs Desborde (overflow)](#4-colisión-vs-desborde-overflow)
- [5. Estimación del overflow (Distribución de Poisson)](#5-estimación-del-overflow-distribución-de-poisson)
- [6. Tratamiento de overflow en hashing estático](#6-tratamiento-de-overflow-en-hashing-estático)
  - [6.1 Saturación progresiva](#61-saturación-progresiva)
  - [6.2 Saturación progresiva encadenada](#62-saturación-progresiva-encadenada)
  - [6.3 Dispersión doble (doble hash)](#63-dispersión-doble-doble-hash)
  - [6.4 Área de desborde separada](#64-área-de-desborde-separada)
- [7. Hashing dinámico](#7-hashing-dinámico)
  - [7.1 Hashing extensible](#71-hashing-extensible)
- [8. Elección de organización](#8-elección-de-organización)

---

### 1. Introducción y motivación

Buscamos un mecanismo de acceso a registros con **una sola lectura**:

| Método | Accesos promedio |
|:-------|:----------------|
| Secuencial | N/2 |
| Búsqueda binaria (archivo ordenado) | Log₂ N |
| Árboles B (orden alto) | 3-4 |
| **Hashing** | **~1** |

El hashing trabaja sobre la **clave primaria** (unívoca, no repetible). Las demás claves actúan a través de ella.

A diferencia de índices y árboles, **el hashing organiza directamente el archivo de datos**, no requiere estructuras auxiliares separadas.

### 2. Definición

**Hashing (dispersión)** es una técnica que convierte la clave de un registro en un número (casi aleatorio) que sirve para determinar **dónde se almacena** el registro en el archivo.

```
  Clave → [F. Hash] → Dirección → [Archivo de datos]
```

**Atributos del hash**:
- No requiere almacenamiento adicional (índice).
- Facilita inserción y eliminación rápida.
- Encuentra registros con muy pocos accesos a disco (idealmente 1).

**Limitaciones**:
- No pueden usarse registros de longitud variable.
- No hay orden físico de datos (no se puede recorrer en orden de clave).
- No permite claves duplicadas.
- Solo puede organizarse por **un único criterio**: la clave primaria.

### 3. Parámetros fundamentales

Cuatro parámetros influyen en el desempeño del hashing:

1. Función de hash
2. Tamaño de las cubetas (nodos)
3. Densidad de empaquetamiento
4. Método de tratamiento de desbordes

#### 3.1 Función de hash

Caja negra que a partir de una clave genera la **dirección base** donde debe almacenarse el registro.

A diferencia de los índices, **no hay relación aparente** entre clave y dirección. Dos claves distintas pueden transformarse en la misma dirección (colisión).

**Tres pasos**:
1. Representar la llave en forma numérica (si no lo está).
2. Aplicar la función (ej. módulo, plegamiento, mitad del cuadrado, etc.).
3. Relacionar el número resultante con el espacio disponible.

**Condiciones deseables**:
- Repartir registros en forma uniforme.
- Aleatoriedad: las claves no deben influir unas sobre otras.

```
           Uniforme       Aceptable        Peor
dir 1:       A B C           A E             A B C D E
dir 2:       D E F           B D
dir 3:       G H I           C F
...          ...             ...
```

#### 3.2 Tamaño de las cubetas

Cada dirección puede almacenar más de un registro (cubeta de capacidad C).

| Capacidad | Ventaja | Desventaja |
|:----------|:--------|:-----------|
| Mayor C | Menos overflow | Mayor fragmentación interna, búsqueda más lenta dentro de la cubeta |
| Menor C | Menos fragmentación | Más overflow |

#### 3.3 Densidad de empaquetamiento

Proporción del espacio del archivo que realmente almacena registros:

```
DE = (cantidad de registros) / (capacidad total del archivo)
   = R / (C × N)
```

Donde:
- R = cantidad de registros
- C = capacidad de cada cubeta
- N = cantidad de cubetas (direcciones)

| DE | Overflow | Desperdicio |
|:---|:---------|:------------|
| Baja (ej. 10%) | Poco | Mucho espacio libre |
| Alta (ej. 100%) | Mucho | Poco espacio libre |

### 4. Colisión vs Desborde (overflow)

**Claves sinónimas**: dos claves son sinónimas cuando, al aplicarles la función de hash, obtienen el mismo resultado (colisionan en la misma dirección).

**Colisión**: situación en la que un registro es asignado a una dirección que ya está ocupada por otro registro.

**Desborde (overflow)**: colisión en la que **no queda espacio** en la cubeta para el nuevo registro (la cubeta está llena).

- Colisión ≠ overflow (puede haber colisión sin overflow si la cubeta tiene capacidad > 1 y aún hay lugar).
- El overflow siempre implica colisión.

**Soluciones posibles**:
- Funciones hash perfectas (sin colisiones) → imposibles de conseguir en la práctica.
- Esparcir registros: distribuir de la forma más aleatoria posible.
- Usar memoria adicional: baja la DE → disminuye overflow → desperdicia espacio.
- Colocar más de un registro por dirección: mejora notablemente.

### 5. Estimación del overflow (Distribución de Poisson)

Para estimar cuántos registros producirán overflow, se usa la **distribución de Poisson**:

```
P(I) = probabilidad de que una cubeta reciba exactamente I registros

P(I) = ( (R/N)^I * e^(-R/N) ) / I!

  donde:
  R = cantidad de registros total
  N = cantidad de cubetas
```

La cantidad esperada de cubetas con I registros es: `N × P(I)`

**Tabla de overflow esperado según DE y capacidad C**:

| DE | C=1 | C=2 | C=5 | C=10 | C=100 |
|:---|:----|:----|:----|:-----|:------|
| 10% | 4.8% | 0.6% | 0.0% | 0.0% | 0.0% |
| 30% | 13.6% | 4.5% | 0.4% | 0.0% | 0.0% |
| 50% | 21.3% | 10.4% | 2.5% | 0.4% | 0.0% |
| 70% | 28.1% | 17.0% | 7.1% | 2.9% | 0.0% |
| **80%** | **31.2%** | **20.4%** | **10.3%** | **5.3%** | **0.1%** |
| 100% | 36.8% | 27.1% | 17.6% | 12.5% | 4.0% |

> **Lectura**: con DE=50% y C=2, el 10.4% de los registros producirán overflow. Con C=5, baja a 2.5%.

**Conclusión**: aumentar la capacidad de la cubeta (C) reduce drásticamente el overflow, incluso con densidades altas.

##### Ejemplo 1: DE = 100% (N=10.000, K=10.000, C=1)

| i (registros) | P(i) | N × P(i) (nodos) | En saturación |
|:---:|:---:|:---:|:---:|
| 0 | 0.3679 | 3.679 | 0 |
| 1 | 0.3679 | 3.679 | 0 |
| 2 | 0.1839 | 1.839 | 1.839 |
| 3 | 0.0613 | 613 | 1.226 |
| 4 | 0.0153 | 153 | 459 |
| **Total** | | | **3.524 registros en overflow (35.2%)** |

##### Ejemplo 2: DE = 50% (K=10.000, N=20.000, C=1)

| i | P(i) | N × P(i) | En saturación |
|:---:|:---:|:---:|:---:|
| 0 | 0.6065 | 12.130 | 0 |
| 1 | 0.3032 | 6.065 | 0 |
| 2 | 0.0758 | 1.516 | 1.516 |
| 3 | 0.0126 | 252 | 504 |
| 4 | 0.0016 | 32 | 96 |
| **Total** | | | **2.116 registros en overflow (21.2%)** |

##### Ejemplo 3: DE = 50% con C = 2 (K=10.000, N=10.000)

| i | P(i) | N × P(i) | En saturación |
|:---:|:---:|:---:|:---:|
| 0 | 0.3678 | 3.678 | 0 |
| 1 | 0.3678 | 3.678 | 0 |
| 2 | 0.1839 | 1.839 | 0 |
| 3 | 0.0613 | 613 | 613 |
| 4 | 0.0153 | 153 | 306 |
| **Total** | | | **919 registros en overflow (9.2%)** |

> **Comparación**: al aumentar la capacidad de cubeta de 1 a 2 (manteniendo DE=50%), el overflow baja del 21.2% al 9.2%.

### 6. Tratamiento de overflow en hashing estático

En **hashing estático**, el espacio de direccionamiento está **fijado previamente** (no crece). Al diseñar el archivo se define N (cantidad de cubetas) que se mantiene fijo.

#### 6.1 Saturación progresiva

Cuando una cubeta se completa, se busca **secuencialmente** la siguiente cubeta libre.

> **Importante**: Si una clave A se ubicó en su cubeta base, y una clave B (sinónima de A) debía ir allí pero produjo overflow y se ubicó en la siguiente cubeta libre, al llegar una clave C que debe ir a esa segunda cubeta (su cubeta base), la clave **B debe ser re-acomodada** a otra posición. La idea es que la mayoría de las claves estén en su lugar original (cubeta base) para minimizar los tiempos de búsqueda.

```
Ejemplo: cubetas de capacidad 2, función hash que da direcciones
Fh(alfa)=50, Fh(beta)=51, Fh(gamma)=50, Fh(delta)=50, Fh(epsilon)=52, Fh(phi)=51

  alfa → cubeta 50   ┌──────┐
  beta → cubeta 51   │50: alfa, gamma│ ← gamma colisiona, se coloca ahí
  gamma → 50 llena → │51: beta, delta│ ← delta colisiona con beta, va a 51
          busca 51   │52: epsilon, phi│
  delta → 50 llena → └──────┘
          busca 51
          (hay lugar)
```

**Problemas**:
- Tiende a **agrupar** registros en zonas contiguas (clustering).
- Las búsquedas se vuelven largas cuando la densidad tiende a 1.
- La eliminación requiere cuidado para no obstaculizar las búsquedas posteriores.

#### 6.2 Saturación progresiva encadenada

Similar a la saturación progresiva, pero los registros de saturación se **encadenan** y no ocupan necesariamente posiciones contiguas.

Cada cubeta tiene un puntero al siguiente nodo de overflow. Los registros que no caben en su cubeta original se almacenan en cubetas libres y se enlazan.

```
  Cubeta 50: [alfa, gamma] → [epsilon] → null
  Cubeta 51: [beta, delta] → [phi] → null
```

**Ventaja sobre saturación progresiva simple**: no hay agrupamiento en zonas contiguas.

#### 6.3 Dispersión doble (doble hash)

Utiliza una **segunda función de hash** para determinar el incremento cuando hay overflow.

- F1h(clave) = dirección base
- F2h(clave) = incremento a sumar

```
F1h(alfa)=50, F2h(alfa)=5
F1h(beta)=51, F2h(beta)=10
F1h(gamma)=50, F2h(gamma)=20
F1h(delta)=50, F2h(delta)=8

  alfa → 50          ┌──────┐
  beta → 51          │50: alfa, gamma│
  gamma → 50 llena → │51: beta       │
          probar 50+20=70 → libre →  │52: epsilon    │
          se guarda en 70             │58: delta      │ ← 50+8
  delta → 50 llena → │60: tau        │
          probar 50+8=58 → libre → 58│70: gamma      │ ← 50+20
```

**Ventaja**: evita el agrupamiento de la saturación progresiva. Los overflow se distribuyen por todo el espacio.

#### 6.4 Área de desborde separada

Los registros de overflow **no usan** las cubetas normales. Se almacenan en un **área especial de desborde** (al final del archivo, en cilindros separados, o a intervalos regulares).

```
┌─────── Cubetas primarias ───────┬─────── Área de desborde ───────┐
│ 50: alfa, gamma →               │ overflow → [epsilon, phi, ...] │
│ 51: beta, delta →               │                                │
│ 52: epsilon →  [overflow]      │                                │
│ ...                              │                                │
└─────────────────────────────────┴────────────────────────────────┘
```

**Ventaja**: mejora el tratamiento de inserciones y eliminaciones (no se desplazan registros).
**Desventaja**: empeora el tiempo de acceso promedio (más desplazamientos de brazo).

#### 6.5 Hash asistido por tabla

Técnica de hashing estático que asegura acceder a un registro en **un solo acceso a disco** (garantizado), pero requiere una estructura adicional (tabla en memoria principal).

**Tres funciones de hash**:
1. **F1H(clave)**: retorna la dirección base (dirección del nodo donde debería residir).
2. **F2H(clave)**: retorna un desplazamiento (se suma en caso de overflow).
3. **F3H(clave)**: retorna una secuencia de bits (usada para comparar con la tabla).

**Tabla en memoria**: tiene tantas entradas como direcciones de nodos disponibles. Cada entrada inicia con todos sus bits en 1.

```
Ejemplo: 10 claves, nodos de capacidad 2

Clave     F1H   F2H   F3H
Alfa      50    3     0001
Beta      51    4     0011
Gamma     52    7     0101
Delta     50    3     0110
Epsilon   52    3     1000
Rho       51    5     0100
Pi        50    2     0010
Tau       53    2     1110
Psi       50    9     1010
Omega     50    4     0000
```

**Tabla inicial** (todas las entradas en 1111...):

```
Dir   Valor en tabla
50    1111
51    1111
52    1111
53    1111
```

**Proceso de inserción**:

1. Insertar Alfa, Beta, Gamma, Delta, Epsilon, Rho sin overflow (cada uno entra en su nodo base).

```
Nodo 50: [Alfa, Delta]   (lleno)
Nodo 51: [Beta, Rho]     (lleno)
Nodo 52: [Gamma, Epsilon] (lleno)
Nodo 53: [vacío]
```

2. Llega **Pi** → nodo 50 lleno → **overflow**:
   - Calcular F3H para los registros del nodo 50: Alfa(0001), Delta(0110), Pi(0010).
   - La clave con F3H **mayor** es Delta (0110).
   - Sacar Delta del nodo 50 → nodo 50 queda [Alfa].
   - La entrada 50 de la tabla queda con F3H(Delta) = 0110.
   - Calcular nueva dirección: F1H(Delta) + F2H(Delta) = 50 + 3 = 53.
   - Insertar Delta en nodo 53.
   - Insertar Pi en nodo 50 (tiene lugar).

```
Nodo 50: [Alfa, Pi]      (lleno)
Nodo 51: [Beta, Rho]     (lleno)
Nodo 52: [Gamma, Epsilon] (lleno)
Nodo 53: [Delta]          (1 registro)

Tabla: 50→0110, 51→1111, 52→1111, 53→1111
```

3. Llega **Tau** → nodo 53: [Delta]. Tiene espacio → insertar.

```
Nodo 53: [Delta, Tau]    (lleno)
```

4. Llega **Psi** → nodo 50 lleno → overflow:
   - F3H(Psi) = 1010. Es la clave con F3H mayor → Psi se reubica.
   - Nueva dirección: F1H(Psi) + F2H(Psi) = 50 + 9 = 59.
   - Nodo 59 está vacío → insertar Psi.

5. Llega **Omega** → nodo 50 lleno → overflow:
   - Pi tiene F3H = 0010. Es la mayor entre Alfa(0001), Pi(0010), Omega(0000).
   - Nueva dirección: F1H(Pi) + F2H(Pi) = 50 + 2 = 52.
   - Nodo 52 lleno [Gamma, Epsilon] → **overflow en cascada**.
   - Epsilon tiene F3H = 1000 (mayor que Gamma 0101).
   - Nueva dirección: F1H(Epsilon) + F2H(Epsilon) = 52 + 3 = 55.
   - Nodo 55 vacío → insertar Epsilon.
   - Ahora nodo 52 tiene lugar → insertar Pi.

```
Nodo 50: [Alfa, Omega]   (lleno)
Nodo 52: [Gamma, Pi]     (lleno)
Nodo 55: [Epsilon]       (1 registro)
Nodo 59: [Psi]           (1 registro)
```

**Proceso de búsqueda** (ejemplo: buscar Delta):

1. Calcular F1H(Delta) = 50 → ir a nodo 50.
2. Calcular F3H(Delta) = 0110.
3. Comparar con entrada 50 de la tabla (valor = 0110 de Delta) → **son iguales**.
4. Delta está en la dirección original → buscar en nodo 50: no está.
5. Calcular F2H(Delta) = 3 → nueva dirección 50 + 3 = 53.
6. Comparar F3H(Delta) con entrada 53 de la tabla (1111) → 0110 < 1111 → Delta debería estar en 53.
7. Acceder a nodo 53 → **encontrado**. **Un solo acceso a disco adicional.**

**Búsqueda de un elemento inexistente** (ejemplo: buscar Rho):

1. F1H(Rho) = 50, F3H(Rho) = 0100.
2. Valor en tabla[50] = 0110. 0100 < 0110 → Rho debería estar más adelante.
3. Nueva dirección: 50 + 5 = 55.
4. Valor en tabla[55] = 1111. 0100 < 1111 → Rho debería estar en 55.
5. Acceder a nodo 55 → no está → **elemento no existe**.

**Costos**:
- **Búsqueda**: siempre **1 acceso a disco** (garantizado).
- **Inserción**: complejidad adicional si produce overflow (varios accesos según overflows sucesivos).
- Requiere espacio extra para la tabla en memoria principal.

**Proceso de eliminación**:
1. Localizar el registro con el proceso de búsqueda.
2. Si se encuentra, reescribir el nodo sin el elemento a borrar.
3. **Caso especial**: si se borra una clave que produjo overflow (la que estaba en la tabla), la tabla queda con un valor de F3H que ya no corresponde a ningún registro en ese nodo. Para insertar un nuevo elemento en ese nodo, debe cumplir: `F3H(nuevo) < Tabla(direccion_del_nodo)`.

### 7. Hashing dinámico

Problema del hashing estático:

- El espacio de direcciones es **fijo**.
- Cuando el archivo se llena → saturación excesiva.
- Solución clásica: **redispersar** (nueva función, reorganizar todo) → muy costoso.

**Hashing dinámico**: el espacio de direccionamiento **crece y decrece** según las necesidades.

#### 7.1 Hashing extensible

Técnica que adapta la cantidad de bits usados de la función de hash según el tamaño del archivo.

**Componentes**:
- **Tabla de directorio**: en memoria principal, contiene NRR de cubetas. Tamaño = 2^i (i = cantidad de bits actuales).
- **Cubetas**: nodos en disco, cada una con un valor asociado (bits que usa internamente) y capacidad fija (ej. 2 registros).
- **Función de hash**: genera una secuencia de bits (normalmente 32).

**Operación**:
1. Se aplica la función de hash a la clave → se obtiene una secuencia de bits.
2. Se toman los **primeros i bits** de la secuencia para indexar la tabla.
3. La tabla direcciona a la cubeta correspondiente.

**Inserción - caso normal**:
- Hay lugar en la cubeta → se inserta directamente.

**Inserción - overflow**:
1. Se incrementa en 1 el valor asociado a la cubeta saturada.
2. Se crea una nueva cubeta con el mismo valor.
3. Se compara el valor de la cubeta con el de la tabla:
   - Si el valor de la cubeta > valor de la tabla → **duplicar la tabla** (2× tamaño), incrementar i en 1, y redireccionar.
   - Si el valor de la cubeta <= valor de la tabla → no duplicar, solo reasignar.
4. Se redispersan las claves de la cubeta original entre las dos cubetas (vieja y nueva) usando un bit más.

```
Ejemplo paso a paso (capacidad 2, función hash de 32 bits):

Estado inicial: i=0, tabla=[0], cubeta0=[alfa, beta]

Insertar gamma → overflow en cubeta0.
  1. cubeta0.pbits = 1, crear cubeta1.pbits = 1
  2. cubeta0.pbits(1) > tabla.pbits(0) → duplicar tabla (i=1)
  3. Tabla: [0→cubeta0, 1→cubeta1]
  4. Re-dispersar: alfa(0011)→cubeta1, beta(0110)→cubeta1, gamma(1001)→cubeta0

Estado: i=1, tabla=[cubeta1, cubeta0], cubeta1=[alfa,beta], cubeta0=[gamma]
```

**Ventajas**:
- No requiere reorganización completa del archivo.
- Solo se redispersan las claves de la(s) cubeta(s) involucrada(s).
- El archivo crece gradualmente.

**Desventajas**:
- La tabla de directorio puede crecer mucho (2^i entradas).
- Si la función hash distribuye mal, la tabla se duplica innecesariamente.

#### 7.1.1 Ejemplo paso a paso de hash extensible

Claves y sus bits de hash (función de 32 bits, se muestran los últimos bits):

| Clave | Hash (últimos bits) | | Clave | Hash (últimos bits) |
|:------|:--------------------|-|:------|:--------------------|
| Alfa | `...1001` | | Pi | `...0110` |
| Beta | `...0100` | | Tau | `...1101` |
| Gamma | `...0010` | | Psi | `...0001` |
| Delta | `...1111` | | Omega | `...0111` |
| Epsilon | `...0000` | | | |
| Rho | `...1011` | | | |

Capacidad de cada cubeta: 2 registros. Se usan los **últimos** bits del hash.

**Estado inicial**: tabla con Vt=0 bits, una sola entrada apuntando a cubeta 0 (vacía).

```
Tabla (Vt=0):
  [0] → cubeta 0 (Vb=0): [vacía]
```

**Paso 1 — +Alfa**: Vt=0 → 0 bits → cubeta 0. Vacía → insertar.

```
Tabla (Vt=0):
  [0] → cubeta 0 (Vb=0): [Alfa]
```

**Paso 2 — +Beta**: Vt=0 → cubeta 0. Tiene espacio → insertar.

```
Tabla (Vt=0):
  [0] → cubeta 0 (Vb=0): [Alfa, Beta]  LLENA
```

**Paso 3 — +Gamma**: Vt=0 → cubeta 0. **OVERFLOW** (llena).

```
Resolución:
  1. Vb cubeta 0: 0 → 1
  2. Crear cubeta 1 (Vb=1)
  3. Vb(1) > Vt(0) → DUPLICAR tabla → Vt=1
  4. Redispersar cubeta 0 con 1 bit:
     Alfa  (...1001): último bit = 1 → cubeta 1
     Beta  (...0100): último bit = 0 → cubeta 0
  5. Insertar Gamma (...0010): último bit = 0 → cubeta 0

Tabla (Vt=1):
  [0] → cubeta 0 (Vb=1): [Beta, Gamma]
  [1] → cubeta 1 (Vb=1): [Alfa]
```

**Paso 4 — +Delta**: Vt=1 → 1 bit: "1" → cubeta 1: [Alfa]. Tiene espacio → insertar.

```
Tabla (Vt=1):
  [0] → cubeta 0 (Vb=1): [Beta, Gamma]  LLENA
  [1] → cubeta 1 (Vb=1): [Alfa, Delta]  LLENA
```

**Paso 5 — +Epsilon**: Vt=1 → 1 bit: "0" → cubeta 0. **OVERFLOW**.

```
Resolución:
  1. Vb cubeta 0: 1 → 2
  2. Crear cubeta 2 (Vb=2)
  3. Vb(2) > Vt(1) → DUPLICAR tabla → Vt=2
  4. Redispersar cubeta 0 con 2 bits (últimos 2):
     Beta  (...0100): "00" → cubeta 0
     Gamma (...0010): "10" → cubeta 2
  5. Insertar Epsilon (...0000): "00" → cubeta 0

Tabla (Vt=2):
  [00] → cubeta 0 (Vb=2): [Beta, Epsilon]  LLENA
  [01] → cubeta 1 (Vb=2): [Alfa, Delta]    LLENA
  [10] → cubeta 2 (Vb=2): [Gamma]
  [11] → cubeta 2 (Vb=2): [Gamma]          (entradas duplicadas)
```

**Paso 6 — +Rho**: Vt=2 → 2 bits: "11" → cubeta 2: [Gamma]. Tiene espacio → insertar.

```
Tabla (Vt=2):
  [00] → cubeta 0: [Beta, Epsilon]  LLENA
  [01] → cubeta 1: [Alfa, Delta]    LLENA
  [10] → cubeta 2: [Gamma, Rho]     LLENA
  [11] → cubeta 2: [Gamma, Rho]     (misma cubeta)
```

**Paso 7 — +Pi**: Vt=2 → 2 bits: "10" → cubeta 2. **OVERFLOW**.

```
Resolución:
  1. Vb cubeta 2: 2 → 3
  2. Crear cubeta 3 (Vb=3)
  3. Vb(3) > Vt(2) → DUPLICAR tabla → Vt=3
  4. Redispersar cubeta 2 con 3 bits:
     Gamma (...0010): "010" → cubeta 010
     Rho   (...1011): "011" → cubeta 011
  5. Insertar Pi (...0110): "110" → cubeta 110

Tabla (Vt=3):
  000 → cubeta [Beta, Epsilon]    (entradas duplicadas)
  001 → cubeta [Beta, Epsilon]
  010 → cubeta [Gamma]            (nueva)
  011 → cubeta [Rho, Pi]          (nueva)
  100 → cubeta [Alfa, Delta]      (entradas duplicadas)
  101 → cubeta [Alfa, Delta]
  110 → cubeta [Gamma]            (comparte con 010)
  111 → cubeta [Rho, Pi]          (comparte con 011)
```

**Resumen de la mecánica**:

1. Aplicar función hash → secuencia de bits.
2. Tomar los últimos `Vt` bits para indexar la tabla → obtener cubeta.
3. Si la cubeta tiene lugar → insertar.
4. Si la cubeta está llena (overflow):
   - Incrementar en 1 el valor de bits de la cubeta (Vb).
   - Crear nueva cubeta con el mismo Vb.
   - Si `Vb > Vt` → duplicar tabla (2× entradas) e incrementar Vt.
   - Re-dispersar las claves de la cubeta original entre la vieja y la nueva, usando 1 bit más.

**Ventaja clave del hash extensible**: solo se redispersan las claves de la(s) cubeta(s) afectadas por el overflow, no todo el archivo. Esto lo hace eficiente para archivos que crecen gradualmente.

### 8. Elección de organización

| Organización | Acceso 1 registro CP | Todos los registros CP |
|:------------|:--------------------|:----------------------|
| **Secuencial** | Lento | Lento |
| **Index secuencial** | Lento | Rápido |
| **Hash** | **Rápido** | Lento |
| **Árbol B/B+** | Bueno | Rápida |

**Criterios para elegir**:
1. **Características del archivo**: cantidad de registros, tamaño de registros, tipo de clave.
2. **Requerimientos del usuario**: tipos de operación (altas/bajas/modificaciones/consultas), frecuencia.
3. **Características del hardware**: tamaño de sectores, bloques, pistas, cilindros.
4. **Parámetros de tiempo**: desarrollo, mantenimiento, procesamiento.
5. **Uso promedio**: registros usados / registros totales.

---

### Autoevaluación

1. ¿Cuál es la diferencia entre colisión y overflow?
2. ¿Qué significa que dos claves sean sinónimas?
3. ¿Cómo afecta la densidad de empaquetamiento (DE) al overflow?
4. ¿Qué relación hay entre el tamaño de cubeta (C) y el overflow esperado?
5. ¿Cuál es la principal desventaja de la saturación progresiva?
6. ¿En qué se diferencia la saturación progresiva encadenada de la simple?
7. ¿Cómo funciona la dispersión doble? ¿qué problema resuelve?
8. ¿Qué es el área de desborde separada y qué ventaja tiene?
9. En hash extensible: ¿cuándo se duplica la tabla de directorio?
10. ¿Cuándo conviene usar hashing en lugar de árboles B?

> **Ejercicio sugerido**: calcular la tabla de overflow esperado para un archivo con R=1000, N=500, C=2 (DE=100%). Repetir con C=5 (DE=40%). Verificar con la herramienta e-Hash de la cátedra.
