#include <stdio.h>
#include <string.h>

//-------------------- DEFINICIONES DEL AUTÓMATA --------------------
typedef enum { Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7} t_estado;

#define CANT_ESTADOS 8
#define LONG_ALFABETO 26
#define CANT_FINALES 4
#define EST_INICIAL Q0
#define CENTINELA '#'

int tabla_estados[CANT_ESTADOS][LONG_ALFABETO] = {
    {Q1,Q2,Q2,Q2,Q2,Q2,Q2,Q2,Q2,Q2,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q6,Q6},
    {Q5,Q5,Q5,Q5,Q5,Q5,Q5,Q5,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q3,Q3,Q7,Q7},
    {Q2,Q2,Q2,Q2,Q2,Q2,Q2,Q2,Q2,Q2,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7},
    {Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q7,Q7,Q7,Q7},
    {Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q4,Q7,Q7,Q7,Q7},
    {Q5,Q5,Q5,Q5,Q5,Q5,Q5,Q5,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7},
    {Q7,Q2,Q2,Q2,Q2,Q2,Q2,Q2,Q2,Q2,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7},
    {Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7,Q7}
};

int estados_finales[CANT_FINALES] = {Q1,Q2,Q4,Q5};

char alfabeto[] = {
    '0','1','2','3','4','5','6','7','8','9',
    'A','B','C','D','E','F',
    'a','b','c','d','e','f',
    'x','X','+','-'
};

// Contadores globales
int cantDecimal = 0;
int cantOctal = 0;
int cantHexa = 0;

//-------------------- FUNCIONES DEL AUTÓMATA --------------------
int posicion_alfabeto(char c){
    for(int i = 0; i < LONG_ALFABETO; i++)
        if(alfabeto[i] == c) return i;
    return -1;
}

int caracter_alfabeto(char c){
    for(int i = 0; i < LONG_ALFABETO; i++)
        if(alfabeto[i] == c) return 1;
    return 0;
}

int es_final(int estado){
    for(int i = 0; i < CANT_FINALES; i++)
        if(estado == estados_finales[i]) return 1;
    return 0;
}

int automata(const char *cadena, FILE *salida){
    int estado = EST_INICIAL;
    int i = 0;
    int inicio = 0; // inicio del número actual

    while(cadena[i] != '\0'){
        char letra = cadena[i];

        if(letra == CENTINELA){ // fin del número
            if(i > inicio){ // hay caracteres
                if(es_final(estado)){
                    switch(estado){
                        case Q1: case Q5:
                            fprintf(salida,"%.*s   → OCTAL\n", i-inicio, &cadena[inicio]);
                            printf("%.*s   → OCTAL\n", i-inicio, &cadena[inicio]);
                            cantOctal++; break;
                        case Q2:
                            fprintf(salida,"%.*s   → DECIMAL\n", i-inicio, &cadena[inicio]);
                            printf("%.*s   → DECIMAL\n", i-inicio, &cadena[inicio]);
                            cantDecimal++; break;
                        case Q4:
                            fprintf(salida,"%.*s   → HEXADECIMAL\n", i-inicio, &cadena[inicio]);
                            printf("%.*s   → HEXADECIMAL\n", i-inicio, &cadena[inicio]);
                            cantHexa++; break;
                    }
                } else {
                    fprintf(salida,"%.*s   → ERROR LÉXICO\n", i-inicio, &cadena[inicio]);
                    printf("%.*s   → ERROR LÉXICO\n", i-inicio, &cadena[inicio]);
                }
            }
            estado = EST_INICIAL;
            inicio = i+1;
        } else if(!caracter_alfabeto(letra)){ // caracter inválido
            // marcar todo el número como error hasta próximo #
            int j = i;
            while(cadena[j] != CENTINELA && cadena[j] != '\0') j++;
            fprintf(salida,"%.*s   → ERROR LÉXICO\n", j-inicio, &cadena[inicio]);
            printf("%.*s   → ERROR LÉXICO\n", j-inicio, &cadena[inicio]);
            i = j-1;
            estado = EST_INICIAL;
            inicio = j + (cadena[j]==CENTINELA?1:0);
        } else {
            estado = tabla_estados[estado][posicion_alfabeto(letra)];
        }

        i++;
    }

    // último número si no termina en #
    if(i > inicio){
        if(es_final(estado)){
            switch(estado){
                case Q1: case Q5:
                    fprintf(salida,"%.*s   → OCTAL\n", i-inicio, &cadena[inicio]);
                    printf("%.*s   → OCTAL\n", i-inicio, &cadena[inicio]);
                    cantOctal++; break;
                case Q2:
                    fprintf(salida,"%.*s   → DECIMAL\n", i-inicio, &cadena[inicio]);
                    printf("%.*s   → DECIMAL\n", i-inicio, &cadena[inicio]);
                    cantDecimal++; break;
                case Q4:
                    fprintf(salida,"%.*s   → HEXADECIMAL\n", i-inicio, &cadena[inicio]);
                    printf("%.*s   → HEXADECIMAL\n", i-inicio, &cadena[inicio]);
                    cantHexa++; break;
            }
        } else {
            fprintf(salida,"%.*s   → ERROR LÉXICO\n", i-inicio, &cadena[inicio]);
            printf("%.*s   → ERROR LÉXICO\n", i-inicio, &cadena[inicio]);
        }
    }

    return 0;
}

