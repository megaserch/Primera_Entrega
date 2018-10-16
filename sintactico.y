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
/******pilas***********************/
/**********************************/
struct lifo
{
	int elm; /*variable que coniene el elmento de tipo entero*/
	char tipo_salto[31];
	int tipo_de_nexo;
	struct lifo *nxt; /*nodo que apunta al siguiente en la pila*/
};

typedef struct lifo *pila; 
pila crearpila();
pila push(pila p,int elm,char* tipo_cmp,int t_nexo);
pila pop(pila p);
int peek(pila p);
pila invertir(pila p);
void cargar_nexo(pila p,int t_nexo);


pila pila_dec;
pila pila_tercetos;
pila pila_while;
pila pila_var;

/*listas*/
struct lista_tercetos
{
    int numero_de_terceto;
    char a[31];
    char b[31];
    char c[31];
    char cad[200];
    struct lista_tercetos *sig;
};

typedef struct lista_tercetos *l_tercetos;

void liberar(void);
int vacia(void);
void imprimir(void);
void insertar(int x);
void insertar_terc(l_tercetos x);

l_tercetos terceto_ordenados;

void invertir_cmp(char*);
 
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
#define TERCETO_READ 16
#define TERCETO_WRITE_CTE 17
#define TERCETO_WRITE_VAR 18
#define TERCETO_ELSE_RESERVA 19
#define TERCETO_ELSE_COMPLETA 20



int Pos_indice=0;
int Factor_ind=0;
int Termino_ind=0;
int Comparador_ind=0;
int Condicion_ind=0;
int Programa_ind=0;
int Asignacion_ind=0;
int lista_ind=0;
int lista_ind_mult=0;
int IF_ind=0;
int WHILE_ind=0;
int BETWEEN_ind=0;
int Expresion_ind=0;
int Expresion_izq_ind=0;
int Expresion_der_ind=0;
int Expresion_min_ind=0;
int Expresion_max_ind=0;
int Var_between_ind=0;
	
int const_entera;
int const_entera1;
int crear_terceto(int,int,char*,char*,char*);


char Comparador_id[3];

int pila_de_if=0;
int tipo_procesando=0;
int es_multiple=0;
int es_not=0;

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
%token <str> PR_NOT
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
%type <str> cuerpo_if
/*%type <str> tipo*/
%type <str> dec
%type <str> lista_def
%type <str> cond_simple
%type <str> cond_mult
%type <str> expresion_izq
%type <str> expresion_der
%type <str> expresion_min
%type <str> expresion_max


/**********************************/
/***SECCION DEFINICION DE REGLAS***/
/**********************************/

%%
programa:  	   
	declaracion programa;

programa:  	   
	PR_INICIO {printf(" Inicia COMPILADOR\n");	} sentencia {	imprimir(); printf(" Fin COMPILADOR - OK\n");}	PR_FIN;

declaracion:
	PR_DECVAR {printf(" Inicia declaraciones\n");} linea_dec {	printf(" Fin de las Declaraciones\n");
																while (pila_dec!=NULL)	{
																			modifica_TS(tipo_procesando,tabla_simbolos[pila_dec->elm].nombre);
																			pila_dec=pop(pila_dec);		}
																			} PR_ENDDEC;

linea_dec:
	linea_dec dec
	| dec;

dec:
	lista_def PR_DOSP tipo


lista_def:
	lista_def PR_COMA VAR{	pila_dec=push(pila_dec,busca_en_TS($3),"_",0);	};

lista_def:
	VAR {	pila_dec=push(pila_dec,busca_en_TS($1),"_",0);	};

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
	WHILE {Condicion_ind=crear_terceto(TERCETO_WHILE_RESERVA,Comparador_ind,"_","_","_");} PR_AP condicion PR_CP 
			PR_ALL sentencia PR_CLL {$$=$4; Condicion_ind=crear_terceto(TERCETO_WHILE_COMPLETA,Comparador_ind,"_","_","_");
				printf(" Inicia WHILE\n");}

/*iteracion:
	WHILE PR_AP condicion PR_CP PR_ALL sentencia PR_CLL {$$=$3;}*/

decision:
	IF PR_AP condicion PR_CP {printf("apilar if\n");} cuerpo_if {
		printf(" salio del cuerpo del if\n");
		Condicion_ind=crear_terceto(TERCETO_IF_COMPLETA,Comparador_ind,$3,"_","_");
		$$=$3;
		};

