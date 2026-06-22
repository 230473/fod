{
  Parte 1 - Ejercicio 1
  Modificar el ejercicio 4 de la práctica 1 (programa de gestión de empleados)
  agregando una opción que permita realizar bajas físicas en el archivo.
  La baja debe realizarse a partir del número de empleado ingresado por teclado,
  identificando el registro correspondiente en el archivo. Una vez encontrado, se
  debe reemplazar el registro a eliminar por el último registro del archivo, y luego
  truncar el archivo en la posición del último registro para evitar duplicados.
}

program ej1;

const
    LONGITUD_TEXTO = 20;

type
    texto = string[LONGITUD_TEXTO];

    empleado = record
        numero_empleado: integer;
        dni: integer;
        edad: integer;
        nombre: texto;
        apellido: texto;
    end;

    archivo_empleados = file of empleado;

procedure imprimirUnEmpleado(empleado_a_mostrar: empleado);
begin
    writeln('----------');
    writeln('EMPLEADO N° ', empleado_a_mostrar.numero_empleado);
    writeln('DNI: ', empleado_a_mostrar.dni);
    writeln('NOMBRE: ', empleado_a_mostrar.nombre);
    writeln('APELLIDO: ', empleado_a_mostrar.apellido);
    writeln('EDAD: ', empleado_a_mostrar.edad);
end;

procedure cargarUnEmpleado(var empleado_a_cargar: empleado);
begin
    write('Ingrese apellido (fin para terminar): '); readln(empleado_a_cargar.apellido);
    if empleado_a_cargar.apellido <> 'fin' then begin
        write('Ingrese nombre: '); readln(empleado_a_cargar.nombre);
        write('Ingrese edad: '); readln(empleado_a_cargar.edad);
        write('Ingrese DNI (0 si no tiene): '); readln(empleado_a_cargar.dni);
        write('Ingrese numero de empleado: '); readln(empleado_a_cargar.numero_empleado);
    end;
end;

procedure cargarArchivoEmpleados(var archivo_destino: archivo_empleados);
var
    empleado_temporal: empleado;
begin
    cargarUnEmpleado(empleado_temporal);
    while empleado_temporal.apellido <> 'fin' do begin
        write(archivo_destino, empleado_temporal);
        cargarUnEmpleado(empleado_temporal);
    end;
end;

procedure opcionUno_CrearArchivo;
var
    nombre_archivo: texto;
    archivo_empleados_nuevo: archivo_empleados;
begin
    write('Ingrese nombre del archivo: '); readln(nombre_archivo);
    writeln('---------');
    assign(archivo_empleados_nuevo, nombre_archivo);
    rewrite(archivo_empleados_nuevo);
    cargarArchivoEmpleados(archivo_empleados_nuevo);
    close(archivo_empleados_nuevo);
end;

procedure imprimirEmpleadoPorNombreOApellido(var archivo_a_buscar: archivo_empleados; nombre_o_apellido_buscado: texto);
var
    empleado_actual: empleado;
begin
    while not eof(archivo_a_buscar) do begin
        read(archivo_a_buscar, empleado_actual);
        if (empleado_actual.nombre = nombre_o_apellido_buscado) or (empleado_actual.apellido = nombre_o_apellido_buscado) then
            imprimirUnEmpleado(empleado_actual);
    end;
end;

procedure listarTodosEmpleados(var archivo_a_listar: archivo_empleados);
var
    empleado_actual: empleado;
begin
    while not eof(archivo_a_listar) do begin
        read(archivo_a_listar, empleado_actual);
        imprimirUnEmpleado(empleado_actual);
    end;
end;

procedure opcionDos_BuscarPorNombreOApellido;
var
    nombre_archivo: texto;
    nombre_o_apellido_buscado: texto;
    archivo_a_buscar: archivo_empleados;
begin
    write('Ingrese nombre del archivo: '); readln(nombre_archivo);
    writeln('---------');
    write('Ingrese nombre o apellido del empleado: '); readln(nombre_o_apellido_buscado);
    writeln('---------');
    assign(archivo_a_buscar, nombre_archivo);
    reset(archivo_a_buscar);
    imprimirEmpleadoPorNombreOApellido(archivo_a_buscar, nombre_o_apellido_buscado);
    close(archivo_a_buscar);
end;

procedure opcionTres_ListarTodos;
var
    nombre_archivo: texto;
    archivo_a_listar: archivo_empleados;
begin
    write('Ingrese nombre del archivo: '); readln(nombre_archivo);
    writeln('---------');
    assign(archivo_a_listar, nombre_archivo);
    reset(archivo_a_listar);
    listarTodosEmpleados(archivo_a_listar);
    close(archivo_a_listar);
end;

procedure imprimirEmpleadosMayoresDe70(var archivo_a_filtrar: archivo_empleados);
var
    empleado_actual: empleado;
