grammar Python3;

tokens { INDENT, DEDENT }

@lexer::members {
  // A queue where extra tokens are pushed on (see the NEWLINE lexer rule).
  private java.util.LinkedList<Token> tokens = new java.util.LinkedList<>();
  // The stack that keeps track of the indentation level.
  private java.util.Stack<Integer> indents = new java.util.Stack<>();
  // The amount of opened braces, brackets and parenthesis.
  private int opened = 0;
  // The most recently produced token.
  private Token lastToken = null;
  @Overrideg
  public void emit(Token t) {
    super.setToken(t);
    tokens.offer(t);
  }

  @Override
  public Token nextToken() {
    // Check if the end-of-file is ahead and there are still some DEDENTS expected.
    if (_input.LA(1) == EOF && !this.indents.isEmpty()) {
      // Remove any trailing EOF tokens from our buffer.
      for (int i = tokens.size() - 1; i >= 0; i--) {
        if (tokens.get(i).getType() == EOF) {
          tokens.remove(i);
        }
      }

      // First emit an extra line break that serves as the end of the statement.
      this.emit(commonToken(Python3Parser.NEWLINE, "\n"));

      // Now emit as much DEDENT tokens as needed.
      while (!indents.isEmpty()) {
        this.emit(createDedent());
        indents.pop();
      }

      // Put the EOF back on the token stream.
      this.emit(commonToken(Python3Parser.EOF, "<EOF>"));
    }

    Token next = super.nextToken();

    if (next.getChannel() == Token.DEFAULT_CHANNEL) {
      // Keep track of the last token on the default channel.
      this.lastToken = next;
    }

    return tokens.isEmpty() ? next : tokens.poll();
  }

  private Token createDedent() {
    CommonToken dedent = commonToken(Python3Parser.DEDENT, "");
    dedent.setLine(this.lastToken.getLine());
    return dedent;
  }

  private CommonToken commonToken(int type, String text) {
    int stop = this.getCharIndex() - 1;
    int start = text.isEmpty() ? stop : stop - text.length() + 1;
    return new CommonToken(this._tokenFactorySourcePair, type, DEFAULT_TOKEN_CHANNEL, start, stop);
  }

  // Calculates the indentation of the provided spaces, taking the
  // following rules into account:
  //
  // "Tabs are replaced (from left to right) by one to eight spaces
  //  such that the total number of characters up to and including
  //  the replacement is a multiple of eight [...]"
  //
  //  -- https://docs.python.org/3.1/reference/lexical_analysis.html#indentation
  static int getIndentationCount(String spaces) {
    int count = 0;
    for (char ch : spaces.toCharArray()) {
      switch (ch) {
        case '\t':
          count += 8 - (count % 8);
          break;
        default:
          // A normal space char.
          count++;
      }
    }

    return count;
  }

  boolean atStartOfInput() {
    return super.getCharPositionInLine() == 0 && super.getLine() == 1;
  }
}

single_input: NEWLINE | simple_stmt | compound_stmt NEWLINE;
file_input: (NEWLINE | stmt)* ENDMARKER;
eval_input: testlist NEWLINE* ENDMARKER;

funcdef: 'def' NAME parameters ['->' test] ':' suite;

parameters: '(' [typedargslist] ')';
typedargslist: (tfpdef ['=' test] (',' tfpdef ['=' test])* [','
       ['*' [tfpdef] (',' tfpdef ['=' test])* [',' '**' tfpdef] | '**' tfpdef]]
     |  '*' [tfpdef] (',' tfpdef ['=' test])* [',' '**' tfpdef] | '**' tfpdef);
tfpdef: NAME [':' test];
varargslist: (vfpdef ['=' test] (',' vfpdef ['=' test])* [','
       ['*' [vfpdef] (',' vfpdef ['=' test])* [',' '**' vfpdef] | '**' vfpdef]]
     |  '*' [vfpdef] (',' vfpdef ['=' test])* [',' '**' vfpdef] | '**' vfpdef);
vfpdef: NAME;

stmt: simple_stmt | compound_stmt;
simple_stmt: small_stmt (';' small_stmt)* [';'] NEWLINE;
small_stmt: (expr_stmt | del_stmt | pass_stmt | flow_stmt |
             import_stmt | global_stmt | nonlocal_stmt | assert_stmt);
expr_stmt: testlist_star_expr (augassign (yield_expr|testlist) |
                     ('=' (yield_expr|testlist_star_expr))*);
testlist_star_expr: (test|star_expr) (',' (test|star_expr))* [','];
augassign: ('+=' | '-=' | '*=' | '@=' | '/=' | '%=' | '&=' | '|=' | '^=' |
            '<<=' | '>>=' | '**=' | '//=');
