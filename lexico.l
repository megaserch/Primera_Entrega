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
int yylval;


float yyfval;

int numberLine, numberChar;

typedef struct{
	int posicion;
	char nombre[30];
	char tipo[20];
	char valor[100];

	int longitud;
	} TS_reg;

	extern TS_reg tabla_simb[100];
 
%}

/**********************************/
/*****SECCION CONJUNTOS Y REGEX****/
/**********************************/

%option noyywrap  
%option yylineno 

DIGITO			[0-9]
LETRA			[a-zA-Z]
COMA                    [","]
CONST_STR               "({LETRA}|{DIGITO}|.)+"
CONST_REAL              {DIGITO}+"."{DIGITO}+
CONST_INT               {DIGITO}+
VAR			{LETRA}({LETRA}|{DIGITO}|_)*
espacio [" "]
caracter [a-z,A-Z,0-9,=,>,<,!,:,+,-,*,/]
texto "'"({caracter}+|{espacio})*"'"
COMENTARIOS             \-\/({LETRA}|{DIGITO}|.)+\/\- 

/**********************************/
/***SECCION DEFINICION DE REGLAS***/
/**********************************/

%%
"main"		{ return PR_INICIO;}    
"end"		{ graba_TS();return PR_FIN;}       
"decvar"	{ return PR_DECVAR;}    
"enddec"	{ return PR_ENDDEC;}    
{CONST_INT}		{ 
                if(!validar_cota_int()){
                  yyterminate();
                }
                inserta_TS("CONST_INT",yytext); 
                return CONST_INT;
              } 
{CONST_STR}		{ 
                if(!validar_longitud_string(yytext)) { 
                  yyterminate(); 
                }
                inserta_TS("CONST_STR",yytext); 
                return CONST_STR;
              }
{CONST_REAL}	{ 
                if(!validar_cota_real()){
                  yyterminate(); 
                }
                inserta_TS("CONST_REAL",yytext); 
                return CONST_REAL;
              } 
"real"		{ return FLOAT;}        
"int"		{ return ENTERO;}      
"string"	{ return STRING;}       
"if"		{ return IF;}           
"else"		{ return ELSE;}         
"while"		{ return WHILE;}        
"between"	{ return BETWEEN;}      
":="		{ return OP_ASIG;}      
"+"		{ return OP_SUMA;}      
"-"		{ return OP_RESTA;}     
"*"		{ return OP_MULT;}      
"/"		{ return OP_DIV;}       
"read"		{ return READ;}         
"write"		{ return WRITE;}        
{VAR}		{ printf("Encontre un ID %s\n", yytext);
                inserta_TS("ID","---"); 
		printf("ID Tanto:%s yylval:%d \n", yytext,yylval);
                return VAR;}
";"		{ return PR_PYC;}       
":"		{ return PR_DOSP;}       
{COMA}		{ return PR_COMA;}      
"^"		{ return PR_NOT;}       
"&&"		{ return PR_AND;}       
"||"		{ return PR_OR;}        
"("		{ return PR_AP;}        
")"		{ return PR_CP;}        
"["		{ return PR_AC;}        
"]"		{ return PR_CC;}        
"{"		{ return PR_ALL;}       
"}"		{ return PR_CLL;}       
">"		{ return OP_MAYOR;}     
"<"		{ return OP_MENOR;}     
"="		{ return OP_IGUAL;}     
"!="		{ return OP_DISTINTO;}  
">="		{ return OP_MAYORIGUAL;}
"<="		{ return OP_MENORIGUAL;}
{COMENTARIOS}	{ printf("Encontre comentario\n");}

"\n"      		
"\t"		

%%


/**********************************/
/**********SECCION CODIGO**********/
/**********************************/

int cant_entradas = 0;
FILE* pf_TS;

int busca_en_TS(char*);
int graba_TS();
int inserta_TS(char*,char*);

int validar_cota_int();
int validar_cota_real();
int validar_longitud_string(char*); 


int  validar_cota_int()
{
	int valor = atoi(yytext);
	if(valor >32767 || valor < -32768)
	{
		printf("SINTAX ERROR: INT OVERFLOW\n");		
		return 0;
	}
	return 1;
}


int validar_longitud_string(char* texto){
  char* p = texto;
  int idx = 0;
  while(idx++ < 30 && *p != '\n'){
    p++;
  }

  if(*p != '\n'){
    printf("SINTAX ERROR: STRING EXCEDE MAXIMO DE 30 CARACTERES (%s)\n", texto);    
    return 0;
  }

  return 1;
}

int validar_cota_real()
{
	int valor = atoi(yytext);
	if(valor > 4294967295 || valor < -4294967296)
	{
		printf("SINTAX ERROR: REAL OVERFLOW\n");		
		return 0;
	}
	return 1;
} 

/***********************INICIO TABLA DE SIMBOLOS************************/
//Buscamos que no la hayamos guardado
int busca_en_TS(char* nombre)
{
    int i;
    for(i = 0; i<cant_entradas; i++)
    {
          if(!strcmp(tabla_simb[i].nombre, nombre))
          {
                 return i;
          }
    }
    
    return -1;
}


int inserta_TS(char* tipo,char* valor)
{
	 if((yylval = busca_en_TS(yytext)) == -1)
     {
		TS_reg reg;
		strcpy(reg.nombre, yytext);
		strcpy(reg.tipo, tipo);
		strcpy(reg.valor, valor);
		reg.longitud = strlen(yytext);
		reg.posicion = cant_entradas;
		tabla_simb[cant_entradas++] = reg;
		
		return yylval = cant_entradas-1;
	 }
	 return yylval;
}

int graba_TS()
{
     int i;
     char* TS_file = "ts.txt";
     
     if((pf_TS = fopen(TS_file, "w")) == NULL)
     {
               printf("Error al grabar la tabla de simbolos \n");
               exit(1);
     }
     
     fprintf(pf_TS, "POSICION \t\t NOMBRE \t\t TIPO \t\t VALOR \t\t LONGITUD \n");
     
      for(i = 0; i < cant_entradas; i++)
      {
           fprintf(pf_TS,"%d \t\t\t\t %s \t\t\t", tabla_simb[i].posicion, tabla_simb[i].nombre);
           
          
            if(tabla_simb[i].tipo != NULL)
               fprintf(pf_TS,"%s \t\t\t", tabla_simb[i].tipo);
           
          
            if(tabla_simb[i].valor != NULL)
               fprintf(pf_TS,"%s \t\t\t", tabla_simb[i].valor);
           
            fprintf(pf_TS,"%d \n", tabla_simb[i].longitud);
      }    
     fclose(pf_TS);
} 
