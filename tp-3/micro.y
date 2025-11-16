%{
#include <stdio.h>
#include <stdlib.h> 
#include <math.h>
#include <string.h>

extern char *yytext;
extern int yyleng;
extern int yylex(void);
void yyerror(char*);
extern int yylineno;

/* Tabla de símbolos */
typedef struct Simbolo {
    char *nombre;
    int inicializada;          
    struct Simbolo *sig;
} Simbolo;

Simbolo *tabla = NULL;

Simbolo* buscar(char *nombre);
Simbolo* insertar(char *nombre, int inicializada);
void usar_variable(char *nombre);
void asignar_variable(char *nombre);
void leer_variable(char *nombre);
%}

%union{
   char* cadena;
   int num;
} 

/* Tokens léxicos */
%token ASIGNACION PYCOMA SUMA RESTA PARENIZQUIERDO PARENDERECHO COMA
%token INICIO FIN LEER ESCRIBIR
%token <cadena> ID
%token <num> CONSTANTE

/* Tipos de no terminales */
%type <num> expresion primaria

%left SUMA RESTA

%%

programa
    : INICIO sentencias FIN
      {
        printf("Analisis sintactico y semantico finalizado correctamente.\n");
      }
    ;

/* Secuencia de sentencias */
sentencias
    : /* vacio */
    | sentencias sentencia
    ;

/* Tipos de sentencia */
sentencia
    : asignacion
    | lectura
    | escritura
    ;

/* ID := expresion ; */
asignacion
    : ID ASIGNACION expresion PYCOMA
      {
        asignar_variable($1);
        free($1);
      }
    ;

/* leer(a,b,c); */
lectura
    : LEER PARENIZQUIERDO lista_ids PARENDERECHO PYCOMA
    ;

/* escribir(expr1, expr2, ...); */
escritura
    : ESCRIBIR PARENIZQUIERDO lista_exp PARENDERECHO PYCOMA
    ;

/* lista de IDs: a | a,b | a,b,c,... */
lista_ids
    : ID
      {
        leer_variable($1);  
        free($1);
      }
    | lista_ids COMA ID
      {
        leer_variable($3);
        free($3);
      }
    ;

/* lista de expresiones: expr | expr, expr | expr, expr, ... */
lista_exp
    : expresion
    | lista_exp COMA expresion
    ;

/* expr + expr | expr - expr | primaria */
expresion
    : primaria
    | expresion SUMA primaria
      { $$ = $1 + $3; }
    | expresion RESTA primaria
      { $$ = $1 - $3; }
    ;

/* primaria: ID | CONSTANTE | (expr) */
primaria
    : ID
      {
        usar_variable($1);  
        $$ = 0;              
        free($1);
      }
    | CONSTANTE
      {
        $$ = $1;
      }
    | PARENIZQUIERDO expresion PARENDERECHO
      {
        $$ = $2;
      }
    ;

%%

int main(void) {
    return yyparse();
}

void yyerror (char *s){
    fprintf(stderr,
        "Error sintactico en linea %d: %s cerca de '%s'\n",
        yylineno, s, yytext);
}

/* --- Implementación tabla de símbolos y rutinas semánticas --- */

Simbolo* buscar(char *nombre) {
    Simbolo *act = tabla;
    while (act) {
        if (strcmp(act->nombre, nombre) == 0)
            return act;
        act = act->sig;
    }
    return NULL;
}

Simbolo* insertar(char *nombre, int inicializada) {
    Simbolo *s = (Simbolo*) malloc(sizeof(Simbolo));
    s->nombre = strdup(nombre);
    s->inicializada = inicializada;
    s->sig = tabla;
    tabla = s;
    return s;
}

/* usar_variable:
   - si no existe, la crea como no inicializada y tira error
   - si existe pero no esta inicializada, tira error
*/
void usar_variable(char *nombre) {
    Simbolo *s = buscar(nombre);
    if (!s) {
        s = insertar(nombre, 0);
        fprintf(stderr,
            "Error semantico en linea %d: variable '%s' usada sin haber sido leida o asignada.\n",
            yylineno, nombre);
    } else if (!s->inicializada) {
        fprintf(stderr,
            "Error semantico en linea %d: variable '%s' usada sin valor inicial.\n",
            yylineno, nombre);
    }
}

/* asignar_variable: ID := expr; */
void asignar_variable(char *nombre) {
    Simbolo *s = buscar(nombre);
    if (!s)
        s = insertar(nombre, 1);
    else
        s->inicializada = 1;
}

/* leer_variable: leer(a,b); */
void leer_variable(char *nombre) {
    Simbolo *s = buscar(nombre);
    if (!s)
        s = insertar(nombre, 1);
    else
        s->inicializada = 1;
}

int yywrap()  {
  return 1;  
}
