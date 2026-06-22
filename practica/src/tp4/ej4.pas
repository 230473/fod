{4. Dado el siguiente algoritmo de busqueda en un arbol B:
procedure buscar(NRR, clave, NRR_encontrado, pos_encontrada, resultado)
var
    clave_encontrada: boolean;
begin
    if (nodo = null)
        resultado := false //clave no encontrada
    else
        begin
            posicionarYLeerNodo(A, nodo, NRR);
            claveEncontrada(A, nodo, clave, pos, clave_encontrada);
            if (clave_encontrada) then begin
                NRR_encontrado := NRR;  //NRR actual
                pos_encontrada := pos;  //posicion dentro del array
                resultado := true;
            end
            else
                buscar(nodo.hijos[pos], clave, NRR_encontrado, pos_encontrada, resultado)
        end;
end;

a. PosicionarYLeerNodo: que hace y como deben enviarse los parametros?
   Implemente el modulo en Pascal.
b. claveEncontrada: que hace y como deben enviarse los parametros?
   Como lo implementaria?
c. Existe algun error en el codigo? Modifique lo necesario.
d. Que cambios son necesarios para que funcione en un arbol B+?}

{A. posicionarYLeerNodo(A, nodo, NRR) es un procedimiento que se posiciona en
un NRR dentro del archivo y lee el nodo. NRR debe pasarse por valor, mientras
que el archivo A y la variable nodo deben pasarse por referencia porque se
modifican.}

//Implementacion
procedure posicionarYLeerNodo(var A: arbolB; var nodo: nodo; NRR: integer);
begin
    seek(A, NRR);
    read(A, nodo);
end;

{B. claveEncontrada() verifica si una clave esta en el nodo actual. Si la
encuentra, almacena la posicion y devuelve true. Si no, devuelve false y
almacena en pos la posicion del hijo por donde continuar. La clave se
pasa por valor; pos y clave_encontrada por referencia; A y nodo tambien
por referencia.}

//Implementacion
procedure claveEncontrada(var A: arbolB; nodo: nodo; clave: longint; var pos: integer; var encontrada: boolean);
var
    i: integer;
begin
    encontrada := false;
    for i := 1 to nodo.cant_claves do
        if nodo.claves[i] = clave then begin
            encontrada := true;
            pos := i;
            exit;
        end
        else if nodo.claves[i] > clave then begin
            pos := i;
            exit;
        end;
    pos := nodo.cant_claves + 1;
end;

{C. Errores del codigo original:
1. La variable 'nodo' y 'pos' no estan declaradas.
2. 'if (nodo = null)' se evalua antes de leer el nodo.
3. 'A' no esta declarado como parametro.
4. No se verifica si el hijo es valido (-1) antes de la recursion.

Version corregida:}

function buscar(NRR: integer; clave: longint; var A: arbolB; var pos_encontrada: integer; var NRR_encontrado: integer): boolean;
var
    nodo_actual: nodo;
    pos: integer;
    encontrada: boolean;
begin
    if (NRR < 0) then begin
        buscar := false;
        exit;
    end;
    posicionarYLeerNodo(A, nodo_actual, NRR);
    claveEncontrada(A, nodo_actual, clave, pos, encontrada);
    if encontrada then begin
        pos_encontrada := pos;
        NRR_encontrado := NRR;
        buscar := true;
    end
    else if (nodo_actual.hijos[pos] >= 0) then
        buscar := buscar(nodo_actual.hijos[pos], clave, A, pos_encontrada, NRR_encontrado)
    else
        buscar := false;
end;

{D. Para B+, la busqueda debe continuar hasta llegar a una hoja, sin verificar
la existencia de la clave en nodos internos aunque coincida con un separador.}
