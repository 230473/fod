# Fundamentos de Organización de Datos – Índices

## Índice

- [1. Definición de Índice](#1-definición-de-índice)
- [2. Motivación](#2-motivación)
- [3. Estructura básica de un índice](#3-estructura-básica-de-un-índice)
- [4. Operaciones básicas con índices](#4-operaciones-básicas-con-índices)
  - [4.1 Agregar registros](#41-agregar-registros)
  - [4.2 Eliminar registros](#42-eliminar-registros)
  - [4.3 Modificar registros](#43-modificar-registros)
- [5. Índices primarios](#5-índices-primarios)
- [6. Índices secundarios](#6-índices-secundarios)
  - [6.1 Problemas de los índices secundarios](#61-problemas-de-los-índices-secundarios)
  - [6.2 Solución: vector de punteros](#62-solución-vector-de-punteros)
  - [6.3 Solución: listas invertidas](#63-solución-listas-invertidas)
- [7. Índices completos vs raleados](#7-índices-completos-vs-raleados)
- [8. Ventajas y desventajas](#8-ventajas-y-desventajas)
- [9. Persistencia de datos](#9-persistencia-de-datos)

---

### 1. Definición de Índice

Un **índice** es una estructura de datos auxiliar que permite encontrar registros en un archivo de forma más rápida que recorriendo el archivo completo.

> Es el equivalente al **índice temático de un libro**: en lugar de hojear todo el libro buscando un tema, se consulta el índice que dice en qué página está.

Cada entrada de un índice contiene:

- **Clave (llave)**: el valor por el que se busca (ej. DNI, código de producto, título).
- **Referencia (dirección)**: indica dónde encontrar el registro dentro del archivo de datos. Puede ser un NRR (número relativo de registro, para longitud fija) o la distancia en bytes desde el inicio del archivo (para longitud variable).

```
  Índice (archivo ordenado)          Archivo de datos
┌─────────────────┬─────────┐     ┌────────────────────────┐
│     Clave       │   Ref   │     │   Registros            │
├─────────────────┼─────────┤     ├────────────────────────┤
│ ANG3795         │   167   │ ──→ │ ANG3795│Sinfonía...     │
│ COL31809        │   353   │ ──→ │ COL31809│Sinfonía...    │
│ COL38358        │   211   │ ──→ │ COL38358│Nebraska...     │
│ DG139201        │   396   │ ──→ │ DG139201│Concierto...    │
│ DG18807         │   256   │ ──→ │ DG18807│Sinfonía...      │
│ ...             │   ...   │     │ ...                    │
└─────────────────┴─────────┘     └────────────────────────┘
```

### 2. Motivación

Sin índice, buscar un registro implica:

- **Búsqueda secuencial**: O(N) accesos a disco. Para un archivo de 1.000.000 de registros, promedio 500.000 lecturas.
- **Búsqueda binaria**: O(Log₂ N) accesos, pero exige que el archivo esté **ordenado** y sea de **longitud fija**. Además, reordenar el archivo de datos por cada alta es prohibitivo.

El índice resuelve esto porque:

1. Es un archivo separado, mucho más pequeño que los datos.
2. Tiene registros de **longitud fija** (clave + referencia), aunque los datos sean de longitud variable.
3. Se mantiene **ordenado** en memoria o en disco, permitiendo búsqueda binaria.
4. **No requiere reordenar el archivo de datos**: los datos se agregan al final, y solo se actualiza el índice.

### 3. Estructura básica de un índice

Un índice se implanta como un archivo de registros de longitud fija con dos campos:

```pascal
const
  LARGO_CLAVE = 12;

type
  tRegIndice = record
    clave: string[LARGO_CLAVE];   // clave canónica
    nrr: integer;                 // NRR en datos (o distancia en bytes)
  end;

  tArchIndice = file of tRegIndice;
```

El índice se carga en memoria (un arreglo) y se mantiene ordenado allí. Cada vez que se cierra el archivo, se reescribe completo a disco.

```pascal
var
  indices: array[1..MAX_INDICES] of tRegIndice;
  cantIndices: integer;
```

### 4. Operaciones básicas con índices

#### 4.1 Agregar registros

1. Agregar el registro al **archivo de datos** al final.
   - Si los datos son de longitud fija: se escribe al final, se obtiene su NRR.
   - Si los datos son de longitud variable: se escribe al final, se guarda la distancia en bytes.
2. Agregar la entrada en el **índice en memoria** (arreglo), manteniendo el orden por clave canónica.
3. Reescribir el archivo de índice al cerrar.

```pascal
procedure AgregarConIndice(var datos: tArchDatos; var idx: tArchIndice;
                           var arr: array of tRegIndice; var cant: integer;
                           reg: tRegistro);
var
  entrada: tRegIndice;
begin
  // 1. Agregar al archivo de datos
  seek(datos, filesize(datos));
  write(datos, reg);

  // 2. Preparar entrada en el índice
  entrada.clave := ObtenerClaveCanonica(reg);
  entrada.nrr := filesize(datos) - 1;

  // 3. Insertar ordenadamente en el arreglo
  InsertarOrdenado(arr, cant, entrada);
end;
```

#### 4.2 Eliminar registros

- **Archivo de datos**: se aplica cualquier técnica de baja (lógica, física, lista invertida; ver `archivos.md`).
- **Archivo de índices**: se quita la entrada del arreglo (o se marca como borrada).

#### 4.3 Modificar registros

**Sin modificar la clave:**
- Si el registro **no cambia de longitud** (longitud fija o la misma cantidad de bytes): se sobrescribe en la misma posición. El índice no se toca.
- Si el registro **cambia de longitud** (se agranda) y se reubica al final del archivo de datos: se debe actualizar la referencia en el índice con la nueva posición.
- Si es longitud fija, no hay que hacer más actividad.

**Modificando la clave:**
- Se debe actualizar y **reorganizar el archivo de índices** porque el orden cambia.
- Forma práctica: tratar como **eliminar + agregar** (operaciones ya conocidas).

### 5. Índices primarios

Un **índice primario** se construye sobre la **clave primaria (unívoca)** del archivo de datos.

- La clave primaria identifica de forma única a cada registro.
- El índice primario tiene **una entrada por cada registro** del archivo de datos.
- La relación entre índice y datos es **1 a 1**.
- Al buscar por clave primaria: se busca en el índice (binaria, O(Log₂ N)), se obtiene el NRR, y se accede directamente a los datos (O(1)).

**Ejemplo**: en un archivo de discos musicales, clave primaria = compañía + número de identificación (canónica: "ANG3795", "COL31809", etc.).

### 6. Índices secundarios

Un **índice secundario** se construye sobre una **clave secundaria**, que **puede repetirse** (varios registros comparten el mismo valor).

- No sería natural buscar siempre por clave primaria; se usan campos más fáciles de recordar.
- Ejemplo: en un catálogo de música, buscar por **compositor** (Beethoven puede tener varias obras).
- El índice secundario relaciona la clave secundaria con la **clave primaria** (NO con la dirección física directamente).
- ¿Por qué no apuntar directo a la dirección física? Porque un archivo puede tener varios índices secundarios. Si el registro cambiara de ubicación (por ej. una baja + alta), habría que actualizar **todos** los índices secundarios. En cambio, si solo el índice primario tiene la dirección física, al mover un registro solo se actualiza el índice primario.
- El acceso es de dos pasos:
  1. Buscar por clave secundaria → se obtiene(n) la(s) clave(s) primaria(s).
  2. Con la clave primaria, buscar en el índice primario → se obtiene el NRR.
  3. Acceder al registro de datos.

```
Índice secundario (Compositores)     Índice primario
┌──────────────┬──────────────┐     ┌─────────┬──────┐
│ Clave secund │ Clave primaria│     │ Clave   │ NRR │
├──────────────┼──────────────┤     ├─────────┼──────┤
│ BEETHOVEN    │ ANG3795       │     │ANG3795  │ 167 │
│ BEETHOVEN    │ DG139201      │     │DG139201 │ 396 │
│ BEETHOVEN    │ DG18807       │     │DG18807  │ 256 │
│ BEETHOVEN    │ RCA2626       │     │...      │ ... │
│ COREA        │ WAR23699      │     └─────────┴──────┘
│ DVORAK       │ COL31809      │
│ PROKOFIEV    │ LON2312       │
│ SPRINGSTEEN  │ COL38358      │
│ ...          │ ...           │
└──────────────┴──────────────┘
```

#### 6.1 Problemas de los índices secundarios

1. **Repetición de información**: la misma clave secundaria aparece tantas veces como registros la tengan.
2. **Reordenamiento constante**: al agregar un registro con una clave secundaria ya existente, el archivo de índices se debe reacomodar (porque se ordena por clave secundaria y luego por clave primaria).
3. **Desperdicio de espacio**: la clave secundaria se repite muchas veces.
4. **Menor probabilidad de que el índice quepa en memoria**: al ser más grande.

#### 6.2 Solución: vector de punteros

En lugar de repetir la clave secundaria, se usa una estructura de **clave + vector de punteros** a claves primarias:

```
BEETHOVEN → [ANG3795, DG139201, DG18807, RCA2626]
```

**Ventaja**: al agregar un registro con una clave existente, no se reacomoda el índice; solo se agrega un elemento al vector.
**Problema**: tamaño fijo del vector → si es pequeño, puede ser insuficiente; si es grande, fragmentación interna.

#### 6.3 Solución: listas invertidas

Una **lista invertida** elimina la repetición de claves secundarias usando dos archivos:

1. **Archivo de índice secundario**: contiene una entrada por cada **clave secundaria distinta**, con un NRR al primer elemento de la lista de claves primarias asociadas.
2. **Archivo de listas de claves primarias**: contiene las claves primarias encadenadas, una por ocurrencia.

```
Archivo índice secundario        Archivo de listas (claves primarias)
┌──────────────┬──────┐         ┌──────────┬──────┐
│ Clave        │ NRR  │         │ Clave    │ Link │
├──────────────┼──────┤         ├──────────┼──────┤
│ BEETHOVEN    │ 0    │ ──────→ │ LON2312  │  1   │
│ COREA        │ 1    │ ──────→ │ RCA2626  │  -1  │
│ DVORAK       │ 2    │ ────┐   │ WAR23699 │  -1  │
│ PROKOFIEV    │ 3    │ ──┐ │   │ ANG3795  │  4   │
│ RIMSKY-KORSAK│ 4    │ ─┐│ │   │ COL38358 │  -1  │
│ SPRINGSTEEN  │ 5    │ ┐││ │   │ DG18807  │  6   │
│ SWEET HONEY  │ 6    │ │││ │   │ MER76016 │  -1  │
└──────────────┴──────┘ │││ │   │ COL31809 │  -1  │
                        │││ │   │ DG139201 │  9   │
                        │││ │   │ FF245    │  -1  │
                        │││ │   │ ANG36193 │  -1  │
                        └──┴───┴──────────┴──────┘
```

**Ventajas:**
- No se desperdicia espacio: no hay reserva fija.
- Al agregar un registro con clave secundaria existente, se encadena al final de la lista correspondiente; no se necesita reorganización completa.
- El único reacomodamiento en el archivo índice es al agregar o cambiar un nombre de clave secundaria.
- Como el reacomodamiento es a bajo costo, el archivo índice puede almacenarse en memoria secundaria, liberando RAM.

**Desventajas:**
- El archivo de listas es conveniente tenerlo en memoria principal porque puede haber muchos desplazamientos en disco (costoso si hay muchos índices secundarios).

El acceso con listas invertidas:
1. Buscar clave secundaria en el archivo índice → obtener NRR de la lista.
2. Recorrer la lista encadenada de claves primarias.
3. Para cada clave primaria, buscar en el índice primario → obtener NRR del registro de datos.
4. Acceder a los registros de datos.

### 7. Índices completos vs raleados

| Característica | Índice completo (dense) | Índice raleado (sparse) |
|:--------------|:----------------------|:----------------------|
| Entradas | Una por cada registro de datos | Una por cada bloque/página de datos |
| Tamaño | Grande (≈ N entradas) | Pequeño (≈ N/bloque entradas) |
| Búsqueda | Exacta, acceso directo al registro | Se llega al bloque, luego búsqueda secuencial dentro del bloque |
| Mantenimiento | Cada alta/baja modifica el índice | Solo se modifica cuando se crea/vacía un bloque |
| Uso típico | Índices secundarios, claves no ordenadas | Índices primarios sobre archivos ordenados |

- **Índice completo**: hay una entrada por cada registro. Ocupa más espacio pero permite llegar directamente al registro.
- **Índice raleado**: hay una entrada por cada bloque de datos (ej. por cada página de 4 KB). Se busca en el índice, se accede al bloque, y dentro del bloque se busca secuencialmente. Ocupa menos espacio y tiene menos mantenimiento.

### 8. Ventajas y desventajas

**Ventajas:**
- Se almacena en memoria principal (si cabe), lo que acelera las búsquedas.
- Permite búsqueda binaria sobre una estructura pequeña y de longitud fija.
- El mantenimiento es menos costoso que reordenar el archivo de datos completo.
- Proporciona múltiples caminos de acceso al archivo (varios índices secundarios).

**Desventajas:**
- Si el índice no cabe en memoria RAM, se degrada la performance.
- Requiere reescritura completa del archivo de índices si se mantiene en disco.
- Los índices secundarios con listas invertidas pueden requerir muchos accesos a disco.
- La persistencia de datos implica coordinar archivo de datos + archivo(s) de índice(s).

### 9. Persistencia de datos

Cuando el índice **no cabe en memoria principal**, se necesitan estructuras alternativas:

- **Árboles** (B, B*, B+): organizan el índice en disco como un árbol balanceado, minimizando la cantidad de accesos (profundidad = altura del árbol). Ver `arboles.md`.
- **Dispersión (Hashing)**: función hash que permite acceso directo O(1) promedio sin estructura de índice separada. Ver `hashing.md`.

---

### Autoevaluación

1. ¿Por qué los índices secundarios apuntan a la clave primaria y no directamente a la dirección física?
2. ¿Cuál es la diferencia entre un índice completo (dense) y uno raleado (sparse)?
3. En una lista invertida para índice secundario: ¿qué ventaja tiene sobre almacenar (clave_sec, vector_punteros)?
4. ¿Qué dos pasos se requieren para acceder a un registro usando un índice secundario?
5. ¿Qué sucede con el índice cuando se modifica un registro sin cambiar su clave? ¿Y cuando se cambia la clave?
6. ¿Cuándo conviene usar un índice raleado en lugar de uno completo?

> **Ejercicio sugerido**: implementar un índice en Pascal: cargar un archivo de datos desordenado, construir un índice ordenado por clave primaria en memoria (arreglo), y usar el índice para buscar registros. Extender con índice secundario usando listas invertidas (dos archivos).
