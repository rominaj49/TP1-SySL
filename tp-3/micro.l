%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "micro.tab.h"

int yylineno = 1;
#define MAX_ID_LEN 32

int yywrap(void) { return 1; }
%}

/* Macros */
letra      [A-Za-z]
digito     [0-9]
id         {letra}({letra}|{digito})*
constante  {digito}+

%%

"inicio"      { return INICIO; }
"fin"         { return FIN; }
"leer"        { return LEER; }
"escribir"    { return ESCRIBIR; }

"+"           { return MAS; }
"-"           { return MENOS; }

"("           { return APARENTESIS; }
")"           { return CPARENTESIS; }
","           { return COMA; }
";"           { return PUNTOYCOMA; }

":="          { return ASIGNACION; }

{constante}   {
                  yylval.ival = atoi(yytext);
                  return CONSTANTE;
              }

{id}          {
                  if (strlen(yytext) > MAX_ID_LEN) {
                      fprintf(stderr,
                              "Error semantico en linea %d: identificador '%s' excede los 32 caracteres.\n",
                              yylineno, yytext);
                  }
                  yylval.sval = strdup(yytext);
                  return IDENTIFICADOR;
              }

[ \t\r]+      { /* ignorar espacios y tabs */ }

\n            { yylineno++; }

.             {
                  fprintf(stderr,
                          "Error lexico en linea %d: caracter invalido '%s'\n",
                          yylineno, yytext);
              }

%%