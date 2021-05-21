%{
#include "semantique.c"	

#include <stdio.h>	
#include <stdlib.h>
#include <string.h>


extern int num_ligne;
char nom[256];

void yyerror(char * );	
int yylex(void);
void Begin();
void End();

%}

%token PROGRAM
%token BEGIN_TOKEN
%token END
%token VAR
%token FUNCTION
%token PROCEDURE
%token IF
%token THEN
%token ELSE
%token DO
%token WHILE
%token WRITE
%token READ
%token WRITELN
%token READLN
%token REAL
%token CHAR
%token INTEGER
%token ARRAY
%token OF
%token LEFT_PARENTHESE
%token RIGHT_PARENTHESE
%token LEFT_BRACKETS
%token RIGHT_BRACKETS
%token LEFT_BRACES
%token RIGHT_BRACES
%token IDENTIFIER
%token INT_LITERAL

%token String_LITERAL
%token OPP_ADD
%token OPP_MULT
%token COLON
%token OPPAFFECT
%token SEMICOLON
%token COMMA
%token LESS_OR_EQ
%token MORE_OR_EQ
%token DIFF
%token EQUAL
%token INTERVAL_SEPARATOR
%token COMMENT
%token COMMENT_BLOCK
%token ADD
%token SOUSTRACT
%token MULT
%token DIV
%error-verbose
%start programmes

%%
                                                           
programmes :  PROGRAM IDENTIFIER SEMICOLON  
		 |PROGRAM IDENTIFIER SEMICOLON liste_declarations instruction_composee    
		 |PROGRAM IDENTIFIER SEMICOLON declaration_methodes instruction_composee    
		 |PROGRAM IDENTIFIER SEMICOLON liste_declarations declaration_methodes instruction_composee   

		 | COMMENT_BLOCK  PROGRAM IDENTIFIER SEMICOLON  
		 | COMMENT_BLOCK  PROGRAM IDENTIFIER SEMICOLON liste_declarations instruction_composee    
		 | COMMENT_BLOCK  PROGRAM IDENTIFIER SEMICOLON declaration_methodes instruction_composee   
		 | COMMENT_BLOCK  PROGRAM IDENTIFIER SEMICOLON liste_declarations declaration_methodes instruction_composee  

		 |PROGRAM IDENTIFIER SEMICOLON COMMENT_BLOCK liste_declarations instruction_composee   
		 |PROGRAM IDENTIFIER SEMICOLON COMMENT_BLOCK declaration_methodes instruction_composee   
		 |PROGRAM IDENTIFIER SEMICOLON COMMENT_BLOCK liste_declarations declaration_methodes instruction_composee   

		 |PROGRAM IDENTIFIER SEMICOLON  liste_declarations COMMENT_BLOCK instruction_composee    
		 |PROGRAM IDENTIFIER SEMICOLON  declaration_methodes COMMENT_BLOCK instruction_composee   
		 |PROGRAM IDENTIFIER SEMICOLON  liste_declarations COMMENT_BLOCK declaration_methodes instruction_composee 

		 |error IDENTIFIER SEMICOLON  {yyerror(" Mot cle PROGRAM attendu"); }
		 |error IDENTIFIER SEMICOLON liste_declarations instruction_composee   {yyerror(" Mot cle PROGRAM attendu"); }
		 |error IDENTIFIER SEMICOLON declaration_methodes instruction_composee   {yyerror(" Mot cle PROGRAM attendu"); }
		 |error IDENTIFIER SEMICOLON liste_declarations declaration_methodes instruction_composee   {yyerror(" Mot cle PROGRAM attendu"); }

		 |PROGRAM error SEMICOLON   {yyerror(" L'identitfiant du programme est attendu"); }
		 |PROGRAM error SEMICOLON liste_declarations instruction_composee  {yyerror(" L'identitfiant du programme est attendu"); }
		 |PROGRAM error SEMICOLON declaration_methodes instruction_composee  {yyerror(" L'identitfiant du programme est attendu"); } 
		 |PROGRAM error SEMICOLON liste_declarations declaration_methodes instruction_composee   {yyerror(" L'identitfiant du programme est attendu"); }
         

         |PROGRAM IDENTIFIER error  {yyerror(" point virgule attendu"); }
		 |PROGRAM IDENTIFIER error liste_declarations instruction_composee   {yyerror(" point virgule attendu"); }
		 |PROGRAM IDENTIFIER error declaration_methodes instruction_composee   {yyerror(" point virgule attendu"); }
		 |PROGRAM IDENTIFIER error liste_declarations declaration_methodes instruction_composee   {yyerror(" point virgule attendu"); }

;                             
liste_declarations:
	declaration
	liste_declarations
	| declaration 
;

declaration:
	VAR
	declaration_corps
	SEMICOLON
;

