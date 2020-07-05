import os
import subprocess
import sys

negative_path = '../test-cases/negative'
build_path = '../../build'
output_path = '../output'

object_name = 'Pascal_S_Compiler'

test_cases = os.listdir(negative_path)
output_cases = list(map(lambda name: name.split('.')[0] + '.c', test_cases))

def join_command(executable, source, target):
    return executable + ' ' + source + ' ' + target

if(('-a' != sys.argv[1]) and ('--all' != sys.argv[1])):
    source = sys.argv[1] + '_errors.pas'
    target = sys.argv[1] + '_errors.c'
    print('\033[33m' + 'Compiling ' + source + ', write generated C file in \'' + 
            os.path.join(output_path, target) + '\'\033[0m')
    subprocess.call(join_command(os.path.join(build_path, object_name), 
                                os.path.join(negative_path, source), 
                                os.path.join(output_path, target)), shell=True)
else:
    for source, target in zip(test_cases, output_cases):
        print('\033[33m' + 'Compiling ' + source + ', write generated C file in \'' + 
                os.path.join(output_path, target) + '\'\033[0m')
        subprocess.call(join_command(os.path.join(build_path, object_name), 
                                    os.path.join(negative_path, source), 
                                    os.path.join(output_path, target)), shell=True)
        print()