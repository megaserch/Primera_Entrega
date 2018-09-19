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
 TS_reg tabla_simb[100];
FILE* pf_intermedio;

char listaDeTipos[][100]={"."};
char listaDeIDs[][100]={"."};

int cantidadTipos=0;              
int cantidadIDs=0;     
char* yytext;






int grabar_archivo();
void agregarTipo(char * );
void agregarIDs(char * );



void printfTabla(TS_reg); 

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
%token CONST_REAL
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
	PR_INICIO {printf(" Inicia COMPILADOR\n");grabar_archivo();} sentencia {printf(" Fin COMPILADOR ok\n");} PR_FIN;

declaracion:
	PR_DECVAR {printf("DECLARACIONES\n");} linea_dec {printf(" Fin de las Declaraciones\n");} PR_ENDDEC;

linea_dec:
	linea_dec dec | dec;

dec:  
	VAR PR_DOSP tipo;

sentencia:
	sentencia sent;	

sentencia:
	sent;

sent:	iteracion | decision | asig | entrada | salida;

iteracion:
	WHILE PR_AP condicion PR_CP PR_ALL sentencia PR_CLL;

decision:
	IF PR_AP condicion PR_CP PR_ALL sentencia PR_CLL ELSE PR_ALL sentencia PR_CLL;
decision:
	IF PR_AP condicion PR_CP PR_ALL sentencia PR_CLL;

asig:
	lista_var OP_ASIG expresion {printf(" entro en asig exp\n");};
lista_var:
	lista_var OP_ASIG VAR;
lista_var:
	VAR;

entrada:
	READ VAR;

salida:
	WRITE VAR;

salida:
	WRITE constante;

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
	expresion OP_SUMA termino;
expresion:
	expresion OP_RESTA termino;
expresion:
	termino;
termino:
	termino OP_MULT factor;
termino:
	termino OP_DIV factor;
termino:
	factor;

factor:
	VAR | constante | PR_AP expresion PR_CP;
constante:
	CONST_STR | CONST_INT | CONST_REAL;

entre:
	BETWEEN PR_AP VAR PR_COMA PR_AC expresion PR_PYC expresion PR_CC PR_CP;

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
/**********************TIPO y IDS***************************/
void agregarTipo(char * tipo)
{
	strcpy(listaDeTipos[cantidadTipos],tipo);
	cantidadTipos++;
}

void agregarIDs(char * id)
{
	strcpy(listaDeIDs[cantidadIDs],id);
	cantidadIDs++;
	printf("IDDDDDDDDDDDDDDDD %s %d\n",listaDeIDs[cantidadIDs], cantidadIDs);
}
/******************************************************/


/*******************Escribir arhivo**********************/





void printfTabla(TS_reg linea_tabla)
{
	printf("pos:%d nom:%s tipo:%s val:%s long:%d \n",linea_tabla.posicion,linea_tabla.nombre,linea_tabla.tipo,linea_tabla.valor,linea_tabla.longitud);
}

int grabar_archivo()
{
     int i;
     char* TS_file = "intermedia.txt";
     
     if((pf_intermedio = fopen(TS_file, "w")) == NULL)
     {
               printf("Error al grabar el archivo de intermedio \n");
               exit(1);
     }
     
     fprintf(pf_intermedio, "Codigo Intermedio \n");
     
    /*  for(i = 0; i < cant_entradas; i++)
      {
           fprintf(pf_TS,"%d \t\t\t\t %s \t\t\t", tabla_simb[i].posicion, tabla_simb[i].nombre);
           
          
            if(tabla_simb[i].tipo != NULL)
               fprintf(pf_TS,"%s \t\t\t", tabla_simb[i].tipo);
           
          
            if(tabla_simb[i].valor != NULL)
               fprintf(pf_TS,"%s \t\t\t", tabla_simb[i].valor);
           
            fprintf(pf_TS,"%d \n", tabla_simb[i].longitud);
      }*/    
     fclose(pf_intermedio);
} 


