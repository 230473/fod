
# Práctica 2: Archivos Secuenciales Ordenados - Algorítmica Clásica

Ejercicios de procesamiento de archivos ordenados mediante mezcla, compactación y actualización de archivos maestro-detalle.

---

## Ejercicio 1: Compactación de comisiones

Una empresa posee un archivo de ingresos por comisión.

**Datos del archivo de entrada:**

- Código de empleado
- Nombre
- Monto de la comisión

**Características:**

- Archivo ordenado por código de empleado
- Cada empleado puede aparecer múltiples veces
- Procesar en **un único recorrido**

**Resultado esperado:**
Generar nuevo archivo donde cada empleado aparece **una sola vez** con el total acumulado de comisiones.

> **Nota:** No se conoce a priori la cantidad de empleados

---

## Ejercicio 2: Actualización de stock con archivo detalle

Una tienda de productos de limpieza necesita actualizar su stock diariamente.

### Archivo maestro (productos)

| Campo | Descripción |
| ----- | ----------- |
| Código de producto | Identificador único |
| Nombre comercial | Nombre del producto |
| Precio de venta | Precio unitario |
| Stock actual | Cantidad disponible |
| Stock mínimo | Mínimo requerido |

### Archivo detalle (ventas diarias)

| Campo | Descripción |
| ----- | ----------- |
| Código de producto | Referencia |
| Cantidad vendida | Unidades vendidas |

### Opción a: Actualizar archivo maestro

- Ambos archivos están ordenados por código de producto
- Cada maestro puede ser actualizado por 0, 1 o más registros del detalle
- El detalle solo contiene códigos que existen en el maestro

### Opción b: Generar reporte de bajo stock (Ej. 2)

- Crear archivo `stock_minimo.txt`
- Incluir productos cuyo stock actual < stock mínimo

---

## Ejercicio 3: Actualización de alfabetización

Actualizar información de alfabetización a nivel provincial.

### Archivo maestro (provincia)

| Campo |
| ----- |
| Nombre de provincia |
| Cantidad de personas alfabetizadas |
| Total de encuestados |

### Archivos detalle (2 archivos de censo)

| Campo |
| ----- |
| Nombre de provincia |
| Código de localidad |
| Cantidad de personas alfabetizadas |
| Cantidad de encuestados |

**Requisitos:**

- Todos los archivos están ordenados por nombre de provincia
- Cada archivo detalle puede tener 0, 1 o más registros por provincia
- Actualizar el maestro con información de ambos detalles

> **Nota:** Procesar en un único recorrido de cada archivo

---

## Ejercicio 4: Actualización desde múltiples sucursales

Una cadena de venta de alimentos congelados tiene archivo maestro y 30 archivos detalles (uno por sucursal).

### Archivo maestro - Productos

| Campo |
| ----- |
| Código de producto |
| Nombre |
| Descripción |
| Stock disponible |
| Stock mínimo |
| Precio |

### Archivos detalle - Ventas por sucursal

| Campo |
| ----- |
| Código de producto |
| Cantidad vendida |

### Tareas - Ej. 4

1. **Actualizar maestro** desde los 30 detalles
2. **Generar informe** en texto con:
   - Productos con stock < stock mínimo
   - Nombre, descripción, stock y precio

**Análisis requerido:**

Evaluar alternativas para generar el informe:

| Opción | Ventajas | Desventajas |
| ------ | -------- | ----------- |
| Procedimiento separado | Lógica clara y reutilizable | Requiere 2 recorridos |
| En el mismo procedimiento | Un solo recorrido de datos | Lógica más compleja |

> **Nota:** Todos los archivos están ordenados por código de producto. Pueden haber 0, 1 o más registros por producto en cada detalle.

---

## Ejercicio 5: Consolidación de logs de red

Una LAN con 5 máquinas genera reportes semanales de sesiones de usuarios.

### Archivos detalle - Uno por máquina

| Campo |
| ----- |
| Código de usuario |
| Fecha |
| Tiempo de sesión |

### Archivo maestro a crear

| Campo |
| ----- |
| Código de usuario |
| Fecha |
| Tiempo total de sesiones |

**Características:**

- Cada detalle está ordenado por código de usuario y fecha
- Un usuario puede tener múltiples sesiones el mismo día (misma/diferentes máquinas)
- Consolidar tiempos totales por usuario y fecha

**Ubicación:** `/var/log`

> **Nota:** Cada archivo debe recorrerse una única vez

---

## Ejercicio 6: Sistema COVID provincial

El Ministerio de Salud necesita consolidar datos de 10 municipios.

### Archivos detalle - Uno por municipio

| Campo |
| ----- |
| Código de localidad |
| Código de cepa |
| Cantidad de casos activos |
| Cantidad de casos nuevos |
| Cantidad de casos recuperados |
| Cantidad de casos fallecidos |

