program example(input, output);
    var x, y: integer;
    function gcd(a, b:integer):integer;
        begin
            if b = 0 then gcd:=a
            else gcd:=gcd(b, a mod b)
        end;
    begin
        x := x + y;
        x := x - y;
        x := x * y;
        x := x / y;
        x := x and y;
        x := x or y;
        x := x div y;
        x := x mod y;
        read(x, y);
        write(gcd(x, y))
    end.