cuerpo_if:
	PR_ALL sentencia PR_CLL {$$=$2;}
	|	PR_ALL sentencia PR_CLL ELSE {
		Condicion_ind=crear_terceto(TERCETO_ELSE_COMPLETA,Comparador_ind,"_","_","_");
		Condicion_ind=crear_terceto(TERCETO_IF_RESERVA,Comparador_ind,"JMP","_","_");
		printf("apilar else\n");}
		PR_ALL sentencia PR_CLL  {	printf("desapilar else\n");$$=$2;}

asig:
	lista_var OP_ASIG expresion
					{
						while(es_multiple!=0)
						{

							lista_ind=crear_terceto(TERCETO_SIMPLE_VARIABLE,lista_ind,pila_var->tipo_salto,"_","_");
							Asignacion_ind=crear_terceto(TERCETO_CON_TERCETOS,Asignacion_ind,"=",(char*)lista_ind,(char*)Expresion_ind);
							pila_var=pop(pila_var);
							es_multiple--;
						}
						/*es_multiple=0;*/
					/*Asignacion_ind=crear_terceto(TERCETO_ASIG_COMPLETA,lista_ind,(char*)Expresion_ind,"_","_");*/
					/*Asignacion_ind=crear_terceto(TERCETO_CON_TERCETOS,Asignacion_ind,"=",(char*)lista_ind,(char*)Expresion_ind);*/
					
						/*printf("\n\nterceto con variable %d\n\n",pila_var->elm);
						pila_var=pop(pila_var);
						crear_terceto(TERCETO_ASIG_COMPLETA,0,$1,"_","_");*/
					/*aca desapilo y meto expresion en el medio*/
					}
lista_var:
	lista_var OP_ASIG VAR {/*Termino_ind=crear_terceto(0,0,"*",(char*)Termino_ind,(char*)Factor_ind);*/
					/*Termino_ind=crear_terceto(TERCETO_ASIG_RESERVA,0,$3,"_","_");*/
					/*ESTO VA COMO PIÑA
					es_multiple=1;
					lista_ind=crear_terceto(TERCETO_SIMPLE_VARIABLE,lista_ind,$3,"_","_");
					lista_ind_mult=crear_terceto(TERCETO_SIMPLE_VARIABLE,lista_ind,"V.A.","_","_");
					Asignacion_ind=crear_terceto(TERCETO_CON_TERCETOS,Asignacion_ind,"=",(char*)lista_ind,(char*)lista_ind_mult);
					ESTO VA COMO PIÑA */
					pila_var=push(pila_var,lista_ind,$3,0);
					es_multiple++;
					/*pila_var=push(pila_var,lista_ind,"=",0);*/
					/*aca de guardan las variables*/
					};
lista_var:
	VAR {/*PONER ACA RESERVA DE ESPACIO PARA LA EXPRESION*/
		/* ESTO VA COMO PIÑA
		lista_ind=crear_terceto(TERCETO_SIMPLE_VARIABLE,lista_ind,"V.A.","_","_");
		lista_ind_mult=crear_terceto(TERCETO_ASIG_RESERVA,lista_ind,"V.A.","_","_");
		Asignacion_ind=crear_terceto(TERCETO_CON_TERCETOS,Asignacion_ind,"=",(char*)lista_ind,(char*)lista_ind_mult);
		lista_ind=crear_terceto(TERCETO_SIMPLE_VARIABLE,lista_ind,$1,"_","_");
		lista_ind_mult=crear_terceto(TERCETO_SIMPLE_VARIABLE,lista_ind,"V.A.","_","_");
		Asignacion_ind=crear_terceto(TERCETO_CON_TERCETOS,Asignacion_ind,"=",(char*)lista_ind,(char*)lista_ind_mult);
		ESTo VA COMO PIÑA */
		/*lista_ind=crear_terceto(TERCETO_ASIG_COMPLETA,lista_ind,"V.A.","_","_");*/
		pila_var=push(pila_var,lista_ind,$1,0);
		es_multiple++;
		};

entrada:
	READ VAR {printf(" Inicia READ\n");
				crear_terceto(TERCETO_READ,0,$2,"_","_");
				} 

salida:
	WRITE VAR {printf(" Inicia WRITE de variable\n");
			crear_terceto(TERCETO_WRITE_VAR,0,$2,"_","_");
				}

salida:
	WRITE constante {printf(" Inicia WRITE de constante\n");
			printf("\n$2 = %d\n",$2);
			crear_terceto(TERCETO_WRITE_CTE,0,(char*)$2,"_","_");
				} 

