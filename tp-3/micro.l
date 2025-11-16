%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "micro.tab.h"

    int yylineno = 1;
%}

DIGITO          [0-9]
LETRA           [a-zA-Z]
IDENTIFICADOR   {LETRA}({LETRA}|{DIGITO})*
CONSTENTERA     {DIGITO}+

%%

"inicio"        { return INICIO; }
"fin"           { return FIN; }
"leer"          { return LEER; }
"escribir"      { return ESCRIBIR; }

":="            { return ASIGNACION; }

"+"             { return SUMA; }
"-"             { return RESTA; }

","             { return COMA; }
";"             { return PYCOMA; }
"("             { return PARENIZQUIERDO; }
")"             { return PARENDERECHO; }

{CONSTENTERA}   {
                    yylval.num = atoi(yytext);
                    return CONSTANTE;
                }

{IDENTIFICADOR} {
                    yylval.cadena = strdup(yytext);
                    return ID;
                }

[ \t\r]+        { }

\n              { yylineno++; }

.               {
                    fprintf(stderr,
                        "Error lexico en linea %d: caracter invalido '%s'\n",
                        yylineno, yytext);
                }

%%
