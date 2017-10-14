{$mode objfpc} { Directive for defining classes }
{$m+}	         { Directive for using constructor }

program PascalProgram37;
uses crt, math; { e.g. crt enables `readkey`; math - `power`, `abs` etc }


{ class Vector }
type
  array_of_double_type = array of double;

type
  VectorClass = class
    private
      _size     : integer;
      _elements : array_of_double_type;

      procedure create_elements(size : integer);
    public
      constructor create(size : integer);

      function  get_size() : integer;
      procedure set_element(element : double; index : integer);
      function  get_element(index : integer) : double;
      function  get_elements() : array_of_double_type;
end;

constructor VectorClass.create(size : integer);
begin
  _size := size;
  create_elements(size);
end;

procedure VectorClass.create_elements(size : integer);
begin
  setlength(_elements, size); { std procedure to set length of dynamic array }
end;

function VectorClass.get_size() : integer;
begin
  get_size := _size;
end;

procedure VectorClass.set_element(element : double; index : integer);
begin
  _elements[index] := element;
end;

function VectorClass.get_element(index : integer) : double;
begin
  get_element := _elements[index];
end;

function VectorClass.get_elements() : array_of_double_type;
begin
  get_elements := _elements;
end;
{ ---------------------------------------------------------------------------- }


{ class SquareMatrix }
type
  array_of_vectors_type = array of VectorClass;

type
  SquareMatrixClass = class
    private
      _size : integer;
      _rows : array_of_vectors_type;

      procedure create_rows(size : integer);
    public
      constructor create(size : integer);

      function  get_size() : integer;
      procedure set_row(row : VectorClass; index : integer);
      function  get_row(index : integer) : VectorClass;
      function  get_rows() : array_of_vectors_type;
      procedure set_element(
        element : double;
        row_index : integer;
        column_index : integer
      );
      function  get_element(
        row_index : integer;
        column_index : integer
      ) : double;
      function construct_transposed_martix() : SquareMatrixClass;
end;

constructor SquareMatrixClass.create(size : integer);
begin
  _size := size;
  create_rows(size);
end;

procedure SquareMatrixClass.create_rows(size : integer);
var
  i : integer;
begin
  setlength(_rows, size);  { std procedure to set length of dynamic array }

  for i := 0 to size - 1 do
  begin
    _rows[i] := VectorClass.create(size);
  end;
end;

function SquareMatrixClass.get_size() : integer;
begin
  get_size := _size;
end;

procedure SquareMatrixClass.set_row(row : VectorClass; index : integer);
begin
  _rows[index] := row;
end;

function SquareMatrixClass.get_row(index : integer) : VectorClass;
begin
  get_row := _rows[index];
end;

function SquareMatrixClass.get_rows() : array_of_vectors_type;
begin
  get_rows := _rows;
end;

procedure SquareMatrixClass.set_element(
  element : double;
  row_index : integer;
  column_index : integer
);
begin
  _rows[row_index].set_element(element, column_index);
end;

function SquareMatrixClass.get_element(
  row_index : integer;
  column_index : integer
) : double;
begin
  get_element := _rows[row_index].get_element(column_index);
end;

function SquareMatrixClass.construct_transposed_martix() : SquareMatrixClass;
var
  size              : integer;
  transposed_matrix : SquareMatrixClass;
  i                 : integer;
  j                 : integer;
begin
  size := get_size();

  transposed_matrix := SquareMatrixClass.create(size);

  for i := 0 to size - 1 do
  begin
    for j := 0 to size - 1 do
    begin
      transposed_matrix.set_element(self.get_element(j, i), i, j)
    end;
  end;

  construct_transposed_martix := transposed_matrix;
end;
{ ---------------------------------------------------------------------------- }


