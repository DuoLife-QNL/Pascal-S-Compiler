program example(input, output);
    var x, y: integer;
    function gcd(var a, b:integer):integer;
        begin
            if b = 0 then gcd:=a
            else gcd:=gcd(b, a)
        end;
    begin

        read(x, y);
        write(gcd(x, y))
    end.
