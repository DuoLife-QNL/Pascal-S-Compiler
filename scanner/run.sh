echo "            Doing Functional Test."
echo "----------------------------------------------"
for file in ./test/FunctionalTest/*
do
    echo ""
    echo "             " ${file##*/}
    echo "----------------------------------------------"
    echo ""
    
    ./scanner_only_out ${file}
    tmp_file_path=${file##*/}
    filePath="./result/"${tmp_file_path%.*}"_R.txt"
    if [ ! -f "$filePath" ];then
        touch $filePath
    fi
    ./scanner_only_out ${file} ${filePath}
done
