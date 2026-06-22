{
  Parte 1 - Ejercicio 5
  Una cadena de tiendas de indumentaria dispone de un archivo maestro no ordenado que
  contiene la información de las prendas que se encuentran a la venta. De cada prenda se
  registran: cod_prenda, descripción, colores, tipo_prenda, stock y precio_unitario.

  Debido a un cambio de temporada, es necesario actualizar las prendas disponibles.
  Para ello, se recibe un archivo detalle que contiene los códigos (cod_prenda) de aquellas
  prendas que quedarán obsoletas.

  Se deberá implementar:
  1. Un procedimiento que reciba ambos archivos y realice la baja lógica de las prendas
     indicadas, modificando el campo stock asignándole un valor negativo como marca.
  2. Otro procedimiento que permita efectivizar las bajas lógicas, creando un archivo
     auxiliar con solo las prendas no eliminadas (stock >= 0), y luego reemplazando
     el archivo maestro original por el auxiliar.
}

program ej5;

const
    LONGITUD_DESC = 50;
    LONGITUD_COLORES = 30;
    LONGITUD_TIPO = 20;

type
    texto_desc = string[LONGITUD_DESC];
    texto_colores = string[LONGITUD_COLORES];
    texto_tipo = string[LONGITUD_TIPO];

    prenda = record
        cod: integer;
        descripcion: texto_desc;
        colores: texto_colores;
        tipo: texto_tipo;
        stock: integer;
        precio: real;
    end;

    archivo_maestro = file of prenda;
    archivo_detalle = file of integer;

procedure crearMaestroDesdeTexto(var maestro: archivo_maestro);
var
    txt: Text;
    p: prenda;
begin
    assign(maestro, 'maestro.dat');
    rewrite(maestro);

    assign(txt, 'maestro.txt');
    reset(txt);

    while not eof(txt) do begin
        with p do begin
            readln(txt, cod, stock, precio, descripcion);
            readln(txt, tipo);
            readln(txt, colores);
        end;
        write(maestro, p);
    end;

    close(maestro);
    close(txt);
    writeln('Archivo maestro creado desde maestro.txt');
end;

procedure crearDetalleDesdeTexto(var detalle: archivo_detalle);
var
    txt: Text;
    cod: integer;
begin
    assign(detalle, 'detalle.dat');
    rewrite(detalle);

    assign(txt, 'detalle.txt');
    reset(txt);

    while not eof(txt) do begin
        readln(txt, cod);
        write(detalle, cod);
    end;

    close(detalle);
    close(txt);
    writeln('Archivo detalle creado desde detalle.txt');
end;

procedure bajaLogica(var maestro: archivo_maestro; var detalle: archivo_detalle);
var
    p: prenda;
    cod: integer;
begin
    reset(maestro);
    reset(detalle);

    while not eof(detalle) do begin
        read(detalle, cod);
        seek(maestro, 0);
        read(maestro, p);
        while (not eof(maestro)) and (p.cod <> cod) do
            read(maestro, p);
        if p.cod = cod then begin
            p.stock:= -1;
            seek(maestro, filepos(maestro) - 1);
            write(maestro, p);
            writeln('Prenda codigo ', cod, ' marcada como eliminada.');
        end;
    end;

    close(maestro);
    close(detalle);
end;

procedure compactarArchivo(var maestro: archivo_maestro);
var
    aux: archivo_maestro;
    p: prenda;
begin
    reset(maestro);
    assign(aux, 'auxiliar.dat');
    rewrite(aux);

    while not eof(maestro) do begin
        read(maestro, p);
        if p.stock >= 0 then
            write(aux, p);
    end;

    close(maestro);
    close(aux);

    erase(maestro);
    rename(aux, 'maestro.dat');
    assign(maestro, 'maestro.dat');

    writeln('Compactacion completada. Archivo maestro reemplazado.');
end;

procedure listarMaestro(var maestro: archivo_maestro);
var
    p: prenda;
begin
    reset(maestro);
    writeln('--- LISTA DE PRENDAS ---');
    while not eof(maestro) do begin
        read(maestro, p);
        writeln('Cod: ', p.cod, ' | Desc: ', p.descripcion, ' | Stock: ', p.stock, ' | Precio: $', p.precio:0:2);
    end;
    close(maestro);
end;

var
    maestro: archivo_maestro;
    detalle: archivo_detalle;
    opcion: integer;
begin
    repeat
        writeln('');
        writeln('====== MENU INDUMENTARIA ======');
        writeln('1. Crear maestro desde maestro.txt');
        writeln('2. Crear detalle desde detalle.txt');
        writeln('3. Realizar baja logica');
        writeln('4. Compactar archivo (baja fisica)');
        writeln('5. Listar prendas');
        writeln('0. Salir');
        write('Ingrese opcion: ');
        readln(opcion);

        case opcion of
            1: crearMaestroDesdeTexto(maestro);
            2: crearDetalleDesdeTexto(detalle);
            3: bajaLogica(maestro, detalle);
            4: compactarArchivo(maestro);
            5: listarMaestro(maestro);
            0: writeln('Programa finalizado.');
        else
            writeln('Opcion invalida.');
        end;
    until opcion = 0;
end.
