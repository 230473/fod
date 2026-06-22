{
  Ejercicio 2 - TP 2 

  El encargado de ventas de un negocio de productos de limpieza desea administrar
  el stock de los productos que comercializa. Para ello, dispone de un archivo maestro
  en el que se registran todos los productos. De cada producto se almacena la siguiente
  información: código de producto, nombre comercial, precio de venta, stock actual y
  stock mínimo.

  Diariamente se genera un archivo detalle donde se registran todas las ventas realizadas.
  De cada venta se almacena: código de producto y cantidad de unidades vendidas.

  Se solicita desarrollar un programa que permita:

  a) Actualizar el archivo maestro a partir del archivo detalle, teniendo en cuenta que:
  - Ambos archivos están ordenados por código de producto.
  - Cada registro del archivo maestro puede ser actualizado por cero, uno o más registros
    del archivo detalle.
  - El archivo detalle sólo contiene registros cuyos códigos existen en el archivo maestro.

  b) Generar un archivo de texto llamado stock_minimo.txt que contenga aquellos productos
  cuyo stock actual se encuentre por debajo del stock mínimo permitido.
}

program ej2;
const
    LONGITUD_CADENA = 50;
    VALOR_ALTO = 9999999;
type
    cadena = String[LONGITUD_CADENA];

    producto = record
        id: integer;
        nombre: cadena;
        stock_actual: integer;
        stock_minimo: integer;
    end;

    venta_producto = record
        id_producto: integer;
        cantidad: integer;
    end;

    archivo_productos = file of producto;
    archivo_ventas = file of venta_producto;

procedure leer_detalle(var archivo_detalle: archivo_ventas; var registro_detalle: venta_producto);
begin
    if (not(eof(archivo_detalle))) then
        read(archivo_detalle, registro_detalle)
    else
        registro_detalle.id_producto := VALOR_ALTO;
end;

procedure actualizarMaestro(var archivo_maestro: archivo_productos; var archivo_detalle: archivo_ventas);
var
    registro_detalle: venta_producto;
    registro_maestro: producto;
    codigo_producto_actual: integer;
    cantidad_total_vendida: integer;
begin
    read(archivo_maestro, registro_maestro);
    leer_detalle(archivo_detalle, registro_detalle);

    while (registro_detalle.id_producto <> VALOR_ALTO) do begin
        codigo_producto_actual := registro_detalle.id_producto;
        cantidad_total_vendida := 0;

        while (codigo_producto_actual = registro_detalle.id_producto) do begin
            cantidad_total_vendida := cantidad_total_vendida + registro_detalle.cantidad;
            leer_detalle(archivo_detalle, registro_detalle);
        end;

        while (registro_maestro.id <> codigo_producto_actual) do
            read(archivo_maestro, registro_maestro);

        registro_maestro.stock_actual := registro_maestro.stock_actual - cantidad_total_vendida;
        seek(archivo_maestro, filepos(archivo_maestro) - 1);
        write(archivo_maestro, registro_maestro);

        if (not(EOF(archivo_maestro))) then
            read(archivo_maestro, registro_maestro);
    end;
end;



procedure opcion_actualizar_maestro;
var
    archivo_maestro: archivo_productos;
    archivo_detalle: archivo_ventas;
begin
    assign(archivo_maestro, 'maestro.dat');
    assign(archivo_detalle, 'detalle.dat');

    reset(archivo_maestro);
    reset(archivo_detalle);

    actualizarMaestro(archivo_maestro, archivo_detalle);

    close(archivo_maestro);
    close(archivo_detalle);

    writeln('Actualizacion completada');
end;

procedure opcion_generar_stock_minimo;
var
    archivo_maestro: archivo_productos;
    archivo_salida: text;
    registro_maestro: producto;
begin
    assign(archivo_maestro, 'maestro.dat');
    assign(archivo_salida, 'stock_minimo.txt');

    reset(archivo_maestro);
    rewrite(archivo_salida);

    while (not(eof(archivo_maestro))) do begin
        read(archivo_maestro, registro_maestro);
        if (registro_maestro.stock_actual < registro_maestro.stock_minimo) then begin
            writeln(archivo_salida, 'Producto: ', registro_maestro.nombre);
            writeln(archivo_salida, 'Codigo: ', registro_maestro.id);
            writeln(archivo_salida, 'Stock actual: ', registro_maestro.stock_actual);
            writeln(archivo_salida, 'Stock minimo: ', registro_maestro.stock_minimo);
            writeln(archivo_salida, '---');
        end;
    end;

    close(archivo_maestro);
    close(archivo_salida);

    writeln('Archivo stock_minimo.txt generado');
end;

var
    opcion: integer;

begin
    writeln('1. Actualizar maestro desde detalle');
    writeln('2. Generar archivo stock_minimo.txt');
    writeln('Ingrese opcion: ');
    readln(opcion);

    case opcion of
        1: opcion_actualizar_maestro;
        2: opcion_generar_stock_minimo;
    else
        writeln('Opcion invalida');
    end;
end.