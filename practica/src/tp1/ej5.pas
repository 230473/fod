// 5. Realizar un programa para una tienda de celulares, que presente un menú con opciones para:
//    a. Crear un archivo de registros no ordenados de celulares y cargarlo con datos ingresados 
//    desde un archivo de texto denominado "celulares.txt". Los registros correspondientes a los 
//    celulares deben contener: código de celular, nombre, descripción, marca, precio, stock 
//    mínimo y stock disponible. El formato del archivo de texto de carga se especifica en la 
//    NOTA 2 ubicada al final del ejercicio.
//    b. Listar en pantalla los datos de aquellos celulares que tengan un stock menor al stock 
//    mínimo.
//    c. Listar en pantalla los celulares del archivo cuya descripción contenga una cadena de 
//    caracteres proporcionada por el usuario.
//    d. Exportar el archivo binario creado en el inciso a) a un archivo de texto denominado 
//    "celulares.txt" con todos los celulares del mismo. El archivo de texto generado podría ser 
//    utilizado en un futuro como archivo de carga (ver inciso a), por lo que debería respetar el 
//    formato dado para este tipo de archivos en la NOTA 2.

//    NOTA 1: El nombre del archivo binario de celulares debe ser proporcionado por el usuario.
//    NOTA 2: El archivo de carga debe editarse de manera que cada celular se especifique en tres 
//    líneas consecutivas. En la primera se especifica: código de celular, el precio y marca, en 
//    la segunda el stock disponible, stock mínimo y la descripción y en la tercera nombre en ese 
//    orden. Cada celular se carga leyendo tres líneas del archivo "celulares.txt".

//    Ejemplo de Archivo:
//    ```
//    101 250000 Samsung
//    15 5 Galaxy A15 128GB
//    Galaxy A15
//    102 320000 Motorola
//    3 6 Moto G84 256GB color azul
//    Moto G84
//    104 950000 Apple
//    2 4 iPhone 15 256GB negro
//    iPhone 15
//    ```

program ej5;
const
    LONGITUD_CADENA = 50;

type
    cadena = string[LONGITUD_CADENA];

    celular = record
        codigo: integer;
        precio: real;
        marca: cadena;
        stock_disponible: integer;
        stock_minimo: integer;
        descripcion: cadena;
        nombre: cadena;
    end;

    archivo_celulares = file of celular;

// procedimientos

procedure extraerUnCelularDeTextfile(var archivo_texto: Text; var celular_leido: celular);
begin
    ReadLn(archivo_texto, celular_leido.codigo, celular_leido.precio, celular_leido.marca);
    ReadLn(archivo_texto, celular_leido.stock_disponible, celular_leido.stock_minimo, celular_leido.descripcion);
    ReadLn(archivo_texto, celular_leido.nombre);
end;

procedure cargarArchivoCelulares(var archivo_origen_texto: Text; var archivo_destino_binario: archivo_celulares);
var
    celular_procesado: celular;
begin
    while not eof(archivo_origen_texto) do begin
        extraerUnCelularDeTextfile(archivo_origen_texto, celular_procesado);
        write(archivo_destino_binario, celular_procesado);
    end;
end;

procedure incisoA;
var
    archivo_origen_texto: Text;
    archivo_destino_binario: archivo_celulares;
    nombre_archivo_destino: cadena;
begin
    writeln('');
    writeln('--- Inciso A: Crear archivo y cargar datos ---');
    
    assign(archivo_origen_texto, 'celulares.txt');
    reset(archivo_origen_texto);

    writeln('Ingrese nombre del archivo binario a crear: ');
    readln(nombre_archivo_destino);
    assign(archivo_destino_binario, nombre_archivo_destino);
    rewrite(archivo_destino_binario);

    cargarArchivoCelulares(archivo_origen_texto, archivo_destino_binario);

    close(archivo_origen_texto);
    close(archivo_destino_binario);
    writeln('Archivo "' , nombre_archivo_destino, '" creado exitosamente.');
    writeln('');
end;

procedure imprimirUnCelular(c: celular);
begin
    writeln('  Codigo: ', c.codigo);
    writeln('  Nombre: ', c.nombre);
    writeln('  Marca: ', c.marca);
    writeln('  Descripcion: ', c.descripcion);
    writeln('  Precio: $', c.precio:0:2);
    writeln('  Stock disponible: ', c.stock_disponible);
    writeln('  Stock minimo: ', c.stock_minimo);
    writeln('');
end;

procedure listarCelularesBajoStock(var archivo_binario: archivo_celulares);
var
    celular_actual: celular;
    cantidad_encontrada: integer;
begin
    cantidad_encontrada:= 0;
    writeln('');
    writeln('Celulares con stock bajo:');
    writeln('---');
    while not eof(archivo_binario) do begin
        read(archivo_binario, celular_actual);
        if celular_actual.stock_disponible < celular_actual.stock_minimo then begin
            imprimirUnCelular(celular_actual);
            cantidad_encontrada:= cantidad_encontrada + 1;
        end;
    end;
    if cantidad_encontrada = 0 then writeln('  No hay celulares con stock bajo.');
    writeln('Total encontrados: ', cantidad_encontrada);
end;

procedure incisoB;
var
    archivo_binario: archivo_celulares;
    nombre_archivo_a_abrir: cadena;
