{
  Parte 2 - Ejercicio 3
  Suponga que trabaja en una oficina donde está montada una LAN (red local).
  La misma fue construida sobre una topología de red que conecta 5 máquinas entre
  sí y todas las máquinas se conectan con un servidor central. Semanalmente cada
  máquina genera un archivo de logs informando las sesiones abiertas por cada
  usuario en cada terminal y por cuánto tiempo estuvo abierta.

  Cada archivo detalle contiene los siguientes campos: cod_usuario, fecha, tiempo_sesion.

  Debe realizar un procedimiento que reciba los archivos detalle y genere un archivo
  maestro con los siguientes datos: cod_usuario, fecha, tiempo_total_de_sesiones_abiertas.

  Notas:
  - Los archivos detalle no están ordenados por ningún criterio.
  - Un usuario puede iniciar más de una sesión el mismo día en la misma máquina,
    o inclusive, en diferentes máquinas.
}

program ej10;

const
    CANT_DETALLES = 5;

type
    sesion = record
        cod_usuario: integer;
        fecha: string[10];
        tiempo_sesion: integer;
    end;

    sesion_maestro = record
        cod_usuario: integer;
        fecha: string[10];
        tiempo_total: integer;
    end;

    archivo_detalle = file of sesion;
    archivo_maestro = file of sesion_maestro;

    detalles_array = array[1..CANT_DETALLES] of archivo_detalle;
    nombres_array = array[1..CANT_DETALLES] of string[20];

procedure generarDetalles(var detalles: detalles_array);
var
    i: integer;
    s: sesion;
    nombres: nombres_array;
begin
    nombres[1]:= 'detalle1.dat';
    nombres[2]:= 'detalle2.dat';
    nombres[3]:= 'detalle3.dat';
    nombres[4]:= 'detalle4.dat';
    nombres[5]:= 'detalle5.dat';

    for i:= 1 to CANT_DETALLES do begin
        assign(detalles[i], nombres[i]);
        rewrite(detalles[i]);
        writeln('Cargando ', nombres[i], ':');
        write('  Ingrese codigo de usuario (0 para terminar): '); readln(s.cod_usuario);
        while s.cod_usuario <> 0 do begin
            write('  Ingrese fecha (dd/mm/aaaa): '); readln(s.fecha);
            write('  Ingrese tiempo de sesion (minutos): '); readln(s.tiempo_sesion);
            write(detalles[i], s);
            write('  Ingrese codigo de usuario (0 para terminar): '); readln(s.cod_usuario);
        end;
        close(detalles[i]);
        writeln(nombres[i], ' creado.');
    end;
end;

procedure mergeDetalles(var detalles: detalles_array; var maestro: archivo_maestro);
var
    i: integer;
    s: sesion;
    sm, sm_aux: sesion_maestro;
    encontrado: boolean;
    nombres: nombres_array;

    maestro_temp: archivo_maestro;
    temp_nombre: string;
begin
    nombres[1]:= 'detalle1.dat';
    nombres[2]:= 'detalle2.dat';
    nombres[3]:= 'detalle3.dat';
    nombres[4]:= 'detalle4.dat';
    nombres[5]:= 'detalle5.dat';

    temp_nombre:= 'maestro_temp.dat';
    assign(maestro_temp, temp_nombre);
    rewrite(maestro_temp);

    for i:= 1 to CANT_DETALLES do begin
        assign(detalles[i], nombres[i]);
        reset(detalles[i]);

        while not eof(detalles[i]) do begin
            read(detalles[i], s);

            encontrado:= false;
            seek(maestro_temp, 0);

            while not eof(maestro_temp) do begin
                read(maestro_temp, sm);
                if (sm.cod_usuario = s.cod_usuario) and (sm.fecha = s.fecha) then begin
                    encontrado:= true;
                    sm.tiempo_total:= sm.tiempo_total + s.tiempo_sesion;
                    seek(maestro_temp, filepos(maestro_temp) - 1);
                    write(maestro_temp, sm);
                    break;
                end;
            end;

            if not encontrado then begin
                sm.cod_usuario:= s.cod_usuario;
                sm.fecha:= s.fecha;
                sm.tiempo_total:= s.tiempo_sesion;
                seek(maestro_temp, filesize(maestro_temp));
                write(maestro_temp, sm);
            end;
        end;

        close(detalles[i]);
    end;

    close(maestro_temp);

    assign(maestro, 'maestro_sesiones.dat');
    rewrite(maestro);
    reset(maestro_temp);

    while not eof(maestro_temp) do begin
        read(maestro_temp, sm);
        write(maestro, sm);
    end;

    close(maestro_temp);
    close(maestro);
    erase(maestro_temp);

    writeln('Archivo maestro generado: maestro_sesiones.dat');
end;

procedure listarMaestro(var maestro: archivo_maestro);
var
    sm: sesion_maestro;
begin
    reset(maestro);
    writeln('--- MAESTRO DE SESIONES ---');
    writeln('Usuario  Fecha        Tiempo Total');
    writeln('-------  ----------   ------------');
    while not eof(maestro) do begin
        read(maestro, sm);
        writeln(sm.cod_usuario:5, '     ', sm.fecha, '   ', sm.tiempo_total:5, ' min');
    end;
    close(maestro);
end;

var
    detalles: detalles_array;
    maestro: archivo_maestro;
    opcion: integer;
begin
    repeat
        writeln('');
        writeln('====== MENU LAN LOGS ======');
        writeln('1. Generar archivos detalle (5 maquinas)');
        writeln('2. Consolidar a archivo maestro');
        writeln('3. Listar maestro de sesiones');
        writeln('0. Salir');
        write('Ingrese opcion: ');
        readln(opcion);

        case opcion of
            1: generarDetalles(detalles);
            2: mergeDetalles(detalles, maestro);
            3: listarMaestro(maestro);
            0: writeln('Programa finalizado.');
        else
            writeln('Opcion invalida.');
        end;
    until opcion = 0;
end.
