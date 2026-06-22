{
  Parte 1 - Ejercicio 3
  Realizar un programa que gestione un archivo de libros de una librería.
  De cada libro se registra: código, género, título, autor, cantidad de páginas y precio.
  El programa debe presentar un menú con las siguientes opciones:
    a. Crear el archivo y cargarlo con datos ingresados por teclado, utilizando la
       técnica de lista invertida para recuperar espacio libre en el archivo.
    b. Abrir el archivo existente y permitir su mantenimiento mediante:
       i.  Dar de alta un libro (recuperando espacio libre con lista invertida)
       ii. Modificar los datos de un libro (el código no puede modificarse)
       iii. Eliminar un libro cuyo código es ingresado por teclado
    c. Exportar el contenido a "libros.txt", excluyendo los registros marcados como borrados.

  NOTAS:
  - Usar lista invertida para recuperación de espacio libre.
  - El primer registro del archivo se usa como cabecera de la lista.
    - El campo código de la cabecera tiene valor 0 si no hay espacio libre.
    - Si el campo código de la cabecera tiene un valor negativo, indica la posición
      del primer registro a reutilizar.
  - Los registros libres usan el campo código como enlace (posición negativa).
  - En alta: si hay espacio libre, reutilizar; si no, agregar al final.
  - En baja: incorporar a la lista invertida (pila).
}

program ej3;

const
    LONGITUD_TITULO = 50;
    LONGITUD_AUTOR = 40;
    LONGITUD_GENERO = 20;

type
    texto_genero = string[LONGITUD_GENERO];
    texto_titulo = string[LONGITUD_TITULO];
    texto_autor = string[LONGITUD_AUTOR];

    libro = record
        codigo: integer;
        genero: texto_genero;
        titulo: texto_titulo;
        autor: texto_autor;
        paginas: integer;
        precio: real;
    end;

    archivo_libros = file of libro;

procedure leerLibro(var l: libro);
begin
    write('Ingrese codigo (0 para terminar): '); readln(l.codigo);
    if l.codigo <> 0 then begin
        write('Ingrese genero: '); readln(l.genero);
        write('Ingrese titulo: '); readln(l.titulo);
        write('Ingrese autor: '); readln(l.autor);
        write('Ingrese cantidad de paginas: '); readln(l.paginas);
        write('Ingrese precio: '); readln(l.precio);
    end;
end;

procedure imprimirLibro(l: libro);
begin
    writeln('Codigo: ', l.codigo, ' | Titulo: ', l.titulo, ' | Autor: ', l.autor);
    writeln('  Genero: ', l.genero, ' | Paginas: ', l.paginas, ' | Precio: $', l.precio:0:2);
end;

procedure crearArchivo(var archivo: archivo_libros);
var
    nombre: string[30];
    cabecera: libro;
    l: libro;
begin
    write('Ingrese nombre del archivo: '); readln(nombre);
    assign(archivo, nombre);
    rewrite(archivo);

    cabecera.codigo:= 0;
    cabecera.genero:= '';
    cabecera.titulo:= '';
    cabecera.autor:= '';
    cabecera.paginas:= 0;
    cabecera.precio:= 0;
    write(archivo, cabecera);

    leerLibro(l);
    while l.codigo <> 0 do begin
        write(archivo, l);
        leerLibro(l);
    end;

    close(archivo);
    writeln('Archivo creado exitosamente.');
end;

procedure altaLibro(var archivo: archivo_libros);
var
    cabecera, libre, nuevo: libro;
begin
    reset(archivo);
    read(archivo, cabecera);
    leerLibro(nuevo);

    if cabecera.codigo = 0 then begin
        seek(archivo, filesize(archivo));
        write(archivo, nuevo);
        writeln('Libro agregado al final del archivo.');
    end
    else begin
        seek(archivo, abs(cabecera.codigo));
        read(archivo, libre);
        seek(archivo, filepos(archivo) - 1);
        write(archivo, nuevo);
        seek(archivo, 0);
        cabecera.codigo:= libre.codigo;
        write(archivo, cabecera);
        writeln('Libro agregado reutilizando espacio libre.');
    end;

    close(archivo);
end;

procedure modificarLibro(var archivo: archivo_libros);
var
    l: libro;
    cod: integer;
    encontrado: boolean;
