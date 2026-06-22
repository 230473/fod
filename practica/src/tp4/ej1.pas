{1. Considere que desea almacenar en un archivo la informacion correspondiente a los
alumnos de la Facultad de Informatica de la UNLP. De los mismos debera guardarse
nombre y apellido, DNI, legajo y anio de ingreso. Suponga que dicho archivo se organiza
como un arbol B de orden M.
a. Defina en Pascal las estructuras de datos necesarias para organizar el archivo de
alumnos como un arbol B de orden M.
b. Suponga que la estructura de datos que representa a un alumno ocupa 64 bytes,
que cada nodo del arbol B tiene un tamano de 512 bytes y que los numeros enteros
ocupan 4 bytes. Cuantos registros de alumno entrarian en un nodo? Cual seria el
orden M? Utilice N = (M-1) * A + M * B + C donde A=tamano registro, B=tamano
enlace a hijo, C=campo de cantidad de claves.
c. Que impacto tiene sobre el valor de M organizar el archivo con toda la informacion?
d. Que dato seleccionaria como clave de identificacion? Hay mas de una opcion?
e. Describa el proceso de busqueda de un alumno por el criterio de ordenamiento
especificado en el punto previo. Cuantas lecturas se necesitan en el mejor y peor
caso?
f. Que ocurre si desea buscar por un criterio diferente?}

//A.
const
    M = .. //Orden del arbol
type
    alumno = record
        nombre: string;
        apellido: string;
        dni: integer;
        legajo: integer;
        anioIngreso: integer;
    end;
    nodo = record
        cant_datos: integer;
        datos: array[1..M-1] of alumno;
        hijos: array[1..M] of integer;
    end;
    arbolB = file of nodo;
var
    archivoDatos: arbolB;

{B. N = (M-1) * A + M * B + C
    512 = (M-1) * 64 + M * 4 + 4
    512 = 64M - 64 + 4M + 4
    512 + 64 - 4 = 68M
    572 / 68 = M
    M = 8.4

En un nodo del arbol B entrarian 7 registros de alumno, al ser M = 8.}

{C. El valor de M determina la cantidad maxima de claves y de hijos que puede tener
un nodo. Un valor mayor de M resultara en nodos mas grandes y en una estructura
mas ancha y menos profunda. Un valor menor de M resultara en nodos mas
pequenos y una estructura mas profunda pero mas estrecha.}

{D. Seleccionaria tanto el DNI como el legajo como claves de identificacion,
ya que ambos son campos unicos de cada alumno de la Facultad.}

{E. En el mejor de los casos se necesita una unica lectura para encontrar un alumno
por su clave de identificacion. En el peor de los casos se necesitan h lecturas,
con h la altura del arbol.}

{F. Si se desea buscar un alumno por un criterio diferente se debe recorrer el arbol
por completo, siendo necesarias n lecturas en el peor de los casos, siendo n la
cantidad total de nodos del arbol.}
