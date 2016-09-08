grammar Python3;

parse: stat* EOF;

// Statements and the whole rest
stat: assignment | print | function_def | for_stat;

func_stat: stat | PASS | return_stat;

assignment: ID ASSIGN expr;

print: PRINT LPAR expr RPAR;

function_def: DEF ID LPAR arguments? RPAR COL function_body;

arguments: ID (',' ID)*;

function_body: (TAB func_stat)+;

return_stat: RETURN expr;

for_stat: FOR ID IN RANGE LPAR INT RPAR COL for_body;

for_body: (TAB stat)+;

expr
 : MINUS expr                           #minusExpr
 | NOT expr                             #notExpr
 | expr op=(MUL | DIV) expr             #mulExpr
 | expr op=(PLUS | MINUS) expr          #addExpr
 | atom                                 #atomExpr
 ;

atom
 : ID LPAR arguments? RPAR  #funcCallAtom
 | (INT | FLOAT)            #numberAtom
 | (TRUE | FALSE)           #booleanAtom
 | ID                       #idAtom
 | STRING                   #stringAtom
 | NONE                     #nilAtom
 ;

// Operators
PLUS : '+';
MINUS : '-';
MUL : '*';
DIV : '/';
NOT : 'not';
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
FOR: 'for';
IN: 'in';
RANGE: 'range';

ID: [a-zA-Z_] [a-zA-Z_0-9]*;

COMMENT: '#' ~[\r\n]* -> skip;
WS: [ \r\n] -> skip;
OTHER: .;
