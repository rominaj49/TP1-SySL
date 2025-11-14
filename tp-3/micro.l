%{
#include <stdio.h>
#include <string.h>

int yylineno = 1;
#define MAX_ID_LEN 32

enum {
    T_INICIO = 256,
    T_FIN,
    T_LEER,
    T_ESCRIBIR,
    T_IDENTIFICADOR,
    T_CONSTANTE,
    T_MAS,
    T_MENOS,
    T_ASIGNACION,
    T_APARENTESIS,
    T_CPARENTESIS,
    T_COMA,
    T_PUNTOYCOMA
};

int yywrap(void) { return 1; }

%}

/* Expresiones regulares */
letra      [A-Za-z]
digito     [0-9]
id         {letra}({letra}|{digito})*
constante  {digito}+

%%

"inicio"      { printf("INICIO\n"); return T_INICIO; }
"fin"         { printf("FIN\n"); return T_FIN; }
"leer"        { printf("LEER\n"); return T_LEER; }
"escribir"    { printf("ESCRIBIR\n"); return T_ESCRIBIR; }

"+"           { printf("MAS\n"); return T_MAS; }
"-"           { printf("MENOS\n"); return T_MENOS; }

"("           { printf("APARENTESIS\n"); return T_APARENTESIS; }
")"           { printf("CPARENTESIS\n"); return T_CPARENTESIS; }
","           { printf("COMA\n"); return T_COMA; }
";"           { printf("PUNTOYCOMA\n"); return T_PUNTOYCOMA; }

":="          { printf("ASIGNACION\n"); return T_ASIGNACION; }

{constante}   {
                  printf("CONSTANTE(%s)\n", yytext);
                  return T_CONSTANTE;
              }

{id}          {
                  if (strlen(yytext) > MAX_ID_LEN) {
                      fprintf(stderr,
                              "Error semántico en línea %d: identificador '%s' excede los 32 caracteres.\n",
                              yylineno, yytext);
                  }
                  printf("IDENTIFICADOR(%s)\n", yytext);
                  return T_IDENTIFICADOR;
              }

[ \t\r]+      { /* ignorar espacios y tabs */ }

\n            { yylineno++; }

.             {
                  fprintf(stderr,
                          "Error léxico en línea %d: carácter inválido '%s'\n",
                          yylineno, yytext);
              }

%%

int main(void) {
    int t;
    while ((t = yylex()) != 0) {
            }
    return 0;
}
