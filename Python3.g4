grammar Python3;

parse: stat* EOF;

// Statements and the whole rest
stat: assignment | print | function_def | OTHER {print("unknown char: " + OTHER.text);};

assignment: ID ASSIGN expr;

print: PRINT LPAR expr RPAR;

function_def: DEF ID LPAR arguments? RPAR COL function_body;

arguments: ID (',' ID)*;

function_body: TAB assignment;

expr
// : expr POW expr                        #powerExpression
// | MINUS expr                           #minusExpression
// | NOT expr                             #notExpression
// | expr op=(MUL | DIV | MOD) expr      #multiplicationExpression
// | expr op=(PLUS | MINUS) expr          #additionExpression
// | expr op=(LTE | GTE | LT | GT) expr #comparisonExpression
// | expr op=(EQ | NEQ) expr              #equalityExpression
// | expr AND expr                        #andExpr
// | expr OR expr                         #orExpr
 : atom                                 #atomExpr
 ;

atom
 : LPAR expr RPAR #parExpr
 | (INT | FLOAT)  #numberAtom
 | (TRUE | FALSE) #booleanAtom
 | ID             #idAtom
 | STRING         #stringAtom
 | NONE           #nilAtom
 ;

// Operators
OR : 'or';
AND : 'and';
EQ : '==';
NEQ : '!=';
GT : '>';
LT : '<';
GTE : '>=';
LTE : '<=';
PLUS : '+';
MINUS : '-';
MUL : '*';
DIV : '/';
MOD : '%';
POW : '^';
NOT : '!';
ASSIGN : '=';

// Types
INT: [0-9]+;
FLOAT: [0-9]+ '.' [0-9]* | '.' [0-9]+;
STRING: '"' (~["\r\n] | '""')* '"';
TRUE : 'True';
FALSE : 'False';
NONE : 'None';

// Others, flow control etc
COL : ':';
LPAR : '(';
RPAR : ')';
LCURLY : '{';
RCURLY : '}';
TAB : '\t';

PRINT : 'print';
DEF: 'def';
RETURN: 'return';
PASS: 'pass';

ID: [a-zA-Z_] [a-zA-Z_0-9]*;

COMMENT: '#' ~[\r\n]* -> skip;
WS: [ \r\n] -> skip;
OTHER: .;
