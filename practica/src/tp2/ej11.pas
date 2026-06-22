program ej11;

const
  VALOR_ALTO = 'ZZZZZZZZZZ';
  CATEGORIAS = 15;

type
  str20 = string[20];

  regHoraExtra = record
    departamento: str20;
    division: integer;
    empleado: integer;
    categoria: 1..CATEGORIAS;
    horas: integer;
  end;

  archivoHoras = file of regHoraExtra;
  vectorValorHora = array[1..CATEGORIAS] of real;

procedure leer(var a: archivoHoras; var r: regHoraExtra);
begin
  if not eof(a) then
    read(a, r)
  else
    r.departamento := VALOR_ALTO;
end;

procedure cargarValorHora(var txt: text; var vh: vectorValorHora);
var
  i, cat: integer;
  valor: real;
begin
  for i := 1 to CATEGORIAS do
    vh[i] := 0;

  reset(txt);
  while not eof(txt) do
  begin
    readln(txt, cat, valor);
    if (cat >= 1) and (cat <= CATEGORIAS) then
      vh[cat] := valor;
  end;
  close(txt);
end;

procedure procesarReporte(var a: archivoHoras; const vh: vectorValorHora);
var
  r: regHoraExtra;
  depAct: str20;
  divAct, empAct: integer;

  hsEmp, hsDiv, hsDep: integer;
  montoEmp, montoDiv, montoDep: real;
begin
  reset(a);
  leer(a, r);

  while r.departamento <> VALOR_ALTO do
  begin
    depAct := r.departamento;
    hsDep := 0;
    montoDep := 0;

    writeln('DEPARTAMENTO ', depAct);

    while (r.departamento = depAct) do
    begin
      divAct := r.division;
      hsDiv := 0;
      montoDiv := 0;

      writeln('  DIVISION ', divAct);

      while (r.departamento = depAct) and (r.division = divAct) do
      begin
        empAct := r.empleado;
        hsEmp := 0;
        montoEmp := 0;

        while (r.departamento = depAct) and (r.division = divAct) and (r.empleado = empAct) do
        begin
          hsEmp := hsEmp + r.horas;
          montoEmp := montoEmp + (r.horas * vh[r.categoria]);
          leer(a, r);
        end;

        writeln('    Empleado ', empAct, ' | ', hsEmp, ' Hs. | $', montoEmp:0:2);

        hsDiv := hsDiv + hsEmp;
        montoDiv := montoDiv + montoEmp;
      end;

      writeln;
      writeln('    Total Division ', divAct, ': ', hsDiv, ' horas | $', montoDiv:0:2);
      writeln;

      hsDep := hsDep + hsDiv;
      montoDep := montoDep + montoDiv;
    end;

    writeln('  Total Departamento ', depAct, ': ', hsDep, ' horas | $', montoDep:0:2);
    writeln;
  end;

  close(a);
end;

var
  a: archivoHoras;
  txt: text;
  vh: vectorValorHora;
begin
  assign(txt, 'valor_hora.txt');
  cargarValorHora(txt, vh);

  assign(a, 'horas_extras.dat');
  procesarReporte(a, vh);
end.
