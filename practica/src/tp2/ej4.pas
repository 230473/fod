program ej4;

const
  DF = 30;
  VALOR_ALTO = 9999999;

type
  str40 = string[40];

  producto = record
    codigo: integer;
    nombre: str40;
    descripcion: str40;
    stockDisponible: integer;
    stockMinimo: integer;
    precio: real;
  end;

  venta = record
    codigo: integer;
    cantidadVendida: integer;
  end;

  maestro = file of producto;
  detalle = file of venta;

  rangoDetalles = 1..DF;
  vectorDetalles = array[rangoDetalles] of detalle;
  vectorRegistros = array[rangoDetalles] of venta;

procedure leer(var d: detalle; var r: venta);
begin
  if not eof(d) then
    read(d, r)
  else
    r.codigo := VALOR_ALTO;
end;

procedure minimo(var vd: vectorDetalles; var vr: vectorRegistros; var min: venta);
var
  i: rangoDetalles;
  pos: integer;
begin
  min.codigo := VALOR_ALTO;
  pos := -1;

  for i := 1 to DF do
    if vr[i].codigo < min.codigo then
    begin
      min := vr[i];
      pos := i;
    end;

  if pos <> -1 then
    leer(vd[pos], vr[pos]);
end;

procedure abrirDetalles(var vd: vectorDetalles; var vr: vectorRegistros);
var
  i: rangoDetalles;
  nombre: string;
begin
  for i := 1 to DF do
  begin
    str(i, nombre);
    assign(vd[i], 'detalle' + nombre + '.dat');
    reset(vd[i]);
    leer(vd[i], vr[i]);
  end;
end;

procedure cerrarDetalles(var vd: vectorDetalles);
var
  i: rangoDetalles;
begin
  for i := 1 to DF do
    close(vd[i]);
end;

procedure escribirBajoStock(var txt: text; const p: producto);
begin
  writeln(txt, 'Codigo: ', p.codigo);
  writeln(txt, 'Nombre: ', p.nombre);
  writeln(txt, 'Descripcion: ', p.descripcion);
  writeln(txt, 'Stock: ', p.stockDisponible);
  writeln(txt, 'Precio: ', p.precio:0:2);
  writeln(txt, '---');
end;

procedure actualizarMaestro(var aMae: maestro; var vd: vectorDetalles; var vr: vectorRegistros);
var
  rMae: producto;
  min: venta;
  codigoActual: integer;
  totalVendido: integer;
begin
  reset(aMae);
  if eof(aMae) then
  begin
    close(aMae);
    exit;
  end;

  read(aMae, rMae);
  minimo(vd, vr, min);

  while min.codigo <> VALOR_ALTO do
  begin
    codigoActual := min.codigo;
    totalVendido := 0;

    while min.codigo = codigoActual do
    begin
      totalVendido := totalVendido + min.cantidadVendida;
      minimo(vd, vr, min);
    end;

    while rMae.codigo <> codigoActual do
      read(aMae, rMae);

    rMae.stockDisponible := rMae.stockDisponible - totalVendido;
    seek(aMae, filepos(aMae) - 1);
    write(aMae, rMae);

    if not eof(aMae) then
      read(aMae, rMae);
  end;

  close(aMae);
end;

procedure generarInformeSeparado(var aMae: maestro; const nombreTxt: string);
var
  rMae: producto;
  txt: text;
begin
  assign(txt, nombreTxt);
  rewrite(txt);

  reset(aMae);
  while not eof(aMae) do
  begin
    read(aMae, rMae);
    if rMae.stockDisponible < rMae.stockMinimo then
      escribirBajoStock(txt, rMae);
  end;
  close(aMae);

  close(txt);
end;

procedure actualizarEInformarIntegrado(var aMae: maestro; var vd: vectorDetalles; var vr: vectorRegistros; const nombreTxt: string);
var
  rMae: producto;
  min: venta;
  codigoActual: integer;
  totalVendido: integer;
  txt: text;
begin
  assign(txt, nombreTxt);
  rewrite(txt);

  reset(aMae);
  if eof(aMae) then
  begin
    close(aMae);
    close(txt);
    exit;
  end;

  read(aMae, rMae);
  minimo(vd, vr, min);

  while min.codigo <> VALOR_ALTO do
  begin
    codigoActual := min.codigo;
    totalVendido := 0;

    while min.codigo = codigoActual do
    begin
      totalVendido := totalVendido + min.cantidadVendida;
      minimo(vd, vr, min);
    end;

    while rMae.codigo < codigoActual do
    begin
      if rMae.stockDisponible < rMae.stockMinimo then
        escribirBajoStock(txt, rMae);
      if not eof(aMae) then
        read(aMae, rMae)
      else
        break;
    end;

    if rMae.codigo = codigoActual then
    begin
      rMae.stockDisponible := rMae.stockDisponible - totalVendido;
      seek(aMae, filepos(aMae) - 1);
      write(aMae, rMae);
      if rMae.stockDisponible < rMae.stockMinimo then
        escribirBajoStock(txt, rMae);

      if not eof(aMae) then
        read(aMae, rMae);
    end;
  end;

  while not eof(aMae) do
  begin
    if rMae.stockDisponible < rMae.stockMinimo then
      escribirBajoStock(txt, rMae);
    read(aMae, rMae);
  end;
  if rMae.stockDisponible < rMae.stockMinimo then
    escribirBajoStock(txt, rMae);

  close(aMae);
  close(txt);
end;

var
  aMae: maestro;
  vd: vectorDetalles;
  vr: vectorRegistros;
  opcion: integer;
begin
  assign(aMae, 'maestro.dat');

  writeln('Ejercicio 4');
  writeln('1) Actualizar maestro + informe separado (2 recorridos de maestro)');
  writeln('2) Actualizar maestro + informe integrado (1 recorrido de maestro)');
  write('Opcion: ');
  readln(opcion);

  abrirDetalles(vd, vr);

  case opcion of
    1:
      begin
        actualizarMaestro(aMae, vd, vr);
        generarInformeSeparado(aMae, 'stock_bajo_ej4.txt');
      end;
    2:
      actualizarEInformarIntegrado(aMae, vd, vr, 'stock_bajo_ej4.txt');
  else
    writeln('Opcion invalida');
  end;

  cerrarDetalles(vd);
  writeln('Proceso finalizado.');
end.