tipo:
	ENTERO {tipo_procesando=1;
			while (pila_dec!=NULL)	{
				modifica_TS(1,tabla_simbolos[pila_dec->elm].nombre);
				pila_dec=pop(pila_dec);	}
			};
	| STRING {tipo_procesando=3;
			while (pila_dec!=NULL)	{
				modifica_TS(3,tabla_simbolos[pila_dec->elm].nombre);
				pila_dec=pop(pila_dec);	}
			};
	| FLOAT {tipo_procesando=2;
			while (pila_dec!=NULL)	{
				modifica_TS(2,tabla_simbolos[pila_dec->elm].nombre);
				pila_dec=pop(pila_dec);	}
			};

condicion:
	cond_mult;

condicion:
	cond_simple;

cond_mult:
	cond_simple PR_AND cond_simple {cargar_nexo(pila_tercetos,1);}
	/*{Condicion_ind=crear_terceto(TERCETO_IF_COMPLETA,Comparador_ind,$3,"_","_");};*/

cond_mult:
	cond_simple PR_OR cond_simple {cargar_nexo(pila_tercetos,2);
									/*Condicion_ind=crear_terceto(TERCETO_IF_COMPLETA,Comparador_ind,$3,"_","_");*/};

cond_mult:
	PR_NOT { 
			es_not=1;
			printf("\n\n\nES UNA NOT!!!\n\n\n");
			} cond_simple;

cond_simple:
	expresion_izq comparador expresion_der
						{ $$=$1;
							printf("\n\n\nEntro???\n\n\n");
							Condicion_ind=crear_terceto(TERCETO_CON_TERCETOS,Comparador_ind,"CMP",(char*)Expresion_izq_ind,(char*)Expresion_der_ind);
							if (es_not==0)
							{
							Condicion_ind=crear_terceto(TERCETO_IF_RESERVA,Comparador_ind,Comparador_id,"_","D");
							}
							else
							{
							Condicion_ind=crear_terceto(TERCETO_IF_RESERVA,Comparador_ind,Comparador_id,"_","N");
							es_not=0;
							}
						}
cond_simple:
	entre;

comparador:
	OP_MAYOR {strcpy(Comparador_id,"JLE");};
comparador:
	OP_MENOR {strcpy(Comparador_id,"JGE");};
comparador:
	OP_IGUAL {strcpy(Comparador_id,"JNE");};
comparador:
	OP_DISTINTO {strcpy(Comparador_id,"JE");};
comparador:
	OP_MAYORIGUAL {strcpy(Comparador_id,"JL");};
comparador:	
	OP_MENORIGUAL {strcpy(Comparador_id,"JG");};

/*nexo:
	PR_AND | PR_OR*/

expresion_izq:
	expresion {Expresion_izq_ind=Expresion_ind;};

expresion_der:
	expresion {Expresion_der_ind=Expresion_ind;};

expresion_min:
	expresion {Expresion_min_ind=Expresion_ind;};

expresion_max:
	expresion {Expresion_max_ind=Expresion_ind;};

expresion:
	expresion OP_SUMA termino
						{Expresion_ind=crear_terceto(TERCETO_CON_TERCETOS,Expresion_ind,"+",(char*)Expresion_ind,(char*)Termino_ind);} 
expresion:
	expresion OP_RESTA termino
						{Expresion_ind=crear_terceto(TERCETO_CON_TERCETOS,Expresion_ind,"-",(char*)Expresion_ind,(char*)Termino_ind);}
expresion:
	termino{Expresion_ind=Termino_ind;};

termino:
	termino OP_MULT factor
					{Termino_ind=crear_terceto(TERCETO_CON_TERCETOS,Termino_ind,"*",(char*)Termino_ind,(char*)Factor_ind);}
termino:
	termino OP_DIV factor
					{Termino_ind=crear_terceto(TERCETO_CON_TERCETOS,Termino_ind,"/",(char*)Termino_ind,(char*)Factor_ind);}
termino:
	factor{		Termino_ind=Factor_ind;	};

factor:
	VAR     	{Factor_ind=crear_terceto(TERCETO_SIMPLE_VARIABLE,Factor_ind,$1,"_","_");}
factor:
	constante	{printf("\n\nACA TA\n\n");
		Factor_ind=crear_terceto(TERCETO_SIMPLE_CONSTANTE,Factor_ind,$1,"_","_");};
factor:	
	PR_AP expresion PR_CP {	$$=$2;	Factor_ind=Expresion_ind;};
	
