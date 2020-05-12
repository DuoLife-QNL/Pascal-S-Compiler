# 已完成工作
* 总体设计思路及人员分工
* 完成词法分析
* 基本完成语法分析
* 完成符号表构建

# 总体实现思路
## 实现方式
* Lex + YACC
* 生成的目标代码：C code

## 组内分工
* 词法分析：袁子麒
* 语法语义分析：李鸿政、侯崴瀛、张樊昊
* 目标代码生成：邓昊元、杜世航

## 需求分析
### 词法分析

单独来看，词法分析的作用是将原文件的字符流转换成标记 (token) 流的过程。

在整个 Pascal-S 编译程序中，词法分析作为语法分析的子程序。语法分析程序通过调用 yylex 得到下一个 token 的类型以及相应的属性。

#### 词法分析详细需求分析

-   Pascal-S 识别的单词种类：
    -   关键字（Keyword） ：program, const, var, integer, boolean, real, char, array, procedure, function, begin, end, of, if, then, else, while, for, to, do. 
        -   Note: Pascal 关键字不区分大小写
        -   关键字单词模式：以 `program` 为例,其模式表达为 :`[Pp][Rr][Oo][Gg][Rr][Aa][Mm]      ` 
    -   注释 （comment）
        -   单行注释：// + 注释内容
            -   单词模式：`//` 
        -   多行注释：{+注释内容}
            -   单词模式：`\{[\S\s]*?\}`
            -   由于需要记录token的 row 以及 column 来定位，所以直接采用匹配 `{` 进行相应的处理。
    -   标识符（identifier）
        -   单词模式 `[A-Za-z][A-Za-z0-9_]* ` 
    -   常数（constant）
        -   单词模式：[0-9]+|[0-9]+\.[0-9]+
    -   赋值运算符（assign operator）: :=
    -   关系运算符（relation operator）：>, <, >=, <=, <>, =
    -   算数运算符（arithmetic operator）: +, -, or, *, /, mod, div, and 
    -   分隔符（delim）： :, ;, 逗号, 句号
    -   空白 （space）：" "|"\t"
    -   其他（other）：[, ], (, ) 
-   Pascal-S 识别的语法错误：
    -   非法表示符：wrong_identifier        {digits}+{letter}({digits}|{letter})*
    -   引号不配对: quotation_not_match (\'|\")
    -   未识别的符号：匹配方式: `.`  

### 语法分析
语法分析是整个软件的核心。从词法分析阶段获得词法分析的识别结果，并通过语法翻译制导技术执行语义动作。

#### 文法产生式
需要实现要求中所有产生式。

但PPT中文法为非L属性定义，为了便于编写翻译方案，需要对部分文法进行改写，例如：
```text
var_declaration -> var_declaration ; idlist : type | idlist : type
```
修改为：
```text
var_declaration -> var_declaration ; id L | id L
L -> , id L | : type
```

#### 语法错误检查
需要处理语法错误，例如：
* 符号缺失：缺少`;`、`,`、`(`、`)`......
* 标识符缺失：缺少`begin`、`end`、`of`......
* 结构缺失：如`begin`和`end`之前缺少`statement_list`
* 其它未匹配错误




### 语义分析
#### 类型
* 基本类型
  * boolean
  * char
  * integer
  * real
* 类型构造器
  * 数组 `var a:array [1..10] of integer`

#### 类型检查
在以下情况下要进行类型检查：
* 赋值
* 运算
* 函数参数传递

#### 作用域检查
通过符号表检查作用域，符号表需实现如下需求：
* 标识符的名字
* 标识符类型
* 标识符作用域

#### 错误处理
##### 类型错误
**Error: Type mismatch**
在类型不匹配时发生：
* 赋值对象与赋值表达式右值类型不同
* 调用函数传递的参数类型和函数定义时

**Error: Incompatible types**
表达式中两个子表达式类型不匹配且无法进行类型转换时，如：
`int := int + char`


##### 标识符错误
* **Error: Identifier not found**：符号表中未找到标识符
* **Duplicate identifier**：当前作用域中该符号已定义

### 代码生成

# 具体实现方式

## 词法分析
## 语法分析
## 语义分析
### 类型表达式
1. 基本类型
    * boolean
    * char
    * integer
    * real
2. 错误类型
    * type_error
3. 回避类型
    * void
4. 类型构造器
    * 数组 `var a:array [1..10] of integer`
    * 笛卡尔积
    * record(暂不考虑)
    * 指针 `var p:↑row`
    * 函数 `function fun(a, b:char):↑integer`
    
### 类型等价
* 名字等价


### 符号表
符号表 std::vector（尽管是栈式，但由于有检索操作，设计成vector）
符号表记录
1. 变量名
2. 类型

块索引表 std::stack
1. 符号表记录指针（下标）
由于不允许函数嵌套定义，块索引表最多只有两个记录。

符号表操作
1. 插入：先调用检索操作判断是否重名，若否，则将符号插入
2. 检索：根据名字从后向前查找
3. 定位：进入函数/过程后定义第一个变量前执行定位操作，将符号表栈顶top（下标，即size）记录到块索引表。
4. 重定位：退出函数/过程后用块索引表top替换符号表的top（清除符号表从索引块表top至末尾的所有记录）
## 代码生成

# 各部分接口说明
## 词法与语法之间
## 语法语义与代码生成之间
