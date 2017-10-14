{$mode objfpc} { Directive for defining classes }
{$m+}	         { Directive for using constructor }

program PascalProgram37;
uses crt, math; { }


{ `Abstract` class Example // No lambdas in free Pascal }
type
  ExampleClass = class
    public
      function calculate_f(x : double) : double; virtual; abstract;
end;
{ ---------------------------------------------------------------------------- }


{ ExampleClass1 < ExampleClass }
type
  ExampleClass1 = class(ExampleClass)
    public
      function calculate_f(x : double) : double; override;
end;

function ExampleClass1.calculate_f(x : double) : double;
begin
  calculate_f := power(x - 5, 2);
end;
{ ---------------------------------------------------------------------------- }


{ class Interval. Represents interval like [3, 7] or [-1, 1] or etc. }
type
  IntervalClass = class
    private
      _lower_limit : double;
      _upper_limit : double;

    public
      constructor create(lower_limit, upper_limit : double);

      function get_lower_limit() : double;
      function get_upper_limit() : double;
end;

constructor IntervalClass.create(lower_limit, upper_limit : double);
begin
  _lower_limit := lower_limit;
  _upper_limit := upper_limit;
end;

function IntervalClass.get_lower_limit() : double;
begin
  get_lower_limit := _lower_limit;
end;

function IntervalClass.get_upper_limit() : double;
begin
  get_upper_limit := _upper_limit;
end;
{ ---------------------------------------------------------------------------- }


{ class Point }
type
  PointClass = class
    private
      _x : double;
      _y : double;

    public
      constructor create(x : double; y : double);

      function get_x() : double;
      function get_y() : double;
end;

constructor PointClass.create(x : double; y : double);
begin
  _x := x;
  _y := y;
end;

function PointClass.get_x() : double;
begin
  get_x := _x;
end;

function PointClass.get_y() : double;
begin
  get_y := _y;
end;
{ ---------------------------------------------------------------------------- }


{ class DSCAlgorithm }
type
  array_of_points_type = array of PointClass;

type
  DSCAlgorithmClass = class
    private
      _example : ExampleClass;

      function find_localized_interval(points : array_of_points_type) : IntervalClass;

    public
      const INITIAL_X = 0;
      const INITIAL_H = 1;

      constructor create(var example : ExampleClass);

      function get_example() : ExampleClass;
      function get_initial_x() : double;
      function get_initial_h() : double;
      function apply() : IntervalClass;
end;

constructor DSCAlgorithmClass.create(var example : ExampleClass);
begin
  _example := example;
end;

function DSCAlgorithmClass.find_localized_interval(points : array_of_points_type) : IntervalClass;
var
  step               : integer;
  first_index        : integer;
  last_index         : integer;
  point              : PointClass;
  index_of_maximal_y : integer;
  i                  : integer;
  next_index         : integer;
  filtered_points    : array[0..2] of PointClass;
  minimal_x          : double;
  maximal_x          : double;
begin
  step        := 1;
  first_index := 0;
  last_index  := length(points) - step;

  point              := points[first_index];
  index_of_maximal_y := first_index;

  for i := first_index + step to last_index do
  begin
    if (points[i].get_y() > point.get_y()) then
    begin
      point := points[i];
      index_of_maximal_y := i;
    end;
  end;

  next_index := first_index;

  for i := first_index to last_index do
  begin
    if (i <> index_of_maximal_y) then
    begin
      filtered_points[next_index] := points[i];
      next_index := next_index + step;
    end;
  end;

  point     := filtered_points[first_index];
  minimal_x := filtered_points[first_index].get_x();

  for i := first_index to last_index - step do
  begin
    if (filtered_points[i].get_x() < point.get_x()) then
    begin
      point     := filtered_points[i];
      minimal_x := filtered_points[i].get_x();
    end;
  end;

  point     := filtered_points[first_index];
  maximal_x := filtered_points[first_index].get_x();

  for i := first_index to last_index - step do
  begin
    if (filtered_points[i].get_x() > point.get_x()) then
    begin
      point     := filtered_points[i];
      maximal_x := filtered_points[i].get_x();
    end;
  end;

  find_localized_interval := IntervalClass.create(minimal_x, maximal_x);
end;

function DSCAlgorithmClass.get_example() : ExampleClass;
begin
  get_example := _example;
end;

function DSCAlgorithmClass.get_initial_x() : double;
begin
  get_initial_x := INITIAL_X;
end;

function DSCAlgorithmClass.get_initial_h() : double;
begin
  get_initial_h := INITIAL_H;
end;

function DSCAlgorithmClass.apply() : IntervalClass;
var
  example               : ExampleClass;
  previous_h            : double;
  current_h             : double;
  next_h                : double;
  previous_x            : double;
  current_x             : double;
  next_x                : double;
  previous_f            : double;
  current_f             : double;
  next_f                : double;
  k                     : integer;
  one_more_x            : double;
  points                : array[0..3] of PointClass;
begin
  example := get_example();

  { previous_x := some default value }
  current_h := get_initial_h();
  { next_h := some default value }

  { previous_x := some default value }
  current_x  := get_initial_x();
  next_x     := current_x + current_h;

  { previous_f := some default value }
  current_f := example.calculate_f(current_x);
  next_f    := example.calculate_f(next_x);

  k := 0;

  if (current_f < next_f) then
    current_h := -current_h;

  while current_f > next_f do { TODO MAXIMAL_AMOUNT_OF_ITERATIONS }
  begin
    next_h := 2 * current_h;

    previous_x := current_x;
    current_x  := next_x;
    next_x     := next_x + next_h;

    previous_f := current_f;
    current_f  := next_f;
    next_f     := example.calculate_f(next_x);

    previous_h := current_f;
    current_h  := next_h;
    k          := k + 1;
  end;

  one_more_x := next_x - previous_h / 2;

  points[0] := PointClass.create(next_x, next_f);
  points[1] := PointClass.create(current_x, current_f);
  points[2] := PointClass.create(previous_x, previous_f);
  points[3] := PointClass.create(one_more_x, example.calculate_f(one_more_x));

  apply := find_localized_interval(points);
end;
{ ---------------------------------------------------------------------------- }


{ Program variables }
var
  example       : ExampleClass;
  dsc_algorithm : DSCAlgorithmClass;
  interval      : IntervalClass;

{ Like main }
begin
  writeln('Hello');

  example       := ExampleClass1.create();
  dsc_algorithm := DSCAlgorithmClass.create(example);

  interval      := dsc_algorithm.apply();

  writeln(interval.get_lower_limit());
  writeln(interval.get_upper_limit());

  readkey;
end.