begin
    while not eof(archivo_a_filtrar) do begin
        read(archivo_a_filtrar, empleado_actual);
        if empleado_actual.edad > 70 then
            imprimirUnEmpleado(empleado_actual);
    end;
end;

procedure opcionCuatro_ListarMayoresDe70;
var
    nombre_archivo: texto;
    archivo_a_filtrar: archivo_empleados;
begin
    write('Ingrese nombre del archivo: '); readln(nombre_archivo);
    writeln('---------');
    assign(archivo_a_filtrar, nombre_archivo);
    reset(archivo_a_filtrar);
    imprimirEmpleadosMayoresDe70(archivo_a_filtrar);
    close(archivo_a_filtrar);
end;

function localizarEmpleadoPorNumero(var archivo_busqueda: archivo_empleados; numero_empleado_buscado: integer): integer;
var
    empleado_actual: empleado;
begin
    seek(archivo_busqueda, 0);
    localizarEmpleadoPorNumero:= -1;

    while not eof(archivo_busqueda) do begin
        read(archivo_busqueda, empleado_actual);
        if empleado_actual.numero_empleado = numero_empleado_buscado then begin
            localizarEmpleadoPorNumero:= filepos(archivo_busqueda) - 1;
            exit;
        end;
    end;
end;

procedure ingresarDatosNuevoEmpleado(var empleado_a_ingresar: empleado);
begin
    write('  Ingrese numero de empleado: '); readln(empleado_a_ingresar.numero_empleado);
    write('  Ingrese apellido: '); readln(empleado_a_ingresar.apellido);
    write('  Ingrese nombre: '); readln(empleado_a_ingresar.nombre);
    write('  Ingrese edad: '); readln(empleado_a_ingresar.edad);
    write('  Ingrese DNI (0 si no tiene): '); readln(empleado_a_ingresar.dni);
end;

procedure aniadirUnEmpleado(var archivo_a_modificar: archivo_empleados);
var
    empleado_nuevo: empleado;
begin
    ingresarDatosNuevoEmpleado(empleado_nuevo);

    if localizarEmpleadoPorNumero(archivo_a_modificar, empleado_nuevo.numero_empleado) <> -1 then
        writeln('Error: Ya existe un empleado con numero ', empleado_nuevo.numero_empleado, '.')
    else begin
        seek(archivo_a_modificar, filesize(archivo_a_modificar));
        write(archivo_a_modificar, empleado_nuevo);
        writeln('Empleado agregado exitosamente.');
    end;
end;

procedure opcionCinco_AnadirEmpleado;
var
    nombre_archivo: texto;
    archivo_a_modificar: archivo_empleados;
begin
    write('Ingrese nombre del archivo: '); readln(nombre_archivo);
    writeln('---------');
    assign(archivo_a_modificar, nombre_archivo);
    reset(archivo_a_modificar);
    aniadirUnEmpleado(archivo_a_modificar);
    close(archivo_a_modificar);
end;

procedure modificarEdadEmpleadoPorNumero(var archivo_a_modificar: archivo_empleados; numero_empleado: integer; edad_nueva: integer);
var
    posicion_registro: integer;
    empleado_a_actualizar: empleado;
begin
    posicion_registro:= localizarEmpleadoPorNumero(archivo_a_modificar, numero_empleado);

    if posicion_registro <> -1 then begin
        seek(archivo_a_modificar, posicion_registro);
        read(archivo_a_modificar, empleado_a_actualizar);
        seek(archivo_a_modificar, filepos(archivo_a_modificar) - 1);
        empleado_a_actualizar.edad:= edad_nueva;
        write(archivo_a_modificar, empleado_a_actualizar);
        writeln('Edad modificada exitosamente.');
    end
    else begin
        writeln('Empleado con numero ', numero_empleado, ' no encontrado.');
    end;
end;

procedure opcionSeis_ModificarEdad;
var
    nombre_archivo: texto;
    archivo_a_modificar: archivo_empleados;
    numero_empleado: integer;
    edad_nueva: integer;
begin
    write('Ingrese nombre del archivo: '); readln(nombre_archivo);
    writeln('---------');
    write('Ingrese numero de empleado a modificar: '); readln(numero_empleado);
    writeln('---------');
    write('Ingrese edad nueva: '); readln(edad_nueva);
    writeln('---------');
    assign(archivo_a_modificar, nombre_archivo);
    reset(archivo_a_modificar);
    modificarEdadEmpleadoPorNumero(archivo_a_modificar, numero_empleado, edad_nueva);
    close(archivo_a_modificar);
end;

procedure exportarTodosEmpleadosATexto(var archivo_origen_binario: archivo_empleados);
var
    empleado_a_exportar: empleado;
    archivo_destino_texto: Text;
