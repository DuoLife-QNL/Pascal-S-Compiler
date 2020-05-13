flex scanner.l
cc lex.yy.c -ll -o scanner_out

echo ""
echo "---------------------------"
echo "Scanner build finish."
echo ""
echo "use \"./scanner_out test/IntegralTest/gcd.pas\" to see result directly."
echo "use \"./scanner_out test/IntegralTest/gcd.pas result/result.txt\" to get the result in file."
# echo "use \"./scanner_out < [test file]\" to see scan result"
# echo "use \"./scanner_test.sh\" to scan multiple files"
echo "use \"ls ./test/\" to see test case"
