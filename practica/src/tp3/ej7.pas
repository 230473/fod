{
  Parte 1 - Ejercicio 7
  Se cuenta con un archivo con información de las diferentes distribuciones de linux
  existentes. De cada distribución se conoce: nombre, año de lanzamiento, número de
  versión del kernel, cantidad de desarrolladores y descripción.
  El nombre de las distribuciones no puede repetirse.

  Este archivo debe ser mantenido realizando bajas lógicas y utilizando la técnica de
  reutilización de espacio libre llamada lista invertida.

  Procedimientos:
    a. BuscarDistribucion: módulo que recibe por parámetro el archivo, un nombre de
       distribución y devuelve la posición dentro del archivo donde se encuentra el
       registro correspondiente (si existe) o devuelve -1 en caso contrario.
    b. AltaDistribucion: módulo que recibe el archivo y el registro de una nueva
       distribución, y agrega la distribución al archivo reutilizando espacio disponible.
       El control de unicidad lo debe realizar usando el módulo anterior.
    c. BajaDistribucion: módulo que recibe el archivo y el nombre de una distribución,
       y da de baja lógicamente la distribución dada. Para marcar una distribución como
       borrada se debe utilizar el campo cantidad de desarrolladores para mantener
       actualizada la lista invertida. Usa BuscarDistribucion para verificar existencia.
}

program ej7;

const
    LONGITUD_NOMBRE = 30;
    LONGITUD_DESCRIPCION = 100;

type
    texto_nombre = string[LONGITUD_NOMBRE];
    texto_desc = string[LONGITUD_DESCRIPCION];

    distribucion = record
        nombre: texto_nombre;
        anio: integer;
        version_kernel: real;
        cant_desarrolladores: integer;
        descripcion: texto_desc;
    end;

    archivo_distribuciones = file of distribucion;

procedure leerDistribucion(var d: distribucion);
begin
    write('Ingrese nombre: '); readln(d.nombre);
    if d.nombre <> '' then begin
        write('Ingrese anio de lanzamiento: '); readln(d.anio);
        write('Ingrese version del kernel: '); readln(d.version_kernel);
        write('Ingrese cantidad de desarrolladores: '); readln(d.cant_desarrolladores);
        write('Ingrese descripcion: '); readln(d.descripcion);
    end;
end;

procedure imprimirDistribucion(d: distribucion);
begin
    writeln('Nombre: ', d.nombre, ' | Anio: ', d.anio, ' | Kernel: ', d.version_kernel:0:1);
    writeln('  Desarrolladores: ', d.cant_desarrolladores, ' | Desc: ', d.descripcion);
end;

procedure crearArchivo(var archivo: archivo_distribuciones);
var
    cabecera: distribucion;
    d: distribucion;
begin
    assign(archivo, 'distribuciones.dat');
    rewrite(archivo);

    cabecera.nombre:= '';
    cabecera.anio:= 0;
    cabecera.version_kernel:= 0;
    cabecera.cant_desarrolladores:= 0;
    cabecera.descripcion:= '';
    write(archivo, cabecera);

    leerDistribucion(d);
    while d.nombre <> '' do begin
        write(archivo, d);
        leerDistribucion(d);
    end;

    close(archivo);
    writeln('Archivo creado exitosamente.');
end;

function BuscarDistribucion(var archivo: archivo_distribuciones; nombre: texto_nombre): integer;
var
    d: distribucion;
    pos: integer;
begin
    reset(archivo);
    BuscarDistribucion:= -1;
    pos:= 0;

    while not eof(archivo) do begin
        read(archivo, d);
        if d.nombre = nombre then begin
            BuscarDistribucion:= pos;
            close(archivo);
            exit;
        end;
        pos:= pos + 1;
    end;

    close(archivo);
end;

procedure AltaDistribucion(var archivo: archivo_distribuciones; d: distribucion);
var
    cabecera, libre: distribucion;
begin
    if BuscarDistribucion(archivo, d.nombre) <> -1 then begin
        writeln('Ya existe la distribucion.');
        exit;
    end;

    reset(archivo);
    read(archivo, cabecera);

    if cabecera.cant_desarrolladores = 0 then begin
        seek(archivo, filesize(archivo));
        write(archivo, d);
        writeln('Distribucion agregada al final del archivo.');
    end
    else begin
        seek(archivo, abs(cabecera.cant_desarrolladores));
        read(archivo, libre);
        seek(archivo, filepos(archivo) - 1);
        write(archivo, d);
        seek(archivo, 0);
        cabecera.cant_desarrolladores:= libre.cant_desarrolladores;
        write(archivo, cabecera);
        writeln('Distribucion agregada reutilizando espacio libre.');
    end;

    close(archivo);
end;

procedure BajaDistribucion(var archivo: archivo_distribuciones; nombre: texto_nombre);
var
    cabecera, d: distribucion;
    pos: integer;
begin
    pos:= BuscarDistribucion(archivo, nombre);

    if pos = -1 then begin
        writeln('Distribucion no existente.');
        exit;
    end;

    reset(archivo);
    read(archivo, cabecera);

    seek(archivo, pos);
    read(archivo, d);
    seek(archivo, filepos(archivo) - 1);
    d.cant_desarrolladores:= cabecera.cant_desarrolladores;
    write(archivo, d);

    seek(archivo, 0);
    cabecera.cant_desarrolladores:= pos * -1;
    write(archivo, cabecera);

    close(archivo);
    writeln('Distribucion "', nombre, '" eliminada exitosamente.');
end;

procedure listarDistribuciones(var archivo: archivo_distribuciones);
var
    d: distribucion;
begin
    reset(archivo);
    writeln('--- LISTA DE DISTRIBUCIONES ---');
    while not eof(archivo) do begin
        read(archivo, d);
        if d.cant_desarrolladores > 0 then
            imprimirDistribucion(d)
        else
            writeln('[Eliminada] Pos: ', filepos(archivo) - 1, ' | Enlace: ', d.cant_desarrolladores);
    end;
    close(archivo);
end;

var
    archivo: archivo_distribuciones;
    opcion: integer;
    d: distribucion;
    nombre_buscar: texto_nombre;
    pos: integer;
begin
    repeat
        writeln('');
        writeln('====== MENU DISTRIBUCIONES LINUX ======');
        writeln('1. Crear archivo');
        writeln('2. Buscar distribucion');
        writeln('3. Alta de distribucion');
        writeln('4. Baja de distribucion');
        writeln('5. Listar distribuciones');
        writeln('0. Salir');
        write('Ingrese opcion: ');
        readln(opcion);

        case opcion of
            1: crearArchivo(archivo);
            2: begin
                   write('Ingrese nombre a buscar: '); readln(nombre_buscar);
                   pos:= BuscarDistribucion(archivo, nombre_buscar);
                   if pos = -1 then
                       writeln('Distribucion no encontrada.')
                   else
                       writeln('Distribucion encontrada en la posicion ', pos);
               end;
            3: begin
                   writeln('Ingrese datos de la nueva distribucion:');
                   leerDistribucion(d);
                   if d.nombre <> '' then
                       AltaDistribucion(archivo, d);
               end;
            4: begin
                   write('Ingrese nombre de la distribucion a eliminar: '); readln(nombre_buscar);
                   BajaDistribucion(archivo, nombre_buscar);
               end;
            5: listarDistribuciones(archivo);
            0: writeln('Programa finalizado.');
        else
            writeln('Opcion invalida.');
        end;
    until opcion = 0;
end.
