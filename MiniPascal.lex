%option yylineno

%{	
 
#include <stdio.h>	
#include <stdlib.h>	          
#include <string.h>
#include <math.h>
#include "MiniPascal.tab.h"	

int num_ligne = 1;
extern char nom[];

%}

%x commentaire
delim     [ \t]
blanc     {delim}*
chiffre   [0-9]
lettre    [a-zA-Z]
id        {lettre}({lettre}|{chiffre})*
nb        ("-")?{chiffre}+("."{chiffre}+)?(("E"|"e")"-"?{chiffre}+)?
int 	  ("-")?{chiffre}+
string    \'([^'\n]|\'\')+\'
iderrone  {chiffre}({lettre}|{chiffre})*
ouvrante  (\()
fermante  (\))
crochet_ouvrant (\[)
crochet_fermant (\])
Accolade_ouvrant (\{)
Accolade_fermant (\})
add          (\+)
soustraction (\-)
mult         (\*)
div	         (\/)
multop       {mult}|{div}
addop		 {add}|{soustraction}
COMMENT_LINE_starter       "//"
Comment_line {COMMENT_LINE_starter}({delim}*|{lettre}*)*
start_com_bloc (\/*)
end_com_bloc   (\*/)



%%

{delim}                                                                    /* pas d'actions */
{blanc}                                                                    /* pas d'actions */
"\n" 			                                                           {++num_ligne;} 
"program"                                           return PROGRAM;
"begin"                                             return BEGIN_TOKEN;
"end"                                               return END;
"var"										        return VAR;
"function"										    return FUNCTION;
"procedure"										    return PROCEDURE;
"if"											    return IF;
"then"											    return THEN;
"else" 											    return ELSE;
"do"											    return DO;
"while"											    return WHILE;
"write"											    return WRITE;
"read"											    return READ;
"writeln"										    return WRITELN;
"readln"										    return READLN;
"real"											    return REAL;
"char"											    return CHAR;
"integer"                                           return INTEGER;
"array"											    return ARRAY;
"of"											    return OF;
{ouvrante}                                          return LEFT_PARENTHESE;
{fermante}                                          return RIGHT_PARENTHESE;
{crochet_ouvrant}								    return LEFT_BRACKETS;
{crochet_fermant}								    return RIGHT_BRACKETS;
{Accolade_ouvrant}								    return LEFT_BRACES;
{Accolade_fermant}								    return RIGHT_BRACES;
{mult}					                            return MULT;
{div}				 							    return DIV;
{add}											    return ADD;
{soustraction}				 					    return SOUSTRACT;
{id}                                                {strcpy(nom, yytext);return IDENTIFIER;}
{int}											    return INT_LITERAL;
{string}										    return String_LITERAL;
{addop}											    return OPP_ADD;
{multop}										    return OPP_MULT;
":"												    return COLON;
":="	                                            return OPPAFFECT;
";"												    return SEMICOLON;
","												    return COMMA;
"<="|"=<"            						        return LESS_OR_EQ;
"=>"|">="            							    return MORE_OR_EQ;
"<>"                 							    return DIFF;
"="                  							    return EQUAL;
".."                  							    return INTERVAL_SEPARATOR;
{Comment_line}			        				    return COMMENT;

{iderrone}              							{fprintf(stderr,"illegal identifier \'%s\' on line :%d\n",yytext,num_ligne);}

"."                   { fprintf(stderr,"Error on line %d : Illegal character \'%s\'\n", num_ligne); }

"/*"         BEGIN(commentaire);

<commentaire>[^*\n]+        /* manger tout ce qui n'est pas un '*' */
<commentaire>\n             ++num_ligne;
<commentaire><<EOF>>    {
                        fprintf(stderr,"Comment Block is still not ended on line :%d\n",num_ligne);
                        yyterminate();
                    }
<commentaire>"*"+"/"          BEGIN(INITIAL);
<commentaire>[*/] return COMMENT_BLOCK;





%%

yywrap()
{
	return(1);
}