declaration_corps:
	liste_identificateurs COLON type {
							while( g_index > 0 ) {
								g_index-- ;
								g_ListIdentifiers[g_index]->type = g_type;
							}
							g_index = 0 ;
						}
	|liste_identificateurs COLON error { yyerror("type manquant"); }
;

liste_identificateurs:
	IDENTIFIER  {checkIdentifier(nom,num_ligne);} COMMA liste_identificateurs |
	IDENTIFIER  {checkIdentifier(nom,num_ligne);}
	|IDENTIFIER error liste_identificateurs { yyerror("virgule manquant"); }
;

type:
	standard_type | ARRAY LEFT_BRACKETS INT_LITERAL INTERVAL_SEPARATOR INT_LITERAL RIGHT_BRACKETS OF standard_type
;

standard_type:
	INTEGER { g_type = tInt; } 
	| REAL  { g_type = tReal; }
	| CHAR  { g_type = tChar; }
	| error { yyerror("type errone"); }
;
 

declaration_methodes:
	declaration_methode SEMICOLON declaration_methodes
	|declaration_methode SEMICOLON
;


declaration_methode:
	entete_methode 	liste_declarations	instruction_composee 
	|entete_methode instruction_composee
;

entete_methode 			: PROCEDURE { g_IfProc = 1; } IDENTIFIER{if( chercherNoeud(nom, table) ){yyerror("Procedure already defined");}	            else{g_noeudProc = creerNoeud(nom, NODE_TYPE_UNKNOWN, procedure, NULL);
					table = insererNoeud(g_noeudProc, table);}
				g_IfProcParameters = 1;} arguments 
						{
						    g_noeudProc->nbParam = g_nbParam;
							g_nbParam = 0;
						} SEMICOLON 
						
			   	
	|error IDENTIFIER arguments SEMICOLON  {yyerror(" Mot cle PROCEDURE/FUNCTION attendu"); }
	|error IDENTIFIER SEMICOLON  {yyerror(" Mot cle PROCEDURE/FUNCTION attendu"); }
	|error IDENTIFIER LEFT_PARENTHESE RIGHT_PARENTHESE	SEMICOLON  {yyerror(" Mot cle PROCEDURE/FUNCTION attendu"); }
	|error IDENTIFIER arguments COLON INTEGER SEMICOLON  {yyerror(" Mot cle PROCEDURE/FUNCTION attendu"); }
						;
arguments:
	
	|LEFT_PARENTHESE liste_parametres{g_IfProcParameters = 0;}  RIGHT_PARENTHESE
	|LEFT_PARENTHESE  RIGHT_PARENTHESE;
 

liste_parametres:
     declaration_corps 
	|declaration_corps SEMICOLON liste_parametres
	|error SEMICOLON liste_parametres { yyerror("Declaration corps manquante"); }
	|declaration_corps error liste_parametres { yyerror("point virgule manquant"); }

instruction_composee: 
	BEGIN_TOKEN liste_instructions END {endProc(num_ligne); }
	|BEGIN_TOKEN END {endProc(num_ligne);}
	|error END { yyerror("BEGIN_TOKEN manquante"); }
	|BEGIN_TOKEN liste_instructions error { yyerror("end manquante"); }

liste_instructions:
	instruction SEMICOLON liste_instructions
	|instruction SEMICOLON
	|error SEMICOLON liste_instructions { yyerror("instruction manquante"); }
	|instruction error liste_instructions { yyerror("point virgule manquant"); }

instruction: 
	lvalue OPPAFFECT expression 
	|error OPPAFFECT expression { yyerror("lvalue manquante"); }
	|lvalue error expression { yyerror("operateur d'affectation manquant"); }
	|lvalue OPPAFFECT error { yyerror("expression manquante"); }

	|appel_methode
	|instruction_composee

	|IF expression THEN instruction ELSE instruction
	|error expression THEN instruction ELSE instruction { yyerror("if manquante"); }
	|IF error THEN instruction ELSE instruction { yyerror("expression apres if manquante"); }
	|IF expression error instruction ELSE instruction { yyerror("then manquante"); }
	|IF expression THEN error ELSE instruction { yyerror("instruction apres then manquante"); }
	|IF expression THEN instruction error instruction { yyerror("else manquante"); }
	|IF expression THEN instruction ELSE error { yyerror("instruction apres else manquante"); }


	|WHILE expression DO instruction
	|error expression DO instruction { yyerror("while manquante"); }
	|WHILE error DO instruction { yyerror("expression apres while manquante"); }
	|WHILE expression error instruction { yyerror("do manquante"); }
	|WHILE expression DO error { yyerror("instruction apres do manquante"); }

	|WRITE LEFT_PARENTHESE RIGHT_PARENTHESE
	|error LEFT_PARENTHESE RIGHT_PARENTHESE { yyerror("identificateur ou mot clé write manquant"); }
	|WRITE error RIGHT_PARENTHESE { yyerror("parenthese ouvrante manquante"); }
	|WRITE LEFT_PARENTHESE error { yyerror("parenthese fermante manquante"); }


	|WRITE LEFT_PARENTHESE liste_expressions RIGHT_PARENTHESE {g_nbParam = 0;}
	
	|WRITE error liste_expressions RIGHT_PARENTHESE{ yyerror("parenthese ouvrante manquante"); }
	|WRITE LEFT_PARENTHESE liste_expressions error{ yyerror("parenthese fermante manquante"); }

	|READ LEFT_PARENTHESE liste_identificateurs RIGHT_PARENTHESE {g_nbParam = 0;}

	|error LEFT_PARENTHESE liste_identificateurs RIGHT_PARENTHESE { yyerror("read manquant"); }
	|READ error liste_identificateurs RIGHT_PARENTHESE { yyerror("parenthese ouvrante manquante"); }
	|READ LEFT_PARENTHESE error RIGHT_PARENTHESE { yyerror("liste identificateurs manquante"); }
	|READ LEFT_PARENTHESE liste_identificateurs error { yyerror("parenthese fermante manquante"); }

