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

FILE* pf_TS;
char notacion_intermedia[200];

int tipo_de_la_def;

typedef struct{

int posicion;
char nombre[30];
char tipo[20];

char valor[100];
int longitud;

} TS_reg;
 TS_reg tabla_simbolos[100];

 
/**********************************/
/*******VARIABLES INTERMEDIA*******/
/**********************************/

/*crearTerceto_simple()*/
/*crearTerceto_simple()*/
#define TERCETO_SIMPLE_VARIABLE  0 //(VAR_,_)
#define TERCETO_SIMPLE_CONSTANTE  1 //(CONST_,_)
#define TERCETO_CON_TERCETOS  2 //(OPERADOR,TERCETO,TERCETO)
#define TERCETO_TERCETO_VARIABLE  3 //(OPERADOR,TERCETO,VARIABLE)
#define TERCETO_TERCETO_CONSTANTE  4 //(OPREADOR,TERCETO,CONSTANTE)
#define TERCETO_VARIABLE_VARIABLE  5 //(OPERADOR,VARIABLE,VARIABLE)
#define TERCETO_VARIABLE_TERCETO  6 //(OPERADOR,VARIABLE,TERCETO)
#define TERCETO_CONSTANTE_TERCETO  7 //(OPERADOR,CONST,TERCETO)
#define TERCETO_IF_RESERVA  8 //(OPERADOR,CONST,TERCETO)
#define TERCETO_IF_COMPLETA 9
#define TERCETO_WHILE_RESERVA 10
#define TERCETO_WHILE_COMPLETA 11
#define TERCETO_BETWEEN_RESERVA 12
#define TERCETO_BETWEEN_COMPLETA 13
#define TERCETO_ASIG_RESERVA 14
#define TERCETO_ASIG_COMPLETA 15


int Pos_indice=0;
int Factor_ind=0;
int Termino_ind=0;
int Comparador_ind=0;
int Condicion_ind=0;
int Programa_ind=0;
int Asignacion_ind=0;
int lista_ind=0;
int IF_ind=0;
int WHILE_ind=0;
int BETWEEN_ind=0;
int Expresion_ind=0;
int Expresion_izq_ind=0;
int Expresion_der_ind=0;
	
int const_entera;
int const_entera1;
int crear_terceto(int,int,char*,char*,char*);
void modificar_tipo(int,char*);

char* Comparador_id[3];

int pila_de_if=0;
int tipo_procesando=0;

%}


/**********************************/
/**********SECCION TOKENS**********/
/**********************************/
%union {
        int num;
        double flot;
        char* str;
    }

%token <str> VAR
%token <num> ENTERO
%token <flot> FLOAT
%token <str> STRING
%token OP_ASIG

%token PR_INICIO
%token PR_FIN
%token PR_DECVAR
%token PR_ENDDEC
%token <num> CONST_INT
%token <flot> CONST_FLOT
%token <str> CONST_STR
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

%type <str> asig
%type <str> sent
%type <str> lista_var
%type <str> termino
%type <str> expresion
%type <str> factor
%type <str> constante
%type <str> iteracion
%type <str> decision
%type <str> entrada
%type <str> salida
%type <str> condicion
%type <str> sentencia
%type <str> entre
%type <str> tipo
%type <str> dec
%type <str> lista_def
%type <str> cond_simple
%type <str> cond_mult
%type <str> expresion_izq
%type <str> expresion_der


/**********************************/
/***SECCION DEFINICION DE REGLAS***/
/**********************************/

%%
programa:  	   
	declaracion programa;

programa:  	   
	PR_INICIO {printf(" Inicia COMPILADOR\n");	} sentencia {	printf(" Fin COMPILADOR - OK\n");}	PR_FIN;

declaracion:
	PR_DECVAR {printf(" Inicia declaraciones\n");} linea_dec {printf(" Fin de las Declaraciones\n");} PR_ENDDEC;

linea_dec:
	linea_dec dec
	| dec;

dec:
	lista_def PR_DOSP tipo {
							if (tipo_procesando==1)
							printf("procesando INT\n\n");
							if (tipo_procesando==2)
							printf("procesando FLOAT\n\n");
							if (tipo_procesando==3)
							printf("procesando STRING\n\n");

							};
lista_def:
	lista_def PR_COMA VAR{
						/*printf("variable a procesar lista_def=lista_def PR_COMA VAR: %s\n",$3);*/
						modificar_tipo(tipo_procesando,$3);
						};
