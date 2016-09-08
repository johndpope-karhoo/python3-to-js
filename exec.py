import pprint
import sys
from antlr4 import *

from Interpret import Interpreter
from gen.Python3Lexer import Python3Lexer
from gen.Python3Parser import Python3Parser


def main(argv):
    input = FileStream(argv[1])
    lexer = Python3Lexer(input)
    stream = CommonTokenStream(lexer)
    parser = Python3Parser(stream)
    tree = parser.parse()
    visitor = Interpreter()
    visitor.visit(tree)
    pprint.pprint(visitor.vars)

if __name__ == '__main__':
    main(sys.argv)