lvalue 					:
						| IDENTIFIER 
						{
							if(checkIdentifierDeclared(nom,num_ligne)) {
								varInitialized (nom); 
							} 
						}
						| IDENTIFIER LEFT_BRACKETS expression RIGHT_BRACKETS

						|error LEFT_BRACKETS expression RIGHT_BRACKETS { yyerror("identificateur manquant"); }
						|IDENTIFIER  error expression error { yyerror("crochet  manquant"); }
						|IDENTIFIER LEFT_BRACKETS error RIGHT_BRACKETS { yyerror("expression manquante"); }
						;
appel_methode 			: IDENTIFIER {g_noeud = chercherNoeud(nom,table);} LEFT_PARENTHESE liste_expressions RIGHT_PARENTHESE
						{if ( g_noeud->nbParam != g_nbParam)
								yyerror("invalid number of parameters ");
							g_nbParam = 0;}

						| IDENTIFIER error {yyerror("Missing parentheses");}
						;
liste_expressions:
	expression {g_nbParam ++;}  COMMA liste_expressions
	|expression {g_nbParam ++;} 
	|error COMMA liste_expressions { yyerror("instruction manquante"); }
	|expression instruction COMMA liste_expressions { yyerror("point virgule manquant"); }

expression: 
	facteur
	|facteur addop facteur
	|facteur mulop facteur
	|facteur LESS_OR_EQ facteur
	|facteur MORE_OR_EQ facteur
	|facteur EQUAL facteur
	|facteur DIFF facteur

	|error addop facteur { yyerror("facteur manquant"); }
	|error mulop facteur { yyerror("facteur manquant"); }
	|error LESS_OR_EQ facteur { yyerror("facteur manquant"); }
	|error MORE_OR_EQ facteur { yyerror("facteur manquant"); }
	|error EQUAL facteur { yyerror("facteur manquant"); }
	|error DIFF facteur { yyerror("facteur manquant"); }

	|facteur error facteur { yyerror("addop ou mulop ou comparaison manquant"); }

	|facteur addop error { yyerror("facteur manquant"); }
	|facteur mulop error { yyerror("facteur manquant"); }
	|facteur LESS_OR_EQ error { yyerror("facteur manquant"); }
	|facteur MORE_OR_EQ error { yyerror("facteur manquant"); }
	|facteur EQUAL error { yyerror("facteur manquant"); }
	|facteur DIFF error { yyerror("facteur manquant"); }

mulop:
	MULT
	|DIV

addop:
	ADD
	|SOUSTRACT 

facteur 				: IDENTIFIER 
						{
							if(checkIdentifierDeclared(nom,num_ligne)) {
								checkVarInit(nom, num_ligne);
							}
						}
						| IDENTIFIER LEFT_BRACKETS expression RIGHT_BRACKETS
						| INT_LITERAL 
						| LEFT_PARENTHESE expression RIGHT_PARENTHESE
						;
						|error LEFT_BRACKETS expression RIGHT_BRACKETS { yyerror("identificateur manquant"); }
						|IDENTIFIER  error expression error { yyerror("crochet manquant"); }
						|IDENTIFIER LEFT_BRACKETS error RIGHT_BRACKETS { yyerror("expression manquante"); }


%% 



void yyerror(char * ch) {

	fprintf(stderr,"Erreur (ligne n %d): %s \n",num_ligne, ch);
}

extern FILE *yyin;

void Begin()
{
	//initialisations
	table = NULL;
	tableLocale = NULL;

	g_type = NODE_TYPE_UNKNOWN;

	g_index = 0;
	g_nbParam = 0;

	g_IfProc = 0 ;
    g_IfProcParameters = 0 ;

}

void End()
{
	//DisplaySymbolsTable(table);
	destructSymbolsTable(table);
}

main()
{
	Begin();
	yyparse();
	End();
	return(0);
}


                   
