/**********************************/
/*******SECCION DEFINICIONES*******/
/**********************************/

%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"
int yystopparser=0;
FILE  *yyin;

typedef struct{

int posicion;
char nombre[30];
char tipo[20];

char valor[100];
int longitud;

} TS_reg;
 TS_reg tabla_simbolos[100];
char* yytext;


%}

/**********************************/
/**********SECCION TOKENS**********/
/**********************************/


%token VAR
%token ENTERO
%token FLOAT
%token STRING
%token OP_ASIG

%token PR_INICIO
%token PR_FIN
%token PR_DECVAR
%token PR_ENDDEC
%token CONST_INT
%token CONST_FLOT
%token CONST_STR
%token IF
%token ELSE
%token WHILE
%token BETWEEN
%token OP_SUMA
%token OP_RESTA
%token OP_MULT
%token OP_DIV
%token READ
%token WRITE
%token PR_PYC
%token PR_DOSP
%token PR_COMA
%token PR_NOT
%token PR_AND
%token PR_OR
%token PR_AP
%token PR_CP
%token PR_AC
%token PR_CC
%token PR_ALL
%token PR_CLL
%token OP_MAYOR
%token OP_MENOR
%token OP_IGUAL
%token OP_DISTINTO
%token OP_MAYORIGUAL
%token OP_MENORIGUAL


/**********************************/
/***SECCION DEFINICION DE REGLAS***/
/**********************************/

%%
programa:  	   
	declaracion programa;

programa:  	   
	PR_INICIO {printf(" Inicia COMPILADOR\n");} sentencia {printf(" Fin COMPILADOR - OK\n");} PR_FIN;

declaracion:
	PR_DECVAR {printf(" Inicia declaraciones\n");} linea_dec {printf(" Fin de las Declaraciones\n");} PR_ENDDEC;

linea_dec:
	linea_dec dec | dec;

dec:
	lista_def PR_DOSP tipo;

lista_def:
	lista_def PR_COMA VAR;
lista_def:
	VAR;


sentencia:
	sentencia sent;	

sentencia:
	sent;

sent:	iteracion | decision | asig | entrada | salida;

iteracion:
	WHILE {printf(" Inicia WHILE\n");} PR_AP condicion PR_CP PR_ALL sentencia PR_CLL;

decision:
	IF PR_AP condicion PR_CP PR_ALL sentencia PR_CLL ELSE PR_ALL sentencia PR_CLL;
decision:
	IF PR_AP condicion PR_CP PR_ALL sentencia PR_CLL;

asig:
	lista_var OP_ASIG expresion {printf(" Inicia asignacion\n");};
lista_var:
	lista_var OP_ASIG VAR;
lista_var:
	VAR;

entrada:
	READ {printf(" Inicia READ\n");} VAR;

salida:
	WRITE {printf(" Inicia WRITE de variable\n");} VAR;

salida:
	WRITE {printf(" Inicia WRITE de constante\n");} constante;

tipo:
	ENTERO | STRING | FLOAT 

condicion:
	cond_simple;
condicion:
	cond_mult;
cond_mult:
	cond_simple nexo cond_simple;
cond_mult:
	PR_NOT cond_simple;
cond_simple:
	expresion comparador expresion;
cond_simple:
	entre;
comparador:
	OP_MAYOR | OP_MENOR | OP_IGUAL | OP_DISTINTO | OP_MAYORIGUAL | OP_MENORIGUAL;
nexo:
	PR_AND | PR_OR

expresion:
	expresion OP_SUMA {printf(" Realiza SUMA\n");} termino;
expresion:
	expresion OP_RESTA {printf(" Realiza Resta\n");} termino;
expresion:
	termino;
termino:
	termino OP_MULT {printf(" Realiza Multiplacion\n");} factor;
termino:
	termino OP_DIV {printf(" Realiza Division\n");} factor;
termino:
	factor;

factor:
	VAR | constante | PR_AP expresion PR_CP;
constante:
	CONST_STR | CONST_INT | CONST_FLOT;

entre:
	BETWEEN {printf(" Inicia BETWEEN\n");} PR_AP VAR PR_COMA PR_AC expresion PR_PYC expresion PR_CC PR_CP;

%%

/**********************************/
/**********SECCION CODIGO**********/
/**********************************/

int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else
  {
	yyparse();
  }
  fclose(yyin);
  return 0;
}

int yyerror(char const *line)
{
	printf("Syntax Error\n");   
	exit (1);
}
