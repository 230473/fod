{
  Parte 1 - Ejercicio 4
  Dada la siguiente estructura:
    type
      reg_flor = record
        nombre: String[45];
        codigo: integer;
      end;
      tArchFlores = file of reg_flor;

  Se desea implementar un sistema de gestión de flores utilizando un archivo con
  reutilización de espacio.
  - Las bajas lógicas se realizan apilando los registros eliminados.
  - Las altas deben reutilizar los espacios libres disponibles antes de agregar nuevos.
  - El registro en la posición 0 se utiliza como cabecera de la pila de registros borrados.

  Política de reutilización:
  - Si el campo código del registro cabecera es 0, no hay registros borrados disponibles.
  - Si el campo código es -N, el próximo registro libre está en la posición N.
  - Cada registro borrado almacena en su campo código el valor negativo que apunte al
    siguiente registro libre, formando una pila enlazada.

  a. Implementar:
     procedure agregarFlor(var a: tArchFlores; nombre: string; codigo: integer);
  b. Listado del contenido omitiendo flores eliminadas.
  c. Implementar:
     procedure eliminarFlor(var a: tArchFlores; flor: reg_flor);
}

program ej4;

type
    reg_flor = record
        nombre: string[45];
        codigo: integer;
    end;

    tArchFlores = file of reg_flor;

procedure agregarFlor(var a: tArchFlores; nombre: string; codigo: integer);
var
    cabecera, libre: reg_flor;
begin
    reset(a);
    read(a, cabecera);

    libre.nombre:= nombre;
    libre.codigo:= codigo;

    if cabecera.codigo = 0 then begin
        seek(a, filesize(a));
        write(a, libre);
        writeln('Flor agregada al final del archivo.');
    end
    else begin
        seek(a, abs(cabecera.codigo));
        read(a, libre);
        seek(a, filepos(a) - 1);
        write(a, libre);
        seek(a, 0);
        cabecera.codigo:= libre.codigo;
        write(a, cabecera);
        writeln('Flor agregada reutilizando espacio libre.');
    end;

    close(a);
end;

procedure eliminarFlor(var a: tArchFlores; flor: reg_flor);
var
    cabecera, f: reg_flor;
    encontrado: boolean;
    pos_eliminado: integer;
begin
    reset(a);
    encontrado:= false;
    read(a, cabecera);

    while (not eof(a)) and (not encontrado) do begin
        read(a, f);
        if f.codigo = flor.codigo then begin
            encontrado:= true;
            pos_eliminado:= filepos(a) - 1;
        end;
    end;

    if not encontrado then
        writeln('Flor con codigo ', flor.codigo, ' no encontrada.')
    else begin
        f.codigo:= cabecera.codigo;
        seek(a, pos_eliminado);
        write(a, f);
        cabecera.codigo:= pos_eliminado * -1;
        seek(a, 0);
        write(a, cabecera);
        writeln('Flor con codigo ', flor.codigo, ' eliminada exitosamente.');
    end;

    close(a);
end;

procedure listarFlores(var a: tArchFlores);
var
    f: reg_flor;
begin
    reset(a);
    writeln('--- LISTA DE FLORES (activas) ---');
    while not eof(a) do begin
        read(a, f);
        if f.codigo > 0 then
            writeln('Codigo: ', f.codigo, ' | Nombre: ', f.nombre);
    end;
    close(a);
end;

procedure crearArchivo(var a: tArchFlores);
var
    cabecera: reg_flor;
    f: reg_flor;
    cod: integer;
    nom: string[45];
begin
    assign(a, 'flores.dat');
    rewrite(a);

    cabecera.codigo:= 0;
    cabecera.nombre:= 'CABECERA';
    write(a, cabecera);

    write('Ingrese codigo de flor (0 para terminar): '); readln(cod);
    while cod <> 0 do begin
        write('Ingrese nombre: '); readln(nom);
        f.codigo:= cod;
        f.nombre:= nom;
        write(a, f);
        write('Ingrese codigo de flor (0 para terminar): '); readln(cod);
    end;

    close(a);
    writeln('Archivo creado exitosamente.');
end;

var
    archivo: tArchFlores;
    opcion: integer;
    cod: integer;
    nom: string[45];
    flor_aux: reg_flor;
begin
    repeat
        writeln('');
        writeln('====== MENU FLORES ======');
        writeln('1. Crear archivo');
        writeln('2. Agregar flor');
        writeln('3. Eliminar flor');
        writeln('4. Listar flores activas');
        writeln('0. Salir');
        write('Ingrese opcion: ');
        readln(opcion);

        case opcion of
            1: crearArchivo(archivo);
            2: begin
                   write('Ingrese codigo: '); readln(cod);
                   write('Ingrese nombre: '); readln(nom);
                   agregarFlor(archivo, nom, cod);
               end;
            3: begin
                   write('Ingrese codigo de flor a eliminar: '); readln(cod);
                   flor_aux.codigo:= cod;
                   eliminarFlor(archivo, flor_aux);
               end;
            4: listarFlores(archivo);
            0: writeln('Programa finalizado.');
        else
            writeln('Opcion invalida.');
        end;
    until opcion = 0;
end.
