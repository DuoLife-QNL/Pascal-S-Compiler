flex scanner.l
cc lex.yy.c -ll -o scanner_out
echo "run the test ...\n"
./scanner_out gcd.pas result.txt