begin
    writeln('');
    writeln('--- Inciso B: Listar celulares con stock bajo ---');
    writeln('Ingrese nombre del archivo binario: ');
    readln(nombre_archivo_a_abrir);
    assign(archivo_binario, nombre_archivo_a_abrir);
    reset(archivo_binario);

    listarCelularesBajoStock(archivo_binario);

    close(archivo_binario);
    writeln('');
end;

function contieneSubstring(cadena_a_buscar: cadena; cadena_almacenada: cadena): boolean;
var
    i, j: integer;
    coincide: boolean;
begin
    contieneSubstring:= false;

    if (cadena_a_buscar = '') or (length(cadena_a_buscar) > length(cadena_almacenada)) then
        exit;

    i:= 1;
    while (i <= length(cadena_almacenada) - length(cadena_a_buscar) + 1) and (not contieneSubstring) do begin
        coincide:= true;
        j:= 1;
        while (j <= length(cadena_a_buscar)) and coincide do begin
            if cadena_almacenada[i + j - 1] <> cadena_a_buscar[j] then
                coincide:= false;
            j:= j + 1;
        end;

        if coincide then
            contieneSubstring:= true;
        i:= i + 1;
    end;
end;

procedure listarCelularesSubstring(var archivo_binario: archivo_celulares; termino_busqueda: cadena);
var
    celular_actual: celular;
    cantidad_coincidencias: integer;
begin
    cantidad_coincidencias:= 0;
    writeln('');
    writeln('Celulares con descripcion que contiene "', termino_busqueda, '":');
    writeln('---');
    seek(archivo_binario, 0);
    while not eof(archivo_binario) do begin
        read(archivo_binario, celular_actual);
        if contieneSubstring(termino_busqueda, celular_actual.descripcion) then begin
            imprimirUnCelular(celular_actual);
            cantidad_coincidencias:= cantidad_coincidencias + 1;
        end;
    end;
    if cantidad_coincidencias = 0 then writeln('  No se encontraron celulares.');
    writeln('Total encontrados: ', cantidad_coincidencias);
end;

procedure incisoC;
var
    archivo_binario: archivo_celulares;
    nombre_archivo_a_abrir: cadena;
    termino_busqueda_usuario: cadena;
begin
    writeln('');
    writeln('--- Inciso C: Buscar celulares por descripcion ---');
    writeln('Ingrese nombre del archivo binario: ');
    readln(nombre_archivo_a_abrir);
    assign(archivo_binario, nombre_archivo_a_abrir);
    reset(archivo_binario);

    writeln('Ingrese cadena a buscar en descripcion: ');
    readln(termino_busqueda_usuario);
    listarCelularesSubstring(archivo_binario, termino_busqueda_usuario);

    close(archivo_binario);
    writeln('');
end;


procedure exportarATexto(var archivo_origen_binario: archivo_celulares; nombre_archivo_destino_texto: cadena);
var
    archivo_destino_texto: Text;
    celular_a_exportar: celular;
begin
    seek(archivo_origen_binario, 0);
    assign(archivo_destino_texto, nombre_archivo_destino_texto);
    rewrite(archivo_destino_texto);

    { Escribe cada registro en formato texto de 3 lineas }
    while not eof(archivo_origen_binario) do begin
        read(archivo_origen_binario, celular_a_exportar);
        WriteLn(archivo_destino_texto, celular_a_exportar.codigo, ' ', celular_a_exportar.precio:0:2, ' ', celular_a_exportar.marca);
        WriteLn(archivo_destino_texto, celular_a_exportar.stock_disponible, ' ', celular_a_exportar.stock_minimo, ' ', celular_a_exportar.descripcion);
        WriteLn(archivo_destino_texto, celular_a_exportar.nombre);
    end;

    close(archivo_destino_texto);
end;

procedure incisoD;
var
    archivo_binario_origen: archivo_celulares;
    nombre_archivo_binario: cadena;
begin
    writeln('');
    writeln('--- Inciso D: Exportar archivo binario a texto ---');
    writeln('Ingrese nombre del archivo binario: ');
    readln(nombre_archivo_binario);
    assign(archivo_binario_origen, nombre_archivo_binario);
    reset(archivo_binario_origen);

    exportarATexto(archivo_binario_origen, 'celulares.txt');

    close(archivo_binario_origen);
    writeln('Archivo "celulares.txt" exportado exitosamente.');
    writeln('');
end;

procedure mostrarMenu;
begin
    writeln('');
    writeln('=== MENU TIENDA DE CELULARES ===');
    writeln('a) Crear archivo y cargar datos');
    writeln('b) Listar celulares con stock bajo');
    writeln('c) Buscar celulares por descripcion');
    writeln('d) Exportar archivo binario a texto');
    writeln('s) Salir');
    writeln('=================================');
end;

{ PROGRAMA PRINCIPAL }
var
    opcion_usuario: char;
begin
    repeat
        mostrarMenu;
        write('Ingrese opcion: ');
        readln(opcion_usuario);

        case opcion_usuario of
            'a', 'A': incisoA;
            'b', 'B': incisoB;
            'c', 'C': incisoC;
            'd', 'D': incisoD;
            's', 'S': writeln('Adios.');
            else writeln('Opcion invalida.');
        end;
    until (opcion_usuario = 's') or (opcion_usuario = 'S');
end.