begin
    assign(archivo_destino_texto, 'todos_empleados.txt');
    rewrite(archivo_destino_texto);

    seek(archivo_origen_binario, 0);
    while not eof(archivo_origen_binario) do begin
        read(archivo_origen_binario, empleado_a_exportar);
        writeln(archivo_destino_texto, empleado_a_exportar.numero_empleado, ' ', empleado_a_exportar.apellido, ' ', empleado_a_exportar.nombre, ' ', empleado_a_exportar.edad, ' ', empleado_a_exportar.dni);
    end;

    close(archivo_destino_texto);
end;

procedure opcionSiete_ExportarTodos;
var
    nombre_archivo: texto;
    archivo_origen: archivo_empleados;
begin
    write('Ingrese nombre del archivo: '); readln(nombre_archivo);
    writeln('---------');
    assign(archivo_origen, nombre_archivo);
    reset(archivo_origen);
    exportarTodosEmpleadosATexto(archivo_origen);
    close(archivo_origen);
    writeln('Archivo "todos_empleados.txt" generado exitosamente.');
end;

procedure exportarEmpleadosSinDniATexto(var archivo_origen_binario: archivo_empleados);
var
    empleado_a_exportar: empleado;
    archivo_destino_texto: Text;
begin
    assign(archivo_destino_texto, 'faltaDNIEmpleado.txt');
    rewrite(archivo_destino_texto);

    seek(archivo_origen_binario, 0);
    while not eof(archivo_origen_binario) do begin
        read(archivo_origen_binario, empleado_a_exportar);
        if empleado_a_exportar.dni = 0 then
            writeln(archivo_destino_texto, empleado_a_exportar.numero_empleado, ' ', empleado_a_exportar.apellido, ' ', empleado_a_exportar.nombre, ' ', empleado_a_exportar.edad, ' ', empleado_a_exportar.dni);
    end;

    close(archivo_destino_texto);
end;

procedure opcionOcho_ExportarSinDni;
var
    nombre_archivo: texto;
    archivo_origen: archivo_empleados;
begin
    write('Ingrese nombre del archivo: '); readln(nombre_archivo);
    writeln('---------');
    assign(archivo_origen, nombre_archivo);
    reset(archivo_origen);
    exportarEmpleadosSinDniATexto(archivo_origen);
    close(archivo_origen);
    writeln('Archivo "faltaDNIEmpleado.txt" generado exitosamente.');
end;

procedure opcionNueve_BajaFisica;
var
    nombre_archivo: texto;
    archivo: archivo_empleados;
    numero_empleado: integer;
    posicion: integer;
    ultimo_empleado: empleado;
begin
    write('Ingrese nombre del archivo: '); readln(nombre_archivo);
    writeln('---------');
    write('Ingrese numero de empleado a eliminar: '); readln(numero_empleado);
    writeln('---------');

    assign(archivo, nombre_archivo);
    reset(archivo);

    posicion:= localizarEmpleadoPorNumero(archivo, numero_empleado);

    if posicion = -1 then
        writeln('Empleado con numero ', numero_empleado, ' no encontrado.')
    else begin
        seek(archivo, filesize(archivo) - 1);
        read(archivo, ultimo_empleado);
        seek(archivo, posicion);
        write(archivo, ultimo_empleado);
        seek(archivo, filesize(archivo) - 1);
        truncate(archivo);
        writeln('Empleado eliminado exitosamente (baja fisica).');
    end;

    close(archivo);
end;

var
    opcion_usuario: integer;
begin
    repeat
        writeln('');
        writeln('====== MENU ======');
        writeln('1. Crear archivo de empleados');
        writeln('2. Listar por nombre o apellido');
        writeln('3. Listar todos los empleados');
        writeln('4. Listar empleados mayores de 70');
        writeln('5. Anadir un empleado');
        writeln('6. Modificar la edad de un empleado');
        writeln('7. Exportar a .txt todos los empleados');
        writeln('8. Exportar a .txt todos los empleados sin DNI');
        writeln('9. Baja fisica de un empleado');
        writeln('0. Salir');
        write('Ingrese opcion: ');
        readln(opcion_usuario);
        writeln('---------');

        case opcion_usuario of
            1: opcionUno_CrearArchivo;
            2: opcionDos_BuscarPorNombreOApellido;
            3: opcionTres_ListarTodos;
            4: opcionCuatro_ListarMayoresDe70;
            5: opcionCinco_AnadirEmpleado;
            6: opcionSeis_ModificarEdad;
            7: opcionSiete_ExportarTodos;
            8: opcionOcho_ExportarSinDni;
            9: opcionNueve_BajaFisica;
            0: writeln('Programa finalizado.');
        else
            writeln('Opcion invalida.');
        end;

        writeln;
    until opcion_usuario = 0;
end.