### Archivo maestro - COVID

| Campo |
| ----- |
| Código de localidad |
| Nombre de localidad |
| Código de cepa |
| Nombre de cepa |
| Cantidad de casos activos |
| Cantidad de casos nuevos |
| Cantidad de casos recuperados |
| Cantidad de casos fallecidos |

### Criterio de actualización - COVID

| Campo | Operación |
| ----- | --------- |
| Casos fallecidos | **Sumar** valor del detalle |
| Casos recuperados | **Sumar** valor del detalle |
| Casos activos | **Reemplazar** con valor detalle |
| Casos nuevos | **Reemplazar** con valor detalle |

**Requisito adicional:**
Informar cantidad de localidades con más de 50 casos activos (actualizadas o no).

> **Nota:** Todos los archivos están ordenados por código de localidad y código de cepa

---

## Ejercicio 7: Actualización de desempeño académico

Una facultad mantiene archivos de alumnos y sus calificaciones.

### Archivo maestro - Estudiantes

| Campo |
| ----- |
| Código de alumno |
| Apellido |
| Nombre |
| Cantidad de cursadas aprobadas |
| Cantidad de finales aprobados |

### Archivo detalle - Cursadas

| Campo |
| ----- |
| Código de alumno |
| Código de materia |
| Año de cursada |
| Resultado (aprobado/desaprobado) |

### Archivo detalle - Exámenes finales

| Campo |
| ----- |
| Código de alumno |
| Código de materia |
| Fecha del examen |
| Nota obtenida |

### Reglas de actualización

- **Si cursada aprobada:** incrementar cursadas aprobadas en 1
- **Si final aprobado (nota ≥ 4):** incrementar finales aprobados en 1

**Características:**

- Un alumno puede cursar y rendir la misma materia múltiples veces
- No es necesario validar inconsistencias
- Procesar en **un único recorrido**

> **Nota:** Garantizado que no hay aprobaciones duplicadas de la misma cursada/final

---

## Ejercicio 8: Consumo de yerba mate por provincia

Gestionar consumo histórico de yerba mate a nivel provincial.

### Archivo maestro (provincias)

| Campo |
| ----- |
| Código de provincia |
| Nombre de provincia |
| Cantidad de habitantes |
| Total histórico de kilos consumidos |

### Archivos detalle (16 relevamientos mensuales)

| Campo |
| ----- |
| Código de provincia |
| Cantidad de kilos consumidos |

**Naturaleza de los datos:**

- Un detalle puede contener datos de 1 o varias provincias
- Una provincia puede aparecer 0, 1 o más veces en los detalles
- Todos los archivos ordenados por código de provincia

### Tareas - Ej. 8

1. **Actualizar maestro** con nueva información de consumo
2. **Generar informe** con:
   - Provincias cuya cantidad total histórica > 10.000 kilos
   - Código, nombre y promedio de consumo por habitante

> **Nota:** Cada archivo debe recorrerse una única vez

---

## Ejercicio 9: Reporte de ventas anuales por cliente

Generar reporte consolidado de ventas con desglose mensual.

### Archivo de entrada

| Campo | Orden |
| ----- | ----- |
| Código de cliente | 1° orden |
| Nombre cliente | |
| Apellido cliente | |
| Año | 2° orden |
| Mes | 3° orden |
| Día | |
| Monto venta | |

**Formato del reporte por pantalla:**

```text
Cliente: Código - Nombre Apellido

  Enero:  $XXXX
  Febrero: $XXXX
  ... (solo meses con compras)

  TOTAL CLIENTE: $XXXXX
```

**Reporte final:**

- Total general de ventas de la empresa

> **Nota:** No informar meses sin ventas del cliente

---

## Ejercicio 10: Conteo de votos por provincia y localidad

Generar reporte jerarquizado de votos.

| Campo |
| ----- |
| Código de provincia |
| Código de localidad |
| Número de mesa |
| Cantidad de votos |

### Formato del reporte

```text
Código de Provincia: XX
  Código de Localidad: YY  |  Total de Votos: ZZZZ
  Código de Localidad: YY  |  Total de Votos: ZZZZ

  Total de Votos Provincia XX: ZZZZZ

Código de Provincia: XX
  Código de Localidad: YY  |  Total de Votos: ZZZZ
  ...

Total General de Votos: ZZZZZZ
```

> **Nota:** El archivo está ordenado por código de provincia y código de localidad

---

## Ejercicio 11: Reporte de horas extras por departamento

Generar reporte jerárquico de gastos en horas extras.

### Archivo de entrada (Ej. 11)

| Campo | Orden |
| ----- | ----- |
| Departamento | 1° orden |
| División | 2° orden |
| Número de empleado | 3° orden |
| Categoría (1-15) | |
| Horas extras | |

