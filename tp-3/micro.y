%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylineno;
int yylex(void);
void yyerror(const char *s);

/* --- Tabla de símbolos --- */
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

/* Valores semánticos */
%union {
    int    ival;    /* para CONSTANTES */
    char*  sval;    /* para IDENTIFICADORES */
}

/* Tokens */
%token INICIO FIN LEER ESCRIBIR
%token <sval> IDENTIFICADOR
%token <ival> CONSTANTE
%token MAS MENOS
%token ASIGNACION
%token APARENTESIS CPARENTESIS COMA PUNTOYCOMA

/* Precedencia */
%left MAS MENOS

/* Tipos de no terminales */
%type <ival> expresion termino

%%

programa
    : INICIO sentencias FIN
      {
        printf("Analisis sintactico y semantico finalizado correctamente.\n");
      }
    ;

sentencias
    : /* vacio */
    | sentencias sentencia
    ;

sentencia
    : asignacion
    | entrada
    | salida
    ;

asignacion
    : IDENTIFICADOR ASIGNACION expresion PUNTOYCOMA
      {
        asignar_variable($1);   /* rutina semantica: marca como inicializada */
        free($1);
      }
    ;

entrada
    : LEER APARENTESIS lista_ids CPARENTESIS PUNTOYCOMA
    ;

salida
    : ESCRIBIR APARENTESIS lista_exp CPARENTESIS PUNTOYCOMA
    ;

lista_ids
    : IDENTIFICADOR
      {
        leer_variable($1);      /* rutina semantica: leer = inicializar */
        free($1);
      }
    | lista_ids COMA IDENTIFICADOR
      {
        leer_variable($3);
        free($3);
      }
    ;

lista_exp
    : expresion
    | lista_exp COMA expresion
    ;

/* Expresiones aritmeticas enteras */
expresion
    : termino
    | expresion MAS termino
    | expresion MENOS termino
    ;

termino
    : IDENTIFICADOR
      {
        usar_variable($1);   /* rutina semantica: usar = debe estar inicializada */
        $$ = 0;              
        free($1);
      }
    | CONSTANTE
      {
        $$ = $1;
      }
    | APARENTESIS expresion CPARENTESIS
      {
        $$ = $2;
      }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error sintactico en linea %d: %s\n", yylineno, s);
}

/* --- Implementacion de tabla de simbolos y rutinas semanticas --- */

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
   - si existe pero no inicializada, tira error
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

/* asignar_variable: IDENTIFICADOR := expr; */
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

int main(void) {
    return yyparse();
}