{ class MethodOfLeastSquares // Choletky method }
type
  MethodOfLeastSquaresClass = class
    private
      _size : integer;
      _a    : SquareMatrixClass;
      _b    : VectorClass;

      function construct_u() : SquareMatrixClass;
      function construct_y(u : SquareMatrixClass) : VectorClass;
      function construct_x(u : SquareMatrixClass; y : VectorClass) : VectorClass;

    public
      constructor create(size: integer; a : SquareMatrixClass; b : VectorClass);

      function get_size() : integer;
      function get_a() : SquareMatrixClass;
      function get_b() : VectorClass;
      function apply() : VectorClass;
end;

constructor MethodOfLeastSquaresClass.create(
  size : integer;
  a : SquareMatrixClass;
  b : VectorClass
);
begin
  _size := size;
  _a    := a;
  _b    := b;
end;

function MethodOfLeastSquaresClass.construct_u() : SquareMatrixClass;
var
  size : integer;
  a    : SquareMatrixClass;
  u    : SquareMatrixClass;
  i    : integer;
  j    : integer;
  k    : integer;
  sum  : double;
begin
  size := get_size();
  a    := get_a();

  u := SquareMatrixClass.create(size);

  { (2.22) 1-st formula }
  u.set_element(sqrt(a.get_element(0, 0)), 0, 0);

  for i := 1 to size - 1 do
  begin
    { (2.22) 2-nd formula }
    u.set_element(a.get_element(0, i) / u.get_element(0, 0), 0, i);
  end;

  for i := 1 to size - 1 do
  begin
    sum := 0; { !!! }

    for k := 0 to i - 1 do
    begin
      sum := sum + power(u.get_element(k, i), 2);
    end;

    { (2.22) 3-rd formula }
    u.set_element(sqrt(a.get_element(i, i) - sum), i, i);

    for j := i to size - 1 do
    begin
      sum := 0; { !!! }

      for k := 0 to i - 1 do
      begin
        sum := sum + u.get_element(k, i) * u.get_element(k, j);
      end;

      { (2.23) (j > i) }
      u.set_element((a.get_element(i, j) - sum) / u.get_element(i, i), i, j);
    end;

    for j := 0 to i - 1 do
    begin
      { (2.24) (j < i) }
      u.set_element(0, i, j);
    end;
  end;

  construct_u := u;
end;

function MethodOfLeastSquaresClass.construct_y(u : SquareMatrixClass) : VectorClass;
var
  size : integer;
  b    : VectorClass;
  i    : integer;
  k    : integer;
  sum  : double;
  y    : VectorClass;
begin
  size := get_size();
  b    := get_b();

  y := VectorClass.create(size);

  for i := 0 to size - 1 do
  begin
    sum := 0; { !!! }

    for k := 0 to i - 1 do
    begin
      sum := sum + u.get_element(k, i) * y.get_element(k);
    end;

    { (2.27) }
    y.set_element((b.get_element(i) - sum) / u.get_element(i, i), i);
  end;

  construct_y := y;
end;

function MethodOfLeastSquaresClass.construct_x(
  u : SquareMatrixClass;
  y : VectorClass
) : VectorClass;
var
  size : integer;
  i    : integer;
  k    : integer;
  sum  : double;
  x    : VectorClass;
begin
  size := get_size();

  x := VectorClass.create(size);

  for i := size - 1 downto 0 do
  begin
    sum := 0; { !!! }

    for k := i + 1 to size - 1 do
    begin
      sum := sum + u.get_element(i, k) * x.get_element(k);
    end;

    { (2.27) }
    x.set_element((y.get_element(i) - sum) / u.get_element(i, i), i);
  end;

  construct_x := x;
end;

function MethodOfLeastSquaresClass.get_size() : integer;
begin
  get_size := _size;
end;

function MethodOfLeastSquaresClass.get_a() : SquareMatrixClass;
begin
  get_a := _a;
end;

function MethodOfLeastSquaresClass.get_b() : VectorClass;
begin
  get_b := _b;
end;

function MethodOfLeastSquaresClass.apply() : VectorClass;
var
  u            : SquareMatrixClass;
  y            : VectorClass;
begin
  u := construct_u();
  y := construct_y(u);

  apply := construct_x(u, y);
end;

{ Program variables }
var
  size                    : integer;
  a                       : SquareMatrixClass;
  b                       : VectorClass;
  method_of_least_squares : MethodOfLeastSquaresClass;
  x                       : VectorClass;
{ Like main }
begin
  // { p.87 ex.1 }
  // size := 4;
  //
  // { `a` must be symmetric positive-definite matrix !!! }
  // a := SquareMatrixClass.create(size);
  //
  // a.set_element(10, 0, 0);
  // a.set_element(1,  0, 1);
  // a.set_element(2,  0, 2);
  // a.set_element(3,  0, 3);
  //
  // a.set_element(1,  1, 0);
  // a.set_element(11, 1, 1);
  // a.set_element(3,  1, 2);
  // a.set_element(1,  1, 3);
  //
  // a.set_element(2,  2, 0);
  // a.set_element(3,  2, 1);
  // a.set_element(15, 2, 2);
  // a.set_element(1,  2, 3);
  //
  // a.set_element(3,  3, 0);
  // a.set_element(1,  3, 1);
  // a.set_element(1,  3, 2);
  // a.set_element(14, 3, 3);
  //
  // b := VectorClass.create(size);
  // b.set_element(18, 0);
  // b.set_element(19, 1);
  // b.set_element(36, 2);
  // b.set_element(20, 3);

  { p.34 }
  size := 4;
  { `a` must be symmetric positive-definite matrix !!! }
  a := SquareMatrixClass.create(size);

  a.set_element(4, 0, 0);
  a.set_element(2, 0, 1);
  a.set_element(2, 0, 2);
  a.set_element(1, 0, 3);

  a.set_element(2, 1, 0);
  a.set_element(5, 1, 1);
  a.set_element(1, 1, 2);
  a.set_element(2, 1, 3);

  a.set_element(2, 2, 0);
  a.set_element(1, 2, 1);
  a.set_element(5, 2, 2);
  a.set_element(1, 2, 3);

  a.set_element(1,     3, 0);
  a.set_element(2,     3, 1);
  a.set_element(1,     3, 2);
  a.set_element(4.875, 3, 3);

  b := VectorClass.create(size);
  b.set_element(9,     0);
  b.set_element(10,    1);
  b.set_element(9,     2);
  b.set_element(8.875, 3);

  method_of_least_squares := MethodOfLeastSquaresClass.create(size, a, b);
  x := method_of_least_squares.apply();

  writeln('x:');
  writeln('x[0] = ', x.get_element(0));
  writeln('x[1] = ', x.get_element(1));
  writeln('x[2] = ', x.get_element(2));
  writeln('x[3] = ', x.get_element(3));

  readkey;
end.