### Tabla de valores

- Crear archivo de texto con valor de hora extra por categoría
- Formato: `categoría valor_hora`
- Cargar en arreglo al inicio (índice = categoría)

### Formato del reporte (Ej. 11)

```text
  DIVISIÓN 1
    Empleado 001 | 5 Hs. | $5000
    Empleado 002 | 3 Hs. | $3000

    Total División 1:     8 horas | $8000

  DIVISIÓN 2
    Empleado 003 | 2 Hs. | $2000

    Total División 2:     2 horas | $2000

  Total Departamento A:  10 horas | $10000

DEPARTAMENTO B
  ...
```

---

## Ejercicio 12: Informe de accesos a servidor web

Generar informe de accesos mensual/diario/usuario.

### Archivo de entrada (Ej. 12)

| Campo | Orden |
| ----- | ----- |
| Año | 1° orden |
| Mes | 2° orden |
| Día | 3° orden |
| ID Usuario | 4° orden |
| Tiempo de acceso | |

### Parámetros

- Año a informar: ingresado por teclado
- Si el año no existe: mostrar "año no encontrado"

### Formato del reporte (Ej. 12)

```text

  MES: 1
    DÍA: 1
      Usuario 001 | 125 segundos
      Usuario 002 | 340 segundos
      Total Día 1: 465 segundos

    DÍA: 2
      ...

    Total Mes 1: XXXXX segundos

  MES: 12
    ...

  Total Año 2024: XXXXXXXX segundos
```

**Requisitos:**

- Recorrido único del archivo
- Definir estructuras de datos
- Procesar solo información del año solicitado

---

## Ejercicio 13: Sistema de correo - Actualización y reportes

Administrar logs de servidor de correo y actualizaciones diarias.

### Archivo maestro - Logs de correo

| Campo |
| ----- |
| Número de usuario |
| Nombre de usuario |
| Nombre |
| Apellido |
| Cantidad de mails enviados |

### Archivo detalle - Correo diario

| Campo |
| ----- |
| Número de usuario |
| Cuenta destino |
| Cuerpo del mensaje |

**Características:**

- Ambos ordenados por número de usuario
- Un usuario puede enviar 0, 1 o más mails por día

### a) Actualizar log

Definir estructuras de datos y procedimiento para actualizar el archivo maestro con datos de un día específico.

### b) Generar informe diario

#### Opción i) - Procedimiento separado

Generar archivo de texto de la forma:

```text
Usuario 001 | 5 mensajes
Usuario 002 | 3 mensajes
...
Usuario XXX | N mensajes
```

**Análisis:**

- Incluir todos los usuarios del sistema
- Compararse con opción ii)

#### Opción ii) - Integrado en actualización

Generar el informe en el mismo procedimiento de actualización.

**Pregunta:** ¿Qué cambios se requieren en el procedimiento para realizar el informe en un único recorrido?

---

## Ejercicio 14: Actualización de vuelos y disponibilidad

Una compañía aérea gestiona vuelos y reservas.

### Archivo maestro - Vuelos

| Campo |
| ----- |
| Destino |
| Fecha |
| Hora de salida |
| Cantidad de asientos disponibles |

### Archivos detalle - Dos diarios, uno por turno

| Campo |
| ----- |
| Destino |
| Fecha |
| Hora de salida |
| Cantidad de asientos comprados |

### Opción a: Actualizar maestro

- Archivos ordenados por destino, fecha y hora
- Pueden haber 0, 1 o más registros detalle por vuelo maestro
- Garantizado: no hay venta sin asiento disponible

### Opción b: Generar reporte de bajo stock

- Solicitará cantidad mínima por teclado
- Listar vuelos con asientos disponibles < cantidad mínima
- Mostrar: destino, fecha y hora

> **Nota:** Los archivos solo pueden recorrerse una vez

---

## Ejercicio 15: Actualización - Localidades viviendas - ONG

Una ONG registra avances en asistencia habitacional.

### Archivo maestro (localidades)

| Campo |
| ----- |
| Código provincia |
| Nombre provincia |
| Código localidad |
| Nombre localidad |
| # Viviendas sin luz |
| # Viviendas sin gas |
| # Viviendas de chapa |

### Archivo detalle

| Campo |
| ----- |
| Código provincia |
| Código localidad |
| # Viviendas con luz (nuevas) |
| # Viviendas construidas |
| # Viviendas con agua (nuevas) |
| # Viviendas con gas (nuevas) |
| # Sanitarios entregados |

### Criterio de actualización

| Campo maestro | Operación |
| ------------- | --------- |
| Sin luz | **Restar** viviendas con luz del detalle |
| Sin agua | **Restar** viviendas con agua del detalle |
| Sin gas | **Restar** viviendas con gas del detalle |

