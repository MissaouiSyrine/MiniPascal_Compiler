# MiniPascal Compiler
The aim of this work is to program in C (or C ++) a source code compiler programmed using a subset of the Pascal language called Mini-Pascal ( You can find the description of its BNF in a file named MiniPasc).
Three steps are needed to accomplish this MiniPascal Compiler:
## 1- The Lexical parser: using Flex
Where we identify the tokens to be shared with the Syntaxic Parser as well as setting apart the comments lignes and comment blocs in order to ignore them while going through the source code of the program to be compiled
## 2- Building the Syntaxic parser: using Bison and Yacc
In this step, we introduce the grammar of the MiniPascal (MiniPasc File ) that identify how a MiniPascal Code should be written
## 3- Building the Semantic Parser:
During this step, we end up by linking the syntaxic errors with the meanings of the Tokens identifyed in the lexical part. 
