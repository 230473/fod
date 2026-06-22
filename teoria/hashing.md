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

Claves y sus primeros bits (función de hash de 32 bits, se muestran los 8 bits menos significativos):

| Clave | Bits | Clave | Bits |
|:------|:-----|:------|:-----|
| Alfa | `0011 0011` | Omega | `1111 1111` |
| Beta | `0110 0101` | Pi | `0000 0000` |
| Gamma | `1001 1010` | Tau | `0011 1011` |
| Epsilon | `0111 1100` | Lambda | `0100 1000` |
| Delta | `1100 0001` | Sigma | `0010 1110` |
| Tita | `0001 0110` | | |

Capacidad de cada cubeta: 2 registros.

**Estado inicial**: tabla con i=0 bits, una sola entrada apuntando a cubeta 0 (vacía).

```
tabla bits = 0     cubeta 0 (bits=0): [vacio]
[0→cubeta0]
```

**Paso 1 — +Alfa, +Beta**: se toman 0 bits → ambas van a cubeta 0.

```
cubeta 0: [Alfa, Beta]
```

**Paso 2 — +Gamma**: cubeta 0 llena → **overflow**.
1. cubeta 0: incrementar a 1 bit. Crear cubeta 1 con 1 bit.
2. Valor cubeta (1) = valor tabla (0) → **duplicar tabla** a 2 entradas (i=1).
3. Re-dispersar usando 1 bit: Alfa(0), Beta(0), Gamma(1).

```
tabla bits = 1     cubeta 0 (bits=1): [Gamma]
[0→cubeta1]        cubeta 1 (bits=1): [Alfa, Beta]
[1→cubeta0]
```

**Paso 3 — +Epsilon**: Epsilon(0) → cubeta 0. Se llena → overflow.
1. cubeta 0: bits 1→2. Crear cubeta 2 con bits 2.
2. Valor cubeta (2) > valor tabla (1) → **duplicar tabla** a 4 entradas (i=2).
3. Re-dispersar cubeta 0: Gamma(10), Epsilon(00). Gamma→00(entrada 0 de tabla), Epsilon→10(entrada 2).

```
tabla bits = 2     cubeta 0 (bits=2): [Gamma, Epsilon]
[00→cubeta1]       cubeta 1 (bits=2): [Beta, Delta]
[01→cubeta2]       cubeta 2 (bits=2): [Alfa]
[10→cubeta0]       (entradas duplicadas: 01→cubeta2, 11→cubeta2)
[11→cubeta2]
```

**Paso 4 — +Delta**(1100 0001): primer bit 1 → cubeta1. Ya hay [Beta, Alfa]. Alfa(0011)=0, Beta(0110)=1, Delta (1100)=0. Con 1 bit: Alfa→cubeta0, Beta→cubeta1, Delta→cubeta1 → overflow en cubeta1.

1. cubeta1: bits 1→2. Crear cubeta2 con bits 2.
2. Valor cubeta (2) > valor tabla (1) → **duplicar tabla**.
   Pero en este punto ya se duplicó antes así que se maneja diferentemente...

(El ejemplo completo del hash extensible es extenso; la mecánica se repite: al llenarse una cubeta, se incrementan sus bits, se crea una nueva cubeta, y si es necesario se duplica la tabla hasta tener entradas suficientes para direccionar todas las cubetas.)

**Resumen de la mecánica**:

1. Aplicar función hash → secuencia de bits.
2. Tomar los primeros `i` bits para indexar la tabla → obtener NRR de cubeta.
3. Si la cubeta tiene lugar → insertar.
4. Si la cubeta está llena (overflow):
   - Incrementar en 1 el valor de bits de la cubeta.
   - Crear nueva cubeta con el mismo valor de bits.
   - Si `bits_cubeta > bits_tabla` → duplicar tabla (2× entradas) e incrementar i.
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
