#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/* run this program using the console pauser or add your own getch, system("pause") or input loop */

typedef enum {
	NODE_TYPE_UNKNOWN,
	tInt,
	tReal,
	tChar
} TYPE_IDENTIFIANT;

typedef enum {
	CLASSE_UNKNOWN,
	variable,
	procedure,
	parametre
} CLASSE;

struct NOEUD
{ 
    char* nom;
    TYPE_IDENTIFIANT type;
	CLASSE classe;
    int isInit; 
    int isUsed;
    int nbParam;
    
    struct NOEUD * suivant;
};

typedef struct NOEUD * NOEUD;
typedef NOEUD TABLE_SEMANTIQUE;

TABLE_SEMANTIQUE table, tableLocale;

// Variables Globales
NOEUD g_noeud, g_noeudProc;
NOEUD g_ListIdentifiers[100];

TYPE_IDENTIFIANT g_type;
int g_index;
int g_IfProc;
int g_IfProcParameters;
int g_nbParam;


NOEUD creerNoeud (const char* nom, TYPE_IDENTIFIANT type, CLASSE classe, NOEUD suivant){
    NOEUD noeud = (NOEUD)malloc(sizeof(struct NOEUD));
    noeud->nom = (char *)malloc(strlen(nom)+1);
    strcpy(noeud->nom, nom);
    noeud->type = type;
	noeud->classe = classe;
    noeud->suivant = suivant;
    return noeud;
}

NOEUD insererNoeud (NOEUD noeud, TABLE_SEMANTIQUE table) {
	if( !table ) {
		return noeud;
	}
	else {
		NOEUD last = table;
		while( last->suivant ) {
			last = last->suivant;
		}
		last->suivant = noeud;
		return table;
	}
}

NOEUD chercherNoeud (const char* nom, TABLE_SEMANTIQUE table) {
	if( !table )
		return NULL;
	NOEUD noeud = table;
	while( noeud && ( strcmp(nom, noeud->nom) != 0 ) )
		noeud = noeud->suivant;
	return noeud;
}

void destructSymbolsTable( TABLE_SEMANTIQUE table )
{
	if( !table )
		return;
	NOEUD noeud = table;
	while( noeud )
	{
		free(noeud->nom);
		free(noeud);
		noeud = noeud->suivant;
	}
}


void DisplaySymbolsTable( TABLE_SEMANTIQUE SymbolsTable ){
	printf("La table des Symboles \n");
	if( !SymbolsTable )
		return;
	NOEUD Node = SymbolsTable;
	while( Node )
	{
		switch( Node->type )
		{
			case tInt :
				printf("int ");
				break;
			
			case NODE_TYPE_UNKNOWN :
				switch (Node->classe)
				{
				case procedure:
					printf("procedure ");
					break;
				
				default:
					break;
				}


		}

		switch (Node->classe)
		{
			case variable:
				printf("variable ");
				break;

			case parametre:
				printf("parametre ");
				break;	

			default:
				break;
		}

	switch( Node->type )
		{
			case tInt :
				printf(" nom var %s", Node->nom);
				printf("\n");
				break;
			
			case NODE_TYPE_UNKNOWN :
				switch (Node->classe)
				{
				case procedure:
					printf(" nom proc %s", Node->nom);
					printf("\n");
					break;
				
				default:
					break;
				}
			}
		



		Node = Node->suivant;
	}
}


void checkIdentifier (char* nom, int num_ligne){
	CLASSE classe;

	if (g_IfProc){
		if (g_IfProcParameters){
			classe = parametre;
			g_nbParam ++;
		}else{
			classe = variable;
		}
		if( chercherNoeud(nom, tableLocale) ){
			fprintf(stderr,"Identifier already defined %d   \n",num_ligne);
		}else{
			NOEUD noeud = creerNoeud(nom, g_type, classe ,NULL);
			tableLocale = insererNoeud(noeud, tableLocale);
			g_ListIdentifiers[g_index] = noeud;
			g_index++;
		}
	}else{
		if( chercherNoeud(nom, table) ){
			fprintf(stderr,"Identifier already defined %d  \n",num_ligne);
		}else{
			NOEUD noeud = creerNoeud(nom, g_type, variable ,NULL);
			table = insererNoeud(noeud, table);
			g_ListIdentifiers[g_index] = noeud;
			g_index++;
		}
	}
}

int checkIdentifierDeclared (char* nom, int num_ligne){

	NOEUD noeud;

	if (g_IfProc){
		noeud = chercherNoeud(nom,tableLocale);
		if ( !noeud ){
			noeud = chercherNoeud(nom,table);
			if( !noeud ){
				fprintf(stderr,"Variable undeclared %d  \n",num_ligne);
				return 0;
			}else
			{
				noeud->isUsed = 1;
			}
		}else
		{
			noeud->isUsed = 1;
		}
	}else{
		noeud = chercherNoeud(nom,table);
		if( !noeud ){
				fprintf(stderr,"Variable undeclared %d  \n",num_ligne);
				return 0;
		}else
		{
			noeud->isUsed = 1;
		}
	}
	return 1;
}

void varInitialized (char* nom){

	NOEUD noeud;

	if (g_IfProc){
		noeud = chercherNoeud(nom,tableLocale);
		if ( !noeud )
			noeud = chercherNoeud(nom,table);
	}else{
		noeud = chercherNoeud(nom,table);
	}
    noeud->isInit = 1;
}

void checkVarInit (char* nom,int num_ligne){

	NOEUD noeud;
	
	if (g_IfProc){
		noeud = chercherNoeud(nom,tableLocale);
		if ( !noeud )
			noeud = chercherNoeud(nom,table);
	}else{
		noeud = chercherNoeud(nom,table);
	}
	if(noeud && noeud->classe == variable && !noeud->isInit)
		fprintf(stderr,"Variable not initialized %d  \n",num_ligne);
}

void endProc(int num_ligne)
{
	NOEUD tmp_table;
	if (g_IfProc == 1){
		// printf("*** Table Locale ***\n");
		// DisplaySymbolsTable( tableLocale );
		g_IfProc = 0;
		tmp_table = tableLocale;
		tableLocale = NULL;
	}else{
		// printf("*** Table Globale ***\n");
		// DisplaySymbolsTable( table );
		tmp_table = table;
	}
	while( tmp_table ){
			if (tmp_table->classe == variable && !tmp_table->isUsed)
				 fprintf(stderr,"Variable declared not used %d  \n",num_ligne);
			tmp_table = tmp_table->suivant;
	}
}

int print_error(char * msg, int num_ligne) 
{
	fprintf(stderr,"Error on line %d : %s\n", num_ligne, msg);
	return(1);
}

