program ej5;

const
    VALORALTO_COD   = maxint;
    VALORALTO_FECHA = 'ZZZZ-ZZ-ZZ';
    DF              = 5;

type
    subRango = 1..DF;

    { tipos separados para detalle y maestro }
    reg_detalle = record
        codigo : integer;
        fecha  : string;
        tiempo : real;
    end;

    reg_maestro = record
        codigo       : integer;
        fecha        : string;
        tiempo_total : real;
    end;

    detalle     = file of reg_detalle;
    maestro     = file of reg_maestro;
    vecDetalles = array[subRango] of detalle;
    vecRegistros = array[subRango] of reg_detalle;

{ -------------------------------------------------- }

procedure crearUnSoloDetalle(var det: detalle);
var
    carga  : text;
    nombre : string;
    s      : reg_detalle;
begin
    writeln('Ingrese la ruta del archivo de texto fuente:');
    readln(nombre);
    assign(carga, nombre);
    reset(carga);

    writeln('Ingrese un nombre para el archivo detalle binario:');
    readln(nombre);
    assign(det, nombre);
    rewrite(det);

    while not eof(carga) do begin
        readln(carga, s.codigo, s.tiempo, s.fecha);
        write(det, s);
    end;

    close(det);
    close(carga);
    writeln('Archivo binario detalle creado.');
end;

{ -------------------------------------------------- }

procedure crearDetalles(var vec: vecDetalles);
var
    i: subRango;
begin
    for i := 1 to DF do
        crearUnSoloDetalle(vec[i]);
end;

{ -------------------------------------------------- }

procedure leer(var det: detalle; var reg: reg_detalle);
begin
    if not eof(det)
        then read(det, reg)
        else begin
            reg.codigo := VALORALTO_COD;
            reg.fecha  := VALORALTO_FECHA;
            reg.tiempo := 0;
        end;
end;

{ -------------------------------------------------- }

procedure minimo(var vec    : vecDetalles;
                 var vecReg : vecRegistros;
                 var min    : reg_detalle);
var
    i, pos : integer;
begin
    { inicializar con VALORALTO explícito para evitar pos sin asignar }
    min.codigo := VALORALTO_COD;
    min.fecha  := VALORALTO_FECHA;
    pos        := 1;

    for i := 1 to DF do
        if (vecReg[i].codigo < min.codigo) or
           ((vecReg[i].codigo = min.codigo) and (vecReg[i].fecha < min.fecha)) then
        begin
            min := vecReg[i];
            pos := i;
        end;

    { solo avanzar el archivo si hay un mínimo real }
    if min.codigo <> VALORALTO_COD then
        leer(vec[pos], vecReg[pos]);
end;

{ -------------------------------------------------- }

procedure crearMaestro(var mae : maestro; var vec : vecDetalles);
var
    min    : reg_detalle;
    regm   : reg_maestro;
    vecReg : vecRegistros;
    i      : subRango;
begin
    assign(mae, '/var/log/maestro');
    rewrite(mae);

    for i := 1 to DF do begin
        reset(vec[i]);
        leer(vec[i], vecReg[i]);
    end;

    minimo(vec, vecReg, min);

    while min.codigo <> VALORALTO_COD do begin

        { nivel 1: mismo usuario }
        regm.codigo := min.codigo;

        while regm.codigo = min.codigo do begin

            { nivel 2: mismo usuario y misma fecha }
            regm.fecha        := min.fecha;
            regm.tiempo_total := 0;

            while (regm.codigo = min.codigo) and (regm.fecha = min.fecha) do begin
                regm.tiempo_total := regm.tiempo_total + min.tiempo;
                minimo(vec, vecReg, min);
            end;

            write(mae, regm);
        end;

    end;

    close(mae);
    for i := 1 to DF do
        close(vec[i]);
end;

{ -------------------------------------------------- }

procedure imprimirMaestro(var mae: maestro);
var
    regm: reg_maestro;
begin
    reset(mae);
    while not eof(mae) do begin
        read(mae, regm);
        writeln('Codigo: ', regm.codigo,
                ' | Fecha: ', regm.fecha,
                ' | Tiempo total: ', regm.tiempo_total:0:2);
    end;
    close(mae);
end;

{ -------------------------------------------------- }

var
    vecDet : vecDetalles;
    mae    : maestro;

begin
    crearDetalles(vecDet);
    crearMaestro(mae, vecDet);
    imprimirMaestro(mae);
end.