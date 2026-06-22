{2. Una mejora respecto a la solucion propuesta en el ejercicio 1 seria mantener por un
lado el archivo que contiene la informacion de los alumnos (archivo de datos no
ordenado) y por otro lado mantener un indice al archivo de datos que se estructura
como un arbol B que ofrece acceso indizado por DNI.
a. Defina en Pascal las estructuras de datos correspondientes para el archivo de
alumnos y su indice.
b. Suponga que cada nodo del arbol B cuenta con un tamano de 512 bytes. Cual
seria el orden M? Asuma que los numeros enteros ocupan 4 bytes. Considere que
en cada nodo se deben almacenar los M-1 enlaces a los registros en el archivo
de datos.
c. Que implica que el orden del arbol B sea mayor que en el caso del ejercicio 1?
d. Describa el proceso para buscar el alumno con DNI 12345678 usando el indice.
e. Que ocurre si desea buscar un alumno por su numero de legajo? Tiene sentido
usar el indice por DNI? Como brindaria acceso indizado por legajo?
f. Que problemas tiene la busqueda por rango de DNI entre 40000000 y 45000000
con apoyo de un arbol B?}

//A
const
    M = .. //Orden del arbol (indice)
type
    alumno = record
        nombre: string;
        apellido: string;
        dni: integer;
        legajo: integer;
        anioIngreso: integer;
    end;
    nodo = record
        cant_claves: integer;
        claves: array[1..M-1] of longint;
        enlaces: array[1..M-1] of integer;
        hijos: array[1..M] of integer;
    end;
    TArchivoDatos = file of alumno;
    arbolB = file of nodo;
var
    archivoDatos: TArchivoDatos;
    archivoIndice: arbolB;

{B. N = (M-1) * 4 + (M-1) * 4 + M * 4 + 4
    512 = 4M - 4 + 4M - 4 + 4M + 4
    512 = 12M - 4
    512 + 4 = 12M
    516 / 12 = M
    M = 43

El orden del arbol B indice es de 43.}

{C. Incrementar el orden del arbol B significa aumentar la cantidad de entradas
de indice que caben en un nodo. En consecuencia, el arbol es menos profundo
y se requieren menos accesos (lecturas) a los nodos para encontrar una clave.}

{D. Se busca en el arbol del indice la clave con DNI 12345678, aprovechando el
criterio de orden, moviendose a la izquierda si es menor o igual, y a la
derecha en caso contrario. Una vez hallada la clave, se usa el NRR guardado
en el enlace para leer el registro completo desde el archivo de datos.}

{E. Si se desea buscar por legajo, se deberia realizar una busqueda secuencial
sobre el archivo de datos. No tiene sentido usar el indice por DNI. Para
brindar acceso indizado por legajo, lo mas conveniente seria armar otro
arbol B con criterio de orden en base al numero de legajo.}

{F. Para buscar DNI entre 40000000 y 45000000, un arbol B permite encontrar
rapidamente el primer DNI del rango, pero para obtener los siguientes es
necesario navegar el arbol subiendo y bajando, ya que no hay enlaces
entre nodos hojas. Esto requiere multiples lecturas de nodos internos
y no es eficiente para recorridos por rango.}