constante:
	CONST_STR	{$$ = $1;}
constante:
	CONST_INT	{}
constante:
	CONST_FLOT	{}

entre:
	BETWEEN PR_AP VAR {Var_between_ind=crear_terceto(TERCETO_SIMPLE_VARIABLE,Factor_ind,$3,"_","_");} PR_COMA PR_AC

			expresion_min PR_PYC
				{
					strcpy(Comparador_id,"JGE");
					Condicion_ind=crear_terceto(TERCETO_CON_TERCETOS,Comparador_ind,"CMP",(char*)Var_between_ind,(char*)$7);
					Condicion_ind=crear_terceto(TERCETO_IF_RESERVA,Comparador_ind,Comparador_id,"_","D");
					printf("hola");
					/*Termino_ind=crear_terceto(TERCETO_CON_TERCETOS,Termino_ind,"*",(char*)Var_between_ind,(char*)$7);*/
				}
			expresion_max PR_CC PR_CP
				{	
					Condicion_ind=crear_terceto(TERCETO_IF_COMPLETA,Comparador_ind,$3,"_","_");

					Condicion_ind=crear_terceto(TERCETO_CON_TERCETOS,Comparador_ind,"CMP",(char*)Var_between_ind,(char*)$10);
					strcpy(Comparador_id,"JLE");
					Condicion_ind=crear_terceto(TERCETO_IF_RESERVA,Comparador_ind,Comparador_id,"_","D");

					/*Factor_ind=crear_terceto(TERCETO_SIMPLE_VARIABLE,Factor_ind,$3,"_","_");*/
					//Termino_ind=crear_terceto(TERCETO_CON_TERCETOS,Termino_ind,"*",(char*)Var_between_ind,(char*)$10);
					//Condicion_ind=crear_terceto(TERCETO_BETWEEN_RESERVA,Comparador_ind,"CMP",$3,(char*)$6);
					//Condicion_ind=crear_terceto(TERCETO_BETWEEN_RESERVA,Comparador_ind,$3,(char*)Var_between_ind,(char*)Expresion_min_ind);
					/*Condicion_ind=crear_terceto(TERCETO_IF_RESERVA,Comparador_ind,"JL","_","_");*/
					printf("\n\nbetween (%s,[%d;%d])\n\n",$3,(char*)$7,(char*)$10);
					printf(" Inicia BETWEEN\n");
				
				}

%%

/**********************************/
/**********SECCION CODIGO**********/
/**********************************/