lista_def:
	VAR {
		/*int a;
		printf("variable %s esta en %d\n",$1,busca_en_TS($1));
		printf("variable %s esta en %d\n","pepe",busca_en_TS("pepe"));
	 	a=busca_en_TS($1);
	 	if(busca_en_TS($1) != -1)
     	{
     		printf("pos: %d - nombre: %s - tipo: %s - valor: %s - longitud: %d\n",tabla_simbolos[a].posicion,tabla_simbolos[a].nombre,
     				tabla_simbolos[a].tipo,tabla_simbolos[a].valor,tabla_simbolos[a].longitud);

			tabla_simbolos[a].longitud=tipo_de_la_def;
		};*/
			/*printf("variable a procesar en lista_dev=var: %s\n",$1);*/
			modificar_tipo(tipo_procesando,$1);
	};


sentencia:
	sentencia sent;	

sentencia:
	sent {printf(" Inicia sentencia\n");};

sent:	iteracion
		| decision
		| asig {printf(" Inicia asig\n");};
		| entrada
		| salida;

iteracion:
	WHILE PR_AP condicion PR_CP PR_ALL sentencia PR_CLL {printf(" Inicia WHILE\n");}

decision:
	IF PR_AP condicion PR_CP PR_ALL sentencia PR_CLL{
		printf(" Inicia if\n");
		Condicion_ind=crear_terceto(TERCETO_IF_COMPLETA,Comparador_ind,"_","_","_");
		$$=$3;};

decision:
	IF PR_AP condicion PR_CP PR_ALL sentencia PR_CLL ELSE PR_ALL sentencia PR_CLL
	{
		/*printf(" Inicia if\n");*/
		/*printf(" %s - %s - %s\n",$3,$6,$10);*/
		$$=$3;
	};

asig:
	lista_var OP_ASIG expresion
					{
					Asignacion_ind=crear_terceto(TERCETO_CON_TERCETOS,Asignacion_ind,"=",(char*)lista_ind,(char*)Expresion_ind);
					}
lista_var:
	lista_var OP_ASIG VAR {/*Termino_ind=crear_terceto(0,0,"*",(char*)Termino_ind,(char*)Factor_ind);*/
					printf(" Entro en lista = lista asig VAR\n");
					printf("[0] (%c,%d,%d)\n",'=',$1,$3);
					};
lista_var:
	VAR {
		lista_ind=crear_terceto(TERCETO_SIMPLE_VARIABLE,lista_ind,$1,"_","_");
		};

entrada:
	READ VAR {printf(" Inicia READ\n");} 

salida:
	WRITE VAR {printf(" Inicia WRITE de variable\n");}

salida:
	WRITE constante {printf(" Inicia WRITE de constante\n");} 

tipo:
	ENTERO {tipo_procesando=1;};
	| STRING {tipo_procesando=3;};
	| FLOAT {tipo_procesando=2;};

condicion:
	cond_simple;
condicion:
	cond_mult;
cond_mult:
	cond_simple nexo cond_simple;
cond_mult:
	PR_NOT cond_simple{$$=$2;};
cond_simple:
	expresion_izq comparador expresion_der
						{
							Condicion_ind=crear_terceto(TERCETO_CON_TERCETOS,Comparador_ind,(char*)Comparador_id,(char*)Expresion_izq_ind,(char*)Expresion_der_ind);
							Condicion_ind=crear_terceto(TERCETO_IF_RESERVA,Comparador_ind,"_","_","_");
						}
cond_simple:
	entre;

comparador:
	OP_MAYOR {strcpy((char*)Comparador_id,">");};
comparador:
	OP_MENOR {strcpy((char*)Comparador_id,"<");};
comparador:
	OP_IGUAL {strcpy((char*)Comparador_id,"==");};
comparador:
	OP_DISTINTO {strcpy((char*)Comparador_id,"!=");};
comparador:
	OP_MAYORIGUAL {strcpy((char*)Comparador_id,">=");};
comparador:	
	OP_MENORIGUAL {strcpy((char*)Comparador_id,"<=");};

nexo:
	PR_AND | PR_OR

expresion_izq:
	expresion {Expresion_izq_ind=Expresion_ind;};

expresion_der:
	expresion {Expresion_der_ind=Expresion_ind;};

expresion:
	expresion OP_SUMA termino
						{
						Expresion_ind=crear_terceto(TERCETO_CON_TERCETOS,Expresion_ind,"+",(char*)Expresion_ind,(char*)Termino_ind);
						} 
expresion:
	expresion OP_RESTA termino
						{
						Expresion_ind=crear_terceto(TERCETO_CON_TERCETOS,Expresion_ind,"-",(char*)Expresion_ind,(char*)Termino_ind);
						}
expresion:
	termino{Expresion_ind=Termino_ind;};

termino:
	termino OP_MULT factor
					{
					Termino_ind=crear_terceto(TERCETO_CON_TERCETOS,Termino_ind,"*",(char*)Termino_ind,(char*)Factor_ind);
					}
termino:
	termino OP_DIV factor
					{
					Termino_ind=crear_terceto(TERCETO_CON_TERCETOS,Termino_ind,"/",(char*)Termino_ind,(char*)Factor_ind);
					}
