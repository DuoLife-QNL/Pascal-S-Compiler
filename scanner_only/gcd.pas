program example (input,output);
var x,1y:real;
"
student:array[1..10, 1..50] of integer;
function gcd(a,b:integer):real;
begin
if b=0 then gcd:=a
else gcd:=gcd(b, a mod b)
end;
begin
read(x, y, a, b, c);
write(gcd(x, y))
end.