int main(int argc,char *argv[])
{
	/*pila_dec = crearpila();*/
	pila_dec=NULL;
	pila_tercetos=NULL;
	terceto_ordenados=NULL;
	pila_while=NULL;
	pila_var=NULL;


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

int graba_intermedia_pru(int notacion)
{
     int i;
     char* INTERMEDIA_file = "intermedia.txt";
     if((pf_TS = fopen(INTERMEDIA_file, "a")) == NULL)
     {
        printf("Error al escribir el archivo de la notacion intermedia\n");
        exit(1);
     }
     fprintf(pf_TS, "%5d",notacion);
     fclose(pf_TS);
} 

int crear_terceto(int tipo_de_terceto, int ter,char* a,char* b,char* c)
{
int a1;
int aux_or;

char tmp[30];

l_tercetos terceto_a_agregar=malloc(sizeof(struct lista_tercetos));
char cadena[200];

switch (tipo_de_terceto)
{
case TERCETO_SIMPLE_VARIABLE:
	terceto_a_agregar->numero_de_terceto=Pos_indice;
	sprintf(terceto_a_agregar->cad, "[%d] (%s,_,_)\n",Pos_indice,a);
	insertar_terc(terceto_a_agregar);
	break;
case TERCETO_SIMPLE_CONSTANTE:
	terceto_a_agregar->numero_de_terceto=Pos_indice;
	sprintf(terceto_a_agregar->cad, "[%d] (%d,_,_)\n",Pos_indice,a);
	insertar_terc(terceto_a_agregar);
	break;
case TERCETO_CON_TERCETOS:
	terceto_a_agregar->numero_de_terceto=Pos_indice;
	sprintf(terceto_a_agregar->cad, "[%d] (%s,[%d],[%d])\n",Pos_indice,a,b,c);
	insertar_terc(terceto_a_agregar);
	break;
case TERCETO_TERCETO_VARIABLE:
	terceto_a_agregar->numero_de_terceto=Pos_indice;
	sprintf(terceto_a_agregar->cad, "[%d] (%s,%s,%d)\n",Pos_indice,a,b,c);
	insertar_terc(terceto_a_agregar);
	break;
case TERCETO_TERCETO_CONSTANTE:
	terceto_a_agregar->numero_de_terceto=Pos_indice;
	sprintf(terceto_a_agregar->cad, "[%d] (%s,%s,%s)\n",Pos_indice,a,b,c);
	insertar_terc(terceto_a_agregar);
	break;
case TERCETO_VARIABLE_VARIABLE:
	terceto_a_agregar->numero_de_terceto=Pos_indice;
	sprintf(terceto_a_agregar->cad, "[%d] (%s,%s,%s)\n",Pos_indice,a,b,c);
	insertar_terc(terceto_a_agregar);
	break;
case TERCETO_VARIABLE_TERCETO:
	terceto_a_agregar->numero_de_terceto=Pos_indice;
	sprintf(terceto_a_agregar->cad, "[%d] (%s,%s,%s)\n",Pos_indice,a,b,c);
	insertar_terc(terceto_a_agregar);
	break;
case TERCETO_CONSTANTE_TERCETO:
	terceto_a_agregar->numero_de_terceto=Pos_indice;
	sprintf(terceto_a_agregar->cad, "[%d] (%s,%s,%s)\n",Pos_indice,a,b,c);
	insertar_terc(terceto_a_agregar);
	break;
case TERCETO_READ:
	terceto_a_agregar->numero_de_terceto=Pos_indice;
	if (sizeof(a)==4)
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%s,%s)\n",Pos_indice,"READ",a,c);
	insertar_terc(terceto_a_agregar);
	break;
case TERCETO_WRITE_VAR:
	terceto_a_agregar->numero_de_terceto=Pos_indice;
	if (sizeof(a)==4)
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%s,%s)\n",Pos_indice,"WRITE",a,c);
	insertar_terc(terceto_a_agregar);
	break;
case TERCETO_WRITE_CTE:
	terceto_a_agregar->numero_de_terceto=Pos_indice;
	if (sizeof(a)==4)
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,%s)\n",Pos_indice,"WRITE",a,c);
	insertar_terc(terceto_a_agregar);
	break;
case TERCETO_ASIG_RESERVA:
	printf("guardando v.a. %s\n",a);	
	printf("\n\nguardando con push\n\n");
	pila_tercetos=push(pila_tercetos,Pos_indice-1,a,0);
	/*Pos_indice--;*/
	break;
case TERCETO_ASIG_COMPLETA:
	printf("guardando variable %s, en pos%d\n",a,pila_tercetos->elm+1);

		terceto_a_agregar->numero_de_terceto=pila_tercetos->elm+1;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,_,_)\n",pila_tercetos->elm+1,a);
		/*sprintf(terceto_a_agregar->cad, "[%d] (%s,_,_)\n",,pila_tercetos->tipo_salto,Pos_indice+1);*/
		insertar_terc(terceto_a_agregar);
		printf("\n\nsacando con pop\n\n");
		pila_tercetos=pop(pila_tercetos);
		Pos_indice--;
	/*pila_tercetos=push(pila_tercetos,Pos_indice-1,a,0);*/

	break;

case TERCETO_BETWEEN_RESERVA:
	/*terceto_a_agregar->numero_de_terceto=Pos_indice;
	sprintf(terceto_a_agregar->cad, "[%d] (%s,[%s],[%d])\n",Pos_indice,a,b,c);
	insertar_terc(terceto_a_agregar);*/
	printf("[%d] (%s,_,_)\n",Pos_indice,a);
	Pos_indice++;
	printf("[%d] (%d,_,_)\n",Pos_indice,b);
	Pos_indice++;
	printf("[%d] (CMP,[%d],[%d])\n",Pos_indice,Pos_indice-1,Pos_indice-2);
	Pos_indice++;
	printf("[%d] (JGE,apilar,_)\n",Pos_indice);
	Pos_indice++;
	//printf("[%d] (%s,[%s],[%d])\n",Pos_indice,a,b,c);
	//printf("[%d] (%s,[%s],[%d])\n",Pos_indice,a,b,c);
	//printf("[%d] (%s,[%s],[%d])\n",Pos_indice,a,b,c);


	break;
case TERCETO_IF_RESERVA:
	printf("valor del argumento antes de not %s\n",a);

	if (strcmp(c,"N"))
		invertir_cmp(a);
	printf("valor del argumento despues de not %s\n",a);
	pila_tercetos=push(pila_tercetos,Pos_indice-1,a,0);
	
	printf("guardando if de terceto %d\n",Pos_indice);
	break;
