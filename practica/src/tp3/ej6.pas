{
  Parte 1 - Ejercicio 6
  Se cuenta con un archivo que almacena información sobre especies de aves en peligro
  de extinción. De cada especie se registran: código, nombre de la especie, familia,
  descripción y zona geográfica. El archivo no se encuentra ordenado por ningún criterio.

  Se desea desarrollar un programa que permita eliminar especies de aves extintas.
  El programa deberá contar con dos procedimientos:

  1. Un procedimiento que, dado el código de una especie, la marque como borrada
     (baja lógica). Este procedimiento podrá invocarse repetidamente.

  2. Un procedimiento que realice la compactación del archivo (baja física), eliminando
     definitivamente aquellas especies marcadas como borradas. Para ello, cada vez que
     se elimine un registro, se deberá reemplazar su posición con el último registro del
     archivo y luego eliminar dicho último registro, evitando así dejar espacios vacíos y
     registros duplicados.

  Implemente además una variante de este procedimiento de compactación en la cual
  el archivo sea truncado una única vez al finalizar el proceso.
}

program ej6;

const
    VALOR_ALTO = 999999;

type
    ave = record
        codigo: integer;
        nombre: string[40];
        familia: string[30];
        descripcion: string[60];
        zona: string[30];
    end;

    archivo_aves = file of ave;

procedure leerAve(var a: ave);
begin
    write('Ingrese codigo (-1 para terminar): '); readln(a.codigo);
    if a.codigo <> -1 then begin
        write('Ingrese nombre: '); readln(a.nombre);
        write('Ingrese familia: '); readln(a.familia);
        write('Ingrese descripcion: '); readln(a.descripcion);
        write('Ingrese zona geografica: '); readln(a.zona);
    end;
end;

procedure imprimirAve(a: ave);
begin
    writeln('Codigo: ', a.codigo, ' | Nombre: ', a.nombre, ' | Familia: ', a.familia);
    writeln('  Zona: ', a.zona, ' | Desc: ', a.descripcion);
end;

procedure crearArchivo(var archivo: archivo_aves);
var
    a: ave;
begin
    assign(archivo, 'aves.dat');
    rewrite(archivo);
    leerAve(a);
    while a.codigo <> -1 do begin
        write(archivo, a);
        leerAve(a);
    end;
    close(archivo);
    writeln('Archivo creado exitosamente.');
end;

procedure listarAves(var archivo: archivo_aves);
var
    a: ave;
begin
    reset(archivo);
    writeln('--- LISTA DE AVES ---');
    while not eof(archivo) do begin
        read(archivo, a);
        if a.codigo > 0 then
            imprimirAve(a)
        else
            writeln('> Registro eliminado (codigo=', a.codigo, ')');
    end;
    close(archivo);
end;

procedure bajaLogica(var archivo: archivo_aves);
var
    a: ave;
    cod: integer;
    encontrado: boolean;
begin
    reset(archivo);
    write('Ingrese codigo de especie a eliminar (', VALOR_ALTO, ' para terminar): '); readln(cod);

    while cod <> VALOR_ALTO do begin
        encontrado:= false;
        seek(archivo, 0);

        while (not eof(archivo)) and (not encontrado) do begin
            read(archivo, a);
            if a.codigo = cod then begin
                encontrado:= true;
                a.codigo:= -1;
                seek(archivo, filepos(archivo) - 1);
                write(archivo, a);
                writeln('Especie codigo ', cod, ' marcada como eliminada.');
            end;
        end;

        if not encontrado then
            writeln('Especie no encontrada.');

        write('Ingrese codigo de especie a eliminar (', VALOR_ALTO, ' para terminar): '); readln(cod);
    end;

    close(archivo);
end;

procedure leer(var archivo: archivo_aves; var a: ave);
begin
    if not eof(archivo) then
        read(archivo, a)
    else
        a.codigo:= VALOR_ALTO;
end;

procedure compactarArchivo(var archivo: archivo_aves);
var
    a, ultimo: ave;
    pos, ultPos: integer;
    ultEncontrado: boolean;
begin
    reset(archivo);
    leer(archivo, a);

    while a.codigo <> VALOR_ALTO do begin
        if a.codigo < 0 then begin
            pos:= filepos(archivo) - 1;
            ultPos:= filesize(archivo) - 1;
            ultEncontrado:= false;

            while (ultPos > pos) and not ultEncontrado do begin
                seek(archivo, ultPos);
                read(archivo, ultimo);
                if ultimo.codigo > 0 then
                    ultEncontrado:= true
                else
                    ultPos:= ultPos - 1;
            end;

            if ultEncontrado then begin
                seek(archivo, pos);
                write(archivo, ultimo);
                seek(archivo, ultPos);
                truncate(archivo);
                seek(archivo, pos);
            end
            else begin
                seek(archivo, pos);
                truncate(archivo);
            end;
        end;
        leer(archivo, a);
    end;

    close(archivo);
    writeln('Compactacion completada.');
end;

procedure compactarUnaSolaTruncada(var archivo: archivo_aves);
var
    aux: archivo_aves;
    a: ave;
begin
    reset(archivo);
    assign(aux, 'aves_aux.dat');
    rewrite(aux);

    while not eof(archivo) do begin
        read(archivo, a);
        if a.codigo > 0 then
            write(aux, a);
    end;

    close(archivo);
    close(aux);

    erase(archivo);
    rename(aux, 'aves.dat');

    writeln('Compactacion (variante) completada. Archivo truncado una unica vez.');
end;

var
    archivo: archivo_aves;
    opcion: integer;
begin
    repeat
        writeln('');
        writeln('====== MENU AVES ======');
        writeln('1. Crear archivo');
        writeln('2. Baja logica de especies');
        writeln('3. Compactar (baja fisica con reemplazo + truncado)');
        writeln('4. Compactar (variante: truncar una unica vez)');
        writeln('5. Listar aves');
        writeln('0. Salir');
        write('Ingrese opcion: ');
        readln(opcion);

        case opcion of
            1: crearArchivo(archivo);
            2: bajaLogica(archivo);
            3: compactarArchivo(archivo);
            4: compactarUnaSolaTruncada(archivo);
            5: listarAves(archivo);
            0: writeln('Programa finalizado.');
        else
            writeln('Opcion invalida.');
        end;
    until opcion = 0;
end.
