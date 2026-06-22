{
  Parte 1 - Ejercicio 2
  Definir un programa que genere un archivo con registros de longitud fija con
  información de productos de un comercio. Los datos se ingresan por teclado y de
  cada producto se almacena: código de producto, nombre, descripción, precio y stock
  disponible. Implementar un procedimiento que, a partir del archivo de datos generado,
  realice la baja lógica de todos aquellos productos cuyo stock disponible sea igual a 0.
  La baja lógica debe indicarse marcando el registro con un carácter especial que se
  sitúa como prefijo en algún campo de tipo string a su elección. Por ejemplo, se puede
  anteponer el carácter @ al nombre del producto: '@Arroz Gallo 1K'.
}

program ej2;

const
    LONGITUD_NOMBRE = 30;
    LONGITUD_DESCRIPCION = 50;

type
    texto_corto = string[LONGITUD_NOMBRE];
    texto_largo = string[LONGITUD_DESCRIPCION];

    producto = record
        codigo: integer;
        nombre: texto_corto;
        descripcion: texto_largo;
        precio: real;
        stock: integer;
    end;

    archivo_productos = file of producto;

procedure cargarProducto(var p: producto);
begin
    write('Ingrese codigo de producto (0 para terminar): '); readln(p.codigo);
    if p.codigo <> 0 then begin
        write('Ingrese nombre: '); readln(p.nombre);
        write('Ingrese descripcion: '); readln(p.descripcion);
        write('Ingrese precio: '); readln(p.precio);
        write('Ingrese stock disponible: '); readln(p.stock);
    end;
end;

procedure crearArchivo(var archivo: archivo_productos);
var
    nombre_fisico: texto_corto;
    p: producto;
begin
    write('Ingrese nombre del archivo a crear: '); readln(nombre_fisico);
    assign(archivo, nombre_fisico);
    rewrite(archivo);
    cargarProducto(p);
    while p.codigo <> 0 do begin
        write(archivo, p);
        cargarProducto(p);
    end;
    close(archivo);
    writeln('Archivo creado exitosamente.');
end;

procedure imprimirProducto(p: producto);
begin
    writeln('Codigo: ', p.codigo, ' | Nombre: ', p.nombre, ' | Stock: ', p.stock, ' | Precio: $', p.precio:0:2);
    writeln('  Descripcion: ', p.descripcion);
end;

procedure listarProductos(var archivo: archivo_productos);
var
    p: producto;
begin
    reset(archivo);
    writeln('--- LISTA DE PRODUCTOS ---');
    while not eof(archivo) do begin
        read(archivo, p);
        imprimirProducto(p);
    end;
    close(archivo);
end;

procedure bajaLogicaStockCero(var archivo: archivo_productos);
var
    p: producto;
    contador: integer;
begin
    reset(archivo);
    contador:= 0;
    while not eof(archivo) do begin
        read(archivo, p);
        if p.stock = 0 then begin
            p.nombre:= '@' + p.nombre;
            seek(archivo, filepos(archivo) - 1);
            write(archivo, p);
            contador:= contador + 1;
        end;
    end;
    close(archivo);
    writeln('Baja logica completada. ', contador, ' producto(s) marcado(s) con stock 0.');
end;

var
    archivo: archivo_productos;
    opcion: integer;
begin
    repeat
        writeln('');
        writeln('====== MENU PRODUCTOS ======');
        writeln('1. Crear archivo de productos');
        writeln('2. Listar productos');
        writeln('3. Realizar baja logica (stock = 0)');
        writeln('0. Salir');
        write('Ingrese opcion: ');
        readln(opcion);

        case opcion of
            1: crearArchivo(archivo);
            2: listarProductos(archivo);
            3: bajaLogicaStockCero(archivo);
            0: writeln('Programa finalizado.');
        else
            writeln('Opcion invalida.');
        end;
    until opcion = 0;
end.