case TERCETO_WHILE_RESERVA:
	pila_while=push(pila_while,Pos_indice,"JMP",0);
	/*aux_while=Pos_indice;
	printf("guardando aux_while %d\n",Pos_indice);*/
	/*pila_tercetos=push(pila_tercetos,Pos_indice-1,a,0);
	printf("guardando if de terceto %d\n",Pos_indice);*/
	Pos_indice--;
	break;
case TERCETO_ELSE_RESERVA:
printf("valor del argumento %s\n",a);
	pila_tercetos=push(pila_tercetos,Pos_indice-1,a,0);
	printf("guardando else\n");
	break;
case TERCETO_WHILE_COMPLETA:
	if (pila_tercetos->tipo_de_nexo==0)
		{
		terceto_a_agregar->numero_de_terceto=pila_tercetos->elm+1;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",pila_tercetos->elm+1,pila_tercetos->tipo_salto,Pos_indice+1);
		insertar_terc(terceto_a_agregar);
		printf("desapilando while de terceto %d\n",pila_tercetos->elm+1);
		pila_tercetos=pop(pila_tercetos);
		
		terceto_a_agregar->numero_de_terceto=Pos_indice;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",Pos_indice,pila_while->tipo_salto,pila_while->elm);
		insertar_terc(terceto_a_agregar);
		pila_while=pop(pila_while);

		/*Pos_indice--;*/

		}
	else
		if (pila_tercetos->tipo_de_nexo==1)
		{
		terceto_a_agregar->numero_de_terceto=pila_tercetos->elm+1;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",pila_tercetos->elm+1,pila_tercetos->tipo_salto,Pos_indice+1);
		insertar_terc(terceto_a_agregar);
		printf("desapilando while de terceto %d\n",pila_tercetos->elm+1);
		pila_tercetos=pop(pila_tercetos);

		terceto_a_agregar->numero_de_terceto=pila_tercetos->elm+1;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",pila_tercetos->elm+1,pila_tercetos->tipo_salto,Pos_indice+1);
		insertar_terc(terceto_a_agregar);
		printf("desapilando while de terceto %d\n",pila_tercetos->elm+1);
		pila_tercetos=pop(pila_tercetos);

		terceto_a_agregar->numero_de_terceto=Pos_indice;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",Pos_indice,pila_while->tipo_salto,pila_while->elm);
		insertar_terc(terceto_a_agregar);
		pila_while=pop(pila_while);

		/*Pos_indice--;*/
		}
	else
		if (pila_tercetos->tipo_de_nexo==2)
		{
		terceto_a_agregar->numero_de_terceto=pila_tercetos->elm+1;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",pila_tercetos->elm+1,pila_tercetos->tipo_salto,Pos_indice+1);
		insertar_terc(terceto_a_agregar);
		printf("desapilando if de terceto %d\n",pila_tercetos->elm+1);
		aux_or=pila_tercetos->elm+1;
		pila_tercetos=pop(pila_tercetos);
		
		invertir_cmp(pila_tercetos->tipo_salto);
		
		terceto_a_agregar->numero_de_terceto=pila_tercetos->elm+1;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",pila_tercetos->elm+1,pila_tercetos->tipo_salto,aux_or+1);
		insertar_terc(terceto_a_agregar);
		printf("desapilando if de terceto %d\n",pila_tercetos->elm+1);
		pila_tercetos=pop(pila_tercetos);

		terceto_a_agregar->numero_de_terceto=Pos_indice;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",Pos_indice,pila_while->tipo_salto,pila_while->elm);
		insertar_terc(terceto_a_agregar);
		pila_while=pop(pila_while);

		/*Pos_indice--;*/
		}
	break;
