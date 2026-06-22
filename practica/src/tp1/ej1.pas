// 1. Realizar un algoritmo que cree un archivo binario de números enteros no ordenados 
// y permita incorporar datos al archivo. Los números son ingresados desde el teclado. 
// La carga finaliza cuando se ingresa el número 30000, que no debe incorporarse al archivo. 
// El nombre del archivo debe ser proporcionado por el usuario desde el teclado.

program ej1;
type
    archivo_numeros = file of integer;

procedure cargarArchivoNumeros (var a: archivo_numeros);
var
    n: integer;
begin
    readln(n);
    while n <> 30000 do begin
        write(a, n);
        readln(n);
    end;
end;

var
    nombre_archivo_numeros: String[20];
    archivo: archivo_numeros;

begin
    readln(nombre_archivo_numeros);
    assign(archivo, nombre_archivo_numeros);
    rewrite(archivo);
    cargarArchivoNumeros(archivo);
    close(archivo);
end.