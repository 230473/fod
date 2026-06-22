# Práctica 1: Archivos Binarios

## Ejercicio 1: Crear archivo de números enteros

Realizar un algoritmo que cree un archivo binario de números enteros no ordenados.

**Requisitos:**

- Permitir incorporar datos desde el teclado
- Finalizar la carga cuando se ingresa 30000 (no incluir este valor)
- Solicitar el nombre del archivo al usuario

---

## Ejercicio 2: Procesar archivo de números

Utilizar el archivo creado en el ejercicio 1 para generar un informe.

**Requisitos:**

- Procesar el archivo en **un único recorrido**
- Reportar la cantidad de números menores a 15000
- Calcular el promedio de todos los números
- Listar el contenido completo del archivo en pantalla
- Solicitar el nombre del archivo una única vez

---

## Ejercicio 3: Sistema de administración de empleados (Básico)

Realizar un programa con menú que permita:

### a) Crear archivo binario de empleados

**Datos por empleado:**

- Número de empleado
- Apellido
- Nombre  
- Edad
- DNI (puede ser 0 si no está disponible)

**Criterios:**

- Finalizar carga cuando se ingresa "fin" como apellido
- Crear archivo binario sin ordenar

### b) Consultas sobre el archivo

| Opción | Descripción |
| ------ | ----------- |
| i) | Buscar empleados por nombre o apellido (ingresado por teclado) |
| ii) | Listar todos los empleados (uno por línea) |
| iii) | Listar empleados mayores de 70 años |

> **Nota:** El usuario debe proporcionar el nombre del archivo a crear/utilizar

---

## Ejercicio 4: Sistema de administración de empleados (Extendido)

Agregar al programa del ejercicio 3 las siguientes opciones:

### a) Añadir empleados

- Insertar uno o más empleados al final del archivo
- **Control de unicidad:** Validar que no existe otro empleado con el mismo número ✓
- Datos ingresados por teclado

### b) Modificar datos

- Actualizar la edad de un empleado existente

### c) Exportar a texto

- Generar archivo `todos_empleados.txt` con todo el contenido del archivo binario

### d) Reporte de DNI faltantes

- Crear archivo `faltaDNIEmpleado.txt`
- Incluir empleados sin DNI registrado (DNI = 0)

> **Nota:** Todas las búsquedas se realizan por número de empleado

---

## Ejercicio 5: Sistema de tienda de celulares (Básico)

Realizar un programa con menú para gestionar inventario de celulares.

### a) Crear archivo y cargar datos

**Datos del celular:**

- Código de celular
- Nombre
- Descripción
- Marca
- Precio
- Stock mínimo
- Stock disponible

**Entrada:** Archivo de texto `celulares.txt` (formato especificado en Nota 2)

### b) Listado de bajo stock

Mostrar celulares cuyo stock disponible sea menor que el stock mínimo

### c) Búsqueda por descripción

Listar celulares cuya descripción contenga una cadena ingresada por el usuario

### d) Exportar a texto

- Generar archivo `celulares.txt`
- Incluir todos los celulares del archivo binario
- Respetar el formato de entrada (para permitir recarga futura)

**Formato del archivo de texto:**

El archivo debe editarse de manera que cada celular ocupe 3 líneas consecutivas:

```text
Línea 1: código precio marca
Línea 2: stock_disponible stock_mínimo descripción
Línea 3: nombre
```

**Ejemplo:**

```text
101 250000 Samsung
15 5 Galaxy A15 128GB
Galaxy A15

102 320000 Motorola
3 6 Moto G84 256GB color azul
Moto G84

104 950000 Apple
2 4 iPhone 15 256GB negro
iPhone 15
```

> **Nota 1:** El usuario debe proporcionar el nombre del archivo binario  
> **Nota 2:** Cargar leyendo exactamente 3 líneas por celular

---

## Ejercicio 6: Sistema de tienda de celulares (Extendido)

Agregar al programa del ejercicio 5 las siguientes opciones:

### a) Añadir celulares

- Insertar uno o más celulares al final del archivo
- Datos ingresados por teclado

### b) Modificar stock

- Actualizar el stock de un celular existente

### c) Reporte de falta de stock

- Crear archivo `SinStock.txt`
- Incluir todos los celulares con stock = 0

> **Nota:** Las búsquedas se realizan por nombre de celular

---

## Ejercicio 7: Sistema de novelas argentinas

Realizar un programa que permita:

### a) Crear archivo binario desde texto

**Entrada:** Archivo `novelas.txt` con información de novelas argentinas

**Datos:**

- Código de novela
- Nombre
- Género
- Precio

**Formato:** Cada novela ocupa 2 líneas

- Línea 1: código precio género
- Línea 2: nombre

### b) Mantenimiento del archivo

- **Agregar:** Insertar nueva novela
- **Modificar:** Actualizar novela existente

**Búsquedas:** Realizar por código de novela

> **Nota:** El usuario proporciona el nombre del archivo binario desde teclado