case TERCETO_ELSE_COMPLETA:
	if (pila_tercetos->tipo_de_nexo==0)
		{
		terceto_a_agregar->numero_de_terceto=pila_tercetos->elm+1;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",pila_tercetos->elm+1,pila_tercetos->tipo_salto,Pos_indice+1);
		insertar_terc(terceto_a_agregar);
		printf("desapilando else de terceto %d\n",pila_tercetos->elm+1);
		pila_tercetos=pop(pila_tercetos);
		Pos_indice--;
		}
	else
		if (pila_tercetos->tipo_de_nexo==1)
		{
		terceto_a_agregar->numero_de_terceto=pila_tercetos->elm+1;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",pila_tercetos->elm+1,pila_tercetos->tipo_salto,Pos_indice+1);
		insertar_terc(terceto_a_agregar);
		printf("desapilando else de terceto %d\n",pila_tercetos->elm+1);
		pila_tercetos=pop(pila_tercetos);

		terceto_a_agregar->numero_de_terceto=pila_tercetos->elm+1;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",pila_tercetos->elm+1,pila_tercetos->tipo_salto,Pos_indice+1);
		insertar_terc(terceto_a_agregar);
		printf("desapilando else de terceto %d\n",pila_tercetos->elm+1);
		pila_tercetos=pop(pila_tercetos);
		Pos_indice--;
		}
	else
		if (pila_tercetos->tipo_de_nexo==2)
		{
		terceto_a_agregar->numero_de_terceto=pila_tercetos->elm+1;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",pila_tercetos->elm+1,pila_tercetos->tipo_salto,Pos_indice+1);
		insertar_terc(terceto_a_agregar);
		printf("desapilando if de terceto %d\n",pila_tercetos->elm+1);
		aux_or=pila_tercetos->elm+1;
		pila_tercetos=pop(pila_tercetos);
		
		invertir_cmp(pila_tercetos->tipo_salto);
		
		terceto_a_agregar->numero_de_terceto=pila_tercetos->elm+1;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",pila_tercetos->elm+1,pila_tercetos->tipo_salto,aux_or+1);
		insertar_terc(terceto_a_agregar);
		printf("desapilando if de terceto %d\n",pila_tercetos->elm+1);
		pila_tercetos=pop(pila_tercetos);
		Pos_indice--;
		}
	break;
case TERCETO_IF_COMPLETA:
	if (pila_tercetos->tipo_de_nexo==0)
		{
		terceto_a_agregar->numero_de_terceto=pila_tercetos->elm+1;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",pila_tercetos->elm+1,pila_tercetos->tipo_salto,Pos_indice);
		insertar_terc(terceto_a_agregar);
		printf("desapilando if de terceto %d\n",pila_tercetos->elm+1);
		pila_tercetos=pop(pila_tercetos);
		Pos_indice--;
		}
	else
		if (pila_tercetos->tipo_de_nexo==1)
		{
		terceto_a_agregar->numero_de_terceto=pila_tercetos->elm+1;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",pila_tercetos->elm+1,pila_tercetos->tipo_salto,Pos_indice);
		insertar_terc(terceto_a_agregar);
		printf("desapilando if de terceto %d\n",pila_tercetos->elm+1);
		pila_tercetos=pop(pila_tercetos);

		terceto_a_agregar->numero_de_terceto=pila_tercetos->elm+1;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",pila_tercetos->elm+1,pila_tercetos->tipo_salto,Pos_indice);
		insertar_terc(terceto_a_agregar);
		printf("desapilando if de terceto %d\n",pila_tercetos->elm+1);
		pila_tercetos=pop(pila_tercetos);
		Pos_indice--;
		}
	else
		if (pila_tercetos->tipo_de_nexo==2)
		{
		terceto_a_agregar->numero_de_terceto=pila_tercetos->elm+1;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",pila_tercetos->elm+1,pila_tercetos->tipo_salto,Pos_indice);
		insertar_terc(terceto_a_agregar);
		printf("desapilando if de terceto %d\n",pila_tercetos->elm+1);
		aux_or=pila_tercetos->elm+1;
		pila_tercetos=pop(pila_tercetos);
		
		invertir_cmp(pila_tercetos->tipo_salto);
		
		terceto_a_agregar->numero_de_terceto=pila_tercetos->elm+1;
		sprintf(terceto_a_agregar->cad, "[%d] (%s,%d,_)\n",pila_tercetos->elm+1,pila_tercetos->tipo_salto,aux_or+1);
		insertar_terc(terceto_a_agregar);
		printf("desapilando if de terceto %d\n",pila_tercetos->elm+1);
		pila_tercetos=pop(pila_tercetos);
		Pos_indice--;
		}
	break;
}
Pos_indice++;
return Pos_indice-1;
}




/************pilas********************/



pila crearpila(){
	pila p;
	p=NULL;
	return p;
}


pila push(pila p,int elm,char*tipo_cmp,int t_nexo){
	pila tmp;
	/*printf("valor del argumento adentro %s\n",tipo_cmp);*/
	tmp = (pila)malloc(sizeof(struct lifo));
	tmp->elm=elm;
	strcpy(tmp->tipo_salto,tipo_cmp);
	tmp->tipo_de_nexo=t_nexo;
	tmp->nxt=p;
	return tmp;
}


