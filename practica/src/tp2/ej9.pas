program ej9;

const
    VALORALTO_INT = 9999999;
    VALORALTO_STR = 'ZZZZZZZ';

type
    str25 = String[25];
    
    cliente = record
        id       : integer;
        nombre   : str25;
        apellido : str25;
    end;

    venta = record
        cliente       : integer;
        año, mes, dia : integer;
        monto         : real;
    end;

    archivo_ventas = file of venta;

{--------------------------}

procedure leer(var det: archivo_ventas; var reg: venta);
begin
    if not eof(det)
        then read(det, reg)
        else begin
            reg.id       := VALORALTO_INT;
            reg.nombre   := VALORALTO_STR;
            reg.apellido := VALORALTO_STR;
        end;
end;

{--------------------------}

procedure crearMaestro(var maestro, detalle: archivo_ventas);
var
    regm, regd: venta;
begin
    assign(maestro, 'maestro.dat');
    rewrite(maestro);
    assign(detalle, 'detalle.dat');
    reset(detalle);

    leer(detalle, regd);
    read(maestro, regm);

    while regd.id <> VALORALTO_INT do begin

        regm.id := regd.id;

        { nivel 1: cliente }

        while regm.id = regd.id do begin

            regm.año := regd.año;

            { nivel 2: año }

            while regm.año = regd.año do begin

                regm.mes := regd.mes 

                { nivel 3: mes }

                while regm.mes = regd.mes do begin
                    regm.dia := regd.dia 

                    { nivel 4: dia }

                    
                end;

            end;

        end;

    end;

    close(maestro);
    close(detalle);
end;

{--------------------------}

var

begin

end.