termino:
	factor{		Termino_ind=Factor_ind;	};

factor:
	VAR     	{
				Factor_ind=crear_terceto(TERCETO_SIMPLE_VARIABLE,Factor_ind,$1,"_","_");
				}
factor:
	constante	{
				Factor_ind=crear_terceto(TERCETO_SIMPLE_CONSTANTE,Factor_ind,$1,"_","_");
				};
factor:	
	PR_AP expresion PR_CP {	$$=$2;
							Factor_ind=Expresion_ind;};
	
constante:
	CONST_STR	{$$ = $1;}
constante:
	CONST_INT	{}
constante:
	CONST_FLOT	{}

entre:
	BETWEEN PR_AP VAR PR_COMA PR_AC expresion PR_PYC expresion PR_CC PR_CP
				{printf(" Inicia BETWEEN\n");}

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

int graba_intermedia(char* notacion)
{
     int i;
     char* INTERMEDIA_file = "intermedia.txt";
     if((pf_TS = fopen(INTERMEDIA_file, "a")) == NULL)
     {
        printf("Error al escribir el archivo de la notacion intermedia\n");
        exit(1);
     }
     fprintf(pf_TS, "%s",notacion);
     fclose(pf_TS);
} 

int crear_terceto(int tipo_de_terceto, int ter,char* a,char* b,char* c)
{
int a1;
char cadena[200];
switch (tipo_de_terceto)
{
case TERCETO_SIMPLE_VARIABLE:
	sprintf(cadena, "[%d] (%s,_,_)\n",Pos_indice,a);
	graba_intermedia(cadena);
	break;
case TERCETO_SIMPLE_CONSTANTE:
	sprintf(cadena, "[%d] (%d,_,_)\n",Pos_indice,a);
	graba_intermedia(cadena);
	break;
case TERCETO_CON_TERCETOS:
	sprintf(cadena, "[%d] (%s,[%d],[%d])\n",Pos_indice,a,b,c);
	graba_intermedia(cadena);
	break;
case TERCETO_TERCETO_VARIABLE:
	sprintf(cadena, "[%d] (%s,%s,%d)\n",Pos_indice,a,b,c);
	graba_intermedia(cadena);
	break;
case TERCETO_TERCETO_CONSTANTE:
	sprintf(cadena, "[%d] (%s,%s,%s)\n",Pos_indice,a,b,c);
	graba_intermedia(cadena);
	break;
case TERCETO_VARIABLE_VARIABLE:
	sprintf(cadena, "[%d] (%s,%s,%s)\n",Pos_indice,a,b,c);
	graba_intermedia(cadena);
	break;
case TERCETO_VARIABLE_TERCETO:
	sprintf(cadena, "[%d] (%s,%s,%s)\n",Pos_indice,a,b,c);
	graba_intermedia(cadena);
	break;
case TERCETO_CONSTANTE_TERCETO:
	sprintf(cadena, "[%d] (%s,%s,%s)\n",Pos_indice,a,b,c);
	graba_intermedia(cadena);
	break;
case TERCETO_IF_RESERVA:
	pila_de_if=Pos_indice-1;
	printf("guardando if\n");
	/*graba_intermedia(cadena);*/
	break;
case TERCETO_IF_COMPLETA:
	sprintf(cadena, "[%d] (BGE,%d,_)\n",pila_de_if+1,Pos_indice);
	Pos_indice--;
	graba_intermedia(cadena);
	break;
}
Pos_indice++;
return Pos_indice-1;
}


void modificar_tipo(int tipo_a_modificar,char*variable_a_modificar)
{

int ind_tmp,b;
ind_tmp=busca_en_TS(variable_a_modificar);
/*printf("variable: %d\n",ind_tmp);*/
    

 if((b = tabla_simbolos[ind_tmp].posicion) != -1)
 		if (strcmp(tabla_simbolos[ind_tmp].tipo,"VAR"))
 		{
 			printf(" %s es variable y tiene tipo %s\n",tabla_simbolos[ind_tmp].nombre,tabla_simbolos[ind_tmp].tipo);
 			strcpy(tabla_simbolos[ind_tmp].tipo,"VAR_INT");
 		}
 		else
			printf(" %s NO es variable porque tiene tipo %s\n",tabla_simbolos[ind_tmp].nombre,tabla_simbolos[ind_tmp].tipo);


/*int inserta_en_TS(char* tipo,char* valor)
{
	 if((yylval.num = busca_en_TS(yytext)) == -1)
     {
		TS_reg reg;
		strcpy(reg.nombre, yytext);
		strcpy(reg.tipo, tipo);
		strcpy(reg.valor, valor);
		reg.longitud = strlen(yytext);
		reg.posicion = cant_simbolos;
		tabla_simbolos[cant_simbolos++] = reg;
		return yylval.num = cant_simbolos-1;
	 }
*/


}

