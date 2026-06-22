{
  Parte 2 - Ejercicio 1
  El encargado de ventas de un negocio de productos de limpieza desea administrar
  el stock de los productos que vende. Para ello, genera un archivo maestro donde
  figuran todos los productos que comercializa. De cada producto se maneja:
  código de producto, nombre comercial, precio de venta, stock actual y stock mínimo.
  Diariamente se genera un archivo detalle donde se registran todas las ventas de
  productos realizadas. De cada venta se registran: código de producto y cantidad
  de unidades vendidas.

  a. Realizar un procedimiento que actualice el archivo maestro con el archivo detalle,
     teniendo en cuenta que:
       i. Los archivos no están ordenados por ningún criterio.
       ii. Cada registro del maestro puede ser actualizado por 0, 1 ó más registros
           del archivo detalle.
  b. ¿Qué cambios realizaría en el procedimiento del punto anterior si se sabe que
     cada registro del archivo maestro puede ser actualizado por 0 o 1 registro del
     archivo detalle?
}

program ej8;

type
    producto = record
        codigo: integer;
        nombre: string[30];
        precio: real;
        stock_actual: integer;
        stock_minimo: integer;
    end;

    venta = record
        codigo: integer;
        cantidad: integer;
    end;

    archivo_maestro = file of producto;
    archivo_detalle = file of venta;

procedure crearMaestro(var maestro: archivo_maestro);
var
    p: producto;
begin
    assign(maestro, 'maestro.dat');
    rewrite(maestro);

    write('Ingrese codigo de producto (0 para terminar): '); readln(p.codigo);
    while p.codigo <> 0 do begin
        write('Ingrese nombre: '); readln(p.nombre);
        write('Ingrese precio: '); readln(p.precio);
        write('Ingrese stock actual: '); readln(p.stock_actual);
        write('Ingrese stock minimo: '); readln(p.stock_minimo);
        write(maestro, p);
        write('Ingrese codigo de producto (0 para terminar): '); readln(p.codigo);
    end;

    close(maestro);
    writeln('Archivo maestro creado.');
end;

procedure crearDetalle(var detalle: archivo_detalle);
var
    v: venta;
begin
    assign(detalle, 'detalle.dat');
    rewrite(detalle);

    write('Ingrese codigo de producto vendido (0 para terminar): '); readln(v.codigo);
    while v.codigo <> 0 do begin
        write('Ingrese cantidad vendida: '); readln(v.cantidad);
        write(detalle, v);
        write('Ingrese codigo de producto vendido (0 para terminar): '); readln(v.codigo);
    end;

    close(detalle);
    writeln('Archivo detalle creado.');
end;

{
  Procedimiento de actualización para archivos no ordenados.
  Estrategia: por cada producto del maestro, recorrer todo el detalle
  sumando las cantidades vendidas de ese producto, y luego actualizar.

  Costo: O(N * M) lecturas donde N = cantidad de productos y M = cantidad de ventas.
}
procedure actualizarMaestro(var maestro: archivo_maestro; var detalle: archivo_detalle);
var
    p: producto;
    v: venta;
    total_vendido: integer;
begin
    reset(maestro);
    reset(detalle);

    while not eof(maestro) do begin
        read(maestro, p);
        total_vendido:= 0;
        seek(detalle, 0);

        while not eof(detalle) do begin
            read(detalle, v);
            if v.codigo = p.codigo then
                total_vendido:= total_vendido + v.cantidad;
        end;

        if total_vendido > 0 then begin
            p.stock_actual:= p.stock_actual - total_vendido;
            seek(maestro, filepos(maestro) - 1);
            write(maestro, p);
            writeln('Producto ', p.codigo, ': stock actualizado (', total_vendido, ' unidades vendidas).');
        end;
    end;

    close(maestro);
    close(detalle);
    writeln('Actualizacion completada.');
end;

{
  b. Si cada registro del maestro puede ser actualizado por 0 o 1 registro del detalle,
     se puede optimizar invirtiendo el recorrido: por cada registro del detalle, buscar
     el correspondiente en el maestro (recorriendo el maestro completo o usando seek si
     se conoce la posición). Esto permite evitar recorrer el detalle completo por cada
     producto del maestro, reduciendo la complejidad.

  Cambios:
  - Recorrer el detalle una sola vez.
  - Por cada venta, buscar el producto en el maestro (recorrido secuencial o con
    estructura auxiliar) y actualizarlo.
  - Como cada maestro se actualiza como máximo una vez, no necesitamos totalizar.
}

procedure listarMaestro(var maestro: archivo_maestro);
var
    p: producto;
begin
    reset(maestro);
    writeln('--- PRODUCTOS ---');
    while not eof(maestro) do begin
        read(maestro, p);
        writeln('Cod: ', p.codigo, ' | ', p.nombre, ' | Stock: ', p.stock_actual, ' | Min: ', p.stock_minimo, ' | $', p.precio:0:2);
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
        writeln('====== MENU PRODUCTOS LIMPIEZA ======');
        writeln('1. Crear archivo maestro');
        writeln('2. Crear archivo detalle');
        writeln('3. Actualizar maestro desde detalle');
        writeln('4. Listar productos');
        writeln('0. Salir');
        write('Ingrese opcion: ');
        readln(opcion);

        case opcion of
            1: crearMaestro(maestro);
            2: crearDetalle(detalle);
            3: actualizarMaestro(maestro, detalle);
            4: listarMaestro(maestro);
            0: writeln('Programa finalizado.');
        else
            writeln('Opcion invalida.');
        end;
    until opcion = 0;
end.
