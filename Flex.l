Digito[0-9]
Letra[a-zA-Z]
Id[a-zA-Z][a-zA-Z0-9_]*
text[a-zA-Z0-9 ]*
Branco[ ]
Quebra[\n]
Tab[\t]

%{
    #define YY_DECL extern "C" int yylex()
    #include<string>
    #include<iostream>
    using namespace std;
    FILE *out;
    int linha;
%}
%option yylineno
%x Comentario
%x String

%%

{Quebra}

"/*" {linha==yylineno; BEGIN(Comentario);}

<Comentario>"*/" {BEGIN(INITIAL);}

<Comentario>(.|\n);

<Comentario><<EOF>> {fprintf(out,"(%d,ERROR,\"/*\")\n",linha);return 0;}

"\'"|"\"" {linha==yylineno; BEGIN(String);}

<String>"\'"|"\"" {BEGIN(INITIAL);}

<String>{text}* {fprintf(out,"(%d,String,\"%s\")\n", yylineno, yytext);}

else|if|int|float|char|return|void|main|while|for|switch|case {fprintf(out,"(%d,Identificador da Linguagem,\"%s\")\n", yylineno, yytext);}

"&&"|"||"|"!" {fprintf(out,"(%d,Operador Logico,\"%s\")\n", yylineno, yytext);}

"+"|"-"|"*"|"/" {fprintf(out,"(%d,Operador Aritmetico,\"%s\")\n", yylineno, yytext);}

"<"|">"|"<="|">="|"=="|"!="|"=" {fprintf(out,"(%d,Operador Relacional,\"%s\")\n", yylineno, yytext);}

"("|")"|"["|"]"|"{"|"}" {fprintf(out,"(%d,Operador Parentizador,\"%s\")\n", yylineno, yytext);}

{Branco}+|{Quebra}|{Tab}+

{Digito}+"."{Digito}+ {fprintf(out,"(%d,Numero Real,\"%s\")\n", yylineno, yytext);}

{Digito}+ {fprintf(out,"(%d,Numero Inteiro,\"%s\")\n", yylineno, yytext);}

{Digito}+{Id} {fprintf(out,"(%d,ERROR,\"%s\")\n", yylineno, yytext);}

{Id}+ {fprintf(out,"(%d,Identificador do usuario,\"%s\")\n", yylineno, yytext);}

";"|"," {fprintf(out,"(%d,Sinal de pontuacao,\"%s\")\n", yylineno, yytext);}

. {fprintf(out,"(%d,ERROR,\"%s\")\n", yylineno, yytext);}

%%

int yywrap();

int main(int argc, char *argv[]){
    FILE *arquivo = fopen(argv[1],"r");
    if (!arquivo){
        cout << "Arquivo Inexistente" << endl;
        return -1;
    }
    yyin = arquivo;
    out = fopen(argv[2],"w");
    yylex();
    return 0;
}

int yywrap(){
    return 1;
}