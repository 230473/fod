// 3. Realizar un programa que presente un menú con opciones para:
//    a. Crear un archivo binario de registros no ordenados de empleados y completarlo con 
//    datos ingresados desde teclado. De cada empleado se registra: número de empleado, apellido, 
//    nombre, edad y DNI. Algunos empleados pueden ingresan el DNI con valor 0, lo que significa 
//    que al momento de la carga puede no tenerlo. La carga finaliza cuando se ingresa el String 'fin' como
//    apellido.
//    b. Abrir el archivo anteriormente generado y
//       i. Listar en pantalla los datos de empleados que tengan un nombre o apellido 
//       determinado, el cual se proporciona desde el teclado.
//       ii. Listar en pantalla los empleados de a uno por línea.
//       iii. Listar en pantalla los empleados mayores de 70 años, próximos a jubilarse.

//    NOTA: El nombre del archivo a crear o utilizar debe ser proporcionado por el usuario.

program ej3;

type
    empleado = record
        id, dni, edad: integer;
        nombre, apellido: string[20];
    end;

    archivo_empleados = file of empleado;

procedure imprimirUnEmpleado(e: empleado);
begin
    writeln('----------');
    writeln('EMPLEADO N° ', e.id);
    writeln('DNI ', e.dni);
    writeln('NOMBRE ', e.nombre);
    writeln('APELLIDO ', e.apellido);
    writeln('EDAD ', e.edad);
end;

procedure cargarUnEmpleado(var e: empleado);
begin
    write('Ingrese apellido (fin para terminar): '); readln(e.apellido);
    if e.apellido <> 'fin' then begin
        write('Ingrese nombre: '); readln(e.nombre);
        write('Ingrese edad: '); readln(e.edad);
        write('Ingrese DNI (0 si no tiene): '); readln(e.dni);
        write('Ingrese numero de empleado: '); readln(e.id);
    end;
end;

procedure cargarArchivoEmpleados(var a: archivo_empleados);
var
    em: empleado;
begin
    cargarUnEmpleado(em);
    while em.apellido <> 'fin' do begin
        write(a, em);
        cargarUnEmpleado(em);
    end;
end;

procedure opcionA();
var
    nombre_archivo: string[20];
    archivo: archivo_empleados;
begin
    write('Ingrese nombre del archivo: '); readln(nombre_archivo);
    writeln('---------');
    assign(archivo, nombre_archivo);
    rewrite(archivo);
    cargarArchivoEmpleados(archivo);
    close(archivo);
end;

procedure imprimirUnEmpleadoSegunNombreOApellido(var a: archivo_empleados; noap: string);
var
    em: empleado;
begin
    while not eof(a) do begin
        read(a, em);
        if (em.nombre = noap) or (em.apellido = noap) then
            imprimirUnEmpleado(em);
    end;
end;

procedure listarTodosLosEmpleados(var a: archivo_empleados);
var
    em: empleado;
begin
    while not eof(a) do begin
        read(a, em);
        imprimirUnEmpleado(em);
    end;
end;

procedure opcionB;
var
    nombre_archivo: string[20];
    nombre_o_apellido: string[20];
    archivo: archivo_empleados;
begin
    write('Ingrese nombre del archivo: '); readln(nombre_archivo);
    writeln('---------');
    write('Ingrese nombre o apellido del empleado: '); readln(nombre_o_apellido);
    writeln('---------');
    assign(archivo, nombre_archivo);
    reset(archivo);
    imprimirUnEmpleadoSegunNombreOApellido(archivo, nombre_o_apellido);
    close(archivo);
end;

procedure opcionBii;
var
    nombre_archivo: string[20];
    archivo: archivo_empleados;
begin
    write('Ingrese nombre del archivo: '); readln(nombre_archivo);
    writeln('---------');
    assign(archivo, nombre_archivo);
    reset(archivo);
    listarTodosLosEmpleados(archivo);
    close(archivo);
end;

procedure imprimirEmpleadosMayores(var a: archivo_empleados);
var
    em: empleado;
begin
    while not eof(a) do begin
        read(a, em);
        if em.edad > 70 then
            imprimirUnEmpleado(em);
    end;
end;

procedure opcionBiii;
var
    nombre_archivo: string[20];
    archivo: archivo_empleados;
begin
    write('Ingrese nombre del archivo: '); readln(nombre_archivo);
    writeln('---------');
    assign(archivo, nombre_archivo);
    reset(archivo);
    imprimirEmpleadosMayores(archivo);
    close(archivo);
end;

procedure mostrarMenu;
begin
    writeln('====== MENU EJ3 ======');
    writeln('1. Crear archivo de empleados (opcion a)');
    writeln('2. Listar por nombre o apellido (opcion b.i)');
    writeln('3. Listar todos los empleados (opcion b.ii)');
    writeln('4. Listar empleados mayores de 70 (opcion b.iii)');
    writeln('0. Salir');
    write('Ingrese opcion: ');
end;

var
    opcion: integer;
begin
    repeat
        mostrarMenu;
        readln(opcion);
        writeln('---------');

        case opcion of
            1: opcionA;
            2: opcionB;
            3: opcionBii;
            4: opcionBiii;
            0: writeln('Programa finalizado.');
        else
            writeln('Opcion invalida.');
        end;

        writeln;
    until opcion = 0;
end.