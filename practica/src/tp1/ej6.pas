// 6. Agregar al menú del programa del ejercicio 5, opciones para:
//    a. Añadir uno o más celulares al final del archivo con sus datos ingresados por teclado.
//    b. Modificar el stock de un celular dado.
//    c. Exportar el contenido del archivo binario a un archivo de texto denominado 
//    "SinStock.txt", con aquellos celulares que tengan stock 0.

//    NOTA: Las búsquedas deben realizarse por nombre de celular.

program ej6;
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
    nombre_archivo_texto_destino: cadena;
begin
    writeln('');
    writeln('--- Inciso D: Exportar archivo binario a texto ---');
    writeln('Ingrese nombre del archivo binario: ');
    readln(nombre_archivo_binario);
    assign(archivo_binario_origen, nombre_archivo_binario);
    reset(archivo_binario_origen);

    writeln('Ingrese nombre del archivo de texto a exportar: ');
    readln(nombre_archivo_texto_destino);
    exportarATexto(archivo_binario_origen, nombre_archivo_texto_destino);

    close(archivo_binario_origen);
    writeln('Archivo "' , nombre_archivo_texto_destino, '" exportado exitosamente.');
    writeln('');
end;

procedure ingresarDatosNuevoCelular(var celular_a_ingresar: celular);
begin
    writeln('  Ingrese codigo del celular: ');
    readln(celular_a_ingresar.codigo);
    
    writeln('  Ingrese nombre: ');
    readln(celular_a_ingresar.nombre);
    
    writeln('  Ingrese marca: ');
    readln(celular_a_ingresar.marca);
    
    writeln('  Ingrese descripcion: ');
    readln(celular_a_ingresar.descripcion);
    
    writeln('  Ingrese precio: ');
    readln(celular_a_ingresar.precio);
    
    writeln('  Ingrese stock disponible: ');
    readln(celular_a_ingresar.stock_disponible);
    
    writeln('  Ingrese stock minimo: ');
    readln(celular_a_ingresar.stock_minimo);
end;

procedure incisoE;
var
    archivo_binario: archivo_celulares;
    nombre_archivo: cadena;
    celular_nuevo: celular;
    continuar_ingresando: char;
begin
    writeln('');
    writeln('--- Inciso E: Anadir celulares al archivo ---');
    writeln('Ingrese nombre del archivo binario: ');
    readln(nombre_archivo);
    
    { Abrimos el archivo en modo append }
    assign(archivo_binario, nombre_archivo);
    reset(archivo_binario);
    seek(archivo_binario, filesize(archivo_binario));
    
    continuar_ingresando:= 's';
    while (continuar_ingresando = 's') or (continuar_ingresando = 'S') do begin
        writeln('');
        ingresarDatosNuevoCelular(celular_nuevo);
        write(archivo_binario, celular_nuevo);
        writeln('Celular agregado exitosamente.');
        
        writeln('Desea agregar otro celular? (s/n): ');
        readln(continuar_ingresando);
    end;
    
    close(archivo_binario);
    writeln('Operacion completada.');
    writeln('');
end;

procedure incisoF;
var
    archivo_binario: archivo_celulares;
    nombre_archivo: cadena;
    nombre_celular_buscado: cadena;
    celular_actual: celular;
    posicion_registro: integer;
    encontrado: boolean;
    nuevo_stock: integer;
begin
    writeln('');
    writeln('--- Inciso F: Modificar stock de un celular ---');
    writeln('Ingrese nombre del archivo binario: ');
    readln(nombre_archivo);
    assign(archivo_binario, nombre_archivo);
    reset(archivo_binario);
    
    writeln('Ingrese nombre del celular a modificar: ');
    readln(nombre_celular_buscado);
    
    { Buscamos el celular por nombre en el archivo }
    encontrado:= false;
    posicion_registro:= 0;
    
    while (not eof(archivo_binario)) and (not encontrado) do begin
        posicion_registro:= filepos(archivo_binario);
        read(archivo_binario, celular_actual);
        if celular_actual.nombre = nombre_celular_buscado then
            encontrado:= true;
    end;
    
    if encontrado then begin
        writeln('');
        writeln('Celular encontrado:');
        imprimirUnCelular(celular_actual);
        
        writeln('Ingrese nuevo stock disponible: ');
        readln(nuevo_stock);
        
        { Modificamos el stock y reescribimos el registro }
        celular_actual.stock_disponible:= nuevo_stock;
        seek(archivo_binario, posicion_registro);
        write(archivo_binario, celular_actual);
        writeln('Stock modificado exitosamente.');
    end
    else begin
        writeln('Celular con nombre "', nombre_celular_buscado, '" no encontrado.');
    end;
    
    close(archivo_binario);
    writeln('');
end;

procedure exportarCelularesSinStock(var archivo_origen_binario: archivo_celulares; nombre_archivo_destino_texto: cadena);
var
    archivo_destino_texto: Text;
    celular_a_exportar: celular;
begin
    seek(archivo_origen_binario, 0);
    assign(archivo_destino_texto, nombre_archivo_destino_texto);
    rewrite(archivo_destino_texto);

    { Escribe solo los celulares con stock 0 }
    while not eof(archivo_origen_binario) do begin
        read(archivo_origen_binario, celular_a_exportar);
        if celular_a_exportar.stock_disponible = 0 then begin
            WriteLn(archivo_destino_texto, celular_a_exportar.codigo, ' ', celular_a_exportar.precio:0:2, ' ', celular_a_exportar.marca);
            WriteLn(archivo_destino_texto, celular_a_exportar.stock_disponible, ' ', celular_a_exportar.stock_minimo, ' ', celular_a_exportar.descripcion);
            WriteLn(archivo_destino_texto, celular_a_exportar.nombre);
        end;
    end;

    close(archivo_destino_texto);
end;

procedure incisoG;
var
    archivo_binario_origen: archivo_celulares;
    nombre_archivo_binario: cadena;
begin
    writeln('');
    writeln('--- Inciso G: Exportar celulares sin stock ---');
    writeln('Ingrese nombre del archivo binario: ');
    readln(nombre_archivo_binario);
    assign(archivo_binario_origen, nombre_archivo_binario);
    reset(archivo_binario_origen);

    exportarCelularesSinStock(archivo_binario_origen, 'SinStock.txt');

    close(archivo_binario_origen);
    writeln('Archivo "SinStock.txt" generado exitosamente con celulares sin stock.');
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
    writeln('e) Anadir celulares al archivo');
    writeln('f) Modificar stock de un celular');
    writeln('g) Exportar celulares sin stock');
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
            'e', 'E': incisoE;
            'f', 'F': incisoF;
            'g', 'G': incisoG;
            's', 'S': writeln('Adios.');
            else writeln('Opcion invalida.');
        end;
    until (opcion_usuario = 's') or (opcion_usuario = 'S');
end.