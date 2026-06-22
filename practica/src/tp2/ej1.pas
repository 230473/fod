{

  Ejercicio 1
  
  Una empresa posee un archivo que contiene información sobre los ingresos percibidos
  por diferentes empleados en concepto de comisión. De cada empleado se conoce: código
  de empleado, nombre y monto de la comisión.
  
  La información del archivo se encuentra ordenada por código de empleado, y cada
  empleado puede aparecer más de una vez en el archivo de comisiones.
  
  Se solicita realizar un procedimiento que reciba el archivo anteriormente descrito
  y lo compacte. Como resultado, deberá generar un nuevo archivo en el cual cada
  empleado aparezca una única vez, con el valor total acumulado de sus comisiones.
  
  Nota: No se conoce a priori la cantidad de empleados. Además, el archivo debe ser
  recorrido una única vez.

}

program ej1;

const
    LONGITUD_CADENA = 50;
    VALOR_ALTO = 9999999;

type
    cadena = String[LONGITUD_CADENA];

    empleado = record
        id: integer;
        nombre: cadena;
    end;

    comision = record
        empleado: empleado;
        monto: integer;
    end;

    archivo_comision = file of comision;

procedure leer(var a: archivo_comision; var dato: comision);
begin
    if (not(eof(a))) then
        read(a, dato)
    else
        dato.empleado.id := VALOR_ALTO;
end;

procedure compactarComisiones(var entrada: archivo_comision; var salida: archivo_comision);
var
    reg_entrada: comision;
    reg_salida: comision;
    id_procesando: integer;
    total_comisiones: integer;
begin
    leer(entrada, reg_entrada);

    while (reg_entrada.empleado.id <> VALOR_ALTO) do begin
        id_procesando := reg_entrada.empleado.id;
        total_comisiones := 0;

        while (reg_entrada.empleado.id = id_procesando) do begin
            total_comisiones := total_comisiones + reg_entrada.monto;
            leer(entrada, reg_entrada);
        end;

        reg_salida.empleado.id := id_procesando;
        reg_salida.empleado.nombre := reg_entrada.empleado.nombre;
        reg_salida.monto := total_comisiones;
        
        write(salida, reg_salida);
    end;
end;

var
    entrada: archivo_comision;
    salida: archivo_comision;

begin
    assign(entrada, 'comisiones.dat');
    assign(salida, 'comisiones_compactadas.dat');
    
    reset(entrada);
    rewrite(salida);
    
    compactarComisiones(entrada, salida);
    
    close(entrada);
    close(salida);
    
    writeln('Compactacion completada');
end.