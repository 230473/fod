{
  Parte 2 - Ejercicio 2
  Se necesita contabilizar los votos de las diferentes mesas electorales registradas
  por localidad en la provincia de Buenos Aires. Para ello, se posee un archivo con
  la siguiente información: código de localidad, número de mesa y cantidad de votos
  en dicha mesa.

  Presentar en pantalla un listado como se muestra a continuación:
    Código de Localidad  Total de Votos
    ....................  ................
    ....................  ................
    Total General de Votos: ..................

  NOTAS:
  - La información en el archivo no está ordenada por ningún criterio.
  - Trate de resolver el problema sin modificar el contenido del archivo dado.
  - Puede utilizar una estructura auxiliar, como por ejemplo otro archivo, para
    llevar el control de las localidades que han sido procesadas.
}

program ej9;

type
    mesa = record
        cod_localidad: integer;
        nro_mesa: integer;
        cant_votos: integer;
    end;

    archivo_mesas = file of mesa;

procedure crearArchivo(var archivo: archivo_mesas);
var
    m: mesa;
begin
    assign(archivo, 'mesas.dat');
    rewrite(archivo);

    write('Ingrese codigo de localidad (0 para terminar): '); readln(m.cod_localidad);
    while m.cod_localidad <> 0 do begin
        write('Ingrese numero de mesa: '); readln(m.nro_mesa);
        write('Ingrese cantidad de votos: '); readln(m.cant_votos);
        write(archivo, m);
        write('Ingrese codigo de localidad (0 para terminar): '); readln(m.cod_localidad);
    end;

    close(archivo);
    writeln('Archivo creado exitosamente.');
end;

procedure listarVotosPorLocalidad(var archivo: archivo_mesas);
var
    m, m_aux: mesa;
    loc_control: array[1..1000] of integer;
    tot_control: array[1..1000] of integer;
    cant_localidades: integer;
    i, j: integer;
    encontrado: boolean;
    total_general: integer;
begin
    reset(archivo);
    cant_localidades:= 0;
    total_general:= 0;

    while not eof(archivo) do begin
        read(archivo, m);
        encontrado:= false;

        for i:= 1 to cant_localidades do begin
            if loc_control[i] = m.cod_localidad then begin
                tot_control[i]:= tot_control[i] + m.cant_votos;
                encontrado:= true;
                break;
            end;
        end;

        if not encontrado then begin
            cant_localidades:= cant_localidades + 1;
            loc_control[cant_localidades]:= m.cod_localidad;
            tot_control[cant_localidades]:= m.cant_votos;
        end;
    end;

    close(archivo);

    writeln;
    writeln('CODIGO DE LOCALIDAD     TOTAL DE VOTOS');
    writeln('....................     ................');

    for i:= 1 to cant_localidades do begin
        writeln(loc_control[i]:10, '              ', tot_control[i]:10);
        total_general:= total_general + tot_control[i];
    end;

    writeln;
    writeln('Total General de Votos: ', total_general);
end;

var
    archivo: archivo_mesas;
    opcion: integer;
begin
    repeat
        writeln('');
        writeln('====== MENU VOTOS ======');
        writeln('1. Crear archivo de mesas');
        writeln('2. Listar votos por localidad');
        writeln('0. Salir');
        write('Ingrese opcion: ');
        readln(opcion);

        case opcion of
            1: crearArchivo(archivo);
            2: listarVotosPorLocalidad(archivo);
            0: writeln('Programa finalizado.');
        else
            writeln('Opcion invalida.');
        end;
    until opcion = 0;
end.