| Sin sanitarios | **Restar** sanitarios del detalle |
| De chapa       | **Restar** viviendas construidas del detalle |

**Información adicional:**

- Cada provincia-localidad aparece máximo una vez
- Informar cantidad de localidades sin viviendas de chapa (actualizadas o no)

> **Nota:** Archivo ordenado por código de provincia y localidad

---

## Ejercicio 16: Actualización de ventas de semanarios

Editorial X gestiona múltiples semanarios.

### Archivo maestro

| Campo |
| ----- |
| Fecha |
| Código de semanario |
| Nombre de semanario |

### Archivo detalle (Ej. 16)

| Campo |
| ----- |
| Fecha |
| Código de semanario |
| Cantidad de ejemplares vendidos |

### Tareas - Ej. 16

1. Actualizar maestro con información de ventas
2. Informar:
   - Semanario con más ventas (fecha y código)
   - Semanario con menos ventas (fecha y código)

> **Nota:** Archivos ordenados por fecha y código de semanario. Sin ventas si no hay ejemplares.

---

## Ejercicio 17: Actualización de stock de motos

Concesionaria de Chascomús actualiza ventas mensuales.

### Archivo maestro (Ej. 17)

| Campo |
| ----- |
| Código |
| Nombre |
| Precio |

### Archivo detalle (Ej. 17)

| Campo           |
| --------------- |
| Código de moto  |
| Precio          |
| Fecha de venta  |

### Tareas - Ej. 17

1. Actualizar stock desde los 10 detalles
2. Informar moto más vendida

> **Nota:** Archivos ordenados por código de moto. Recorrido único y simultáneo de maestro y detalles.

---

## Ejercicio 18: Reporte de COVID por hospital

Consolidar reportes de casos COVID a nivel hospitalario.

### Archivo de entrada (Ej. 18)

| Campo | Orden |
| ----- | ----- |
| Código de localidad | 1° orden |
| Nombre de localidad | |
| Código de municipio | 2° orden |
| Nombre de municipio | |

### Formato del reporte (Ej. 18)

```text
  MUNICIPIO: Centro
    Hospital San Martín..................... 45 casos
    Hospital Rivadavia...................... 23 casos
    Total Municipio Centro: 68 casos

  MUNICIPIO: Sur
    Hospital de Emergencias................ 12 casos
    Total Municipio Sur: 12 casos

  Total Localidad Capital Federal: 80 casos

LOCALIDAD: La Plata
  ...

Total Casos Provincia de Buenos Aires: XXXXX casos
```

> **Nota:** Definir estructuras de datos adecuadas

Además del informe en pantalla anterior, es necesario exportar a un archivo de texto la siguiente información: nombre de localidad, nombre de municipio y cantidad de casos del municipio, para aquellos municipios cuya cantidad de casos supere los 1500. El formato del archivo de texto deberá ser el adecuado para recuperar la información con la menor cantidad de lecturas posibles.

**NOTA:** El archivo debe recorrerse solo una vez.

---

### 19

A partir de un siniestro ocurrido se perdieron las actas de nacimiento y fallecimientos de toda la provincia de buenos aires de los últimos diez años. En pos de recuperar dicha información, se deberá procesar 2 archivos por cada una de las 50 delegaciones distribuidas en la provincia, un archivo de nacimientos y otro de fallecimientos y crear el archivo maestro reuniendo dicha información.

Los archivos detalles con nacimientos, contendrán la siguiente información: nro partida nacimiento, nombre, apellido, dirección detallada (calle, nro, piso, depto, ciudad), matrícula del médico, nombre y apellido de la madre, DNI madre, nombre y apellido del padre, DNI del padre.

En cambio, los 50 archivos de fallecimientos tendrán: nro partida nacimiento, DNI, nombre y apellido del fallecido, matrícula del médico que firma el deceso, fecha y hora del deceso y lugar.

Realizar un programa que cree el archivo maestro a partir de toda la información de los archivos detalles. Se debe almacenar en el maestro: nro partida nacimiento, nombre, apellido, dirección detallada (calle, nro, piso, depto, ciudad), matrícula del médico, nombre y apellido de la madre, DNI madre, nombre y apellido del padre, DNI del padre y si falleció, además matrícula del médico que firma el deceso, fecha y hora del deceso y lugar. Se deberá, además, listar en un archivo de texto la información recolectada de cada persona.

**Nota:** Todos los archivos están ordenados por nro partida de nacimiento que es única. Tenga en cuenta que no necesariamente va a fallecer en el distrito donde nació la persona y además puede no haber fallecido.

---

> **IMPORTANTE:** Se recomienda implementar los ejercicios prácticos en Dev-Pascal. El ejecutable puede descargarse desde la plataforma moodle.
