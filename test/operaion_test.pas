program example(input, output);
    var x, y: integer;
    begin
        begin
            x := x + y;
            x := x - y;
        end;
        if x = y then
        begin
            x := x * y;
            x := x / y;
        end;
        else
        begin
            x := x and y;
            x := x or y;
        end; 看起来这里有语法错误？？
        x := x div y;
        x := x mod y;
    end.