pila pop(pila p){
	if (p!=NULL)
	{
		p=p->nxt;
	}
	return p;
}


int peek(pila p){
	return p->elm;
}

void cargar_nexo(pila p,int t_nexo){
	p->tipo_de_nexo=t_nexo;
}


pila invertir(pila p){
	pila tmp,tmpp;
	tmp=p;
	tmpp=crearpila();
	while(tmp!=NULL){
		tmpp=push(tmp,peek(p),"_",0);
		tmp=pop(tmp);
	}
	return tmpp;
}


void liberar()
{
    struct lista_tercetos *reco = terceto_ordenados;
    struct lista_tercetos *bor;
    while (reco != NULL)
    {
        bor = reco;
        reco = reco->sig;
        free(bor);
    }
}

int vacia()
{
    if (terceto_ordenados == NULL)
        return 1;
    else
        return 0;
}


void imprimir()
{
	char cadena[200];	
    struct lista_tercetos *reco=terceto_ordenados;
    printf("Lista completa.\n");
    while (reco!=NULL)
    {
        /*printf("%i ",reco->numero_de_terceto);*/
        /*sprintf(cadena, "[%d] (%s,%s,%s)\n",reco->numero_de_terceto,reco->a,reco->b,reco->c);*/
        graba_intermedia(reco->cad);
        reco=reco->sig;
    }
    printf("\n");
}


void invertir_cmp(char* tipo_a_invertir)
{
	if (strcmp(tipo_a_invertir,"JE")==0)
		{
		strcpy(tipo_a_invertir,"JNE");
		return;
		}
	if (strcmp(tipo_a_invertir,"JNE")==0)
		{
		strcpy(tipo_a_invertir,"JE");
		return;
		}
	if (strcmp(tipo_a_invertir,"JL")==0)
		{
		strcpy(tipo_a_invertir,"JGE");
		return;
		}
	if (strcmp(tipo_a_invertir,"JGE")==0)
		{
		strcpy(tipo_a_invertir,"JL");
		return;
		}
			if (strcmp(tipo_a_invertir,"JLE")==0)
		{
		strcpy(tipo_a_invertir,"JG");
		return;
		}
	if (strcmp(tipo_a_invertir,"JG")==0)
		{
		strcpy(tipo_a_invertir,"JLE");
		return;
		}
}

void insertar(int x)
{
    struct lista_tercetos *nuevo;
    nuevo=malloc(sizeof(struct lista_tercetos));
    nuevo->numero_de_terceto = x;
    nuevo->sig=NULL;
    if (terceto_ordenados == NULL)
    {
        terceto_ordenados = nuevo;
    }
    else
    {
        if (x<terceto_ordenados->numero_de_terceto)
        {
            nuevo->sig = terceto_ordenados;
            terceto_ordenados = nuevo;
        }
        else
        {
            struct lista_tercetos *reco = terceto_ordenados;
            struct lista_tercetos *atras = terceto_ordenados;
            while (x >= reco->numero_de_terceto && reco->sig != NULL)
            {
                atras = reco;
                reco = reco->sig;
            }
            if (x >= reco->numero_de_terceto)
            {
                reco->sig = nuevo;
            }
            else
            {
                nuevo->sig = reco;
                atras->sig = nuevo;
            }
        }
    }
}



void insertar_terc(l_tercetos x)
{
    struct lista_tercetos *nuevo;
    nuevo=malloc(sizeof(struct lista_tercetos));
    nuevo->numero_de_terceto = x->numero_de_terceto;
    strcpy(nuevo->cad,x->cad);
    nuevo->sig=NULL;
    if (terceto_ordenados == NULL)
    {
        terceto_ordenados = nuevo;
    }
    else
    {
        if (x->numero_de_terceto<terceto_ordenados->numero_de_terceto)
        {
            nuevo->sig = terceto_ordenados;
            terceto_ordenados = nuevo;
        }
        else
        {
            struct lista_tercetos *reco = terceto_ordenados;
            struct lista_tercetos *atras = terceto_ordenados;
            while (x->numero_de_terceto >= reco->numero_de_terceto && reco->sig != NULL)
            {
                atras = reco;
                reco = reco->sig;
            }
            if (x->numero_de_terceto >= reco->numero_de_terceto)
            {
                reco->sig = nuevo;
            }
            else
            {
                nuevo->sig = reco;
                atras->sig = nuevo;
            }
        }
    }
}