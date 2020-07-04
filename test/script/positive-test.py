import os
import subprocess

positive_path = '../test-cases/positive'
build_path = '../../build'
output_path = '../output'

object_name = 'Pascal_S_Compiler'

test_cases = os.listdir(positive_path)
output_cases = list(map(lambda name: name.split('.')[0] + '.c', test_cases))

def join_command(executable, source, target):
    return executable + ' ' + source + ' ' + target

for source, target in zip(test_cases, output_cases):
    print('Compiling ' + source + ', write generated C file in \'' + 
            os.path.join(output_path, target) + '\'')
    subprocess.call(join_command(os.path.join(build_path, object_name), 
                                 os.path.join(positive_path, source), 
                                 os.path.join(output_path, target)), shell=True)
    print()