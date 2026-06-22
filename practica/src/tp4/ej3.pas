{3. Los arboles B+ representan una mejora sobre los arboles B dado que conservan la
propiedad de acceso indexado pero permiten ademas un recorrido secuencial rapido.
Al igual que en el ejercicio 2, considere que por un lado se tiene el archivo de
alumnos (archivo de datos no ordenado) y por otro lado se tiene un indice al archivo
de datos, pero en este caso el indice se estructura como un arbol B+ que ofrece
acceso indizado por DNI. Resuelva:
a. Como se organizan los elementos (claves) de un arbol B+? Que elementos se
encuentran en los nodos internos y que en los nodos hojas?
b. Que caracteristica distintiva presentan los nodos hojas de un arbol B+? Por que?
c. Defina en Pascal las estructuras de datos correspondientes para el archivo de
alumnos y su indice (arbol B+). Por simplicidad, todos los nodos del mismo tamano.
d. Describa el proceso de busqueda de un alumno con un DNI especifico usando el
indice B+. Que diferencia encuentra respecto a la busqueda en un arbol B?
e. Explique el proceso de busqueda por rango de DNI entre 40000000 y 45000000
apoyandose en un arbol B+. Que ventajas respecto a un arbol B?}

{A. Todas las claves se encuentran unicamente en los nodos hojas. Los nodos
internos contienen claves que se utilizan para dirigir la busqueda hacia
el nodo hoja correspondiente (claves de separacion).}

{B. Los nodos hoja contienen todas las claves del arbol B+ y un enlace adicional
que apunta al siguiente nodo hoja en orden ascendente. Esto permite un
recorrido secuencial rapido sobre las claves.}

//C
const
    M = .. //Orden del arbol B+
type
    alumno = record
        nombre: string;
        apellido: string;
        dni: integer;
        legajo: integer;
        anioIngreso: integer;
    end;
    TArchivoDatos = file of alumno;
    nodo = record
        cant_claves: integer;
        claves: array[1..M-1] of longint;
        enlaces: array[1..M-1] of integer;
        hijos: array[1..M] of integer;
        sig: integer;
    end;
    arbolB = file of nodo;
var
    archivoDatos: TArchivoDatos;
    archivoIndice: arbolB;

{D. El proceso de busqueda consiste en aprovechar el criterio de orden y los
separadores de los nodos internos hasta encontrar el dato en una hoja.
Diferencia con B: en B la busqueda puede terminar en cualquier nivel si la
clave esta en un nodo interno, mientras que en B+ siempre se llega a una
hoja porque las claves solo estan alli.}

{E. En B+, para buscar DNI entre 40000000 y 45000000 se busca el limite
inferior hasta llegar a la hoja correspondiente, y luego se recorren las
hojas secuencialmente mediante el puntero sig hasta superar el limite
superior. Ventaja respecto a B: solo se leen las hojas involucradas, sin
necesidad de volver a nodos internos.}