del_stmt: 'del' exprlist;
pass_stmt: 'pass';
flow_stmt: break_stmt | continue_stmt | return_stmt | raise_stmt | yield_stmt;
break_stmt: 'break';
continue_stmt: 'continue';
return_stmt: 'return' [testlist];
yield_stmt: yield_expr;
raise_stmt: 'raise' [test ['from' test]];
import_stmt: import_name | import_from;
import_name: 'import' dotted_as_names;
import_from: ('from' (('.' | '...')* dotted_name | ('.' | '...')+)
              'import' ('*' | '(' import_as_names ')' | import_as_names));
import_as_name: NAME ['as' NAME];
dotted_as_name: dotted_name ['as' NAME];
import_as_names: import_as_name (',' import_as_name)* [','];
dotted_as_names: dotted_as_name (',' dotted_as_name)*;
dotted_name: NAME ('.' NAME)*;
global_stmt: 'global' NAME (',' NAME)*;
nonlocal_stmt: 'nonlocal' NAME (',' NAME)*;
assert_stmt: 'assert' test [',' test];

compound_stmt: if_stmt | while_stmt | for_stmt | try_stmt | with_stmt | funcdef | classdef | decorated | async_stmt;
async_stmt: ASYNC (funcdef | with_stmt | for_stmt);
if_stmt: 'if' test ':' suite ('elif' test ':' suite)* ['else' ':' suite];
while_stmt: 'while' test ':' suite ['else' ':' suite];
for_stmt: 'for' exprlist 'in' testlist ':' suite ['else' ':' suite];
try_stmt: ('try' ':' suite
           ((except_clause ':' suite)+
            ['else' ':' suite]
            ['finally' ':' suite] |
           'finally' ':' suite));
with_stmt: 'with' with_item (',' with_item)*  ':' suite;
with_item: test ['as' expr];
except_clause: 'except' [test ['as' NAME]];
suite: simple_stmt | NEWLINE INDENT stmt+ DEDENT;

test: or_test ['if' or_test 'else' test] | lambdef;
test_nocond: or_test | lambdef_nocond;
lambdef: 'lambda' [varargslist] ':' test;
lambdef_nocond: 'lambda' [varargslist] ':' test_nocond;
or_test: and_test ('or' and_test)*;
and_test: not_test ('and' not_test)*;
not_test: 'not' not_test | comparison;
comparison: expr (comp_op expr)*;
comp_op: '<'|'>'|'=='|'>='|'<='|'<>'|'!='|'in'|'not' 'in'|'is'|'is' 'not';
star_expr: '*' expr;
expr: xor_expr ('|' xor_expr)*;
xor_expr: and_expr ('^' and_expr)*;
and_expr: shift_expr ('&' shift_expr)*;
shift_expr: arith_expr (('<<'|'>>') arith_expr)*;
arith_expr: term (('+'|'-') term)*;
term: factor (('*'|'@'|'/'|'%'|'//') factor)*;
factor: ('+'|'-'|'~') factor | power;
power: atom_expr ['**' factor];
atom_expr: [AWAIT] atom trailer*;
atom: ('(' [yield_expr|testlist_comp] ')' |
       '[' [testlist_comp] ']' |
       '{' [dictorsetmaker] '}' |
       NAME | NUMBER | STRING+ | '...' | 'None' | 'True' | 'False');
testlist_comp: (test|star_expr) ( comp_for | (',' (test|star_expr))* [','] );
trailer: '(' [arglist] ')' | '[' subscriptlist ']' | '.' NAME;
subscriptlist: subscript (',' subscript)* [','];
subscript: test | [test] ':' [test] [sliceop];
sliceop: ':' [test];
exprlist: (expr|star_expr) (',' (expr|star_expr))* [','];
testlist: test (',' test)* [','];
dictorsetmaker: ( ((test ':' test | '**' expr);
                   (comp_for | (',' (test ':' test | '**' expr))* [','])) |
                  ((test | star_expr)
                   (comp_for | (',' (test | star_expr))* [','])) );

classdef: 'class' NAME ['(' [arglist] ')'] ':' suite;

arglist: argument (',' argument)*  [','];


argument: ( test [comp_for] |
            test '=' test |
            '**' test |
            '*' test );

comp_iter: comp_for | comp_if;
comp_for: 'for' exprlist 'in' or_test [comp_iter];
comp_if: 'if' test_nocond [comp_iter];

encoding_decl: NAME;

yield_expr: 'yield' [yield_arg];
yield_arg: 'from' test | testlist;