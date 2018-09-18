/**********************************/
/*******SECCION DEFINICIONES*******/
/**********************************/

%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
FILE  *yyin;
int yylval;
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


/**********************************/
/***SECCION DEFINICION DE REGLAS***/
/**********************************/

%%
"main"		{ return PR_INICIO;}    
"end"		{ return PR_FIN;}       
"decvar"	{ return PR_DECVAR;}    
"enddec"	{ return PR_ENDDEC;}    
{CONST_INT}	{ return CONST_INT;}
{CONST_REAL}	{ return CONST_REAL;}
{CONST_STR}	{ return CONST_STR;}
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
{VAR}		{ return VAR;}          
";"		{ return PR_PYC;}       
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

"\n"      		
"\t"		

%%


/**********************************/
/**********SECCION CODIGO**********/
/**********************************/
