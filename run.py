import sys
from antlr4 import *

from ToJSVisitor import ToJSVisitor
from gen.Python3Lexer import Python3Lexer
from gen.Python3Parser import Python3Parser


def main(argv):
    input = FileStream(argv[1])
    lexer = Python3Lexer(input)
    stream = CommonTokenStream(lexer)
    parser = Python3Parser(stream)
    tree = parser.parse()
    visitor = ToJSVisitor()
    visitor.visit(tree)
    print(visitor.result_buffer)

if __name__ == '__main__':
    main(sys.argv)
