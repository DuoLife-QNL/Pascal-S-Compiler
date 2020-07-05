# Pascal-S-Compiler

A compiler for Pascal-S, output as C, using Flex and Bison

Project link: https://github.com/DuoLife-QNL/Pascal-S-Complier

## 软件运行环境

Ubuntu 16.04/18.04

## 软件使用方式

```
Pascal-S-Compiler <input_file> [output_file] [options]
```

- input_file: the `*.pas` file
- output_file: optional, if not specified, a `*.c` file will be generated.
- options: optional.
  - `-h` `--help`: output the help manual

## 源码编译方式

### 环境要求

* Ubuntu 16.04/18.04
* Bison 3.5  
* Flex 2.5.35
* gcc 5.4.0
* cmake 3.16.8
* Python 3.7

### 编译方法

* 使用CLion集成开发环境，导入项目即可以build
* 在项目根目录下使用指令：`cmake --build ./build --config Debug --target all -- -j 3`

### 目标文件

生成的目标文件位于项目根目录下`build`文件夹内



## 测试用例

### 测试用例位置

* 正确用例位于`test/test-cases/positive`
* 错误用例位于`test/test-cases/negative`

### 测试方式

首先进入`test/script`文件夹

#### 批量测试

* 正确用例批量测试：`python positive-test.py `
* 错误用例批量测试：`python negative-test.py --all`

#### 错误用例逐个测试

`python negative-test.py [model_name]`

其中`model_name`为模块名称：

* array
* block
* const
* id
* lexical
* operation
* type

生成的C文件位于`test/output`文件夹下。针对正确用例，使用gcc编译即可。
