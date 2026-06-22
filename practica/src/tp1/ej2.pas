// 2. Realizar un algoritmo, que utilizando el archivo de números enteros no ordenados 
// creado en el ejercicio 1, informe por pantalla cantidad de números menores a 15000 y el 
// promedio de los números ingresados. El nombre del archivo a procesar debe ser proporcionado 
// por el usuario una única vez. Además, el algoritmo deberá listar el contenido del archivo en 
// pantalla. Resolver el ejercicio realizando un único recorrido del archivo.

program ej2;
type
    archivo_numeros = file of integer;

var
    cantidad_numeros_menores_a_15000: integer;
    cantidad_numeros_archivo: integer;
    promedio_numeros_archivo: real;
    archivo: archivo_numeros;
    nombre_archivo: String[20];
    numero: integer;
begin
    numero:= 0;
    cantidad_numeros_archivo:= 0;
    promedio_numeros_archivo:= 0;
    cantidad_numeros_menores_a_15000:= 0;
    readln(nombre_archivo);
    assign(archivo, nombre_archivo);
    reset(archivo);
    while not eof(archivo) do begin
        cantidad_numeros_archivo:= cantidad_numeros_archivo + 1;
        read(archivo, numero);
        promedio_numeros_archivo:= promedio_numeros_archivo + numero;
        if numero < 15000 then cantidad_numeros_menores_a_15000:= cantidad_numeros_menores_a_15000 + 1;
        writeln(numero);
    end;
    close(archivo);
    writeln('fin del recorrido del archivo.');
    writeln(cantidad_numeros_archivo);
    writeln(cantidad_numeros_menores_a_15000);
    writeln(promedio_numeros_archivo / cantidad_numeros_archivo:0:2);
end.