//-------------------- FUNCIONES EJERCICIO 2 --------------------
int charANumero(char c){
    if(c >= '0' && c <= '9') return c - '0';
    return -1;
}

//-------------------- FUNCIONES EJERCICIO 3 --------------------
int evaluarOperacion(const char *expr){
    int i = 0;
    int result = 0;
    int temp = 0;
    char op = '+';

    while(expr[i] != '\0'){
        int num = 0;
        while(expr[i] >= '0' && expr[i] <= '9'){
            num = num*10 + charANumero(expr[i]);
            i++;
        }

        if(op == '*') temp *= num;
        else if(op == '/') temp /= num;
        else if(op == '+') { result += temp; temp = num; }
        else if(op == '-') { result += temp; temp = -num; }

        op = expr[i];
        i++;
    }

    result += temp;
    return result;
}

//---------------- FUNCIONES AUXILIARES ----------------

void pedirDatos(FILE* archilec, char cadena[], char operacion[], int dimVects) {
    if (!archilec) { // si no se detecta archivo para leer los datos, se pide por CLI
        printf("No se detecto ningun archivo \"entrada.txt\"\n");

        printf("Ingrese la cadena de numeros (# para separar): ");
        fgets(cadena, dimVects, stdin);
        cadena[strcspn(cadena,"\n")] = '\0';
        
        printf("Ingrese la operacion decimal: ");
        fgets(operacion, dimVects, stdin);
        operacion[strcspn(operacion,"\n")] = '\0';

        return;
    }

    printf("Se detecto el archivo \"entrada.txt\"\n");
    
    printf("Leyendo datos...\n");

    fgets(cadena, dimVects, archilec); // para la cadena
    cadena[strcspn(cadena, "\n")] = '\0';

    fgets(operacion, dimVects, archilec); // para la operacion
    operacion[strcspn(operacion, "\n")] = '\0';
    
    printf("Datos leidos correctamente\n");
}

void resumen(FILE* salida, char operacion[]) {
    fprintf(salida,"\nResumen:\n");
    fprintf(salida,"Decimales: %d\n", cantDecimal);
    fprintf(salida,"Octales: %d\n", cantOctal);
    fprintf(salida,"Hexadecimales: %d\n", cantHexa);

    printf("\nDecimales: %d\n", cantDecimal);
    printf("Octales: %d\n", cantOctal);
    printf("Hexadecimales: %d\n", cantHexa);

    // Evaluar operación decimal (Ejercicio 3)
    int resultado = evaluarOperacion(operacion);
    printf("Resultado de la operacion: %d\n", resultado);
    fprintf(salida,"Resultado de la operacion: %d\n", resultado);    
}

//-------------------- FUNCION MAIN --------------------
int main(){
    const int tamBuffer = 256;
    char cadena[tamBuffer];
    char operacion[tamBuffer];

    FILE *archilec = fopen("entrada.txt", "r");
    
    pedirDatos(archilec, cadena, operacion, tamBuffer);

    fclose(archilec);

    FILE *salida = fopen("salida.txt","w");
    if(salida == NULL){
        printf("Error al crear archivo salida.txt\n");
        return 1;
    }

    // Validar la cadena con el autómata (Ejercicio 1)
    automata(cadena, salida);

    // Resumen
    resumen(salida, operacion);

    fclose(salida);
    printf("\nArchivo 'salida.txt' creado con exito.\n");

    return 0;
}
