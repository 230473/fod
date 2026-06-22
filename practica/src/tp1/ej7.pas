// 7. Realizar un programa que permita:
// a) Crear un archivo binario a partir de la informacion almacenada en un archivo de texto. El
// nombre del archivo de texto es: "novelas.txt". La informacion en el archivo de texto
// consiste en: codigo de novela, nombre, genero y precio de diferentes novelas argentinas.
// Los datos de cada novela se almacenan en dos lineas en el archivo de texto. La primera
// linea contiene: codigo novela, precio y genero, y la segunda linea almacena el nombre.
// b) Abrir el archivo binario y permitir la actualizacion del mismo. Se debe poder agregar una
// novela y modificar una existente. Las busquedas se realizan por codigo de novela.
// NOTA: El nombre del archivo binario es proporcionado por el usuario desde el teclado.

program ej7;

type
    cadena = string[50];

    novela = record
        codigo: integer;
        nombre: cadena;
        genero: cadena;
        precio: real;
    end;

    archivo_novelas = file of novela;

function leerNovelaDesdeTexto(var tf: Text): novela;
var
    n: novela;
begin
    readln(tf, n.codigo, n.precio, n.genero);
    readln(tf, n.nombre);
    leerNovelaDesdeTexto:= n;
end;

procedure mostrarNovela(n: novela);
begin
    writeln('Codigo: ', n.codigo, ' | Nombre: ', n.nombre, ' | Genero: ', n.genero, ' | Precio: ', n.precio:0:2);
end;

function buscarPosicionPorCodigo(var bf: archivo_novelas; codigo_buscado: integer): integer;
var
    n: novela;
begin
    seek(bf, 0);
    buscarPosicionPorCodigo:= -1;

    while not eof(bf) do begin
        read(bf, n);
        if n.codigo = codigo_buscado then begin
            buscarPosicionPorCodigo:= filepos(bf) - 1;
            exit;
        end;
    end;
end;

function leerNovelaDesdeConsola(codigo_forzado: integer): novela;
var
    n: novela;
begin
    n.codigo:= codigo_forzado;
    writeln('Ingrese nombre: ');
    readln(n.nombre);
    writeln('Ingrese genero: ');
    readln(n.genero);
    writeln('Ingrese precio: ');
    readln(n.precio);
    leerNovelaDesdeConsola:= n;
end;

procedure crearDesdeTexto(var bf: archivo_novelas);
var
    tf: Text;
    n: novela;
begin
    assign(tf, 'novelas.txt');
    reset(tf);
    rewrite(bf);

    while not eof(tf) do begin
        n:= leerNovelaDesdeTexto(tf);
        write(bf, n);
    end;

    close(tf);
    close(bf);
    reset(bf);
end;

procedure agregarNovela(var bf: archivo_novelas);
var
    codigo_nuevo: integer;
    n: novela;
begin
    writeln('Ingrese codigo de la nueva novela: ');
    readln(codigo_nuevo);

    if buscarPosicionPorCodigo(bf, codigo_nuevo) <> -1 then begin
        writeln('Ya existe una novela con ese codigo.');
        exit;
    end;

    n:= leerNovelaDesdeConsola(codigo_nuevo);
    seek(bf, filesize(bf));
    write(bf, n);
    writeln('Novela agregada.');
end;

procedure modificarNovela(var bf: archivo_novelas);
var
    codigo_buscado: integer;
    posicion: integer;
    actualizada: novela;
begin
    writeln('Ingrese codigo de la novela a modificar: ');
    readln(codigo_buscado);

    posicion:= buscarPosicionPorCodigo(bf, codigo_buscado);
    if posicion = -1 then begin
        writeln('Novela no encontrada.');
        exit;
    end;

    actualizada:= leerNovelaDesdeConsola(codigo_buscado);
    seek(bf, posicion);
    write(bf, actualizada);
    writeln('Novela modificada.');
end;

procedure listarNovelas(var bf: archivo_novelas);
var
    n: novela;
begin
    seek(bf, 0);
    writeln('--- NOVELAS ---');
    while not eof(bf) do begin
        read(bf, n);
        mostrarNovela(n);
    end;
end;

var
    bf: archivo_novelas;
    nombre_archivo_binario: cadena;
    opcion_inicio: integer;
    opcion: integer;
begin
    writeln('Nombre del archivo binario de novelas:');
    readln(nombre_archivo_binario);
    assign(bf, nombre_archivo_binario);

    writeln('1. Crear archivo desde novelas.txt');
    writeln('2. Abrir archivo existente');
    writeln('Opcion inicio: ');
    readln(opcion_inicio);

    if opcion_inicio = 1 then begin
        crearDesdeTexto(bf);
        writeln('Archivo creado desde novelas.txt');
    end
    else begin
        reset(bf);
        writeln('Archivo existente abierto.');
    end;

    repeat
        writeln('');
        writeln('--- MENU NOVELAS ---');
        writeln('1. Agregar novela');
        writeln('2. Modificar novela');
        writeln('3. Listar novelas');
        writeln('4. Salir');
        writeln('Opcion: ');
        readln(opcion);

        case opcion of
            1: agregarNovela(bf);
            2: modificarNovela(bf);
            3: listarNovelas(bf);
            4: writeln('Fin del programa.');
        else
            writeln('Opcion invalida.');
        end;
    until opcion = 4;

    close(bf);
end.
