# Fundamentos de Organización de Datos – Archivos

## Índice

- [PARTE I: Fundamentos Físicos y Teóricos](#parte-i-fundamentos-físicos-y-teóricos)
  - [1. Conceptos básicos de almacenamiento y transmisión](#1-conceptos-básicos-de-almacenamiento-y-transmisión)
  - [2. El Viaje de un Byte](#2-el-viaje-de-un-byte)
  - [3. Organización de archivos según forma de acceso](#3-organización-de-archivos-según-forma-de-acceso)
  - [4. Archivos según cantidad de cambios](#4-archivos-según-cantidad-de-cambios)
- [PARTE II: Implementación en Pascal](#parte-ii-implementación-en-pascal)
  - [5. Estructura Lógica de Datos](#5-estructura-lógica-de-datos)
  - [6. Tipos de Archivos según su naturaleza](#6-tipos-de-archivos-según-su-naturaleza)
    - [6.1 Archivos de registros de longitud fija (tipados)](#61-archivos-de-registros-de-longitud-fija-tipados)
    - [6.2 Archivos de texto](#62-archivos-de-texto)
    - [6.3 Archivos de bloques de bytes (sin tipo)](#63-archivos-de-bloques-de-bytes-sin-tipo)
  - [7. Operaciones básicas sobre archivos tipados (Pascal)](#7-operaciones-básicas-sobre-archivos-tipados-pascal)
  - [8. Ejemplos completos de manejo básico](#8-ejemplos-completos-de-manejo-básico)
  - [9. Conversión entre archivos de texto y archivos binarios](#9-conversión-entre-archivos-de-texto-y-archivos-binarios)
- [PARTE III: Claves y Performance](#parte-iii-claves-y-performance)
  - [10. Claves](#10-claves)
  - [11. Búsqueda y Clasificación](#11-búsqueda-y-clasificación)
- [PARTE IV: Mantenimiento y Eliminación de Registros (Bajas)](#parte-iv-mantenimiento-y-eliminación-de-registros-bajas)
  - [12. Baja Física y Lógica](#12-baja-física-y-lógica)
  - [13. Reutilización del espacio (Listas Invertidas)](#13-reutilización-del-espacio-listas-invertidas)
  - [14. Registros de Longitud Variable y Fragmentación](#14-registros-de-longitud-variable-y-fragmentación)
- [PARTE V: Patrones y Algoritmos Clásicos](#parte-v-patrones-y-algoritmos-clásicos)
  - [15. Agregar nuevos elementos al final](#15-agregar-nuevos-elementos-al-final)
  - [16. Actualización Maestro-Detalle](#16-actualización-maestro-detalle)
  - [17. Corte de Control](#17-corte-de-control)
  - [18. Merge (fusión) de archivos](#18-merge-fusión-de-archivos)
  - [19. Merge con N archivos (vector de detalles)](#19-merge-con-n-archivos-vector-de-detalles)
- [PARTE VI: Índices](#parte-vi-índices)
  - [20. Índices: concepto y tipos](#20-índices-concepto-y-tipo)

---

## PARTE I: Fundamentos Físicos y Teóricos

### 1. Conceptos básicos de almacenamiento y transmisión

#### 1.1 Hardware de almacenamiento

En un sistema de computación existen dos categorías fundamentales de memoria:

- **Almacenamiento primario** (memoria RAM)
  - Volátil: los datos se pierden al cortar la energía.
  - Acceso rápido: los tiempos de lectura/escritura se miden en nanosegundos.
  - Acceso directo por dirección de byte: se puede acceder a cualquier posición sin necesidad de leer las anteriores.
  - Capacidad limitada y mayor costo que el almacenamiento secundario.

- **Almacenamiento secundario** (discos magnéticos, SSD, pendrives)
  - Persistente: los datos permanecen incluso sin energía.
  - Acceso más lento: los tiempos se miden en milisegundos (varias órdenes de magnitud más lento que la RAM).
  - En discos magnéticos tradicionales, el acceso implica movimientos mecánicos (brazo, cabezal, rotación del plato).

> **Importante**: La diferencia de velocidad entre RAM y disco es enorme. Por eso, los algoritmos que manipulan archivos deben minimizar la cantidad de operaciones de lectura/escritura y, cuando sea posible, procesar los datos en forma secuencial para aprovechar el prefetch del sistema operativo.

#### 1.2 Estructura física de un disco magnético

Aunque los SSD funcionan de manera diferente, el modelo de disco magnético sigue siendo útil para comprender conceptos como pistas, sectores y cilindros.

```plaintext
                    ┌─────────────────────────┐
                    │         Plato           │
                    │  ┌───────────────────┐  │
                    │  │   Superficie       │  │
                    │  │  ┌─────────────┐   │  │
                    │  │  │  Pista      │   │  │
                    │  │  │  ┌───────┐  │   │  │
                    │  │  │  │Sector │  │   │  │
                    │  │  │  └───────┘  │   │  │
                    │  │  └─────────────┘   │  │
                    │  └───────────────────┘  │
                    └─────────────────────────┘
```

- **Platos**: discos físicos que giran a alta velocidad (ej. 5400 o 7200 RPM).
- **Superficies**: cada lado de un plato; una cabeza de lectura/escritura accede a cada superficie.
- **Pistas**: círculos concéntricos en una superficie. Un disco típico tiene miles de pistas.
- **Sectores**: divisiones de una pista, generalmente de 512 bytes o 4 KB. Es la unidad mínima de transferencia entre el disco y la memoria.
- **Cilindro**: conjunto de pistas alineadas verticalmente en todos los platos. Permite acceder a la misma pista en todas las superficies sin mover el brazo.

**Tiempos característicos**:

- **Tiempo de búsqueda (seek)**: mover el brazo hasta la pista deseada.
- **Latencia rotacional**: esperar a que el sector deseado pase bajo la cabeza.
- **Tiempo de transferencia**: una vez posicionados, leer/escribir los datos.

#### 1.3 Definiciones de archivo

Un **archivo** puede entenderse de tres maneras complementarias:

1. **Colección de registros** guardados en almacenamiento secundario, organizados de alguna forma (secuencial, indexada, etc.).
2. **Colección de datos** almacenados en dispositivos secundarios de memoria, que pueden ser leídos o escritos mediante operaciones del sistema operativo.
3. **Colección de registros** que representan entidades con un aspecto común (ej. todos los empleados de una empresa) y que se crean con un propósito particular (ej. liquidación de sueldos).

#### 1.4 Archivo Físico vs. Archivo Lógico

```plaintext
Archivo Físico  { - Existe en almacenamiento secundario
                { - Es el archivo tal como lo conoce el S.O.
                    y que aparece en su directorio de archivos

Archivo Lógico  { - Es el archivo visto por el programa
                { - Permite describir las operaciones a efectuarse
                { - No se sabe cuál archivo físico real se utiliza
                    ni dónde está ubicado
```

#### 1.5 Buffers: memoria intermedia

- Los buffers son áreas de memoria RAM que actúan como intermediarios entre el programa y el archivo en disco.
- Cuando se ejecuta `write(arch, dato)`, el dato se copia al buffer interno del archivo. Solo cuando el buffer se llena (o se ejecuta `close` o `flush`) el sistema operativo escribe el bloque completo al disco.
- De manera similar, `read` lee un bloque completo del disco al buffer y luego entrega los datos al programa uno por uno.
- **Ventajas**: reduce la cantidad de operaciones físicas de disco, mejorando el rendimiento.
- **Desventaja**: si el programa termina abruptamente (sin `close`), los datos en el buffer pueden perderse.
- El S.O. es el encargado de manipular los buffers.

```
                    Disco Rígido
                         |
                    Buffer de Entrada
                         |
                    Programa de Usuario
                         |
                    Buffer de Salida
                         |
                    Disco Rígido
```

### 2. El Viaje de un Byte

Escribir un dato en un archivo no es sencillo. Una simple instrucción `write(archivo, variable)` desencadena múltiples ciclos internos. Los actores involucrados son:

- **Administrador de archivos**
- **Buffer de E/S**
- **Procesador de E/S**
- **Controlador de disco**

#### Administrador de archivos

Conjunto de programas del S.O. (capas de procedimientos) que tratan aspectos relacionados con archivos y dispositivos de E/S.

- **Capas Superiores** — aspectos lógicos (tabla):
  - Verifica si las características del archivo son compatibles con la operación deseada **(1)**
- **Capas Inferiores** — aspectos físicos (FAT):
  - Determina dónde se guarda el dato (cilindro, superficie, sector) **(2)**
  - Si el sector está en RAM lo utiliza; si no, lo trae previamente **(3)**

#### Buffers de E/S

Agilizan la E/S de datos. Manejar buffers implica trabajar con grandes grupos de datos en RAM para reducir el acceso a almacenamiento secundario.

#### Procesador de E/S

Dispositivo utilizado para la transmisión desde o hacia almacenamiento externo. Opera de forma **independiente de la CPU**. **(3)**

#### Controlador de disco

Encargado de controlar la operación física de disco:

- Colocarse en la pista
- Colocarse en el sector
- Transferencia a disco

#### Flujo completo — escribir el byte 'P' en disco

**Paso 1 — El programa llama al S.O.:**

```plaintext
+-------------------+        +----------------------+
|     Programa      |        |  Sistema Operativo   |
|  ....             | -----> |  ....                |
|  Write (....)     | <----- |  Toma el byte del    |
|  ....             |        |  área de datos       |
+-------------------+        +----------------------+
         |
+-------------------+
|  Área de datos    |
|  del programa     |
|  ...P...          |
+-------------------+
```

**Paso 2 — El byte pasa al Buffer de Salida:**

```plaintext
+-------------------+        +----------------------+
|  Área de datos    | -----> |   Buffer de Salida   |
|  ...P...          |        |  ... ... ... P ...   |
+-------------------+        +----------------------+
```

**Paso 3 — El Procesador de E/S toma el dato:**

```plaintext
+-------------------------------+       +--------------------+
|  [Programa + S.O. + Buffer]   | ----> | Procesador de E/S  |
|  Buffer de Salida:            |       |   [... P ....]     |
|  ... ... ... P ...            |       +--------------------+
+-------------------------------+               |
                                                v
                                         +------------+
                                         | Disco Rígido|
                                         +------------+
```

**Paso 4 — El Controlador escribe en disco:**

```plaintext
Procesador de E/S                    Controlador de Disco
   [... P ....]           ---->          'P'
                                           |
                                           v
                                     +----------+
                                     |   Disco  |
                                     |  Rígido P|
                                     +----------+
```

**Capas del protocolo resumidas**:

1. El Programa pide al S.O. escribir el contenido de una variable en un archivo
2. El S.O. transfiere el trabajo al Administrador de archivos
3. El Adm. busca el archivo en su tabla de archivos y verifica las características
4. El Adm. obtiene de la FAT la ubicación física del sector del archivo donde se guardará el byte
5. El Adm. se asegura que el sector del archivo está en un buffer y graba el dato donde va dentro del sector en el buffer
6. El Adm. de archivos da instrucciones al procesador de E/S (dónde está el byte en RAM y en qué parte del disco deberá almacenarse)
7. El procesador de E/S encuentra el momento para transmitir el dato a disco, la CPU se libera
8. El procesador de E/S envía el dato al controlador de disco (con la dirección de escritura)
9. El controlador prepara la escritura y transfiere el dato bit por bit en la superficie del disco

### 3. Organización de archivos según forma de acceso

- **Serie** (secuencial físico)
  - Características: Los registros se almacenan uno tras otro en el orden en que se escribieron. Para acceder al registro *i* es necesario leer todos los anteriores.
  - Ejemplo de uso: Archivos de log, respaldos, cintas magnéticas.

- **Secuencial indizado** (lógico)
  - Características: Los registros se ordenan según una clave (ej. DNI). Se mantiene una estructura auxiliar (índice) que permite acceder rápidamente a un registro sin recorrer todo el archivo.
  - Ejemplo de uso: Archivos de base de datos con índice primario.

- **Directo** (aleatorio)
  - Características: Se accede a un registro mediante una dirección calculada a partir de la clave (hash) o mediante un número de registro conocido.
  - Ejemplo de uso: Archivos con `seek` en Pascal, tablas hash persistentes.

En la materia trabajamos principalmente con archivos de **serie** (secuenciales) y las operaciones clásicas sobre ellos.

### 4. Archivos según cantidad de cambios

- **Estáticos**: pocos cambios. Pueden actualizarse en procesamiento por lotes. No necesitan estructuras adicionales.
- **Volátiles**: sometidos a operaciones frecuentes (agregar/borrar/actualizar). Su organización debe facilitar cambios rápidos. Necesitan estructuras adicionales para mejorar los tiempos de acceso.

---

## PARTE II: Implementación en Pascal

### 5. Estructura Lógica de Datos

#### 5.1 Campos y Registros

Los archivos estructurados (tipados) están formados por **registros**, que a su vez se agrupan en **campos** (la unidad lógicamente significativa más pequeña). Para determinar dónde empieza y termina un dato se usan variantes:

- **Longitud fija**: Puede desperdiciar espacio si el dato real es más corto (ej. `String[50]`).
- **Indicador de longitud**: Se almacena al inicio el tamaño en bytes/caracteres.
- **Delimitador**: Un carácter especial (ej. `;` o `*`) que marca el final.

#### 5.2 Claves (resumen — ver Parte III para detalle)

Una **clave** (o llave) permite identificar y ordenar registros:

- **Primaria (Unívoca)**: Identifica un único elemento.
- **Secundaria**: Generalmente no identifica un registro único.
- **Clave Canónica**: Es una forma estándar y única (ej. solo mayúsculas, sin espacios extra). Al insertar, se busca la forma canónica para evitar duplicados.

### 6. Tipos de Archivos según su naturaleza

Según el lenguaje de programación (en este caso Pascal), los archivos se clasifican en tres categorías.

#### 6.1 Archivos de registros de longitud fija (tipados)

- Se declaran con `file of <tipo_dato>`.
- El tipo puede ser simple (`integer`, `real`, `char`, `string`) o estructurado (`record`).
- **Cada componente ocupa el mismo número de bytes**. Esto permite el acceso directo (aleatorio) mediante la función `seek`.
- Son ideales para almacenar información estructurada que necesita actualizaciones por posición.

**Ejemplo**:

```pascal
type
  TEmpleado = record
    legajo: integer;
    nombre: string[30];
    salario: real;
  end;
  ArchivoEmpleados = file of TEmpleado;
var
  empleados: ArchivoEmpleados;
```

#### 6.2 Archivos de texto

- Se declaran como `Text` (un tipo predefinido en Pascal).
- Contienen caracteres organizados en líneas (cada línea termina con un marcador de fin de línea, como CR+LF).
- Las operaciones `read`/`readln` y `write`/`writeln` realizan conversión automática entre la representación externa (caracteres) y los tipos internos (enteros, reales, cadenas).
- **El acceso es exclusivamente secuencial**: no se puede usar `seek` ni `filepos`.
- Muy útiles para **intercambiar datos con otros sistemas** (exportación/importación) y para generar reportes legibles por humanos.

**Ejemplo**:

```pascal
var
  archTxt: Text;
  num: integer;
begin
  assign(archTxt, 'datos.txt');
  reset(archTxt);
  while not eof(archTxt) do
  begin
    readln(archTxt, num);
    writeln('Número leído: ', num);
  end;
  close(archTxt);
end.
```

#### 6.3 Archivos de bloques de bytes (sin tipo)

- Se declaran como `file` (sin `of`).
- El archivo se trata como una secuencia de bytes sin interpretación.
- Las operaciones `blockread` y `blockwrite` permiten leer/escribir bloques de bytes de una sola vez.
- Son menos comunes en ejercicios académicos, pero útiles para almacenar cualquier tipo de dato (imágenes, sonidos, estructuras complejas con campos de longitud variable).

**Ejemplo** (copiar un archivo byte a byte):

```pascal
var
  origen, destino: file;
  buffer: array[1..4096] of byte;
  leidos: integer;
begin
  assign(origen, 'foto.jpg');
  assign(destino, 'copia.jpg');
  reset(origen, 1);   // tamaño lógico de registro = 1 byte
  rewrite(destino, 1);
  repeat
    blockread(origen, buffer, sizeof(buffer), leidos);
    blockwrite(destino, buffer, leidos);
  until leidos = 0;
  close(origen);
  close(destino);
end.
```

### 7. Operaciones básicas sobre archivos tipados (Pascal)

Todas las operaciones estándar para archivos tipados (`file of T`) se muestran a continuación.

#### 7.1 Declaración

Dos formas equivalentes:

```pascal
var archivo_logico: file of tipo_de_dato;
```

o bien

```pascal
type
  nombre_tipo = file of tipo_de_dato;
var
  archivo_logico: nombre_tipo;
```

**Ejemplo completo**:

```pascal
type
  persona = record
    dni: string[8];
    apellido: string[25];
    nombre: string[25];
    direccion: string[25];
    sexo: char;
  end;
  archivo_enteros = file of integer;
  archivo_personas = file of persona;
var
  enteros: archivo_enteros;
  personas: archivo_personas;
```

#### 7.2 Assign – vinculación lógico-física

`assign` asocia el nombre lógico del archivo (la variable) con el nombre físico en el sistema de archivos (ruta).

```pascal
assign(nombre_logico, nombre_fisico);
```

**Ejemplo**:

```pascal
assign(enteros, 'c:\archivos\enteros.dat');
assign(personas, 'c:\archivos\personas.dat');
```

> **Nota**: En Pascal estándar, `assign` no comprueba si el archivo existe ni crea nada. Solo establece la asociación.

#### 7.3 Apertura y creación

- `rewrite(archivo)`
  - Efecto: Crea un archivo nuevo. Si ya existía, lo trunca (borra su contenido). Posiciona el puntero al inicio.
  - Modo de acceso: Solo escritura (aunque en algunos Pascal también se puede leer después de escribir).

- `reset(archivo)`
  - Efecto: Abre un archivo existente. Si el archivo no existe, produce un error. Posiciona el puntero al inicio.
  - Modo de acceso: Lectura y escritura (se puede leer y escribir).

> **Precaución**: Usar `rewrite` sobre un archivo existente sin querer borra todos sus datos. Siempre verificar si se desea sobrescribir o agregar.

#### 7.4 Cierre

```pascal
close(archivo);
```

- Vacía el buffer interno (escribe los datos pendientes en disco).
- Libera los recursos asociados al archivo (manejadores, buffers).
- Es obligatorio hacer `close` antes de que el programa termine para evitar pérdida de datos.

#### 7.5 Lectura y escritura

```pascal
read(archivo, variable);
write(archivo, variable);
```

- La variable debe ser del mismo tipo que los elementos del archivo.
- Después de un `read`, el puntero avanza al siguiente registro.
- Después de un `write`, el puntero avanza al final del registro escrito (a menos que se use `seek`).

#### 7.6 Operaciones adicionales

- `eof(archivo)`
  - Descripción: Devuelve `true` si el puntero está al final del archivo (después del último registro).
  - Ejemplo: `while not eof(arch) do ...`

- `filesize(archivo)`
  - Descripción: Número de registros en el archivo.
  - Ejemplo: `total := filesize(arch);`

- `filepos(archivo)`
  - Descripción: Posición actual del puntero (0‑basada: 0 = primer registro).
  - Ejemplo: `pos := filepos(arch);`

- `seek(archivo, pos)`
  - Descripción: Mueve el puntero a la posición `pos` (debe estar entre 0 y `filesize-1`).
  - Ejemplo: `seek(arch, 5); read(arch, r);`

**Importante**: `seek` solo funciona con archivos tipados (`file of ...`). No está disponible para archivos de texto.

### 8. Ejemplos completos de manejo básico

#### 8.1 Creación de un archivo de enteros

```pascal
program Generar_Archivo;
type archivo = file of integer;
var arc_logico: archivo;
    nro: integer;
    arc_fisico: string[12];
begin
  write('Ingrese el nombre del archivo: ');
  read(arc_fisico);
  assign(arc_logico, arc_fisico);
  rewrite(arc_logico);
  read(nro);
  while nro <> 0 do begin
    write(arc_logico, nro);
    read(nro);
  end;
  close(arc_logico);
end.
```

#### 8.2 Recorrido secuencial

```pascal
procedure Recorrido(var arc_logico: archivo);
var nro: integer;
begin
  reset(arc_logico);
  while not eof(arc_logico) do begin
    read(arc_logico, nro);
    write(nro);
  end;
  close(arc_logico);
end;
```

#### 8.3 Modificación de todos los registros (aumento de salario)

```pascal
type
  registro = record
    nombre: string[20];
    direccion: string[20];
    salario: real;
  end;
  empleados = file of registro;

procedure actualizar(var emp: empleados);
var e: registro;
begin
  reset(emp);
  while not eof(emp) do begin
    read(emp, e);
    e.salario := e.salario * 1.10;
    seek(emp, filepos(emp) - 1);
    write(emp, e);
  end;
  close(emp);
end;
```

**Explicación**: Después del `read`, el puntero queda posicionado justo después del registro leído. Para escribir el mismo registro actualizado, debemos retroceder una posición usando `seek(emp, filepos(emp)-1)`. Luego `write` avanza el puntero nuevamente, dejándolo listo para la siguiente iteración.

### 9. Conversión entre archivos de texto y archivos binarios

Es muy común tener que importar datos desde un archivo de texto (generado por otro sistema, por ejemplo) hacia un archivo binario tipado para su procesamiento eficiente, o viceversa, exportar resultados a un archivo de texto para su visualización.

#### 9.1 Crear un archivo binario desde un archivo de texto

```pascal
type
  tRegistroVotos = record
    codProv: integer;
    codLoc: integer;
    nroMesa: integer;
    cantVotos: integer;
    desc: String;
  end;
  tArchVotos = file of tRegistroVotos;

var
  arch: tArchVotos;
  carga: Text;
  votos: tRegistroVotos;
begin
  assign(carga, 'datos.txt');
  reset(carga);
  assign(arch, 'votos.dat');
  rewrite(arch);
  while not eof(carga) do
  begin
    readln(carga, votos.codProv, votos.codLoc,
           votos.nroMesa, votos.cantVotos, votos.desc);
    write(arch, votos);
  end;
  close(arch);
  close(carga);
end.
```

#### 9.2 Exportar un archivo binario a texto

```pascal
reset(arch);
rewrite(carga);
while not eof(arch) do
begin
  read(arch, votos);
  writeln(carga, votos.codProv, ' ', votos.codLoc, ' ',
          votos.nroMesa, ' ', votos.cantVotos, ' ', votos.desc);
end;
close(arch);
close(carga);
```

> **Observación**: En Pascal, al leer un `String` desde un archivo de texto, se espera que la cadena esté entre comillas o separada por espacios. Si la cadena contiene espacios, conviene usar otro delimitador (por ejemplo, `;`).

---

## PARTE III: Claves y Performance

### 10. Claves

Una **clave** (o llave) permite identificar y ordenar registros. Se concibe al registro como la cantidad de información que se lee o escribe. El objetivo es acceder a un registro específico.

#### 10.1 Tipos de clave

- **Primaria (Unívoca)**: Identifica un único elemento. Ej: DNI, código de producto.
- **Candidata**: Puede ser primaria pero no fue seleccionada.
- **Secundaria**: Generalmente no identifica un registro único. Ej: compositor en un catálogo de música.

#### 10.2 Clave Canónica

Es una forma estándar y única para la llave, ajustada a reglas bien definidas.

- Ej: clave con solo letras mayúsculas y sin espacios al final.
- Al introducir un registro nuevo:
  1. Se forma una llave canónica para ese registro
  2. Se la busca en el archivo. Si ya existe y es unívoca → no se puede ingresar

#### 10.3 Performance de búsqueda por clave

- **Secuencial**: Mejor caso 1, peor caso N, promedio N/2 comparaciones. O(N).
- **Acceso Directo (NRR)**: O(1). Requiere conocer la posición del registro. Fórmula: `distancia_bytes = NRR * longitud_registro`. Solo aplicable con registros de longitud fija.
- **Búsqueda binaria**: O(Log2 N). Requiere archivo ordenado y longitud fija.

### 11. Búsqueda y Clasificación

#### 11.1 Costo de Búsqueda

En almacenamiento secundario, la métrica dominante no son las comparaciones en RAM, sino los **accesos a disco** (lecturas).

- **Búsqueda secuencial**: O(N) lecturas promedio. Eficiente cuando se debe procesar o recorrer el 100% del archivo.
- **Acceso Directo (NRR)**: O(1) lecturas. Solo posible en registros de longitud fija.

#### 11.2 Búsqueda Binaria

Mejora exponencialmente las lecturas, reduciendo a **O(Log2 N)**.

- **Precondiciones**: El archivo debe estar **ordenado por la clave** y ser de **registros de longitud fija** (para acceder al medio inmediatamente).

#### 11.3 Clasificación (Ordenamiento)

Ordenar trae beneficios en búsquedas, pero tiene un costo alto:

1. **Pocos datos**: Cargar todo a memoria RAM y ordenar.
2. **Archivos medianos**: Cargar solo las claves a RAM.
3. **Grandes (Ordenamiento Externo / Merge)**: Se parte el archivo en trozos que entran a RAM, se ordenan y luego se hace un **Merge** para unirlos.

##### Sort interno y merge de K porciones

Si el archivo tiene N registros y la memoria principal admite P registros, se generan `K = N/P` particiones. Cada partición se ordena en memoria y se escribe a disco. Luego se hace un merge de las K particiones.

**Costo del merge**: para merge de K porciones con K buffers, se necesitan **K² desplazamientos** (lecturas + escrituras). Si se hace en un solo paso, la performance es **O(K²)**.

**Ejemplo**: archivo de 800.000 registros, 1 MB de memoria, registros de 100 bytes, claves de 10 bytes.
- Caben 10.000 registros en memoria → K = 80 particiones.
- Merge de 80 en un solo paso: 80² = **6.400 desplazamientos**.
- Alternativa: merge en dos pasos (10 grupos de 8 particiones):
  - Paso 1: 10 × 8² = 640 desplazamientos.
  - Paso 2: 10 × 80 = 800 desplazamientos.
  - **Total: 1.440 desplazamientos** (vs. 6.400).

##### Selección por reemplazo

Método para incrementar el tamaño de las particiones sin más memoria principal. En lugar de escribir una partición completa antes de empezar la siguiente, se reemplaza siempre el registro con la clave menor de memoria principal por uno nuevo del disco.

**Algoritmo**:
1. Leer desde disco tantos registros como quepan en memoria principal.
2. Iniciar una nueva partición.
3. Seleccionar la clave menor de memoria principal → transferir a la partición en disco.
4. Reemplazar por un registro leído desde disco. Si la clave del nuevo es menor que la del transferido, se marca como "no disponible" ("durmiente").
5. Repetir hasta que todos los registros estén no disponibles.
6. Iniciar nueva partición y repetir.

**Ejemplo** (memoria para 3 claves, 13 claves en disco: 34, 19, 25, 59, 15, 18, 8, 22, 68, 13, 6, 48, 17):

```
Paso 1: Cargar 34, 19, 25 → menor=19 → Partición 1: [19]
        Reemplazar 19 por 59 →内存: 34, 59(d), 25
Paso 2: menor=25 → Partición 1: [19, 25]
        Reemplazar 25 por 15 → 15(d), 34, 59(d)
Paso 3: menor=34 → Partición 1: [19, 25, 34]
        Reemplazar 34 por 18 → 15(d), 18, 59(d)
Paso 4: menor=18 → Partición 1: [19, 25, 34, 18]
        Reemplazar 18 por 8 → 15(d), 8, 59(d)
Paso 5: menor=8 → Partición 1: [19, 25, 34, 18, 8]
        Reemplazar 8 por 22 → 15(d), 22, 59(d)
Paso 6: menor=15 → Partición 1: [19, 25, 34, 18, 8, 15]
        Reemplazar 15 por 68 → 15(d), 22, 59(d), 68(d)
        ...y así sucesivamente
```

**Resultado**: en promedio, el método aumenta el tamaño de las particiones al **doble** de la cantidad de registros que caben en memoria principal (**2P**).

---

## PARTE IV: Mantenimiento y Eliminación de Registros (Bajas)

Se denomina **proceso de baja** a quitar información de un archivo. Existen dos modos de hacerlo:

### 12. Baja Física y Lógica

#### 12.1 Baja Física

Borra efectivamente la información, recuperando el espacio físico al instante. En archivos secuenciales tipados esto es inviable in-situ, por lo que **se efectúa copiando a un nuevo archivo** los registros válidos.

**Ventaja**: El archivo ocupa el espacio mínimo necesario.
**Desventaja**: Performance (hay que copiar todo el archivo). Requiere el doble de espacio durante el proceso.

**Variante — corrimientos (baja física in-situ)**: en lugar de copiar a un nuevo archivo, se pueden hacer **corrimientos** dentro del mismo archivo: al eliminar un registro, se desplazan todos los siguientes una posición hacia atrás. No requiere espacio extra pero en el peor caso (eliminar el primer registro) requiere N-1 escrituras.

```pascal
procedure BajaFisicaInSitu(var archivo: empleados);
var
  reg, siguiente: registro;
  posEliminar: integer;
begin
  reset(archivo);
  // Buscar el registro a eliminar
  while not eof(archivo) do
  begin
    read(archivo, reg);
    if reg.nombre = 'Carlos Garcia' then
    begin
      posEliminar := filepos(archivo) - 1;
      // Correr todos los registros siguientes una posición hacia atrás
      while not eof(archivo) do
      begin
        read(archivo, siguiente);
        seek(archivo, filepos(archivo) - 2);  // retroceder 2 (el leído + el eliminado)
        write(archivo, siguiente);
        seek(archivo, filepos(archivo) + 1);  // avanzar para seguir leyendo
      end;
      // Truncar el archivo en la posición actual (quitar el último registro duplicado)
      truncate(archivo);
      break;
    end;
  end;
  close(archivo);
end;
```

> **Importante**: `truncate(archivo)` coloca EOF en la posición actual del puntero, eliminando todo desde ahí. Es diferente a `close()`, que solo coloca EOF después del último registro válido (dejando el último duplicado).

**Análisis de performance**:
- **n lecturas** (siempre, para encontrar y recorrer).
- **n-1 escrituras en el peor caso** (si el elemento a borrar está en la primera posición).
- **Ventaja**: no se necesita capacidad adicional en disco.
- **Desventaja**: mucha actividad de E/S en el peor caso.

```pascal
procedure BajaFisica(var archivo: empleados);
var
  nuevo: empleados;
  reg: registro;
begin
  assign(nuevo, 'empleados_temp.dat');
  reset(archivo);
  rewrite(nuevo);
  while not eof(archivo) do
  begin
    read(archivo, reg);
    if reg.nombre <> 'Carlos Garcia' then
      write(nuevo, reg);
  end;
  close(archivo);
  close(nuevo);
  erase(archivo);
  rename(nuevo, 'empleados.dat');
end;
```

#### 12.2 Baja Lógica

Se marca el registro como "eliminado" cambiando algún campo, sin remover el resto del archivo físicamente. El espacio queda desperdiciado, causando fragmentación.

**Ventaja**: Rápida (solo una marca).
**Desventaja**: Fragmentación, pérdida de espacio.

```pascal
procedure BajaLogica(var archivo: empleados);
var
  reg: registro;
begin
  reset(archivo);
  while not eof(archivo) do
  begin
    read(archivo, reg);
    if reg.nombre = 'Carlos Garcia' then
    begin
      reg.nombre := '***';
      seek(archivo, filepos(archivo)-1);
      write(archivo, reg);
      break;
    end;
  end;
  close(archivo);
end;
```

#### 12.3 Comparación: baja física vs baja lógica

| Aspecto | Baja física | Baja lógica |
|:--------|:------------|:------------|
| **Espacio** | Recupera el espacio ocupado | No recupera espacio (fragmentación) |
| **Performance** | Más lenta (muchas reescrituras o copia completa) | Más eficiente (localizar + 1 escritura) |
| **Reversibilidad** | Irreversible | Se puede "reactivar" el registro |
| **Uso del espacio** | Archivo queda compacto | Archivo crece con registros muertos |
| **Complejidad** | Media (copia o corrimientos) | Baja (marcar un campo) |
| **Cuándo usar** | Cuando se necesita recuperar espacio o el archivo es poco modificable | Cuando se hacen muchas altas/bajas y se puede compactar periódicamente |

> **En la práctica**: se usa baja lógica para operación normal, y periódicamente se ejecuta un proceso de **compactación** (baja física de todos los registros marcados) para recuperar espacio.

### 13. Reutilización del espacio (Listas Invertidas)

Para reasignar el lugar vacío de una baja lógica **sin compactar el disco entero**, se utiliza el **registro cabecera** (NRR = 0, no guarda datos sino administración) apuntando a los lugares vacíos en cascada.

- En **registros de longitud fija**: Cualquiera cabe. Se arma una lista tipo PILA.
- En **registros de longitud variable**: El nuevo debe caber. Se aplican estrategias de colocación.

#### Algoritmo con lista invertida (longitud fija)

El registro cabecera (posición 0) contiene un enlace al primer registro libre. Cada registro libre contiene un enlace al siguiente libre. -1 indica fin de lista.

**Dar de alta**:
1. Leer el registro cabecera (posición 0)
2. Si `header.enlace = 0` (o -1) → no hay libres → `seek(filesize)` y escribir al final
3. Si hay libre → leer el registro libre apuntado, escribir el nuevo dato ahí, y actualizar el cabecera con el enlace del registro que se ocupó

```pascal
procedure AltaConReutilizacion(var archivo: empleados; nuevo_reg: registro);
var
  header, libre: registro;
begin
  reset(archivo);
  read(archivo, header);
  if (header.stock < 0) then
  begin
    seek(archivo, Abs(header.stock));
    read(archivo, libre);
    seek(archivo, Abs(header.stock));
    write(archivo, nuevo_reg);
    seek(archivo, 0);
    header.stock := libre.stock;
    write(archivo, header);
  end
  else
  begin
    seek(archivo, filesize(archivo));
    write(archivo, nuevo_reg);
  end;
  close(archivo);
end;
```

**Dar de baja (marca con enlace)**:
1. Leer cabecera
2. Pararse en el registro a eliminar, escribir el enlace del cabecera en el registro
3. Actualizar el cabecera con la posición del registro eliminado

### 14. Registros de Longitud Variable y Fragmentación

#### 14.1 Fragmentación

- **Interna**: ocurre cuando se desperdicia espacio dentro de un registro (se le asigna un bloque pero no lo ocupa totalmente). Generalmente ocurre con registros de longitud fija.
- **Externa**: ocurre cuando se desperdicia espacio entre registros. Generalmente ocurre con registros de longitud variable.

#### 14.2 Estrategias de colocación

Para reutilizar espacio libre con registros de longitud variable:

- **Primer ajuste**: selecciona la primera entrada de la lista de disponibles que pueda almacenar al registro. Minimiza la búsqueda. Genera fragmentación interna.
- **Mejor ajuste**: elige la entrada que más se aproxime al tamaño del registro. Exige búsqueda. Genera fragmentación interna.
- **Peor ajuste**: selecciona la entrada más grande y le asigna solo el espacio necesario. No genera fragmentación interna pero sí externa.

#### 14.3 Modificaciones con registros de longitud variable

- Si el registro se agranda → no cabe en el espacio original.
- Opciones:
  - Agregar los datos adicionales al final del archivo (con un vínculo al registro original)
  - Reescribir el registro completo al final del archivo (queda espacio vacío en el origen)
- **Solución estándar**: dividir en dos etapas: baja del registro viejo + alta del nuevo registro (siguiendo la política de recuperación de espacio).

#### 14.4 Ejemplo: archivo de empleados con longitud variable

Los registros de longitud variable se almacenan como **secuencia de caracteres** usando marcas de campo (`#`) y marca de fin de registro (`@`). Se utiliza un archivo sin tipo (`file`) y se leen/escriben bloques de bytes con `BlockWrite`/`BlockRead`.

```pascal
type
  archivo_empleados = file;  // sin tipo (secuencia de bytes)

procedure escribirEmpleado(var arch: archivo_empleados;
                           apellido, nombre, direccion, documento: string);
begin
  // Escribir cada campo como caracteres + marcador '#'
  BlockWrite(arch, apellido[1], length(apellido));
  BlockWrite(arch, '#', 1);
  BlockWrite(arch, nombre[1], length(nombre));
  BlockWrite(arch, '#', 1);
  BlockWrite(arch, direccion[1], length(direccion));
  BlockWrite(arch, '#', 1);
  BlockWrite(arch, documento[1], length(documento));
  BlockWrite(arch, '@', 1);  // marca de fin de registro
end;
```

Para **leer** un campo, se leen caracteres hasta encontrar `#`:

```pascal
procedure leerCampo(var arch: archivo_empleados; var campo: string);
var
  c: char;
begin
  campo := '';
  BlockRead(arch, c, 1);
  while (c <> '#') and (c <> '@') do
  begin
    campo := campo + c;
    BlockRead(arch, c, 1);
  end;
end;
```

**Diferencia con longitud fija**: con longitud fija, `read`/`write` transfieren un registro completo de tamaño conocido. Con longitud variable, se lee/escribe carácter a carácter y se usan marcas para delimitar campos y registros.

---

## PARTE V: Patrones y Algoritmos Clásicos

### 15. Agregar nuevos elementos al final

Para añadir registros sin modificar los existentes, se posiciona el puntero al final del archivo y luego se escriben los nuevos.

```pascal
procedure agregar(var emp: empleados);
var e: registro;
begin
  reset(emp);
  seek(emp, filesize(emp));
  writeln('Ingrese nombre (vacío para terminar): ');
  readln(e.nombre);
  while e.nombre <> '' do
  begin
    writeln('Ingrese dirección y salario: ');
    readln(e.direccion, e.salario);
    write(emp, e);
    writeln('Ingrese nombre: ');
    readln(e.nombre);
  end;
  close(emp);
end;
```

### 16. Actualización Maestro-Detalle

Este es uno de los algoritmos **más importantes** en el procesamiento de archivos. Se utiliza en sistemas de gestión, por ejemplo, para actualizar el stock de productos con las ventas diarias.

#### 16.1 Conceptos clave

- **Archivo maestro**: contiene la información principal (ej. productos, empleados, cuentas). Cada registro representa una entidad con su estado actual.
- **Archivo detalle**: contiene los movimientos o transacciones que modifican al maestro (ej. ventas, bajas, cambios).

**Precondiciones generales**:

1. Ambos archivos están ordenados por el mismo criterio (generalmente un código o clave primaria).
2. El detalle solo contiene referencias a registros que existen en el maestro (integridad referencial).
3. El maestro puede tener registros que no aparecen en el detalle.
4. El detalle puede tener uno o varios registros para la misma clave (dependiendo del caso).

> **Importante**: Analizar las precondiciones de cada caso particular. Los algoritmos deben tener en cuenta estas precondiciones, caso contrario determina la falla de su ejecución.

#### 16.2 Caso 1: un detalle, cada registro del maestro se modifica una vez

```pascal
var
  mae: maestro;
  det: detalle;
  regm: producto;
  regd: venta_prod;
begin
  assign(mae, 'maestro.dat');
  assign(det, 'detalle.dat');
  reset(mae);
  reset(det);

  while not eof(det) do
  begin
    read(mae, regm);
    read(det, regd);
    while (regm.cod <> regd.cod) do
      read(mae, regm);
    regm.stock := regm.stock - regd.cant_vendida;
    seek(mae, filepos(mae) - 1);
    write(mae, regm);
  end;
  close(det);
  close(mae);
end.
```

**Limitación**: Si el detalle tuviera dos registros con el mismo código, el segundo no se procesaría.

#### 16.3 Caso 2: un detalle, múltiples registros del detalle por maestro

Usamos corte de control sobre el detalle con centinela (`valoralto`).

```pascal
const valoralto = 'ZZZZ';

procedure leer(var archivo: detalle; var dato: venta_prod);
begin
  if not eof(archivo) then
    read(archivo, dato)
  else
    dato.cod := valoralto;
end;

var
  mae: maestro;
  det: detalle;
  regm: producto;
  regd: venta_prod;
  total: integer;
  aux: str4;
begin
  assign(mae, 'maestro');
  assign(det, 'detalle');
  reset(mae);
  reset(det);
  read(mae, regm);
  leer(det, regd);

  while (regd.cod <> valoralto) do
  begin
    aux := regd.cod;
    total := 0;
    while (aux = regd.cod) do
    begin
      total := total + regd.cant_vendida;
      leer(det, regd);
    end;
    while (regm.cod <> aux) do
      read(mae, regm);
    regm.stock := regm.stock - total;
    seek(mae, filepos(mae) - 1);
    write(mae, regm);
    if not eof(mae) then
      read(mae, regm);
  end;
  close(det);
  close(mae);
end.
```

**Puntos clave**:

- La rutina `leer` evita leer más allá del final del detalle.
- El bucle interno totaliza todos los registros con la misma clave.
- Después de actualizar, se lee el siguiente registro del maestro solo si no estamos al final.
- Este algoritmo funciona incluso si el detalle tiene una sola ocurrencia por clave.

#### 16.4 Caso 3: múltiples archivos de detalle

Cuando existen varios archivos detalle que deben aplicarse al mismo maestro, se usa un **minimizador**.

```pascal
procedure minimo(var r1, r2, r3: venta_prod; var min: venta_prod;
                 var d1, d2, d3: detalle);
begin
  if (r1.cod <= r2.cod) and (r1.cod <= r3.cod) then
  begin
    min := r1;
    leer(d1, r1);
  end
  else if (r2.cod <= r3.cod) then
  begin
    min := r2;
    leer(d2, r2);
  end
  else
  begin
    min := r3;
    leer(d3, r3);
  end;
end;
```

El bucle principal totaliza por clave usando `minimo`:

```pascal
begin
  assign(mae1, 'maestro');
  assign(det1, 'detalle1');
  assign(det2, 'detalle2');
  assign(det3, 'detalle3');
  reset(mae1); reset(det1); reset(det2); reset(det3);
  leer(det1, regd1); leer(det2, regd2); leer(det3, regd3);
  minimo(regd1, regd2, regd3, min);

  while (min.cod <> valoralto) do
  begin
    read(mae1, regm);
    while (regm.cod <> min.cod) do
      read(mae1, regm);
    while (regm.cod = min.cod) do
    begin
      regm.cant := regm.cant - min.cantvendida;
      minimo(regd1, regd2, regd3, min);
    end;
    seek(mae1, filepos(mae1)-1);
    write(mae1, regm);
  end;
end.
```

### 17. Corte de Control

#### 17.1 Concepto

El **corte de control** es una técnica que permite procesar un archivo ordenado por varios niveles (ej. provincia – ciudad – sucursal) y producir un reporte que muestra subtotales en cada cambio de nivel.

**Estructura típica de un reporte**:

```plaintext
Provincia: Buenos Aires
  Ciudad: La Plata
    Sucursal: Centro
      Vendedor 1: $1000
      Vendedor 2: $1500
    Total Sucursal: $2500
    Sucursal: Norte
      Vendedor 3: $800
    Total Sucursal: $800
  Total Ciudad: $3300
  Ciudad: Mar del Plata
    ...
Total Provincia: $...
Total Empresa: $...
```

**Precondición**: El archivo debe estar ordenado exactamente según los campos de corte, de lo contrario los resultados serán incorrectos.

#### 17.2 Algoritmo

```pascal
const valoralto = 'ZZZZ';

procedure leer(var a: archivo; var r: registro);
begin
  if not eof(a) then read(a, r)
  else r.provincia := valoralto;
end;

var
  a: archivo;
  reg: registro;
  totProv, totPart, totCiud: integer;
  prov_act, part_act, ciudad_act: string[10];
begin
  assign(a, 'censo.dat');
  reset(a);
  leer(a, reg);

  while reg.provincia <> valoralto do
  begin
    prov_act := reg.provincia;
    writeln('Provincia: ', prov_act);
    totProv := 0;
    while (reg.provincia = prov_act) do
    begin
      part_act := reg.partido;
      writeln('  Partido: ', part_act);
      totPart := 0;
      while (reg.provincia = prov_act) and (reg.partido = part_act) do
      begin
        ciudad_act := reg.ciudad;
        totCiud := 0;
        while (reg.provincia = prov_act) and (reg.partido = part_act)
              and (reg.ciudad = ciudad_act) do
        begin
          totCiud := totCiud + reg.cantidad;
          leer(a, reg);
        end;
        writeln('    Total Ciudad: ', totCiud);
        totPart := totPart + totCiud;
      end;
      writeln('  Total Partido: ', totPart);
      totProv := totProv + totPart;
    end;
    writeln('Total Provincia: ', totProv);
  end;
  close(a);
end.
```

**Observaciones**:

- Los bucles anidados reflejan la jerarquía de ordenamiento.
- Cada nivel acumula sus subtotales y los entrega al nivel superior.
- Es fundamental que el archivo esté ordenado exactamente según los campos de corte.

### 18. Merge (fusión) de archivos

El **merge** combina dos o más archivos con la misma estructura (y ordenados por la misma clave) en un único archivo también ordenado.

#### 18.1 Merge sin repetición (unión simple)

```pascal
const valoralto = 9999;
type
  alumno = record
    nombre: string[30];
    dni: string[10];
    direccion: string[30];
  end;
  detalle = file of alumno;

procedure leer(var archivo: detalle; var dato: alumno);
begin
  if not eof(archivo) then read(archivo, dato)
  else dato.nombre := valoralto;
end;

procedure minimo(var r1, r2, r3: alumno; var min: alumno;
                 var d1, d2, d3: detalle);
begin
  if (r1.nombre <= r2.nombre) and (r1.nombre <= r3.nombre) then begin
    min := r1; leer(d1, r1);
  end
  else if (r2.nombre <= r3.nombre) then begin
    min := r2; leer(d2, r2);
  end
  else begin
    min := r3; leer(d3, r3);
  end;
end;

var
  det1, det2, det3, maestro: detalle;
  r1, r2, r3, min: alumno;
begin
  assign(det1, 'det1'); assign(det2, 'det2'); assign(det3, 'det3');
  assign(maestro, 'maestro');
  rewrite(maestro);
  reset(det1); reset(det2); reset(det3);
  leer(det1, r1); leer(det2, r2); leer(det3, r3);
  minimo(r1, r2, r3, min, det1, det2, det3);

  while min.nombre <> valoralto do
  begin
    write(maestro, min);
    minimo(r1, r2, r3, min, det1, det2, det3);
  end;
  close(maestro);
  close(det1); close(det2); close(det3);
end.
```

#### 18.2 Merge con repetición (totalización)

```pascal
while min.codigo <> valoralto do
begin
  aux := min;
  total := 0;
  while (min.codigo = aux.codigo) do
  begin
    total := total + min.stock;
    minimo(d1, d2, d3, r1, r2, r3, min);
  end;
  aux.stock := total;
  write(maestro, aux);
end;
```

### 19. Merge con N archivos (vector de detalles)

Generalización para N archivos usando un vector de archivos detalle y un vector de registros.

```pascal
type
  arc_detalle = array[1..100] of file of vendedor;
  reg_detalle = array[1..100] of vendedor;

var
  deta: arc_detalle;
  reg_det: reg_detalle;
  i, n: integer;

procedure minimo(var reg_det: reg_detalle; var min: vendedor;
                 var deta: arc_detalle);
var i, pos: integer;
begin
  // buscar el mínimo entre reg_det[1..n]
  pos := 1;
  for i := 2 to n do
    if reg_det[i].cod < reg_det[pos].cod then
      pos := i;
  min := reg_det[pos];
  leer(deta[pos], reg_det[pos]);
end;

begin
  read(n);
  for i := 1 to n do begin
    assign(deta[i], 'detalle' + i);
    reset(deta[i]);
    leer(deta[i], reg_det[i]);
  end;
  assign(mae1, 'maestro');
  rewrite(mae1);
  minimo(reg_det, min, deta);

  while (min.cod <> valoralto) do
  begin
    regm.cod := min.cod;
    regm.total := 0;
    while (regm.cod = min.cod) do begin
      regm.total := regm.total + min.montoVenta;
      minimo(reg_det, min, deta);
    end;
    write(mae1, regm);
  end;
end.
```

---

## PARTE VI: Índices

### 20. Índices: concepto y tipos

Un **índice** es una estructura de datos adicional que permite agilizar el acceso a la información almacenada en un archivo. Funciona como el índice alfabético de un libro: primero se busca en el índice (estructura pequeña y ordenada), y de allí se obtiene la dirección directa al dato.

**Características**:
- Es otro archivo con registros de longitud fija.
- Su tamaño es considerablemente menor que el archivo original.
- Posibilita imponer orden en un archivo sin que realmente se reacomode.
- La búsqueda se realiza primero en el índice, de allí se obtiene la dirección efectiva del registro, y luego se accede directamente.

#### 20.1 Índice primario

Un **índice primario** relaciona la **clave primaria** del archivo de datos con la **dirección física** (NRR) de cada registro. Está ordenado por clave primaria.

```
Ejemplo: archivo de discos musicales
Clave primaria: Compañía + Código

Índice primario:
  Clave       → Dir. Reg.
  AME2323     → 248
  ARI2313     → 313
  BMG11       → 83
  RCA1313     → 275
  SON13       → 36
  SON15       → 118
  VIR1323     → 209
  VIR2310     → 161
  WAR23       → 15
```

**Operaciones sobre índice primario**:

- **Creación**: al crearse el archivo, se crea también el índice asociado, ambos vacíos.
- **Altas**: se agrega el registro al final del archivo de datos, y se inserta ordenadamente la nueva entrada en el índice.
- **Modificaciones**: si el registro modificado no cambia de longitud, el índice no se altera. Si cambia de longitud (se agranda), el registro debe reubicarse y la nueva posición debe actualizarse en el índice.
- **Bajas**: se elimina la entrada del índice. No tiene sentido recuperar espacio porque el índice debe mantenerse ordenado.

**Ventaja**: al ser de menor tamaño y tener registros de longitud fija, se pueden hacer búsquedas binarias en el índice → O(log₂ N) para encontrar cualquier registro.

#### 20.2 Índice para claves candidatas

Las **claves candidatas** son claves que no admiten repeticiones, similares a la primaria pero que no fueron seleccionadas como tal. Su tratamiento es similar al índice primario.

#### 20.3 Índices secundarios

**Motivación**: no es natural buscar por clave primaria; se busca por nombre, autor, etc. (claves secundarias que pueden contener valores repetidos).

Un **índice secundario** relaciona una clave secundaria con una o más claves primarias (porque varios registros pueden contener la misma clave secundaria).

```
Cadena de acceso:
  Clave secundaria → Índice secundario → Clave primaria → Índice primario → Dir. física

¿Por qué no tener la dirección física directamente?
  Si el registro cambia de lugar, solo debe actualizarse el índice primario.
  Los índices secundarios permanecen sin cambios.
  Si hay 1 índice primario y 4 secundarios, ante un cambio de posición solo se modifica 1.
```

**Ejemplo**: índice de grupos musicales:

```
Clave secundaria   → Clave(s) primaria(s)
A-ha              → SON15, VIR1323, WAR23
Cock Robin        → SON13
Eurythmics        → ARI2313
Genesis           → VIR2310
La Portuaria      → BMG11
REM               → RCA1313
Toto              → AME2323
```

**Operaciones sobre índice secundario**:

- **Creación**: ambos archivos (índice y de datos) vacíos.
- **Altas**: se inserta la entrada ordenadamente en el índice. Bajo costo si cabe en memoria principal.
- **Modificaciones**: si cambia la clave secundaria → reacomodar el índice. Si cambia otro campo → ningún cambio.
- **Bajas**: eliminar la referencia del índice primario y de todos los índices secundarios.

#### 20.4 Alternativas de organización de índices secundarios

**Organización 1 — Clave secundaria repetida**: almacena la misma clave secundaria en tantos registros como ocurrencias haya. Desventaja: mayor espacio, menor posibilidad de caber en memoria principal.

**Organización 2 — Arreglo de claves primarias**: cada registro contiene la clave secundaria más un arreglo de claves primarias. Ejemplo: `A-ha → [SON15, VIR1323, WAR23]`. Problema: elección del tamaño del arreglo (puede resultar insuficiente o generar fragmentación).

**Organización 3 — Lista invertida** (la más común): una lista de claves primarias asociada a cada clave secundaria. Usa **dos archivos**:

- **Archivo de claves secundarias**: NRR, clave secundaria, puntero (a la lista).
- **Archivo de listas invertidas**: NRR, clave primaria, enlace (al siguiente registro de la lista; -1 si es el último).

```
Archivo de claves secundarias:
  NRR  Clave        Puntero
  0    A-ha         → 0 (lista invertida)
  1    Cock Robin   → 3
  2    Eurythmics   → 4
  ...

Archivo de listas invertidas:
  NRR  Clave Primaria  Enlace
  0    SON15            → 1
  1    VIR1323          → 2
  2    WAR23            → -1
  3    SON13            → -1
  4    ARI2313          → -1
  ...
```

**Ventajas de la lista invertida**:
- El reacomodamiento se produce solo al agregar una nueva clave primaria.
- El índice es más pequeño, el reacomodamiento es menos costoso.
- Si se agregan o borran datos de una clave existente, solo se modifica la lista correspondiente.

**Desventaja**: mantener dos archivos por cada índice secundario puede resultar costoso si hay muchos índices.

#### 20.5 Índices selectivos

Incluyen solo claves asociadas a una parte de la información existente (aquellos datos de mayor interés de acceso). Actúan como filtro de acceso. Solo se deben considerar modificaciones vinculadas con los datos presentes en el índice.

---

> **Resumen de patrones**: Los 4 algoritmos fundamentales de la materia son:
> 1. **Maestro-Detalle** (con sus variantes: 1detalle, corte, N detalles)
> 2. **Merge** (con y sin repetición)
> 3. **Corte de Control** (jerarquías anidadas)
> 4. **Bajas** (física, lógica, lista invertida)

---

### Autoevaluación

1. Un archivo con registros de longitud variable: ¿puede estar ordenado? ¿debe tener delimitador?
2. La baja lógica: ¿requiere que el archivo esté ordenado? ¿se puede aplicar a long. fija y variable?
3. La baja física con compactación: ¿qué desventaja tiene respecto al espacio en disco?
4. ¿Qué precondiciones necesita el algoritmo maestro-detalle?
5. En el merge con repetición: ¿cómo se totalizan las claves repetidas?
6. ¿Qué es el NRR y para qué tipo de registros es aplicable?
7. Fragmentación interna vs externa: ¿cuál ocurre con long. fija y cuál con long. variable?
8. Primer ajuste, mejor ajuste, peor ajuste: ¿cuál minimiza la búsqueda? ¿cuál minimiza la fragmentación?

> **Ejercicio sugerido**: implementar los 4 patrones en Pascal: maestro-detalle (1 y N detalles), merge (con y sin repetición), corte de control (2 niveles), y bajas con lista invertida. Verificar el funcionamiento con archivos de prueba pequeños generados desde código.
>
> Todos comparten el patrón `leer` con valor_alto, el uso de `seek(filepos-1)` para actualizar in-situ, y la precondición fundamental de archivos **ordenados por clave**.
