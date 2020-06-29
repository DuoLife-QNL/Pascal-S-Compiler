program idTest(input, output);
    var x, y: integer;
    var a: real;
    var b: boolean;
    var c: char;
    var d: array [1..2] of char;
    procedure out(a: real, b: boolean, c: char)
        begin
        end;

    function gcd(a, b:integer):integer;
        begin
            if b = 0 then gcd:=a
            else gcd:=gcd(b, a mod b)
        end;
    begin
        out();
        read(x, y);
        write(gcd(x, y))
    end.
