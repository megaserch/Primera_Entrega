/**********************************/
/*******SECCION DEFINICIONES*******/
/**********************************/

%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"

FILE  *yyin;

typedef struct	{
				int posicion;
				char nombre[31];
				char tipo[20];
				char valor[100];
				int longitud;
				}	TS_reg;

extern TS_reg tabla_simbolos[100];
extern int tipo_procesando;
%}

/**********************************/
/*****SECCION CONJUNTOS Y REGEX****/
/**********************************/

%option noyywrap  
%option yylineno 

DIGITO				[0-9]
LETRA				[a-zA-Z]
COMA				[","]
COMILLAS			["]
CONST_STR           \"({LETRA}|{DIGITO}|{CARACTER})*\" 
CONST_FLOT			{DIGITO}+"."{DIGITO}+
CONST_INT			{DIGITO}+
VAR					{LETRA}({LETRA}|{DIGITO}|_)*
ESPACIO				[" "]
CARACTER			["<"|">"|_|"*"|" "|":"|"="|"."|"-"|"\-"|","|"/"|"("|")"|"\["|"\]"]
TEXTO				"'"({CARACTER}+|{ESPACIO})*"'"
COMENTARIO_SIMPLE	"-/"({LETRA}|{DIGITO}|"<"|">"|_|" "|":"|"="|"."|"-"|","|"/")*"/-"
COMENTARIO_DOBLE	"-/"({LETRA}|{DIGITO}|{CARACTER}|{COMENTARIO_SIMPLE})*"/-"


/**********************************/
/***SECCION DEFINICION DE REGLAS***/
/**********************************/

%%
"main"				{ return PR_INICIO;}    
"end"				{ graba_TS();return PR_FIN;}       
"decvar"			{ return PR_DECVAR;}    
"enddec"			{ return PR_ENDDEC;}    
{CONST_INT}			{ 
					if(!validar_cota_int())
						yyterminate();
					inserta_en_TS("CONST_INT",yytext); 
					/*yylval = atoi(yytext);*/
					yylval.num = atoi(yytext);
					return CONST_INT;
					} 
{CONST_STR}			{ 
					if(!validar_long_string(yytext))
						yyterminate(); 
					inserta_en_TS("CONST_STR",yytext); 
					yylval.str = strdup(yytext);
					return CONST_STR;
					}
{CONST_FLOT}		{ 
					if(!validar_cota_flot())
						yyterminate(); 
					inserta_en_TS("CONST_FLOT",yytext); 
					/*yylval = atof(yytext);*/
					yylval.flot = atof(yytext);
					return CONST_FLOT;
					} 
"flot"				{ tipo_procesando=2; return FLOAT;}        
"int"				{ tipo_procesando=1; return ENTERO;}      
"str"				{ tipo_procesando=3; return STRING;}       
"if"				{ return IF;}           
"else"				{ return ELSE;}  
"while"				{ return WHILE;}        
"between"			{ return BETWEEN;}      
":="				{ return OP_ASIG;}      
"+"					{ return OP_SUMA;}      
"-"					{ return OP_RESTA;}     
"*"					{ return OP_MULT;}      
"/"					{ return OP_DIV;}       
"read"				{ return READ;}         
"write"				{ return WRITE;}        
{VAR}				{
					inserta_en_TS("VAR","---");
					/*printf("\n\n retornando lexema %s del token VAR\n\n",yytext); */
					/*yylval=yytext;*/
					yylval.str = strdup(yytext);

					/*p=(char *)calloc(strlen(yytext)+1,sizeof(char));
                       strcpy(p,yytext);
                       yylval.text=p;
                       return(t_MONTH);*/

					return VAR;
					}
";"					{ return PR_PYC;}       
":"					{ return PR_DOSP;}       
{COMA}				{ return PR_COMA;}      
"^"					{ return PR_NOT;}       
"&&"				{ return PR_AND;}       
"||"				{ return PR_OR;}        
"("					{ return PR_AP;}        
")"					{ return PR_CP;}        
"["					{ return PR_AC;}        
"]"					{ return PR_CC;}        
"{"					{ return PR_ALL;}       
"}"					{ return PR_CLL;}       
">"					{ return OP_MAYOR;}     
"<"					{ return OP_MENOR;}     
"="					{ return OP_IGUAL;}     
"!="				{ return OP_DISTINTO;}  
">="				{ return OP_MAYORIGUAL;}
"<="				{ return OP_MENORIGUAL;}
{COMENTARIO_SIMPLE}	{ /*printf(" Encontre comentario\n");*/}
{COMENTARIO_DOBLE}	{ /*printf(" Encontre comentario anidado\n");*/}

"\n"      		
"\t"
";"		
{ESPACIO}		

%%


/**********************************/
/**********SECCION CODIGO**********/
/**********************************/

int cant_simbolos = 0;
FILE* pf_TS;
int busca_en_TS(char*);
int graba_TS();
int inserta_en_TS(char*,char*);
void modifica_TS(int,char*);
int validar_cota_int();
int validar_cota_flot();
int validar_long_string(char*); 


int  validar_cota_int()
{
	int valor = atoi(yytext);
	if(valor >32767 || valor < -32768)
	{
		printf("SINTAX ERROR: INT OVERFLOW\n");		
		return 0;
	}
	/*printf("\n\nLEXICO - yylval= - yytext=%d\n\n",yytext);*/
	return 1;
}

int validar_long_string(char* texto)
{
char* p = texto;
int i = 0;
while(i++ <= 32 && *p != '\0')
	{
	if (yytext[i]!='\"'||yytext[i]=='\0')
		yytext[i-1]=yytext[i];
	else
		yytext[i-1]='\0';
	p++;
	}
if(*p != '\0')
	{
		printf("SINTAX ERROR: STRING EXCEDE MAXIMO DE 30 CARACTERES (%s)\n", texto);    
		return 0;
	}
return 1;
}

int validar_cota_flot()
{
	double valor = atof(yytext);
	if(valor >= 3.402823E+38 || valor < 0)
	{
		printf("SINTAX ERROR: FLOT OVERFLOW\n");		
		return 0;
	}
	/*printf("\n\nLEXICO - yylval=%d - yytext=%d\n\n",yylval,yytext);*/
	return 1;
} 

/**********************************/
/*****INICIO TABLA DE SIMBOLOS*****/
/**********************************/

int busca_en_TS(char* nombre)
{
    int i;
    for(i = 0; i<cant_simbolos; i++)
    {
        if(!strcmp(tabla_simbolos[i].nombre, nombre))
			return i;
    }
    return -1;
}

int inserta_en_TS(char* tipo,char* valor)
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
	 return yylval.num;
}