begin
    reset(archivo);
    write('Ingrese codigo del libro a modificar: '); readln(cod);
    encontrado:= false;

    while (not eof(archivo)) and (not encontrado) do begin
        read(archivo, l);
        if l.codigo = cod then
            encontrado:= true;
    end;

    if not encontrado then
        writeln('Libro no encontrado.')
    else begin
        writeln('Ingrese los nuevos datos (el codigo no se modifica):');
        write('Nuevo genero: '); readln(l.genero);
        write('Nuevo titulo: '); readln(l.titulo);
        write('Nuevo autor: '); readln(l.autor);
        write('Nuevas paginas: '); readln(l.paginas);
        write('Nuevo precio: '); readln(l.precio);
        seek(archivo, filepos(archivo) - 1);
        write(archivo, l);
        writeln('Libro modificado exitosamente.');
    end;

    close(archivo);
end;

procedure eliminarLibro(var archivo: archivo_libros);
var
    cabecera, l: libro;
    cod: integer;
    encontrado: boolean;
    pos_eliminado: integer;
begin
    reset(archivo);
    write('Ingrese codigo del libro a eliminar: '); readln(cod);
    encontrado:= false;
    read(archivo, cabecera);

    while (not eof(archivo)) and (not encontrado) do begin
        read(archivo, l);
        if l.codigo = cod then
            encontrado:= true;
    end;

    if not encontrado then
        writeln('Libro no encontrado.')
    else begin
        pos_eliminado:= filepos(archivo) - 1;
        l.codigo:= cabecera.codigo;
        seek(archivo, pos_eliminado);
        write(archivo, l);
        cabecera.codigo:= pos_eliminado * -1;
        seek(archivo, 0);
        write(archivo, cabecera);
        writeln('Libro eliminado exitosamente.');
    end;

    close(archivo);
end;

procedure exportarATexto(var archivo: archivo_libros);
var
    txt: Text;
    l: libro;
    nombre: string[30];
begin
    write('Ingrese nombre del archivo: '); readln(nombre);
    assign(archivo, nombre);
    reset(archivo);

    assign(txt, 'libros.txt');
    rewrite(txt);

    while not eof(archivo) do begin
        read(archivo, l);
        if l.codigo > 0 then begin
            writeln(txt, 'Codigo: ', l.codigo);
            writeln(txt, 'Titulo: ', l.titulo);
            writeln(txt, 'Autor: ', l.autor);
            writeln(txt, 'Genero: ', l.genero);
            writeln(txt, 'Paginas: ', l.paginas);
            writeln(txt, 'Precio: ', l.precio:0:2);
            writeln(txt, '---');
        end;
    end;

    close(archivo);
    close(txt);
    writeln('Archivo "libros.txt" generado exitosamente.');
end;

procedure listarLibros(var archivo: archivo_libros);
var
    l: libro;
    nombre: string[30];
begin
    write('Ingrese nombre del archivo: '); readln(nombre);
    assign(archivo, nombre);
    reset(archivo);

    writeln('--- LISTA DE LIBROS ---');
    while not eof(archivo) do begin
        read(archivo, l);
        if l.codigo > 0 then
            imprimirLibro(l)
        else if l.codigo = 0 then
            writeln('[Cabecera: sin espacio libre]')
        else if l.codigo < 0 then
            writeln('[Cabecera: espacio libre en pos ', abs(l.codigo), ']');
    end;

    close(archivo);
end;

var
    archivo: archivo_libros;
    opcion: integer;
begin
    repeat
        writeln('');
        writeln('====== MENU LIBROS ======');
        writeln('1. Crear archivo');
        writeln('2. Dar de alta un libro');
        writeln('3. Modificar un libro');
        writeln('4. Eliminar un libro');
        writeln('5. Exportar a libros.txt');
        writeln('6. Listar libros');
        writeln('0. Salir');
        write('Ingrese opcion: ');
        readln(opcion);

        case opcion of
            1: crearArchivo(archivo);
            2: altaLibro(archivo);
            3: modificarLibro(archivo);
            4: eliminarLibro(archivo);
            5: exportarATexto(archivo);
            6: listarLibros(archivo);
            0: writeln('Programa finalizado.');
        else
            writeln('Opcion invalida.');
        end;
    until opcion = 0;
end.
