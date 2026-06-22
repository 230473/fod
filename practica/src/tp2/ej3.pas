program ej3;

const
    LONGITUD_CADENA = 50;
    VALOR_ALTO = 'ZZZZZZZZZZZZZZZZZZZZ';

type
    cadena = String[LONGITUD_CADENA];

    datosProvincia = record
        nombre: cadena;
        alfabetizados: integer;
        encuestados: integer;
    end;

    datosCenso = record
        nombreProvincia: cadena;
        codLocalidad: integer;
        alfabetizados: integer;
        encuestados: integer;
    end;

    archivo_maestro = file of datosProvincia;
    archivo_detalle = file of datosCenso;

procedure leer(var archivo: archivo_detalle; var dato: datosCenso);
begin
    if not eof(archivo) then
        read(archivo, dato)
    else
        dato.nombreProvincia := VALOR_ALTO;
end;

procedure determinarMinimo(
    var det1, det2: archivo_detalle;
    var reg1, reg2, minimo: datosCenso
);
begin
    if reg1.nombreProvincia <= reg2.nombreProvincia then begin
        minimo := reg1;
        leer(det1, reg1);
    end
    else begin
        minimo := reg2;
        leer(det2, reg2);
    end;
end;

var
    maestro: archivo_maestro;
    detalle1, detalle2: archivo_detalle;
    regMaestro: datosProvincia;
    regDet1, regDet2, regMin: datosCenso;
    provinciaActual: cadena;
    totalEncuestados, totalAlfabetizados: integer;
begin
    assign(maestro, 'maestro.dat');
    assign(detalle1, 'detalle_1.dat');
    assign(detalle2, 'detalle_2.dat');

    reset(maestro);
    reset(detalle1);
    reset(detalle2);

    read(maestro, regMaestro);
    leer(detalle1, regDet1);
    leer(detalle2, regDet2);
    
    determinarMinimo(detalle1, detalle2, regDet1, regDet2, regMin);

    { regMin queda con el menor nombre de provincia entre ambos detalles. }

    while regMin.nombreProvincia <> VALOR_ALTO do begin
        { Mientras no se llegue al fin de ambos detalles (VALOR_ALTO), sigo. }

        // Inicializo contadores.
        provinciaActual := regMin.nombreProvincia;
        totalEncuestados := 0;
        totalAlfabetizados := 0;

        // Mientras esté contabilizando para esta provincia
        while regMin.nombreProvincia = provinciaActual do begin
            // Acumulo valores
            totalEncuestados := totalEncuestados + regMin.encuestados;
            totalAlfabetizados := totalAlfabetizados + regMin.alfabetizados;
            // Busco próximo registro mínimo
            // Como los detalles están ordenados por nombre de provincia, todos los
            // registros de esta provincia llegarán contiguos (entre ambos archivos).

            determinarMinimo(detalle1, detalle2, regDet1, regDet2, regMin);
        end;
        // Si salgo de este while, dejé de procesar datos de esta provincia

        // Localizo el registro de la provincia que estoy procesando actualmente
        // en el archivo maestro
        while regMaestro.nombre <> provinciaActual do begin
            read(maestro, regMaestro);
        end;

        // Actualizo el maestro
        regMaestro.encuestados := regMaestro.encuestados + totalEncuestados;
        regMaestro.alfabetizados := regMaestro.alfabetizados + totalAlfabetizados;

        seek(maestro, filepos(maestro) - 1);
        write(maestro, regMaestro);

        // Si no se terminó, sigo
        if not eof(maestro) then
            read(maestro, regMaestro);
    end;

    close(maestro);
    close(detalle1);
    close(detalle2);
end.