int graba_TS()
{
     int i,a;
     char* TS_file = "ts.txt";
     if((pf_TS = fopen(TS_file, "w")) == NULL)
     {
        printf("Error al grabar la tabla de simbolos\n");
        exit(1);
     }
     fprintf(pf_TS, "POSICION\t\tNOMBRE\t\t\t\t\tTIPO\t\t\tVALOR\t\tLONGITUD\n");
      for(i = 0; i < cant_simbolos; i++)
      {
        fprintf(pf_TS,"%d\t\t\t%s\t\t\t\t\t", tabla_simbolos[i].posicion, tabla_simbolos[i].nombre);
        if(tabla_simbolos[i].tipo != NULL)
			fprintf(pf_TS,"%s \t\t", tabla_simbolos[i].tipo);
        if(tabla_simbolos[i].valor != NULL)
            fprintf(pf_TS,"%s \t\t", tabla_simbolos[i].valor);
        fprintf(pf_TS,"%d\n", tabla_simbolos[i].longitud);
      }
      fclose(pf_TS);

} 

void modifica_TS(int tipo_a_modificar,char*variable_a_modificar)
{

int ind_tmp,b;
ind_tmp=busca_en_TS(variable_a_modificar);

if (tipo_a_modificar==1)
	{
	if((b = tabla_simbolos[ind_tmp].posicion) != -1)
 		if (!strcmp(tabla_simbolos[ind_tmp].tipo,"VAR"))
 			strcpy(tabla_simbolos[ind_tmp].tipo,"VAR_INT");
 		else
			printf(" %s NO es variable porque tiene tipo %s\n",tabla_simbolos[ind_tmp].nombre,tabla_simbolos[ind_tmp].tipo);

	}
if (tipo_a_modificar==2)
	{
	if((b = tabla_simbolos[ind_tmp].posicion) != -1)
 		if (!strcmp(tabla_simbolos[ind_tmp].tipo,"VAR"))
 			strcpy(tabla_simbolos[ind_tmp].tipo,"VAR_FLOAT");
 		else
			printf(" %s NO es variable porque tiene tipo %s\n",tabla_simbolos[ind_tmp].nombre,tabla_simbolos[ind_tmp].tipo);

	}
if (tipo_a_modificar==3)
	{
	if((b = tabla_simbolos[ind_tmp].posicion) != -1)
 		if (!strcmp(tabla_simbolos[ind_tmp].tipo,"VAR"))
 			strcpy(tabla_simbolos[ind_tmp].tipo,"VAR_STRING");
 		else
			printf(" %s NO es variable porque tiene tipo %s\n",tabla_simbolos[ind_tmp].nombre,tabla_simbolos[ind_tmp].tipo);

	}
}